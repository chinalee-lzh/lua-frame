return function()
  local K = 16807
  local L = 2147483647 -- 2^31 - 1
  local seed = os.time()

  local rand = function()
    seed = K*seed%L
    return seed
  end
  local range = function(m, n)
    rand()
    if notnumber(m) and notnumber(n) then
      return seed/(L-1)
    else
      local low, high
      if isnumber(n) then
        low = m
      else
        low = 0
      end
      high = ENSURE.number(n, m)
      return seed%(high-low+1)+low
    end
  end

  local v1, v2, s
  local phase = 0
  local gaussian = function()
    local v
    if phase == 0 then
      while true do
        local u1 = range()
        local u2 = range()
        v1 = 2*u1-1
        v2 = 2*u2-1
        s = v1*v1+v2*v2
        if s <= 1 and s ~= 0 then break end
      end
      v = v1
    else
      v = v2
    end
    local x = v*math.sqrt(-2*math.log(s)/s)
    phase = 1-phase
    return x
  end

  return {
    range = range,
    srand = function(x) seed = x end,
    getseed = function() return seed end,
    nd = function(mu, sigma)
      mu = ENSURE.number(mu, 0)
      sigma = ENSURE.number(sigma, 1)
      return mu+sigma*gaussian()
    end,
  }
end