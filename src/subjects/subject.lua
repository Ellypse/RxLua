local Observable = require 'observable'
local Observer = require 'observer'
local Subscription = require 'subscription'
local util = require 'util'

--- @class Subject: Observable
--- @description Subjects function both as an Observer and as an Observable. Subjects inherit all
--- Observable functions, including subscribe. Values can also be pushed to the Subject, which will
--- be broadcasted to any subscribed Observers.
local Subject = setmetatable({}, Observable)
Subject.__index = Subject
Subject.__tostring = util.constant('Subject')

--- Creates a new Subject.
--- @return Subject
function Subject.create()
  local self = {
    observers = {},
    stopped = false
  }

  return setmetatable(self, Subject)
end

--- Creates a new Observer and attaches it to the Subject.
--- @generic T
--- @param onNext onNextCallback A function called when the Subject produces a value or an existing Observer to attach to the Subject.
--- @param onError onErrorCallback Called when the Subject terminates due to an error.
--- @param onCompleted onCompletedCallback Called when the Subject completes normally.
--- @return Subscription
--- @overload fun(onNext: onNextCallback, onError: onErrorCallback):Subscription
--- @overload fun(onNext: onNextCallback):Subscription
--- @overload fun(observer: Observer):Subscription
--- @overload fun():Subscription
function Subject:subscribe(onNext, onError, onCompleted)
  local observer

  if util.isa(onNext, Observer) then
    observer = onNext
  else
    observer = Observer.create(onNext, onError, onCompleted)
  end

  table.insert(self.observers, observer)

  return Subscription.create(function()
    for i = 1, #self.observers do
      if self.observers[i] == observer then
        table.remove(self.observers, i)
        return
      end
    end
  end)
end

--- Pushes zero or more values to the Subject. They will be broadcasted to all Observers.
--- @generic T
--- @vararg T
function Subject:onNext(...)
  if not self.stopped then
    for i = #self.observers, 1, -1 do
      self.observers[i]:onNext(...)
    end
  end
end

--- Signal to all Observers that an error has occurred.
--- @param message string A string describing what went wrong.
function Subject:onError(message)
  if not self.stopped then
    for i = #self.observers, 1, -1 do
      self.observers[i]:onError(message)
    end

    self.stopped = true
  end
end

--- Signal to all Observers that the Subject will not produce any more values.
function Subject:onCompleted()
  if not self.stopped then
    for i = #self.observers, 1, -1 do
      self.observers[i]:onCompleted()
    end

    self.stopped = true
  end
end

Subject.__call = Subject.onNext

return Subject
