local create, resume, yield, status, running, wrap
  = coroutine.create, coroutine.resume, coroutine.yield, coroutine.status, coroutine.running, coroutine.wrap
local pack, unpack, insert = table.pack, table.unpack, table.insert

local call = function(fn, ...)
  local co = create(fn)
  resume(co, ...)
end
local wrap = function(fn) return function(...) call(fn, ...) end end
local a2s = function(fnasync, callback_pos)
  return function(...)
    local co = running()
    if isnil(co) then error('this function must be running in coroutine') end
    local rst, waiting = nil, false
    local callback = function(...)
      if waiting then
        resume(co, ...)
      else
        rst = {...}
      end
    end
    local params = pack(...)
    callback_pos = ENSURE.number(callback_pos, #params+1)
    insert(params, callback_pos, callback)
    fnasync(unpack(params))
    if isnil(rst) then
      waiting = true
      rst = {yield()}
    end
    return unpack(rst)
  end
end

return {
  call = call,
  wrap = wrap,
  a2s = a2s,
}