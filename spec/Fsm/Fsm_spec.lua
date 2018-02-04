describe("Fsm", function()

  local mock = require 'mach'

  local Fsm = require 'Fsm.Fsm'
  local state1 = mock.mock_function('state 1')

  it("should call initial state method on initialization", function()
    state1:should_be_called():when(function() Fsm.init(state1) end)
  end)
end)
