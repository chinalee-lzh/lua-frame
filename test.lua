require 'libs.bootstrap'

local m = class {
  ctor = function(self)
    print('call ctor')
  end
}
local obj = m()