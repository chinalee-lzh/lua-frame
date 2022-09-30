local c_go
c_go = classpool({
  new = function(self, csobj) self:init(csobj) end,
  init = function(self, csobj) self.csobj = csobj end,
  setActive = function(self, flag) end,
}, 'gameobject')

return c_go