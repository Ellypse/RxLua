local Observable = require 'observable'

--- Returns a new Observable that only produces the first result of the original.
--- @return Observable
function Observable:first()
  return self:take(1)
end
