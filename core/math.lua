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