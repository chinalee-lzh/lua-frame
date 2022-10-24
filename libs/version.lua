local ver = tonumber(string.sub(_VERSION, 5))
LUAVER = {
  get = function() return ver end,
}