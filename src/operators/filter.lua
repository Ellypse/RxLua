local Observable = require 'observable'
local util = require 'util'

--- Returns a new Observable that only produces values of the first that satisfy a predicate.
--- @generic T
--- @param predicate Predicate The predicate used to filter values.
--- @return Observable
function Observable:filter(predicate)
  predicate = predicate or util.identity

  return Observable.create(function(observer)
    local function onNext(...)
      util.tryWithObserver(observer, function(...)
        if predicate(...) then
          return observer:onNext(...)
        end
      end, ...)
    end

    local function onError(e)
      return observer:onError(e)
    end

    local function onCompleted()
      return observer:onCompleted()
    end

    return self:subscribe(onNext, onError, onCompleted)
  end)
end
