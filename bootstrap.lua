dofile 'libs/import.lua'

import 'libs.type'
import 'libs.ensure'
import 'libs.function'
import 'libs.string'
import 'libs.table'
import 'libs.math'
import 'libs.class'

setmetatable(_G, {
  __index = function(_, k)
    error(string.format('attempt to index a unexist global: [ %s ]. %s', k, debug.traceback('', 1)))
  end,
  __newindex = function(_, k, v)
    error(string.format('attempt to write a unexist global: [ %s ]=[ %s ]. %s', k, v, debug.traceback('', 1)))
  end,
})