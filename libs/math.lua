local abs, floor = math.abs, math.floor

local ERROR = 1e-20

function math.tiny(value) return value < ERROR end
function math.gcd(m, n)
  if m == n then return m end
  if m > n then
    return math.gcd(m-n, n)
  else
    return math.gcd(n-m, m)
  end
end
function math.clamp(value, minvalue, maxvalue)
  if value < minvalue then
    return minvalue
  elseif value > maxvalue then
    return maxvalue
  else
    return value
  end
end
function math.clamp01(value) return math.clamp(value, 0, 1) end
function math.lerp(x, y, t) return x+(y-x)*math.clamp01(t) end
function math.round(value) return floor(value+0.5) end
function math.approximately(x, y) return math.tiny(abs(x-y)) end