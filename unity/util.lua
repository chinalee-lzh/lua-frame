local isNull = function(obj)
  if isnil(obj) then
    return true
  elseif isuserdata(obj) and isfunction(obj.IsNull) then
    return obj:IsNull()
  else
    return false
  end
end

return {
  isNull = isNull,
  notNull = function(obj) return not isNull(obj) end,
}