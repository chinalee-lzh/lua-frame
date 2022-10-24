dofile 'bootstrap.lua'
rawset(_G, 'require', raw_require)

describe('test table', function()
  it('test exist', function()
    assert.truthy(table.exist({1,2,3}, 1))
  end)
end)