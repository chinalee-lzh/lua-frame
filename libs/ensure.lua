local check = function(fn, v1, v2, ...)
  if fn(v1) then return v1 end
  if fn(v2) then return v2 end
  local sz = select('#', ...)
  for i = 1, sz do
    local v = select(i, ...)
    if fn(v) then return v end
  end
end

ENSURE = {
  number = function(n1, n2, ...) return check(isnumber, n1, n2, ...) end,
  string = function(s1, s2, ...) return check(isstring, s1, s2, ...) end,
  boolean = function(b1, b2, ...) return check(isboolean, b1, b2, ...) end,
  table = function(t1, t2, ...) return check(istable, t1, t2, ...) end,
  func = function(f1, f2, ...) return check(isfunction, f1, f2, ...) end,
}