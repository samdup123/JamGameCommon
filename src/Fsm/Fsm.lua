
local currentState

return {
  init = function(initialState)
    currentState = initialState
    currentState('entry')
    return {
      transitionTo = function(newState)
        currentState('exit')
        currentState = newState
        currentState('entry')
      end,
      sendSignal = function(signal)
        currentState(signal)
      end
    }
  end
}
