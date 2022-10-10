local filter = function(prefix, seperator, ...)
  local n = select('#', ...)
  local l = List.Pool.get()
  for i = 1, n do
    local item = select(i, ...)
    l:add(string.format('(notnil(entity[%s]))', item))
  end
  local script = string.format('return function(entity) return %s(%s)', prefix, l:concat(seperator))
  List.Pool.free(l)
  local fn = loadstring(script)
  return fn()
end

return class {
  new = function(self)
    self.entities = {}
    self.systems = {}
  end,
  addSystem = function(self, sys)
  end,
  delSystem = function(self, sys)
  end,
  addEntity = function(self, entity)
    entity.idxWorld = #self.entities+1
    self.entities[entity.idxWorld] = entity
  end,
  delEntity = function(self, entity)
    local idx = entity.idxWorld
    self.entities[idx] = self.entities[#self.entities]
    self.entities[#self.entities] = nil
  end,
  requireAll = function(self, ...) return filter('', 'and', ...) end,
  requireAny = function(self, ...) return filter('', 'or', ...) end,
  rejectAll = function(self, ...) return filter('not', 'or', ...) end,
  rejectAny = function(self, ...) return filter('not', 'and', ...) end,
}