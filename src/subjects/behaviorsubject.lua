local Subject = require 'subjects/subject'
local Observer = require 'observer'
local util = require 'util'

--- @class BehaviorSubject: Subject
--- @description A Subject that tracks its current value. Provides an accessor to retrieve the most
--- recent pushed value, and all subscribers immediately receive the latest value.
local BehaviorSubject = setmetatable({}, Subject)
BehaviorSubject.__index = BehaviorSubject
BehaviorSubject.__tostring = util.constant('BehaviorSubject')

--- Creates a new BehaviorSubject.
--- @generic T
--- @vararg T The initial values.
--- @return BehaviorSubject
function BehaviorSubject.create(...)
  local self = {
    observers = {},
    stopped = false
  }

  if select('#', ...) > 0 then
    self.value = util.pack(...)
  end

  return setmetatable(self, BehaviorSubject)
end

--- Creates a new Observer and attaches it to the BehaviorSubject. Immediately broadcasts the most
--- recent value to the Observer.
--- @generic T
--- @param onNext onNextCallback Called when the BehaviorSubject produces a value.
--- @param onError onErrorCallback Called when the BehaviorSubject terminates due to an error.
--- @param onCompleted onCompletedCallback Called when the BehaviorSubject completes normally.
--- @overload fun(onNext: onNextCallback, onError: onErrorCallback):Subscription
--- @overload fun(onNext: onNextCallback):Subscription
--- @overload fun(observer: Observer):Subscription
--- @return Subscription
function BehaviorSubject:subscribe(onNext, onError, onCompleted)
  local observer

  if util.isa(onNext, Observer) then
    observer = onNext
  else
    observer = Observer.create(onNext, onError, onCompleted)
  end

  local subscription = Subject.subscribe(self, observer)

  if self.value then
    observer:onNext(util.unpack(self.value))
  end

  return subscription
end

--- Pushes zero or more values to the BehaviorSubject. They will be broadcasted to all Observers.
--- @generic T
--- @vararg T
function BehaviorSubject:onNext(...)
  self.value = util.pack(...)
  return Subject.onNext(self, ...)
end

--- Returns the last value emitted by the BehaviorSubject, or the initial value passed to the
--- constructor if nothing has been emitted yet.
--- @generic T
--- @return T
function BehaviorSubject:getValue()
  if self.value ~= nil then
    return util.unpack(self.value)
  end
end

---@return Observable
function BehaviorSubject:asObservable()
  return Observable.create(function(observer)
    self:subscribe(
      function(...) observer:onNext(...) end,
      function(... ) observer:onError(...) end,
      function() observer:onCompleted() end
    )
  end)
end

BehaviorSubject.__call = BehaviorSubject.onNext

return BehaviorSubject
