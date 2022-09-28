isfunction = function(f) return type(f) == 'function' end
notfunction = function(f) return not isfunction(f) end

istable = function(t) return type(t) == 'table' end
nottable = function(t) return not istable(t) end

isnumber = function(n) return type(n) == 'number' end
notnumber = function(n) return not isnumber(n) end

isboolean = function(b) return type(b) == 'boolean' end
notboolean = function(b) return not isboolean(b) end

isstring = function(str) return type(str) == 'string' end
notstring = function(str) return not isstring(str) end

isnil = function(e) return type(e) == 'nil' end
notnil = function(e) return not isnil(e) end

isuserdata = function(u) return type(u) == 'userdata' end
notuserdata = function(u) return not isuserdata(u) end

isthread = function(th) return type(th) == 'thread' end
notthread = function(th) return not isthread(th) end