local create, resume, yield, status, running, wrap
  = coroutine.create, coroutine.resume, coroutine.yield, coroutine.status, coroutine.running, coroutine.wrap
local pack, unpack = table.pack, table.unpack

return classpool({
  new = function(self, fn)
    self.fn = ENSURE.func(fn ,gf_empty)
    self.co = create(function()
      while true do
        local rst = pack(yield())
        return self.fn(unpack(rst))
      end
    end)
    self:resume()
  end,
  init = function(self, fn) self.fn = fn end,
  resume = function(self, ...) resume(self.co, ...) end,
  start = function(self, ...) self:resume(...) end,
  status = function(self) return status(self.co) end,
  isdead = function(self) return self:status() == 'dead' end,
}, 'Thread')