local c_go
c_go = classpool({
  new = function(self, csobj) self:ctor(csobj) end,
  ctor = function(self, csobj) self.csobj = csobj end,
  setActive = function(self, flag) end,
}, 'gameobject')

return c_go