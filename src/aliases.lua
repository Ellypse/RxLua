local Observable = require 'observable'

Observable.wrap = Observable.buffer
Observable['repeat'] = Observable.replicate

---@generic T
---@alias onNextCallback fun(value: T):void
---@alias onErrorCallback fun(error: string):void
---@alias onCompletedCallback fun():void
---@alias Scheduler {schedule: fun(self: table, action: fun(), delay: number)}
---@alias Time fun():number
---@alias Accumulator fun(value: T):T
---@alias Predicate fun(value: T):boolean
