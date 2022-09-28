local c_item = class {
  new = function(self, classtype)
    self.sz = 0
    self.cache = {}
    self.__classtype = classtype
  end,
  get = function()
    local e
    if self.sz == 0 then
      e = self.__classtype()
    else
      e = self.cache[self.sz]
      self.cache[self.sz] = nil
      self.sz = self.sz-1
    end
    assert(e.__free__, string.format('get a busy item from pool. %s', e.__class.__cname))
    return e
  end,
  free = function(e)
    e:__free()
    self.sz = self.sz+1
    self.cache[self.sz] = e
  end,
}

return function()
  local cache = {}
  local getFromCache = function(classtype)
    assert(classtype.__forpool__, string.format('request class is not a PoolItem. %s', classtype.__cname))
    cache[classtype] = cache[classtype] or c_item(classtype)
    return cache[classtype]:get()
  end
  return {
    get = function(classtype, ...) return getFromCache(classtype):__init(...) end,
    copy = function(classtype, ...) return getFromCache(classtype):__copy(...) end,
    free = function(...)
      local n = select('#', ...)
      for i = 1, n do
        local e = select(i, ...)
        if notnil(e) then
          assert(e.__forpool__, string.format('free item is not a PoolItem. %s', e))
          assert(notnil(cache[e.__class]), string.format('free item is not from pool. %s', e.__class.__cname))
          if e:__checkfree() then
            cache[e.__class]:free(e)
          end
        end
      end
    end,
  }
end