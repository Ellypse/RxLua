local Observable = require 'observable'
local util = require 'util'

--- Returns a new Observable that transform the items emitted by an Observable into Observables,
--- then flatten the emissions from those into a single Observable
--- @generic T
--- @param callback fun(value: T):Observable The function to transform values from the original Observable.
--- @return Observable
function Observable:flatMap(callback)
  callback = callback or util.identity
  return self:map(callback):flatten()
end
