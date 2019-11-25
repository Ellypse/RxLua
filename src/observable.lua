local util = require 'util'

--- @class Observable
--- @description Observables push values to Observers.
local Observable = {}
Observable.__index = Observable
Observable.__tostring = util.constant('Observable')

--- Creates a new Observable.
--- @param subscribe fun(observer: Observer):void The subscription function that produces values.
--- @return Observable
function Observable.create(subscribe)
  local self = {
    _subscribe = subscribe
  }

  return setmetatable(self, Observable)
end

--- Shorthand for creating an Observer and passing it to this Observable's subscription function.
--- @generic T
--- @param onNext onNextCallback Called when the Observable produces a value.
--- @param onError onErrorCallback Called when the Observable terminates due to an error.
--- @param onCompleted onCompletedCallback Called when the Observable completes normally.
--- @return Subscription
--- @overload fun(onNext: onNextCallback, onError: onErrorCallback):Subscription
--- @overload fun(onNext: onNextCallback)
--- @overload fun(observer: Observer):Subscription
--- @overload fun():Subscription
function Observable:subscribe(onNext, onError, onCompleted)
  if type(onNext) == 'table' then
    return self._subscribe(onNext)
  else
    return self._subscribe(Observer.create(onNext, onError, onCompleted))
  end
end

--- @return Observable An Observable that immediately completes without producing a value.
function Observable.empty()
  return Observable.create(function(observer)
    observer:onCompleted()
  end)
end

--- @return Observable An Observable that never produces values and never completes.
function Observable.never()
  return Observable.create(function(observer) end)
end

--- @param message string
--- @return Observable An Observable that immediately produces an error.
function Observable.throw(message)
  return Observable.create(function(observer)
    observer:onError(message)
  end)
end

--- Creates an Observable that produces a set of values.
--- @generic T
--- @vararg T
--- @return Observable
function Observable.of(...)
  local args = {...}
  local argCount = select('#', ...)
  return Observable.create(function(observer)
    for i = 1, argCount do
      observer:onNext(args[i])
    end

    observer:onCompleted()
  end)
end

--- Creates an Observable that produces a range of values in a manner similar to a Lua for loop.
--- @param initial number The first value of the range, or the upper limit if no other arguments are specified.
--- @param limit number The second value of the range.
--- @param step number An amount to increment the value by each iteration.
--- @return Observable
function Observable.fromRange(initial, limit, step)
  if not limit and not step then
    initial, limit = 1, initial
  end

  step = step or 1

  return Observable.create(function(observer)
    for i = initial, limit, step do
      observer:onNext(i)
    end

    observer:onCompleted()
  end)
end

--- Creates an Observable that produces values from a table.
--- @generic T
--- @param t T[] The table used to create the Observable.
--- @param iterator fun():T Iterator used to iterate the table, e.g. pairs or ipairs.
--- @param keys boolean Whether or not to also emit the keys of the table.
--- @return Observable
function Observable.fromTable(t, iterator, keys)
  iterator = iterator or pairs
  return Observable.create(function(observer)
    for key, value in iterator(t) do
      observer:onNext(value, keys and key or nil)
    end

    observer:onCompleted()
  end)
end

--- Creates an Observable that produces values when the specified coroutine yields.
--- @param fn thread A coroutine or function to use to generate values.  Note that if a coroutine is used, the values it yields will be shared by all subscribed Observers (influenced by the Scheduler), whereas a new coroutine will be created for each Observer when a function is used.
--- @param scheduler Scheduler
--- @return Observable
function Observable.fromCoroutine(fn, scheduler)
  return Observable.create(function(observer)
    local thread = type(fn) == 'function' and coroutine.create(fn) or fn
    return scheduler:schedule(function()
      while not observer.stopped do
        local success, value = coroutine.resume(thread)

        if success then
          observer:onNext(value)
        else
          return observer:onError(value)
        end

        if coroutine.status(thread) == 'dead' then
          return observer:onCompleted()
        end

        coroutine.yield()
      end
    end)
  end)
end

--- Creates an Observable that produces values from a file, line by line.
--- @param filename string The name of the file used to create the Observable
--- @return Observable
function Observable.fromFileByLine(filename)
  return Observable.create(function(observer)
    local file = io.open(filename, 'r')
    if file then
      file:close()

      for line in io.lines(filename) do
        observer:onNext(line)
      end

      return observer:onCompleted()
    else
      return observer:onError(filename)
    end
  end)
end

--- Creates an Observable that creates a new Observable for each observer using a factory function.
--- @param fn fun():Observable A function that returns an Observable.
--- @return Observable
function Observable.defer(fn)
  if not fn or type(fn) ~= 'function' then
    error('Expected a function')
  end

  return setmetatable({
    subscribe = function(_, ...)
      local observable = fn()
      return observable:subscribe(...)
    end
  }, Observable)
end

--- Returns an Observable that repeats a value a specified number of times.
--- @generic T
--- @param value T The value to repeat.
--- @param count number The number of times to repeat the value.  If left unspecified, the value is repeated an infinite number of times.
--- @return Observable
function Observable.replicate(value, count)
  return Observable.create(function(observer)
    while count == nil or count > 0 do
      observer:onNext(value)
      if count then
        count = count - 1
      end
    end
    observer:onCompleted()
  end)
end

--- Subscribes to this Observable and prints values it produces.
--- @param name string Prefixes the printed messages with a name.
--- @param formatter fun(values):string A function that formats one or more values to be printed.
--- @overload fun(name: string):Subscription
--- @overload fun():Subscription
function Observable:dump(name, formatter)
  name = name and (name .. ' ') or ''
  formatter = formatter or tostring

  local onNext = function(...) print(name .. 'onNext: ' .. formatter(...)) end
  local onError = function(e) print(name .. 'onError: ' .. e) end
  local onCompleted = function() print(name .. 'onCompleted') end

  return self:subscribe(onNext, onError, onCompleted)
end

--- Can be inserted in an observable chain to debug the chain.
--- @param name string Prefixes the printed messages with a name.
--- @param formatter fun(values):string A function that formats one or more values to be printed.
--- @return Observable
--- @overload fun(name: string):Observable
--- @overload fun():Observable
function Observable:debug(name, formatter)
  self:dump(name, formatter)
  return self
end

return Observable
