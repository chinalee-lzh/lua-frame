rawset(_G, 'raw_require', require)
rawset(_G, 'require', nil)

local KEY_DEFAULT = '__default'

local cache = {}
function import(module, category, notcache)
  category = category or KEY_DEFAULT
  cache[category] = cache[category] or {}
  local rst = cache[category][module]
  if rst == nil then
    local path = string.format('%s.lua', module:gsub('%.', '/'))
    rst = dofile(path)
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