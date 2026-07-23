------------------------------------------------------------------------
-- data phase 1
------------------------------------------------------------------------

This, Framework = require('lib.init')()

require('prototypes.entities')
require('prototypes.misc')

---@diagnostic disable-next-line: undefined-field
Framework.post_data_stage()
