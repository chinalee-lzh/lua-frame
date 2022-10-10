return class {
  new = function(self)
    self.cache = {}
  end,
  add = function(self, category)
    if isnil(category) then return end
    self.cache[category] = (self.cache[category] or 0)+1
  end,
  get = function(self, category)
    if isnil(category) then return 0 end
    return ENSURE.number(self.cache[category], 0)
  end,
}