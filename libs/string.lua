local reverse, byte, char, find, upper, gmatch, rep, packsize, lower, format, dump, unpack, pack, sub, match, len, gsub
  = string.reverse, string.byte, string.char, string.find, string.upper, string.gmatch, string.rep, string.packsize, string.lower,
    string.format, string.dump, string.unpack, string.pack, string.sub, string.match, string.len, string.gsub

local raw_startswith = function(str, prefix) return find(str, prefix, 1, true) == 1 end
local raw_endswith = function(str, suffix)
  if len(str) < len(suffix) then return false end
  return find(str, suffix, len(str)-len(suffix)+1, true) and true or false
end
local test_affixes
test_affixes = function(str, affixes, fn)
  if isstring(affixes) then
    return fn(str, test_affixes)
  elseif istable(affixes) then
    for _, affix in ipairs(affixes) do
      if fn(str, affix) then
        return true
      end
    end
    return false
  end
  return false
end

function string.empty(str) return notstring(str) or str == '' end
function string.at(str, idx)
  if isnumber(idx) then
    if idx < 0 then idx = #str+idx+1 end
    return sub(str, idx, idx)
  end
end
function string.replace(str, idx, s)
  if notnumber(idx) or notstring(s) then return str end
  local sz = len(str)
  if idx < 0 then idx = sz+idx+1 end
  if idx < 1 or idx > sz then return str end
  return format('%s%s%s', str:sub(1, idx-1), s, str:sub(idx+1))
end
function string.join(...) return table.concat({...}, '') end
function string.concat(s1, s2, sep) return format('%s%s%s', s1, sep, s2) end
function string.split(str, sep)
  if notstring(sep) or sep == '' then return end
  local tbl = {}
  for field, s in gmatch(str, '([^' .. sep .. ']*)(' .. sep .. '?)') do
    table.insert(tbl, field)
    if s == '' then break end
  end
  return tbl
end
function string.startswith(str, prefix) return test_affixes(str, prefix, raw_startswith) end
function string.endswith(str, suffix) return test_affixes(str, suffix, raw_endswith) end
function string.ensurestart(str, prefix) if string.startswith(str, prefix) then return str else return prefix .. str end end
function string.ensureend(str, suffix) if string.endswith(str, suffix) then return str else return str .. suffix end end
function string.removestart(str, prefix) if string.startswith(str, prefix) then return sub(str, len(prefix)+1) else return str end end
function string.removeend(str, suffix) if string.endswith(str, suffix) then return sub(str, 1, len(str)-len(suffix)) else return str end end
function string.trim(str) return match(str, '^%s*(.-)%s*$') end
function string.utf8len(str)
  local sz = len(str)
  local left = sz
  local cnt = 0
  local arr = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc }
  while left > 0 do
    local tmp = byte(str, -left)
    local i = #arr
    while arr[i] do
      if tmp >= arr[i] then
        left = left-1
        break
      end
      i = i-1
    end
    cnt = cnt+1
  end
  return cnt
end