rawset(_G, 'raw_require', require)
rawset(_G, 'require', nil)

local raw_dofile = dofile
function dofile(path)
  if not path:find('.lua') then
    path = string.format('%s.lua', path:gsub('%.', '/'))
  end
  return raw_dofile(path)
end

if LUAVER.get() == 5.4 then
  loadstring = function(...) return load(...) end
end

local KEY_DEFAULT = '__default'
local cache = {}
function import(module, category, notcache)
  category = category or KEY_DEFAULT
  cache[category] = cache[category] or {}
  local rst = cache[category][module]
  if rst == nil then
    rst = dofile(module)
    if not notcache then
      cache[category][module] = rst
    end
  end
  return rst
end
function clearimport(category)
  category = category or KEY_DEFAULT
  cache[category] = {}
end