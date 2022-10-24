local List = import 'utils.list'

local eIter = enum {'v', 'kv'}
local c_iter = class {
  new = function(self, d)
    self.fns = setmetatable({}, gt_weakv)
    self.d = d
  end,
  init = function(self, type, ...)
    self.type = type
    self.idx = 0
    self.sz = select('#', ...)
    for i = 1, self.sz do self.fns[i] = select(i, ...) end
    return self
  end,
  loop = function(self)
    while true do
      self.idx = self.idx+1
      if self.idx > self.d:size() then break end
      local value, key = self.d:at(self.idx)
      local flag = true
      for i = 1, self.sz do
        flag = self.fns[i](value, key)
        if not flag then break end
      end
      if flag then
        if self.type == eIter.v then
          return value
        elseif self.type == eIter.kv then
          return key, value
        end
      end
    end
  end,
}

local loop = function(self, ...)
  self.__iter:init(...)
  return self.__iter.loop, self.__iter
end

local Dict
Dict = classpool {
  __cname = 'Dict',
  new = function(self)
    self.__container = {}
    self.__iter = c_iter(self)
    self:init()
  end,
  init = function(self) self.__keylist = List.Pool.get() end,
  free = function(self)
    self.__container = {}
    List.Pool.free(self.__keylist)
  end,
  clear = function(self) self.__keylist:clear() end,
  size = function(self) return self.__keylist:size() end,
  get = function(self, key) if notnil(key) then return self.__container[key], key end end,
  exist = function(self, key) return notnil(self:get(key)) end,
  has = function(self, ...) self:exist(...) end,
  set = function(self, key, value)
    if isnil(key) or isnil(value) then return end
    if not self.__keylist:has(key) then
      self.__keylist:add(key)
    end
    self.__container[key] = value
    return value
  end,
  add = function(self, key, value)
    if isnil(key) or isnil(value) then return end
    if self.__keylist:has(key) then return end
    self.__keylist:add(key)
    self.__container[key] = value
    return value
  end,
  del = function(self, key)
    if isnil(key) then return end
    local value = self:get(key)
    if isnil(value) then return end
    self.__container[key] = nil
    self.__keylist:remove(key)
    return value
  end,
  at = function(self, idx) return self:get(self.__keylist:at(idx)) end,
  head = function(self) return self:at(1) end,
  tail = function(self) return self:at(self:size()) end,
  copy = function(self, d)
    if nottable(d) then return end
    if d.__class ~= Dict then return end
    self:clear()
    for k, v in d:loop() do self:set(k, v) end
    return self
  end,
  sort = function(self, fn) return self.__keylist:sort(fn) end,
  loop = function(self, ...) return loop(self, eIter.kv, ...) end,
  loopv = function(self, ...) return loop(self, eIter.v, ...) end,
}

return Dict