local pack, unpack = table.pack, table.unpack

local cachenumber = {}

function safecall(fn, ...) if isfunction(fn) then fn(...) end end
function ifcall(cond, fn, ...) if cond and isfunction(fn) then fn(...) end end
function gf_empty() end
function gf_true() return true end
function gf_false() return false end
function gf_number(n)
  cachenumber[n] = ENSURE.func(cachenumber[n], function() return n end)
  return cachenumber[n]
end
function gf_bind(fn, ...)
  if notfunction(fn) then return end
  local params = pack(...)
  return function(...) fn(unpack(params), ...) end
end
ENUM_HOLDER_STRING = '__holder__'
function enum(tbl, startvalue)
  if nottable(tbl) then return end
  startvalue = ENSURE.number(startvalue, 1)
  local rst = {}
  local mt = {}
  local idxholder = 0
  for _, v in ipairs(tbl) do
    if v == ENUM_HOLDER_STRING then
      idxholder = idxholder+1
      v = string.format('%s%d', ENUM_HOLDER_STRING, idxholder)
    end
    rst[v] = startvalue
    startvalue = startvalue+1
    mt[startvalue] = v
  end
  mt.n = #tbl
  return setmetatable(rst, {__index = mt})
end
function enum0(tbl) return enum(tbl, 0) end
function setfenv(fn, env)
  local i = 1
  while true do
    local name = debug.getupvalue(fn, i)
    if name == '_ENV' then
      debug.upvaluejoin(fn, i, function() return env end, 1)
    elseif isnil(name) then
      break
    end
    i = i+1
  end
  return fn
end