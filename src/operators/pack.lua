local Observable = require 'observable'
local util = require 'util'

--- Returns an Observable that produces the values of the original inside tables.
--- @return Observable
function Observable:pack()
  return self:map(util.pack)
end
