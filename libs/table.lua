local concat, sort, pack, insert, unpack, remove, move
  = table.concat, table.sort, table.pack, table.insert, table.unpack, table.remove, table.move

function table.readonly(tbl)
  if nottable(tbl) then return end
  local mt = {
    __index = tbl,
    __newindex = function() error('Attempt to modify a readonly table', 2) end,
    __paris = function() return pairs(tbl) end,
    __len = function() return #tbl end,
    __metatable = false,
  }
  return setmetatable({}, mt)
end
function table.exist(tbl, value)
  if nottable(tbl) then return false end
  for k, v in pairs(tbl) do
    if v == value then
      return true, k
    end
  end
  return false
end
function table.delete(tbl, value)
  if nottable(tbl) then return end
  for k, v in pairs(tbl) do
    if v == value then
      tbl[k] = nil
      break
    end
  end
end
function table.deletearray(array, value, disorder)
  if nottable(array) then return end
  for i, v in ipairs(array) do
    if v == value then
      if disorder then
        array[i], array[#array] = array[#array], nil
      else
        remove(array, i)
      end
      break
    end
  end
end
function table.copy(tbl)
  if nottable(tbl) then return end
  local rst = {}
  for k, v in pairs(tbl) do rst[k] = v end
  return rst
end
function table.deepcopy(tbl, cache)
  if nottable(tbl) then return tbl end
  cache = cache or {}
  if notnil(cache[tbl]) then return cache[tbl] end
  local rst = {}
  cache[tbl] = rst
  local mt = getmetatable(tbl)
  for k, v in pairs(tbl) do
    k = table.deepcopy(k, cache)
    v = table.deepcopy(v, cache)
    rst[k] = v
  end
  setmetatable(rst, mt)
  return rst
end
function table.update(dst, src)
  if nottable(dst) or nottable(src) then return end
  for k, v in pairs(src) do dst[k] = v end
  return dst
end
function table.updatearray(dst, src)
  if nottable(dst) or nottable(src) then return end
  local sz = #dst
  for i = 1, #src do dst[sz+i] = src[i] end
  return dst
end
function table.merge(tbl1, ...)
  if nottable(tbl1) then return end
  local rst = {}
  local sz = select('#', ...)
  for i = 1, sz do
    local t = select(i, ...)
    if istable(t) then
      table.update(rst, t)
    end
  end
  return rst
end
function table.mergearray(array1, ...)
  if nottable(array1) then return end
  local rst = {}
  local sz = select('#', ...)
  for i = 1, sz do
    local t = select(i, ...)
    if istable(t) then
      table.updatearray(rst, t)
    end
  end
  return rst
end
function table.size(tbl)
  if nottable(tbl) then return 0 end
  local cnt = 0
  for _ in pairs(tbl) do cnt = cnt+1 end
  return cnt
end
local transform = function(src, dst, fn, ...)
  if nottable(tbl) or notfunction(fn) then return end
  for k, v in pairs(tbl) do
    dst[k] = fn(v, ...)
  end
  return dst
end
function table.map(tbl, fn, ...) return transform(tbl, {}, fn, ...) end
function table.transform(tbl, fn, ...) return transform(tbl, tbl, fn, ...) end
function table.foreach(tbl, fn, ...)
  if nottable(tbl) or notfunction(fn) then return end
  for k, v in pairs(tbl) do fn(v, k, ...) end
end
function table.foreachi(tbl, fn, ...)
  if nottable(tbl) or notfunction(fn) then return end
  for i = 1, #tbl do fn(tbl[i], i, ...) end
end
function table.reverse(src, dst)
  if nottable(src) then return end
  dst = ENSURE.table(dst, src)
  for k, v in pairs(src) do dst[v] = k end
  return dst
end
function table.slice(tbl, from, to)
  if nottable(tbl) then return end
  from = ENSURE.number(from, 1)
  to = ENSURE.number(to, #tbl)
  if from < 0 then from = from+#tbl+1 end
  if to < 0 then to = to+#tbl+1 end
  local rst = {}
  for i = from, to do insert(rst, tbl[i]) end
  return rst
end
function table.empty(tbl) return isnil(next(tbl)) end
local iterTbl
iterTbl = function(tbl, cache, indent)
  if cache[tbl] then return '__cached__' end
  cache[tbl] = true
  if isfunction(tbl.__dump__) then return tbl:__dump__(indent) end
  local newline = '\r\n'
  local str2dump = string.format('%s {%s', tbl, newline)
  indent = ENSURE.number(indent, 0)+2
  local a, b, c
  if isfunction(tbl.loop) then
    a, b, c = tbl:loop()
  else
    a, b, c = paris(tbl)
  end
  for k, v in a, b, c do
    if notfunction(tbl.__skipdump__) or not tbl:__skipdump__(k, v) then
      local halfnote = string.rep('-', indent//2)
      str2dump = str2dump .. string.format('%s%s%s', halfnote, indent//2, halfnote)
      if isfunction(tbl.__dumpk__) then
        str2dump = str2dump .. tbl:__dumpk__(k, v)
      elseif isnumber(k) then
        str2dump = str2dump .. string.format('[%s]', k)
      else
        str2dump = str2dump .. tostring(k)
      end
      str2dump = str2dump .. ' = '
      if isfunction(tbl.__dumpv__) then
        str2dump = str2dump .. tbl:__dumpv__(k, v)
      elseif isnumber(v) then
        str2dump = str2dump .. tostring(v)
      elseif istable(v) then
        str2dump = str2dump .. iterTbl(v, indent)
      else
        str2dump = str2dump .. string.format("'%s'", v)
      end
      str2dump = str2dump .. newline
    end    
  end
  indent = indent-2
  if indent//2 > 0 then
    local halfnote = string.rep('-', indent//2)
    str2dump = str2dump .. string.format('%s%s%s}', halfnote, indent//2, halfnote)
  else
    str2dump = str2dump .. '}'
  end
  return str2dump
end
function table.dump(tbl)
  if nottable(tbl) then return end
  local cache = {}
  return iterTbl(tbl, cache)
end
function table.clear(tbl) for k in pairs(tbl) do tbl[k] = nil end end

gt_empty = table.readonly {}
gt_weakk = table.readonly {__mode = 'k'}
gt_weakv = table.readonly {__mode = 'v'}
gt_weakkv = table.readonly {__mode = 'kv'}