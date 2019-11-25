local Subject = require 'subjects/subject'
local Observer = require 'observer'
local util = require 'util'

--- @class ReplaySubject: Subject
--- @description A Subject that provides new Subscribers with some or all of the most recently
--- produced values upon subscription.
local ReplaySubject = setmetatable({}, Subject)
ReplaySubject.__index = ReplaySubject
ReplaySubject.__tostring = util.constant('ReplaySubject')

--- Creates a new ReplaySubject.
--- @param bufferSize number The number of values to send to new subscribers. If nil, an infinite buffer is used (note that this could lead to memory issues).
--- @return ReplaySubject
function ReplaySubject.create(bufferSize)
  local self = {
    observers = {},
    stopped = false,
    buffer = {},
    bufferSize = bufferSize
  }

  return setmetatable(self, ReplaySubject)
end

--- Creates a new Observer and attaches it to the ReplaySubject. Immediately broadcasts the most
--- contents of the buffer to the Observer.
--- @generic T
--- @param onNext onNextCallback Called when the ReplaySubject produces a value.
--- @param onError onErrorCallback Called when the ReplaySubject terminates due to an error.
--- @param onCompleted onCompletedCallback Called when the ReplaySubject completes normally.
--- @return Subscription
--- @overload fun(onNext: onNextCallback, onError: onErrorCallback):Subscription
--- @overload fun(onNext: onNextCallback):Subscription
--- @overload fun(observer: Observer):Subscription
--- @overload fun():Subscription
function ReplaySubject:subscribe(onNext, onError, onCompleted)
  local observer

  if util.isa(onNext, Observer) then
    observer = onNext
  else
    observer = Observer.create(onNext, onError, onCompleted)
  end

  local subscription = Subject.subscribe(self, observer)

  for i = 1, #self.buffer do
    observer:onNext(util.unpack(self.buffer[i]))
  end

  return subscription
end

--- Pushes zero or more values to the ReplaySubject. They will be broadcasted to all Observers.
--- @generic T
--- @vararg T
function ReplaySubject:onNext(...)
  table.insert(self.buffer, util.pack(...))
  if self.bufferSize and #self.buffer > self.bufferSize then
    table.remove(self.buffer, 1)
  end

  return Subject.onNext(self, ...)
end

---@return Observable
function ReplaySubject:asObservable()
  return Observable.create(function(observer)
    self:subscribe(
      function(...) observer:onNext(...) end,
      function(... ) observer:onError(...) end,
      function() observer:onCompleted() end
    )
  end)
end

ReplaySubject.__call = ReplaySubject.onNext

return ReplaySubject
