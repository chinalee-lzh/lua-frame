local List = require 'utils.list'
local Dict = require 'utils.dict'

local c_listener = classpool {
  new = function(self, ...) self:init() end,
  init = function(self, counter, evtid, func, ...)
    self.counter = counter
    self.evtid = evtid
    self.func = func
    self.dirty = false
    self.busy = false
    self.params = List.Pool.get()
    self.params:pack(...)
  end,
  free = function(self) List.Pool.free(self.params) end,
  execute = function(self, ...) self.func(self.params:unpack(), ...) end,
  setbusy = function(self, flag) self.busy = flag end,
  isbusy = function(self) return self.busy end,
  setdirty = function(self) self.dirty = true end,
  isdirty = function(self) return self.dirty end,
}

local freeListener = function(self, listener)
  local counter = listener.counter
  local evtid = listener.evtid
  self.listeners[counter] = nil
  self.events[evtid].d:del(counter)
  c_listener.Pool.free(listener)
end
return class {
  new = function(self)
    self.listeners = {}
    self.events = {}
    self.counter = 0
  end,
  add = function(self, evtid, func, ...)
    self.counter = self.counter+1
    local events = self.events[evtid]
    if nottable(events) then
      events = {
        d = Dict(), firingCount = 0, rmlist = List()
      }
      self.events[evtid] = events
    end
    local listener = c_listener.Pool.get(self.counter, evtid, func, ...)
    self.listeners[self.counter] = listener
    events.d:add(self.counter, listener)
    return self.counter
  end,
  remove = function(self, counter)
    local listener = self.listeners[counter]
    if isnil(listener) then return end
    if listener.isbusy() then
      listener:setdirty()
    else
      freeListener(self, listener)
    end
  end,
  fire = function(self, evtid, ...)
    local events = self.events[evtid]
    if isnil(events) or events.firingCount > 0 then return end
    events.firingCount = events.d:size()
    for i = 1, events.firingCount do
      events.d:at(i):setbusy(true)
    end
    for i = 1, events.firingCount do
      local listener = events.d:at(i)
      if listener:isdirty() then
        events.rmlist:add(listener)
      else
        listener:execute(...)
      end
    end
    for i = 1, events.firingCount do
      events.d:at(i):setbusy(false)
    end
    for v in events.rmlist:loopv() do
      freeListener(self, v)
    end
    events.rmlist:clear()
    events.firingCount = 0
  end,
}