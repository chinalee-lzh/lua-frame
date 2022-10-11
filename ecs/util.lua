local KEY_ENTITY = '__ECS_KEY_ENTITY__'
local KEY_SYS = '__ECS_KEY_SYS__'
local KEY_COM = '__ECS_KEY_COM__'

local isentity = function(obj) return obj.ecskey == KEY_ENTITY end
local notentity = function(...) return not isentity(...) end
local issys = function(obj) return obj.ecskey == KEY_SYS end
local notsys = function(...) return not issys(...) end
local iscom = function(obj) return obj.ecskey == KEY_COM end
local notcom = function(...) return not iscom(...) end

return {
  KEY_ENTITY  = KEY_ENTITY,
  KEY_SYS     = KEY_SYS,
  KEY_COM     = KEY_COM,

  isentity = isentity,
  notentity = notentity,
  issys = issys,
  notsys = notsys,
  iscom = iscom,
  notcom = notcom,
}