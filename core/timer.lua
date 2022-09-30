local List = require 'utils.list'
local Dict = require 'utils.dict'

local eType = enum {'second', 'frame'}

local c_item = classpool {
  new = function(...) self:init(...) end,
  init = function(id, type, born, interval, loop, fn, ...)
    self.id = id
    self.type = type
    self.born = born
    self.loop = loop
    self.interval = interval
    self.fn = fn
    self.params = List.Pool.get():pack(...)
    self.counter = 0
    self.dirty = false
  end,
  free = function(self) List.Pool.free(self.params) end,
  update = function(delta)
    self.counter = self.counter+delta
    if self.counter < self.interval then return false end
    self.fn(self.params:unpack())
    if self.loop then self.counter = 0 end
    return true
  end,
  setdirty = function() self.dirty = true end,
}

local addTimer = function(self, type, interval, loop, fn, ...)
  if notfunction(fn) then return end
  if notnumber(interval) or interval <= 0 then return fn(...) end
  loop = ENSURE.boolean(loop, false)
  self.id = self.id+1
  self.timers:add(self.id, c_item(self.id, type, self.fnFrame(), interval, loop, fn, ...))
  return self.id
end
local delTimer = function(self, id)
  local timer = self.timers:get(id)
  if isnil(timer) then return end
  self.timers:del(id)
  c_item.Pool.free(timer)
end
return class({
  new = function(self, fnFrame)
    self.id = 0
    self.timers = Dict.Pool.get()
    self.rmlist = List.Pool.get()
  end,
  delay = function(self, ...) return addTimer(self, eType.second, ...) end,
  step = function(self, ...) return addTimer(self, eType.frame, ...) end,
  remove = function(self, id)
    local timer = self.timers:get(id)
    if isnil(timer) then return end
    if self.processing then
      timer:setdirty()
      self.rmlist:add(id)
    else
      delTimer(self, id)
    end
  end,
  update = function(self, delta)
    local sz = self.timers:size()
    local frame = self.fnFrame()
    self.processing = true
    local t
    for i = 1, sz do
      local timer = self.timers:at(i)
      if timer.born < frame and not timer.dirty then
        if timer.type == eType.second then
          t = delta
        elseif timer.type == eType.frame then
          t = 1
        end
        local flag = timer:update(t)
        if flag and not timer.loop then
          self.rmlist:add(timer.id)
        end
      end
    end
    for v in self.rmlist:loopv() do
      delTimer(self, v)
    end
    self.rmlist:clear()
    self.processing = false
  end,
}, 'Timer')