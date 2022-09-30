local sqrt, lerp, max, min = math.sqrt, math.lerp, math.max, math.min

local Vector2
Vector2 = classpool({
  new = function(self, x, y) self:set(x, y) end,
  init = function(self, x, y) self:set(x, y) end,
  clone = function(self) return Vector2.Clone(self) end,
  copy = function(self, vec)
    self.x, self.y = vec.x, vec.y
    return self
  end,
  set = function(self, x, y)
    self.x, self.y = ENSURE.number(x, 0), ENSURE.number(y, 0)
    return self
  end,
  get = function(self) return self.x, self.y end,
  sqMagnitude = function(self) return self.x*self.x+self.y*self.y end,
  magnitude = function(self) return sqrt(self:sqrMagnitude()) end,
  normalized = function(self)
    local mag = self:magnitude()
    if mag == 0 then
      self.x, self.y = 0, 0
    else
      self.x, self.y = self.x/mag, self.y/mag
    end
    return self
  end,
  sqDistance = function(self, vec) return (self.x-vec.x)^2+(self.y-vec.y)^2 end,
  distance = function(self, vec) return sqrt(self:sqDistance()) end,
  dot = function(self, vec) return self.x*vec.x+self.y*vec.y end,
  lerp = function(self, vec, t)
    self.x, self.y = lerp(self.x, vec.x, t), lerp(self.y, vec.y, t)
    return self
  end,
  max = function(self, vec)
    self.x, self.y = max(self.x, vec.x), max(self.y, vec.y)
    return self
  end,
  min = function(self, vec)
    self.x, self.y = min(self.x, vec.x), min(self.y, vec.y)
    return self
  end,
  add = function(self, vec)
    self.x, self.y = self.x+vec.x, self.y+vec.y
    return self
  end,
  sub = function(self, vec)
    self.x, self.y = self.x-vec.x, self.x-vec.x
    return self
  end,
  mul = function(self, f)
    self.x, self.y = self.x*f, self.y*f
    return self
  end,
  div = function(self, f)
    if f == 0 then return self end
    self.x, self.y = self.x/f, self.y/f
    return self
  end,
  unm = function(self)
    self.x, self.y = -self.x, -self.y
    return self
  end,

  Clone = function(vec) return Vector2.Pool.get():copy(vec) end,
  Normalized = function(vec) return vec:clone():normalized() end,
  Lerp = function(v1, v2, t) return v1:clone():lerp(v2, t) end,
  Max = function(v1, v2) return v1:clone():max(v2) end,
  Min = function(v1, v2) return v1:clone():min(v2) end,

  __add = function(v1, v2) return v1:clone():add(v2) end,
  __sub = function(v1, v2) return v1:clone():sub(v2) end,
  __mul = function(v1, f) return v1:clone():mul(f) end,
  __div = function(v1, f) return v1:clone():div(f) end,
  __unm = function(vec) return vec:clone():unm() end,
  __eq = function(v1, v2) return math.tiny(v1:sqDistance(v2)) end,
}, 'Vector2')

Vector2.up = Vector2(0, 1)
Vector2.down = Vector2(0, -1)
Vector2.left = Vector2(-1, 0)
Vector2.right = Vector2(1, 0)
Vector2.zero = Vector2(0, 0)
Vector2.one = Vector2(1, 1)

return Vector2