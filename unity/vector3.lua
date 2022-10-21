local sqrt, lerp, max, min = math.sqrt, math.lerp, math.max, math.min

local project = function(v1, v2)
  local n1 = v2:sqMagnitude()
  if math.tiny(n1) then
    return 0, 0, 0
  end
  local n2 = v1:dot(v2)
  local n = n2/n1
  return v2.x*n, v2.y*n, v2.z*n
end

local Vector3
Vector3 = classpool {
  __cname = 'Vector3',
  new = function(self, x, y, z) self:set(x, y, z) end,
  init = function(self, x, y, z) self:set(x, y, z) end,
  clone = function(self) return Vector3.Clone(self) end,
  copy = function(self, vec)
    self.x, self.y, self.z = vec.x, vec.y, vec.z
    return self
  end,
  set = function(self, x, y, z)
    self.x, self.y, self.z = ENSURE.number(x, 0), ENSURE.number(y, 0), ENSURE.number(z, 0)
    return self
  end,
  unpack = function(self) return self.x, self.y, self.z end,
  get = function(self) return self.x, self.y, self.z end,
  sqMagnitude = function(self) return self.x^2+self.y^2+self.z^2 end,
  magnitude = function(self) return sqrt(self:sqrMagnitude()) end,
  normalized = function(self)
    local mag = self:magnitude()
    if mag == 0 then
      self.x, self.y, self.z = 0, 0, 0
    else
      self.x, self.y, self.z = self.x/mag, self.y/mag, self.z/mag
    end
    return self
  end,
  sqDistance = function(self, vec) return (self.x-vec.x)^2+(self.y-vec.y)^2+(self.z-vec.z)^2 end,
  distance = function(self, vec) return sqrt(self:sqDistance()) end,
  dot = function(self, vec) return self.x*vec.x+self.y*vec.y+self.z*vec.z end,
  cross = function(self, vec)
    self.x = self.y*vec.z-self.z*vec.y
    self.y = self.z*vec.x-self.x*vec.z
    self.z = self.x*vec.y-self.y*vec.x
    return self
  end,
  project = function(self, vec) return self:set(project(self, vec)) end,
  projectOnPlane = function(self, plane)
    local x, y, z = project(self, plane)
    return self:set(self.x-x, self.y-y, self.z-z)
  end,
  lerp = function(self, vec, t)
    self.x, self.y, self.z = lerp(self.x, vec.x, t), lerp(self.y, vec.y, t), lerp(self.z, vec.z, t)
    return self
  end,
  max = function(self, vec)
    self.x, self.y, self.z = max(self.x, vec.x), max(self.y, vec.y), max(self.z, vec.z)
    return self
  end,
  min = function(self, vec)
    self.x, self.y, self.z = min(self.x, vec.x), min(self.y, vec.y), min(self.z, vec.z)
    return self
  end,
  add = function(self, vec)
    self.x, self.y, self.z = self.x+vec.x, self.y+vec.y, self.z+vec.z
    return self
  end,
  sub = function(self, vec)
    self.x, self.y, self.z = self.x-vec.x, self.x-vec.x, self.z-vec.z
    return self
  end,
  mul = function(self, f)
    self.x, self.y, self.z = self.x*f, self.y*f, self.z*f
    return self
  end,
  div = function(self, f)
    if f == 0 then return self end
    self.x, self.y, self.z = self.x/f, self.y/f, self.z/f
    return self
  end,
  unm = function(self)
    self.x, self.y, self.z = -self.x, -self.y, -self.z
    return self
  end,

  Clone = function(vec) return Vector3.Pool.get():copy(vec) end,
  Normalized = function(vec) return vec:clone():normalized() end,
  Lerp = function(v1, v2, t) return v1:clone():lerp(v2, t) end,
  Max = function(v1, v2) return v1:clone():max(v2) end,
  Min = function(v1, v2) return v1:clone():min(v2) end,
  Cross = function(v1, v2) return v1:clone():cross(v2) end,
  Project = function(v1, v2) return v1:clone():project(v2) end,
  ProjectOnPlane = function(v1, v2) return v1:clone():projectOnPlane(v2) end,

  __add = function(v1, v2) return v1:clone():add(v2) end,
  __sub = function(v1, v2) return v1:clone():sub(v2) end,
  __mul = function(v1, f) return v1:clone():mul(f) end,
  __div = function(v1, f) return v1:clone():div(f) end,
  __unm = function(vec) return vec:clone():unm() end,
  __eq = function(v1, v2) return math.tiny(v1:sqDistance(v2)) end,
}

Vector3.left = Vector3.Pool.get(-1, 0, 0)
Vector3.right = Vector3.Pool.get(1, 0, 0)
Vector3.up = Vector3.Pool.get(0, 1, 0)
Vector3.down = Vector3.Pool.get(0, -1, 0)
Vector3.forward = Vector3.Pool.get(0, 0, 1)
Vector3.back = Vector3.Pool.get(0, 0, -1)
Vector3.zero = Vector3.Pool.get(0, 0, 0)
Vector3.one = Vector3.Pool.get(1, 1, 1)