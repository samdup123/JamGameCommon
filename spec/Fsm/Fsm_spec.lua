describe("Fsm", function()

  local mock = require 'mach'

  local Fsm = require 'Fsm.Fsm'
  local state1 = mock.mock_function('state 1')
  local state2 = mock.mock_function('state 2')

  it("should call initial state method on initialization", function()
    state1:should_be_called_with('entry'):when(function() Fsm.init(state1) end)
  end)

  it("should be able to switch states", function()
    local fsm
    state1:should_be_called_with('entry'):when(function() fsm = Fsm.init(state1) end)
    state1:should_be_called_with('exit'):and_also(state2:should_be_called_with('entry')):when(function() fsm.transitionTo(state2) end)
  end)

  it("should be able to send a signal", function()
    local fsm
    state1:should_be_called_with('entry'):when(function() fsm = Fsm.init(state1) end)
    state1:should_be_called_with('a signal'):when(function() fsm.sendSignal('a signal') end)
  end)

  it("should be able to transition and then send a signal", function()
    local fsm
    state1:should_be_called_with('entry'):when(function() fsm = Fsm.init(state1) end)
    state1:should_be_called_with('exit'):and_also(state2:should_be_called_with('entry')):when(function() fsm.transitionTo(state2) end)
    state2:should_be_called_with('a signal'):when(function() fsm.sendSignal('a signal') end)
  end)
end)
