dofile 'bootstrap.lua'
rawset(_G, 'require', raw_require)

describe('test class', function()
  it('test class name', function()
    local c_a = class {
      __cname = 'test class'
    }
    local obj = c_a()
    assert.not_nil(c_a.__cname)
    assert.equal(c_a.__cname, 'test class')
    assert.equal(obj.__class, c_a)
  end)
  it('test property', function()
    local c_a = class {}
    property(c_a, 'money')
    assert.not_nil(c_a.getMoney)
    assert.not_nil(c_a.setMoney)

    property(c_a, 'food', false)
    assert.is_nil(c_a.getFood)
    assert.not_nil(c_a.setFood)

    local obj = c_a()
    obj:setMoney(100)
    assert.equal(obj:getMoney(), 100)
  end)
  it('test pool', function()
    local c_a = classpool {}
    local obj_1 = c_a.Pool.get()
    local obj_2 = c_a.Pool.get()
    assert.not_equal(obj_1, obj_2)
    c_a.Pool.free(obj_1)
    local obj_3 = c_a.Pool.get()
    assert.equal(obj_1, obj_3)
  end)
end)