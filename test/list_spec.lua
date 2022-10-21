dofile 'bootstrap.lua'
rawset(_G, 'require', raw_require)

local List = import 'utils.list'

describe('test list', function()
  it('new', function()
    local l1 = List()
    assert.equal(0, l1:size())

    local l2 = List(1, 2, 3)
    assert.equal(3, l2:size())
  end)
  it('pool', function()
    local l1 = List.Pool.get()
    assert.equal(0, l1:size())
    l1:insert(1)
    assert.equal(1, l1:size())
    List.Pool.free(l1)

    local l2 = List.Pool.get()
    assert.equal(l1, l2)
    assert.equal(0, l2:size())
    List.Pool.free(l2)

    local l3 = List.Pool.get(1, 2, 3, 4)
    assert.equal(l2, l3)
    assert.equal(4, l3:size())
    assert.equal(2, l3:at(2))
  end)
  it('iter', function()
    local l = List(1, 2, 3, 4)
    local i = 1
    for v in l:loopv() do
      assert.equal(i, v)
      i = i+1
    end

    local tbl = {'a', 'b', 'c', 'd'}
    local l = List():copyarray(tbl, 2)
    assert.equal(3, l:size())
    local i = 1
    for k, v in l:loop() do
      assert.equal(i, k)
      assert.equal(tbl[i+1], v)
      i = i+1
    end

    local l2 = List():copy(l)
    assert.equal(l:size(), l2:size())
  end)
  it('remove', function()
    local l = List(1, 2, 3, 4, 5)
    l:remove(2)
    assert.equal(4, l:size())
    assert.equal(5, l:at(2))
    l:remove(1, true)
    assert.equal(5, l:head())
    assert.equal(4, l:tail())
  end)
end)