local raw_require = require
rawset(_G, 'require', nil)

local cache = {}
function import(module, notcache)
  local rst = cache[module]
  if rst == nil then
    rst = raw_require(module)
    package.loaded[module] = nil
    if not notcache then
      cache[module] = rst
    end
  end
  return rst
end

function clearimport()
  cache = {}
end