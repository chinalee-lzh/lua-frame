dofile 'bootstrap.lua'
rawset(_G, 'require', raw_require)

describe('test string', function()
  local s = spy.on(string, 'at')

  assert.truthy(string.empty())
  assert.truthy(string.empty(''))

  assert.equal(string.at('hello', 2), 'e')
  assert.equal(string.at('hello', 6), '')
  assert.equal(string.at('hello', -1), 'o')
  assert.equal(string.at('hello', -5), 'h')
  assert.equal(string.at('hello', -6), '')

  assert.equal(string.replace('hello', 3, 'b'), 'heblo')

  assert.spy(s).was.called()
  assert.spy(s).was.called.with('hello', 3)
end)