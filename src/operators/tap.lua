local Observable = require 'observable'
local util = require 'util'

--- Runs a function each time this Observable has activity. Similar to subscribe but does not
--- create a subscription.
--- @param onNext onNextCallback Run when the Observable produces values.
--- @param onError onErrorCallback Run when the Observable encounters a problem.
--- @param onCompleted onCompletedCallback Run when the Observable completes.
--- @return Observable
--- @overload fun(onNext: onNextCallback, onError: onErrorCallback):Observable
--- @overload fun(onNext: onNextCallback):Observable
--- @overload fun():Observable
function Observable:tap(onNext, onError, onCompleted)
  onNext = onNext or util.noop
  onError = onError or util.noop
  onCompleted = onCompleted or util.noop

  return Observable.create(function(observer)
    local function onNext(...)
      util.tryWithObserver(observer, function(...)
        onNext(...)
      end, ...)

      return observer:onNext(...)
    end

    local function onError(message)
      util.tryWithObserver(observer, function()
        onError(message)
      end)

      return observer:onError(message)
    end

    local function onCompleted()
      util.tryWithObserver(observer, function()
        onCompleted()
      end)

      return observer:onCompleted()
    end

    return self:subscribe(onNext, onError, onCompleted)
  end)
end
