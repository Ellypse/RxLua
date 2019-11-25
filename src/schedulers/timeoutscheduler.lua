local Subscription = require 'subscription'

--- @class TimeoutScheduler
--- @description A scheduler that uses luvit's timer library to schedule events on an event loop.
local TimeoutScheduler = {}
TimeoutScheduler.__index = TimeoutScheduler
TimeoutScheduler.__tostring = util.constant('TimeoutScheduler')

--- Creates a new TimeoutScheduler.
--- @return TimeoutScheduler
function TimeoutScheduler.create()
  return setmetatable({}, TimeoutScheduler)
end

--- Schedules an action to run at a future point in time.
--- @param action fun():void The action to run.
--- @arg delay number The delay, in milliseconds.
--- @return Subscription
function TimeoutScheduler:schedule(action, delay, ...)
  local timer = require 'timer'
  local subscription
  local handle = timer.setTimeout(delay, action, ...)
  return Subscription.create(function()
    timer.clearTimeout(handle)
  end)
end

return TimeoutScheduler
