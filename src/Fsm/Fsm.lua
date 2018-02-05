local currentState

local transitionTo = function(newState)
  currentState('exit')
  currentState = newState
  currentState('entry')
end

local sendSignal = function(signal)
  currentState(signal)
end

local init = function(initialState)
  currentState = initialState
  currentState('entry')
  return {transitionTo = transitionTo, sendSignal = sendSignal}
end

return {init = init}
