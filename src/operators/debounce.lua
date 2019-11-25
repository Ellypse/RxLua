local Observable = require 'observable'
local Subscription = require 'subscription'
local util = require 'util'

--- Returns a new throttled Observable that waits to produce values until a timeout has expired, at
--- which point it produces the latest value from the source Observable.  Whenever the source
--- Observable produces a value, the timeout is reset.
--- @param time number An amount in milliseconds to wait before producing the last value.
--- @param scheduler Scheduler The scheduler to run the Observable on.
--- @return Observable
function Observable:debounce(time, scheduler)
  time = time or 0

  return Observable.create(function(observer)
    local debounced = {}

    local function wrap(key)
      return function(...)
        local value = util.pack(...)

        if debounced[key] then
          debounced[key]:unsubscribe()
        end

        local values = util.pack(...)

        debounced[key] = scheduler:schedule(function()
          return observer[key](observer, util.unpack(values))
        end, time)
      end
    end

    local subscription = self:subscribe(wrap('onNext'), wrap('onError'), wrap('onCompleted'))

    return Subscription.create(function()
      if subscription then subscription:unsubscribe() end
      for _, timeout in pairs(debounced) do
        timeout:unsubscribe()
      end
    end)
  end)
end
