local Observable = require 'observable'
local util = require 'util'

--- Returns a new Observable that produces the values produced by all the specified Observables in
--- the order they are specified.
--- @param other Observable The Observable to concatenate.
--- @vararg Observable The Observables to concatenate.
--- @return Observable
--- @overload fun(other: Observable):Observable
function Observable:concat(other, ...)
  if not other then return self end

  local others = {...}

  return Observable.create(function(observer)
    local function onNext(...)
      return observer:onNext(...)
    end

    local function onError(message)
      return observer:onError(message)
    end

    local function onCompleted()
      return observer:onCompleted()
    end

    local function chain()
      return other:concat(util.unpack(others)):subscribe(onNext, onError, onCompleted)
    end

    return self:subscribe(onNext, onError, chain)
  end)
end
