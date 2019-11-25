local Observable = require 'observable'
local util = require 'util'

--- Returns an Observable that intercepts any errors from the previous and replace them with values
--- produced by a new Observable.
--- @param handler fun(error: string):Observable - An Observable or a function that returns an Observable to replace the source Observable in the event of an error.
--- @return Observable
--- @overload fun(handler: Observable):Observable
function Observable:catch(handler)
  handler = handler and (type(handler) == 'function' and handler or util.constant(handler))

  return Observable.create(function(observer)
    local subscription

    local function onNext(...)
      return observer:onNext(...)
    end

    local function onError(e)
      if not handler then
        return observer:onCompleted()
      end

      local success, _continue = pcall(handler, e)
      if success and _continue then
        if subscription then subscription:unsubscribe() end
        _continue:subscribe(observer)
      else
        observer:onError(success and e or _continue)
      end
    end

    local function onCompleted()
      observer:onCompleted()
    end

    subscription = self:subscribe(onNext, onError, onCompleted)
    return subscription
  end)
end
