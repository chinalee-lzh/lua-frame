local CSPrefs = CS.UnityEngine.PlayerPrefs

return {
  deleteAll = function() return CSPrefs.DeleteAll() end,
  deleteKey = function(key) if not string.empty(key) then return CSPrefs.DeleteKey(key) end end,
  hasKey = function(key) return not string.empty(key) and CSPrefs.HasKey(key) end,
  save = function() return CSPrefs.Save() end,
  getInt = function(key, defaultValue)
    if string.empty(key) then return end
    defaultValue = ENSURE.number(defaultValue, 0)
    return CSPrefs.GetInt(key, defaultValue)
  end,
  setInt = function(key, value) if not string.empty(key) and isnumber(value) then return CSPrefs.SetInt(key, value) end end,
  getFloat = function(key, defaultValue)
    if string.empty(key) then return end
    defaultValue = ENSURE.number(defaultValue, 0)
    return CSPrefs.GetFloat(key, defaultValue)
  end,
  setFloat = function(key, value) if not string.empty(key) and isnumber(value) then return CSPrefs.SetFloat(key, value) end end,
  getString = function(key, defaultValue)
    if string.empty(key) then return end
    defaultValue = ENSURE.string(defaultValue, '')
    return CSPrefs.GetString(key, defaultValue)
  end,
  setString = function(key, value) if not string.empty(key) and isstring(value) then return CSPrefs.SetString(key, value) end end,
}