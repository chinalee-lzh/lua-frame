local unpack = table.unpack

local eIter = enum {'v', 'iv'}
local c_iter = class {
  new = function(self, l)
    self.fns = setmetatable({}, gt_weakv)
    self.l = l
  end,
  init = function(type, ...)
    self.type = type
    self.idx = 0
    self.sz = select('#', ...)
    for i = 1, self.sz do self.fns[i] = select(i, ...) end
    return self
  end,
  loop = function(self)
    while true do
      self.idx = self.idx+1
      if self.idx > self.l:size() then break end
      local e = self.l:at(self.idx)
      local flag = true
      for i = 1, self.sz do
        flag = self.fns[i](e)
        if not flag then break end
      end
      if flag then
        if self.type == eIter.v then
          return e
        elseif self.type == eIter.iv then
          return self.idx, e
        end
      end
    end
  end,
}

local loopwith = function(self, ...)
  self.__iter:init(self, ...)
  return self.__iter.loop, self.__iter
end
local loop = function(self, idx)
  idx = idx+1
  if idx <= self:size() then
    return idx, self:at(idx)
  end
end
local setsize = function(self, sz) self.__n = sz end
local changesize = function(self, sz) self.__n = self.__n+sz end
local get = function(self, idx) return self.__container[idx] end
local set = function(self, idx, e) self.__container[idx] = e end
local swap = function(self, i, j) self.__container[i], self.__container[j] = self.__container[j], self.__container[i] end
local partion = function(self, low, high, fn, ...)
  local e = get(self, low)
  while low < high do
    while low < high and not fn(get(self, high), e, ...) do high = high-1 end
    swap(self, low, high)
    while low < high and fn(get(self, low), e, ...) do low = low+1 end
    swap(self, low, high)
  end
  return low
end
local sort
sort = function(self, low, high, fn, ...)
  if low >= high then return end
  local idx = partion(self, low, high, fn, ...)
  sort(self, low, idx-1, fn, ...)
  sort(self, idx+1, high, fn, ...)
end
local valididx = function(self, idx) return isnumber(idx) and idx > 0 and idx <= self.__n end

local List
List = classpool {
  __cname = 'List',
  new = function(self)
    self.__container = {}
    self.__n = 0
    self.__iter = c_iter.Pool.get(self)
  end,
  free = function(self)
    self:clear()
    table.clear(self.__container)
  end,
  clear = function(self) setsize(self, 0) end,
  size = function(self) return self.__n end,
  at = function(self, idx) if valididx(idx) then return get(self, idx) end end,
  head = function(self) return self:at(1) end,
  tail = function(self) return self:at(self:size()) end,
  exist = function(self, e)
    if isnil(e) then return false end
    self.__iter:init(eIter.iv)
    for i, v in self.__iter.loop, self.__iter do
      if v == e then
        return true, i
      end
    end
    return false
  end,
  has = function(self, ...) return self:exist(...) end,
  insert = function(self, e, idx)
    if isnil(e) then return end
    local sz = self:size()
    idx = ENSURE.number(idx, sz+1)
    if idx < 1 or idx > sz+1 then return end
    for i = sz, idx, -1 do set(self, i+1, get(self, i)) end
    set(self, idx, e)
    changesize(self, 1)
    return idx
  end,
  add = function(self, ...) return self:insert(...) end,
  set = function(self, idx, e)
    if isnil(e) or not valididx(idx) then return end
    set(self, idx, e)
  end,
  removeat = function(self, idx, keeporder)
    if not valididx(idx) then return end
    local sz = self:size()
    local e = get(self, idx)
    if idx < sz then
      if keeporder then
        for i = idx, sz-1 do set(self, i, get(self, i+1)) end
      else
        set(self, idx, self:tail())
      end
    end
    changesize(self, -1)
    return e
  end,
  remove = function(self, e, keeporder)
    local ok, idx = self:exist(e)
    if not ok then return end
    return self:removeat(idx, keeporder)
  end,
  removehead = function(self, keeporder) return self:removeat(1, keeporder) end,
  removetail = function(self) setsize(self, self:size()-1) end,
  remove2tail = function(self, idx) if valididx(idx) then setsize(self, idx-1) end end,
  join = function(self, l, i, j)
    if nottable(l) then return end
    if l.__class ~= List then return end
    i = ENSURE.number(i, 1)
    j = ENSURE.number(j, l:size())
    for idx = i, j do self:insert(l:at(i)) end
    return self
  end,
  joinarray = function(self, array, i, j)
    if nottable(array) then return end
    i = ENSURE.number(i, 1)
    j = ENSURE.number(j, #array)
    for idx = i, j do self:insert(array[i]) end
    return self
  end,
  copy = function(self, l, i, j)
    self:clear()
    return self:join(l, i, j)
  end,
  copyarray = function(self, array, i, j)
    self:clear()
    return self:joinarray(array, i, j)
  end,
  copyArgs = function(self, ...)
    self:clear()
    local n = select('#', ...)
    for i = 1, n do
      self:add(select(i, ...))
    end
    return self
  end,
  pack = function(self, ...)
    self:clear()
    local n = select('#', ...)
    for i = 1, n do
      self:add(select(i, ...))
    end
    return self
  end,
  unpack = function(self)
    self.__container[self:size()+1] = nil
    return unpack(self.__container)
  end,
  sort = function(self, fn, ...) return sort(self, 1, self:size(), fn, ...) end,
  concat = function(self, sep, i, j)
    sep = ENSURE.string(sep, '')
    i = ENSURE.number(i, 1)
    j = ENSURE.number(j, self:size())
    if i > j then return '' end
    local str = ''
    for idx = i, j-1 do str = string.format('%s%s', self:at(idx), sep) end
    str = str .. tostring(self:at(j))
    return str
  end,
  getiter = function(...) return self.__iter:init(eIter.iv, ...) end,
  getiterv = function(...) return self.__iter:init(eIter.v, ...) end,
  loop = function(self, ...)
    local n = select('#', ...)
    if n == 0 then
      return loop, self, 0
    else
      return loopwith(self, eIter.iv, ...)
    end
  end,
  loopv = function(self, ...) return loopwith(self, eIter.v, ...) end,
  swap = function(self, i, j)
    if i == j then return end
    if not valididx(i) or not valididx(j) then return end
    local ei, ej = self:at(i), self:at(j)
    self:set(i, ej)
    self:set(j, ei)
  end,
}

return List