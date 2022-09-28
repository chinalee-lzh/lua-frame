function class(__class, ...)
  local sz = select('#', ...)
  local name
  if sz > 0 then name = select(sz, ...) end
  local super = {...}
  if isstring(name) then
    super[#super] = nil
  end
  __class.__super = super
  __class.__cname = name
  local mtclass = {}
  if #super > 0 then
    mtclass.__index = function(_, k)
      for i = 1, #super do
        local v = super[i][k]
        if notnil(v) then
          return v
        end
      end
    end
  end
  local mtobj = {__index = __class}
  mtclass.__call = function(_, ...)
    local obj = setmetatable({__class = __class}, mtobj)
    local new = rawget(__class, 'new')
    safecall(new, obj, ...)
    return obj
  end
  setmetatable(__class, mtclass)
  return __class
end