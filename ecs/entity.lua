local util = import 'ecs.util'

local c_entity = classpool {
  new = function(self)
    self.ecskey = util.KEY_ENTITY
    self:init()
  end,
  init = function(self, ...)
    self.coms = {}
    self:setWorldIdx(-1)
    self:_init(...)
  end,
  _init = gf_empty,
  hascom = function(self, category)
    return notnil(category) and notnil(self.coms[category])
  end,
  getcom = function(self, category)
    if notnil(category) then return self.coms[category] end
  end,
  addcom = function(self, category, com)
    self.coms[category] = com
    return self
  end,
  delcom = function(self, category)
    local com = self:getcom(category)
    if isnil(com) then return end
    self.coms[category] = nil
    return com
  end,
}
property(c_entity, 'worldIdx')

return c_entity