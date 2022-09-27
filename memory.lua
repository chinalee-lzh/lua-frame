local logd = print
local loge = print

local memory

---------------------------------------------- monitor ----------------------------------------------
local _DEFAULT_MONITOR_MODULE_ = -999
local monitor = {
  init = function(self)
    self.leaks = setmetatable({}, {__mode = 'kv'})
    self.initialized = true
  end,
  add = function(self, obj, name, module)
    if notstring(name) then return logd(string.format('the obj added to monitor must has a name')) end
    if nottable(obj) and notfunction(obj) and notthread(obj) and notuserdata(obj) then return logd('the obj added to monitor should not be a value') end
    if not self.initialized then self:init() end
    if isnil(module) then module = _DEFAULT_MONITOR_MODULE_ end
    local t = self.leaks[module]
    if nottable(t) then
      t = {}
      self.leaks[module] = t
    end
    t[name] = obj
  end,
  check = function(self, name, module)
    if not self.initialized then self:init() end
    if isnil(module) then module = _DEFAULT_MONITOR_MODULE_ end
    local t = self.leaks[module]
    if nottable(t) then return end
    if isstring(name) then
      local obj = t[name]
      if notnil(obj) then
        loge('find a leak obj', 'name', name, 'obj', obj)
      end
    else
      for k, v in pairs(t) do
        loge('find a leak obj', 'name', k, 'obj', v)
      end
    end
  end,
}
---------------------------------------------- monitor ----------------------------------------------


---------------------------------------------- snapshot ----------------------------------------------
local _CLASS_NAME_FIELD_ = {'__cname', 'class', '_className'}
local _SCAN_TYPES_ = {
  'table',
  'string',
  'thread',
  'userdata',
  'function'
}
local _TYPE_PREFIX_ = '--**'
local _OBJ_SPLIT_ = '::'
local _ROUTE_PREFIX_ = '    **'
local _MT_ = {__mode = 'k'}
local createRefRecord = function()
  local record = {
    __visited__ = setmetatable({}, _MT_),
    details = {},
  }
  for _, v in ipairs(_SCAN_TYPES_) do
    record.details[v] = setmetatable({}, _MT_)
  end
  return record
end
local getVisited = function(obj, record) return record.__visited__[obj] or 0 end
local setVisited = function(obj, record) record.__visited__[obj] = (record.__visited__[obj] or 0)+1 end
local checkSpecific = function(obj, specifics) return isnil(specifics) or notnil(specifics[obj]) end
local ensureObjRecord = function(record, obj)
  local cache = record.details[type(obj)]
  if isnil(cache) then return end
  local t = cache[obj]
  if isnil(t) then
    t = {count = 0, route = {}}
    cache[obj] = t
  end
  return t
end
local scanObjects, scanTable, scanFunction, scanThread, scanUserdata, scanString
local mapCollect
scanObjects = function(name, obj, record, findall, specificObjs)
  if isnil(obj) or obj == memory then return end
  if checkSpecific(obj, specificObjs) then
    if getVisited(obj, record) > 0 and not findall then return end
    local robj = ensureObjRecord(record, obj)
    if isnil(robj) then return end
    robj.count = robj.count+1
  end
  setVisited(obj, record)
  if notstring(name) then name = '' end
  local fn = mapCollect[type(obj)]
  if isfunction(fn) then fn(name, obj, record, findall, specificObjs) end
end
scanTable = function(name, obj, record, findall, specificObjs)
  for _, v in ipairs(_CLASS_NAME_FIELD_) do
    local str = rawget(obj, v)
    if isstring(str) then
      name = string.format('%s[class: %s ]', name, str)
    end
  end
  if rawequal(obj, _G) then name = name .. '[_G]' end
  if checkSpecific(obj, specificObjs) then
    local robj = ensureObjRecord(record, obj)
    table.insert(robj.route, name)
  end
  if getVisited(obj, record) > 1 then return end
  local weakK, weakV = false, false
  local mt = getmetatable(obj)
  if istable(mt) then
    local mode = rawget(mt, '__mode')
    if isstring(mode) then
      if string.find(mode, 'k') then
        weakK = true
      end
      if string.find(mode, 'v') then
        weakV = true
      end
    end
  end
  for k, v in pairs(obj) do
    local kstr
    if not weakK then
      if istable(k) then
        kstr = '[key:tbl]'
      elseif isfunction(k) then
        kstr = '[key:func]'
      elseif isthread(k) then
        kstr = '[key:thread]'
      elseif isuserdata(k) then
        kstr = '[key:userdata]'
      end
      if notnil(kstr) then scanObjects(name .. '.' .. kstr, k, record, findall, specificObjs) end
    end
    if not weakV then
      local vstr
      if isnil(kstr) then
        vstr = tostring(k)
      else
        vstr = '[value]'
      end
      scanObjects(name .. '.' .. vstr, v, record, findall, specificObjs)
    end
  end
  if istable(mt) then scanObjects(name .. '.[mt]', mt, record, findall, specificObjs) end
end
scanFunction = function(name, obj, record, findall, specificObjs)
  local info = debug.getinfo(obj, 'Su')
  if checkSpecific(obj, specificObjs) then
    local robj = ensureObjRecord(record, obj)
    table.insert(robj.route, string.format('%s[ln:%s@file:%s]', name, info.linedefined, info.short_src))
  end
  if getVisited(obj, record) > 1 then return end
  for i = 1, info.nups do
    local upname, upvalue = debug.getupvalue(obj, i)
    if istable(upvalue) or isfunction(upvalue) or isthread(upvalue) or isuserdata(upvalue) then
      scanObjects(string.format('%s.[up:%s:%s]', name, type(upvalue), upname), upvalue, record, findall, specificObjs)
    end
  end
end
scanThread = function(name, obj, record, _, specificObjs)
  if checkSpecific(obj, specificObjs) then
    local robj = ensureObjRecord(record, obj)
    table.insert(robj.route, name)
  end
end
scanUserdata = function(name, obj, record, findall, specificObjs)
  if checkSpecific(obj, specificObjs) then
    local robj = ensureObjRecord(record, obj)
    table.insert(robj.route, name)
  end
  if getVisited(obj, record) > 1 then return end
  local mt = getmetatable(obj)
  if istable(mt) then scanObjects(name .. '.[mt]', mt, record, findall, specificObjs) end
end
scanString = function(name, obj, record, _, specificObjs)
  if checkSpecific(obj, specificObjs) then
    local robj = ensureObjRecord(record, obj)
    table.insert(robj.route, name .. '[string]')
  end
end
mapCollect = {
  ['string'] = scanString,
  ['table'] = scanTable,
  ['function'] = scanFunction,
  ['thread'] = scanThread,
  ['userdata'] = scanUserdata,
}
local writeNewline = function(file) file:write('\n') end
local output2stdout = function(record)
  for k1, v1 in pairs(record.details) do
    logd(string.format('%s---------------- %s ------------------', _TYPE_PREFIX_, k1))
    for k2, v2 in pairs(v1) do
      logd(string.format('%s%s%d', k2, _OBJ_SPLIT_, v2.count))
      for _, v3 in ipairs(v2.route) do
        logd(_ROUTE_PREFIX_, v3)
      end
    end
  end
end
local output2file = function(outfile, record)
  if notstring(outfile) then
    outfile = string.format('MEM-DUMP %s', os.date('%Y-%m-%d-%H%M%S', os.time()))
  end
  local file = io.open(outfile, 'w')
  if isnil(file) then return end
  for k1, v1 in pairs(record.details) do
    file:write(string.format('%s---------------- %s ------------------', _TYPE_PREFIX_, k1))
    writeNewline(file)
    for k2, v2 in pairs(v1) do
      file:write(string.format('%s%s%d', k2, _OBJ_SPLIT_, v2.count))
      writeNewline(file)
      for _, v3 in ipairs(v2.route) do
        file:write(_ROUTE_PREFIX_, v3)
        writeNewline(file)
      end
    end
  end
  file:close()
end
local tileRecord = function(record)
  local rst = {}
  for _, v1 in pairs(record.details) do
    for k2, v2 in pairs(v1) do
      rst[k2] = v2
    end
  end
  return rst
end
local isStartsWith = function(line, prefix) return line:find(prefix, 1, true) == 1 end
local splitLine = function(line, sep)
  local t = {}
  for field, s in string.gmatch(line, '([^' .. sep .. ']*)(' .. sep .. '?)') do
      table.insert(t, field)
      if s == '' then return t end
  end
  return t
end
local readRecordFromFile = function(file)
  local f = io.open(file, 'r')
  if isnil(f) then return end
  local record = {details = {}}
  local currtype, currobj
  local tmpstr = ''
  while true do
    local line = f:read('l')
    if isnil(line) then break end
    local flag = true
    if isStartsWith(line, _TYPE_PREFIX_) then
      currtype = splitLine(line, ' ')[2]
      record.details[currtype] = {}
    elseif isStartsWith(line, _ROUTE_PREFIX_) then
      table.insert(record.details[currtype][currobj].route, line:sub(7))
    else
      local i, j = line:find('::', 1, true)
      if isnil(i) then
        tmpstr = tmpstr .. '\n' .. line
        flag = false
      else
        currobj = line:sub(1, i-1)
        record.details[currtype][currobj] = {
          count = line:sub(j+1), route = {}
        }
      end
    end
    if flag then tmpstr = '' end
  end
  return record
end
local snapshot = {
  dump = function(self, rootname, root, findall, specificObjs)
    if notstring(rootname) then rootname = 'root' end
    if nottable(root) then root = _G end
    if notbool(findall) then findall = false end
    local record = createRefRecord()
    if notnil(specificObjs) then
      local t = {}
      for _, v in ipairs(specificObjs) do t[v] = 1 end
      specificObjs = t
    end
    scanObjects(rootname, root, record, findall, specificObjs)
    return record
  end,
  dump2stdout = function(self, ...) output2stdout(self:dump(...)) end,
  dump2file = function(self, outfile, ...) output2file(outfile, self:dump(...)) end,
  dumpG = function(self, ...) return self:dump('_G', _G, ...) end,
  dumpG2stdout = function(self, ...) output2stdout(self:dumpG(...)) end,
  dumpG2file = function(self, outfile, ...) output2file(outfile, self:dumpG(...)) end,
  dumpR = function(self, ...) return self:dump('registry', debug.getregistry(), ...) end,
  dumpR2stdout = function(self, ...) output2stdout(self:dumpR(...)) end,
  dumpR2file = function(self, outfile, ...) output2file(outfile, self:dumpR(...)) end,
  compare = function(self, r1, r2)
    local rst = {
      details = {},
    }
    for k1, v1 in pairs(r2.details) do
      local tmp1 = r1.details[k1]
      for k2, v2 in pairs(v1) do
        if isnil(tmp1) or isnil(tmp1[k2]) then
          rst.details[k1] = rst.details[k1] or {r1[k1]}
          rst.details[k1][k2] = v2
        end
      end
    end
    return rst
  end,
  compare2stdout = function(self, ...) output2stdout(self:compare(...)) end,
  compare2file = function(self, outfile, ...) output2file(outfile, self:compare(...)) end,
  compareByFile = function(self, file1, file2)
    local record1 = readRecordFromFile(file1)
    local record2 = readRecordFromFile(file2)
    return self:compare(record1, record2)
  end,
  compare2stdoutByFile = function(self, ...) output2stdout(self:compareByFile(...)) end,
  compare2fileByFile = function(self, outfile, ...) output2file(outfile, self:compareByFile(...)) end,
}
---------------------------------------------- snapshot ----------------------------------------------

memory = {
  setlog = function(fd, fe)
    if isfunction(fd) then logd = fd end
    if isfunction(fe) then loge = fe end
  end,
  monitor = monitor,
  snapshot = snapshot,
}

return memory