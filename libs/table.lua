local concat, sort, pack, insert, unpack, remove, move
  = table.concat, table.sort, table.pack, table.insert, table.unpack, table.remove, table.move

function table.readonly(tbl)
  if nottable(tbl) then return end
  local mt = {
    __index = tbl,
    __newindex = function() error('Attempt to modify a readonly table', 2) end,
    __paris = function() return pairs(tbl) end,
    __len = function() return #tbl end,
    __metatable = false,
  }
  return setmetatable({}, mt)
end
function table.exist(tbl, value)
  if nottable(tbl) then return false end
  for k, v in pairs(tbl) do
    if v == value then
      return true, k
    end
  end
  return false
end
function table.delete(tbl, value)
  if nottable(tbl) then return end
  for k, v in pairs(tbl) do
    if v == value then
      tbl[k] = nil
      break
    end
  end
end
function table.deletearray(array, value, disorder)
  if nottable(array) then return end
  for i, v in ipairs(array) do
    if v == value then
      if disorder then
        array[i], array[#array] = array[#array], nil
      else
        remove(array, i)
      end
      break
    end
  end
end
function table.copy(tbl)
  if nottable(tbl) then return end
  local rst = {}
  for k, v in pairs(tbl) do rst[k] = v end
  return rst
end
function table.deepcopy(tbl, cache)
  if nottable(tbl) then return tbl end
  cache = ENSURE.table(cache, {})
  if notnil(cache[tbl]) then return cache[tbl] end
  local rst = {}
  cache[tbl] = rst
  local mt = getmetatable(tbl)
  for k, v in pairs(tbl) do
    k = table.deepcopy(k, cache)
    v = table.deepcopy(v, cache)
    rst[k] = v
  end
  setmetatable(rst, mt)
  return rst
end
function table.update(dst, src)
  if nottable(dst) or nottable(src) then return end
  for k, v in pairs(src) do dst[k] = v end
  return dst
end
function table.updatearray(dst, src)
  if nottable(dst) or nottable(src) then return end
  local sz = #dst
  for i = 1, #src do dst[sz+i] = src[i] end
  return dst
end
function table.merge(tbl1, ...)
  if nottable(tbl1) then return end
  local rst = {}
  local sz = select('#', ...)
  for i = 1, sz do
    local t = select(i, ...)
    if istable(t) then
      table.update(rst, t)
    end
  end
  return rst
end
function table.mergearray(array1, ...)
  if nottable(array1) then return end
  local rst = {}
  local sz = select('#', ...)
  for i = 1, sz do
    local t = select(i, ...)
    if istable(t) then
      table.updatearray(rst, t)
    end
  end
  return rst
end
function table.size(tbl)
  if nottable(tbl) then return 0 end
  local cnt = 0
  for _ in pairs(tbl) do cnt = cnt+1 end
  return cnt
end
local transform = function(src, dst, fn, ...)
  if nottable(tbl) or notfunction(fn) then return end
  for k, v in pairs(tbl) do
    dst[k] = fn(v, ...)
  end
  return dst
end
function table.map(tbl, fn, ...) return transform(tbl, {}, fn, ...) end
function table.transform(tbl, fn, ...) return transform(tbl, tbl, fn, ...) end
function table.foreach(tbl, fn, ...)
  if nottable(tbl) or notfunction(fn) then return end
  for k, v in pairs(tbl) do fn(v, k, ...) end
end
function table.foreachi(tbl, fn, ...)
  if nottable(tbl) or notfunction(fn) then return end
  for i = 1, #tbl do fn(tbl[i], i, ...) end
end
function table.reverse(src, dst)
  if nottable(src) then return end
  dst = ENSURE.table(dst, src)
  for k, v in pairs(src) do dst[v] = k end
  return dst
end
function table.slice(tbl, from, to)
  if nottable(tbl) then return end
  from = ENSURE.number(from, 1)
  to = ENSURE.number(to, #tbl)
  if from < 0 then from = from+#tbl+1 end
  if to < 0 then to = to+#tbl+1 end
  local rst = {}
  for i = from, to do insert(rst, tbl[i]) end
  return rst
end
function table.empty(tbl) return isnil(next(tbl)) end

gt_empty = table.readonly {}
gt_weakk = table.readonly {__mode = 'k'}
gt_weakv = table.readonly {__mode = 'v'}
gt_weakkv = table.readonly {__mode = 'kv'}