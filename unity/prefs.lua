local csprefs = import('unity.interface').PlayerPrefs

return {
  deleteAll = function() return csprefs.DeleteAll() end,
  deleteKey = function(key) if not string.empty(key) then return csprefs.DeleteKey(key) end end,
  hasKey = function(key) return not string.empty(key) and csprefs.HasKey(key) end,
  save = function() return csprefs.Save() end,
  getInt = function(key, defaultValue)
    if string.empty(key) then return end
    defaultValue = ENSURE.number(defaultValue, 0)
    return csprefs.GetInt(key, defaultValue)
  end,
  setInt = function(key, value) if not string.empty(key) and isnumber(value) then return csprefs.SetInt(key, value) end end,
  getFloat = function(key, defaultValue)
    if string.empty(key) then return end
    defaultValue = ENSURE.number(defaultValue, 0)
    return csprefs.GetFloat(key, defaultValue)
  end,
  setFloat = function(key, value) if not string.empty(key) and isnumber(value) then return csprefs.SetFloat(key, value) end end,
  getString = function(key, defaultValue)
    if string.empty(key) then return end
    defaultValue = ENSURE.string(defaultValue, '')
    return csprefs.GetString(key, defaultValue)
  end,
  setString = function(key, value) if not string.empty(key) and isstring(value) then return csprefs.SetString(key, value) end end,
}