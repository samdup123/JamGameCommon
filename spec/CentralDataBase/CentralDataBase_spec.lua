describe('CentralDataBase', function()

  local mock = require 'mach'

  local CentralDataBase = require '../../src/CentralDataBase/CentralDataBase'

  local shouldFailWith = function(expectedMessage, test)
    local result, actualMessage = pcall(test)
    _, _, actualMessage = actualMessage:find(":%w+: (.+)")
    if result then
      error('expected failure did not happen')
    else
      assert.are.same(actualMessage, expectedMessage)
    end
  end

  local shouldNotFail = function(test)
    if not pcall(test) then error('unexpected failure happened') end
  end

  local nothingShouldHappenWhen = function(thisCodeIsExecuted)
    thisCodeIsExecuted()
  end

  local resource1 = {defaultData = 2, tag = 'resource1'}
  local resource2 = {defaultData = 'word', tag = 'resource2'}

  local callback = mock.mock_function('callback')
  local callback1 = mock.mock_function('callback1')
  local callback2 = mock.mock_function('callback2')

  it('should not initialize with repeat data tags', function()
    shouldFailWith('tags repeated', function() CentralDataBase.init({resource1, resource1}) end)
  end)

  it('should be able to initialize', function()
    shouldNotFail(function() CentralDataBase.init({resource1, resource2}) end)
  end)

  it('should allow client to write to a resource and read from it', function()
    local db = CentralDataBase.init({resource1})
    assert.are.same(db.read('resource1'), 2)
    db.write('new data', 'resource1')
    assert.are.same(db.read('resource1'), 'new data')
  end)

  it('should allow client to write to multiple resources and read from them', function()
    local db = CentralDataBase.init({resource1, resource2})
    assert.are.same(db.read('resource1'), 2)
    assert.are.same(db.read('resource2'), 'word')

    db.write('new data', 'resource1')
    assert.are.same(db.read('resource1'), 'new data')

    db.write('blah', 'resource2')
    assert.are.same(db.read('resource2'), 'blah')
  end)

  it('should be able to have subscriptions to a system data change', function()
    local db = CentralDataBase.init({resource1})
    db.subscribe('resource1', callback)

    callback:should_be_called_with('blah'):when(function() db.write('blah', 'resource1') end)
  end)

  it('should be able to have multiple subscribptions to a system data change', function()
    local db = CentralDataBase.init({resource1})
    db.subscribe('resource1', callback1)
    db.subscribe('resource1', callback2)

    callback1:should_be_called_with('blah'):and_also(callback2:should_be_called_with('blah'))
    :when(function() db.write('blah', 'resource1') end)
  end)

  it('should be able to have a subscription removed', function()
    local db = CentralDataBase.init({resource1})
    db.subscribe('resource1', callback)
    db.unsubscribe('resource1', callback)

    nothingShouldHappenWhen(function() db.write('blah', 'resource1') end)
  end)

  it('should be able to have a subscription removed after many subscriptions', function()
    local db = CentralDataBase.init({resource1})
    db.subscribe('resource1', callback)
    for i = 1, 3 do
      db.subscribe('resource1', function() end)
    end
    db.unsubscribe('resource1', callback)

    nothingShouldHappenWhen(function() db.write('blah', 'resource1') end)
  end)

  it('should be able to have subscriptions to a system data change when there are multiple resources', function()
    local db = CentralDataBase.init({resource1, resource2})
    db.subscribe('resource1', callback1)
    db.subscribe('resource2', callback2)

    callback1:should_be_called_with('blah'):when(function() db.write('blah', 'resource1') end)
    callback2:should_be_called_with('derp'):when(function() db.write('derp', 'resource2') end)
  end)

  it('should be able to have subscriptions to a system data change when there are multiple resources', function()
    local db = CentralDataBase.init({resource1, resource2})
    db.subscribe('resource1', callback1)
    db.subscribe('resource2', callback2)

    callback1:should_be_called_with('blah'):when(function() db.write('blah', 'resource1') end)
    callback2:should_be_called_with('derp'):when(function() db.write('derp', 'resource2') end)
  end)

  it('should do nothing if a client tries to write to a resource that does not exist', function()
    local db = CentralDataBase.init({resource1})
    nothingShouldHappenWhen(function() db.write('blah', 'resource12') end)
    assert.are.same(nil, db.read('resource12'))
  end)
end)
