return {
  isNull = function(obj)
    if isnil(obj) then
      return true
    elseif isuserdata(obj) and isfunction(obj.IsNull) then
      return obj:IsNull()
    else
      return false
    end
  end,
}