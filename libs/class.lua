function class(__class, ...)
  local sz = select('#', ...)
  local name
  if sz > 0 then name = select(sz, ...) end
  local super = {...}
  if isstring(name) then
    super[#super] = nil
  end
  __class.__super = super
  __class.__cname = name
  local mtclass = {}
  if #super > 0 then
    mtclass.__index = function(_, k)
      for i = 1, #super do
        local v = super[i][k]
        if notnil(v) then
          return v
        end
      end
    end
  end
  local mtobj = {__index = __class}
  mtclass.__call = function(_, ...)
    local obj = setmetatable({__class = __class}, mtobj)
    local new = rawget(__class, 'new')
    safecall(new, obj, ...)
    return obj
  end
  setmetatable(__class, mtclass)
  return __class
end

function property(class, propname, getter, setter)
  if string.empty(propname) then return end
  getter = ENSURE.boolean(getter, false)
  setter = ENSURE.boolean(setter, false)
  if getter then
    local fname = string.format('get%s', propname)
    local fn = rawget(class, fname)
    if notfunction(fn) then
      class[fname] = function(self) return self[propname] end
    end
  end
  if setter then
    local fname = string.format('set%s', propname)
    local fn = rawget(class, fname)
    if notfunction(fn) then
      class[fname] = function(self, value) self[propname] = value end
    end
  end
end

function classpool(__class, ...)
  local cls = class(__class, ...)
  local pool = {sz = 0, cache = {}}
  pool.get = function(...)
    local obj
    if pool.sz == 0 then
      obj = cls(...)
    else
      obj = pool.cache[pool.sz]
      pool.cache[pool.sz] = nil
      pool.sz = pool.sz-1
      assert(obj.__free__, string.format('get a busy item from pool. %s', cls.__cname))
      safecall(obj.init, obj, ...)
    end
    obj.__free__ = false
    return obj
  end
  pool.free = function(...)
    local n = select('#', ...)
    for i = 1, n do
      local obj = select(i, ...)
      assert(obj.__class == cls, string.format('free obj is not from this class. %s', cls.__cname))
      assert(not obj.__free__, string.format('duplicate free. %s', cls.__cname))
      safecall(obj.free, obj)
      obj.__free__ = true
      pool.sz = pool.sz+1
      pool.cache[pool.sz] = obj
    end
  end
  pool.clear = function(obj)
    for i = 1, pool.sz do
      pool.cache[i] = nil
    end
  end
  cls.Pool = pool
end