dofile 'libs/version.lua'
dofile 'libs/import.lua'

dofile 'libs.type'
dofile 'libs.ensure'
dofile 'libs.function'
dofile 'libs.string'
dofile 'libs.table'
dofile 'libs.math'
dofile 'libs.class'

setmetatable(_G, {
  __index = function(_, k)
    error(string.format('attempt to index a unexist global: [ %s ]. %s', k, debug.traceback('', 1)))
  end,
  __newindex = function(_, k, v)
    error(string.format('attempt to write a unexist global: [ %s ]=[ %s ]. %s', k, v, debug.traceback('', 1)))
  end,
})