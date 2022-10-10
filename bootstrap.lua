require 'libs.type'
require 'libs.ensure'
require 'libs.function'
require 'libs.string'
require 'libs.table'
require 'libs.math'
require 'libs.class'
require 'libs.sandbox'

setmetatable(_G, {
  __index = function(_, k)
    error(string.format('attempt to index a unexist global: [ %s ]', k))
  end,
  __newindex = function(_, k, v)
    error(string.format('attempt to write a unexist global: [ %s ]=[ %s ]', k, v))
  end,
})