local util = import 'unity.util'
local vector3 = import('unity.vector3').Pool

local c_go
c_go = classpool {
  __cname = 'gameobject',
  new = function(self, csobj) self:init(csobj) end,
  init = function(self, csobj)
    self.csobj = csobj
    self.trans = csobj.transform
    self.lpos = vector3.get():copy(self.trans.localPosition)
    self.pos = vector3.get():copy(self.trans.position)
    self.scale = vector3.get():copy(self.trans.localScale)
  end,
  free = function(self)
    vector3.free(self.lpos, self.pos, self.scale)
  end,
  setActive = function(self, flag)
    flag = ENSURE.boolean(flag, true)
    self.csobj:SetActive(flag)
  end,
  find = function(self, path)
    if string.empty(path) then return self end
    path = path:trim():gsub('%.', '/')
    local rst = self.trans:Find(path)
    if util.notNull(rst) then
      return c_go.Pool.get(rst)
    end
  end,
  synclpos = function(self) self.trans:SetLocalPosition(self.lpos:unpack()) end,
  syncpos = function(self) self.trans:SetLocalPosition(self.pos:unpack()) end,
  syncscale = function(self) self.trans:SetScale(self.scale:unpack()) end,
  getlpos = function(self) return vector3.get():copy(self.lpos) end,
  getlpos_xyz = function(self) return self.lpos:unpack() end,
  setlpos = function(self, pos, sync)
    sync = ENSURE.boolean(sync, true)
    self.lpos:copy(pos)
    if sync then self:synclpos() end
  end,
  setlpos_xyz = function(self, x, y, z, sync)
    sync = ENSURE.boolean(sync, true)
    self.lpos:set(x, y, z)
    if sync then self:synclpos() end
  end,
  getpos = function(self) return vector3.get():copy(self.pos) end,
  getpos_xyz = function(self) return self.pos:unpack() end,
  setpos = function(self, pos, sync)
    sync = ENSURE.boolean(sync, true)
    self.pos:copy(pos)
    if sync then self:syncpos() end
  end,
  setpos_xyz = function(self, x, y, z, sync)
    sync = ENSURE.boolean(sync, true)
    self.pos:set(x, y, z)
    if sync then self:syncpos() end
  end,
  getscale = function(self) return vector3.get():copy(self.scale) end,
  getscale_xyz = function(self) return self.scale:unpack() end,
  setscale = function(self, scale, sync)
    sync = ENSURE.boolean(sync, true)
    self.scale:copy(scale)
    if sync then self:syncscale() end
  end,
  setscale_xyz = function(self, x, y, z, sync)
    sync = ENSURE.boolean(sync, true)
    self.scale:set(x, y, z)
    if sync then self:syncscale() end
  end
}

return c_go