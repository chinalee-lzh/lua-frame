local util = require 'ecs.util'

local createFilter = function(prefix, seperator, ...)
  local n = select('#', ...)
  local l = List.Pool.get()
  for i = 1, n do
    l:add(string.format('(entity:hascom(%s))', select(i, ...)))
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
  addEntity = function(self, entity)
    if util.notentity(entity) then return end
    local idx = #self.entities+1
    self.entities[idx] = entity
    entity:setWorldIdx(idx)
  end,
  delEntity = function(self, entity)
    local idx = entity:getWorldIdx()
    local sz = #self.entities
    self.entities[idx] = self.entities[sz]
    self.entities[sz] = nil
  end,
  requireAll = function(self, ...) return createFilter('', 'and', ...) end,
  requireAny = function(self, ...) return createFilter('', 'or', ...) end,
  rejectAll = function(self, ...) return createFilter('not', 'or', ...) end,
  rejectAny = function(self, ...) return createFilter('not', 'and', ...) end,
  update = function(self, delta)
    for _, sys in ipairs(self.systems) do
      local filter = sys.filter
      for _, entity in ipairs(self.entities) do
        if filter(entity) then
          sys:process(entity, delta)
        end
      end
    end
  end,
}