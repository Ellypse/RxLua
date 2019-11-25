local Observable = require 'observable'

--- Returns a new Observable that skips over a specified number of values produced by the original
--- and produces the rest.
--- @param n number The number of values to ignore.
--- @return Observable
--- @overload fun():Observable
function Observable:skip(n)
  n = n or 1

  return Observable.create(function(observer)
    local i = 1

    local function onNext(...)
      if i > n then
        observer:onNext(...)
      else
        i = i + 1
      end
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
