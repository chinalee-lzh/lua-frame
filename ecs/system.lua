local c_sys = class {
  new = function(self, category)
    self.ecskey = '__ECS_KEY_SYS__'
    self.category = category
  end,
  process = gf_empty,
}
property(c_sys, 'worldIdx')

return c_sys