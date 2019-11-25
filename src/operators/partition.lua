local Observable = require 'observable'

--- Returns two Observables: one that produces values for which the predicate returns truthy for,
--- and another that produces values for which the predicate returns falsy.
--- @generic T
--- @param predicate fun(value :T):boolean The predicate used to partition the values.
--- @return Observable, Observable
function Observable:partition(predicate)
  return self:filter(predicate), self:reject(predicate)
end
