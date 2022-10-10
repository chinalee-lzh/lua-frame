local mt = {__index = _G}
local createENV = function() return setmetatable({}, mt) end
function sandbox(module, env)
  local fn = loadfile(module)
  if notfunction(fn) then return end
  env = ENSURE.table(env, createENV())
  debug.setupvalue(fn, 1, env)
  return fn(module)
end