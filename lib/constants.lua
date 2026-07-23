------------------------------------------------------------------------
-- mod constant definitions.
--
-- can be loaded into scripts and data
------------------------------------------------------------------------

local table = require('stdlib.utils.table')

------------------------------------------------------------------------
-- globals
------------------------------------------------------------------------

---@class dico.Constants
local Constants = {
    prefix = 'hps__dc-',
    name = 'diode-combinator-redux',
    root = '__diode-combinator-redux__',
    order = 'c[combinators]-cd[diode-combinator-redux]',
}

Constants.gfx_location = Constants.root .. '/graphics/'

--------------------------------------------------------------------------------
-- Path and name helpers
--------------------------------------------------------------------------------

---@param value string
---@return string result
function Constants:with_prefix(value)
    return self.prefix .. value
end

---@param path string
---@return string result
function Constants:png(path)
    return self.gfx_location .. path .. '.png'
end

---@param id string
---@return string result
function Constants:locale(id)
    return Constants:with_prefix('gui.') .. id
end

------------------------------------------------------------------------
-- constants and names
------------------------------------------------------------------------

-- Base name
Constants.dico_name = 'signal-diode-combinator' -- Constants:with_prefix(Constants.name)

-- Compactcircuits support
Constants.dico_name_packed = Constants.dico_name .. '-packed'

------------------------------------------------------------------------
return Constants
