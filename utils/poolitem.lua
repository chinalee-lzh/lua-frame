local c_item = class({
  __forpool__ = true,
  new = function(self, ...)
    self.__free__ = true
    self:ctor(...)
  end,
  ctor = gf_empty,
  __init = function(self, ...)
    self:init(...)
    self.__free__ = false
    return self
  end,
  init = gf_empty,
  __free = function(self)
    self:free()
    self.__free = true
  end,
  free = gf_empty,
  __copy = function(self, ...)
    self:copy(...)
    self.__free__ = false
    return self
  end,
  copy = gf_empty,
  __checkfree = function(self)
    assert(not self.__free__, 'duplicate free')
    return true
  end,
}, 'PoolItem')

function classpool(__class, ...)
  return class(__class, c_item, ...)
end