dofile 'bootstrap.lua'
rawset(_G, 'require', raw_require)

local List = import 'utils.list'

describe('test list', function()
  it('new', function()
    local l1 = List()
    assert.equal(l1:size(), 0)

    local l2 = List(1, 2, 3)
    assert.equal(l2:size(), 3)
  end)
end)