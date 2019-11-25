local util = require 'util'

--- @class Observer
--- @generic T
--- @description Observers are simple objects that receive values from Observables.
local Observer = {}
Observer.__index = Observer
Observer.__tostring = util.constant('Observer')

--- Creates a new Observer.
--- @generic T
--- @param onNext onNextCallback void Called when the Observable produces a value.
--- @param onError onErrorCallback void Called when the Observable terminates due to an error.
--- @param onCompleted onCompletedCallback void Called when the Observable completes normally.
--- @return Observer
--- @overload fun(onNext: onNextCallback, onError: onErrorCallback)
--- @overload fun(onNext: onNextCallback)
--- @overload fun():Observer
function Observer.create(onNext, onError, onCompleted)
  local self = {
    _onNext = onNext or util.noop,
    _onError = onError or error,
    _onCompleted = onCompleted or util.noop,
    stopped = false
  }

  return setmetatable(self, Observer)
end

--- Pushes zero or more values to the Observer.
--- @generic T
--- @vararg T
function Observer:onNext(...)
  if not self.stopped then
    self._onNext(...)
  end
end

--- Notify the Observer that an error has occurred.
--- @param message string A string describing what went wrong.
function Observer:onError(message)
  if not self.stopped then
    self.stopped = true
    self._onError(message)
  end
end

--- Notify the Observer that the sequence has completed and will produce no more values.
function Observer:onCompleted()
  if not self.stopped then
    self.stopped = true
    self._onCompleted()
  end
end

return Observer
