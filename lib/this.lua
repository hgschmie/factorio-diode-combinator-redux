----------------------------------------------------------------------------------------------------
--- Initialize this mod's globals
----------------------------------------------------------------------------------------------------

local const = require('lib.constants')

---@class dico.Mod
---@field other_mods table<string, string>
---@field DiCo dico.DiCo
---@field Gui dico.Gui
local This = {
    other_mods = {
        compaktcircuit = 'compaktcircuit',
    },
    remote_apis = {
        PickerDollies = 'picker_dollies',
        compaktcircuit = 'compaktcircuit',
    },
}

if script then
    This.DiCo = require('scripts.dico')
    This.Gui = require('scripts.gui')
end

--------------------------------------------------------------------------------
-- Framework intializer
--------------------------------------------------------------------------------

---@return FrameworkConfig config
function This.framework_init()
    return {
        -- prefix is the internal mod prefix
        prefix = const.prefix,
        -- name is a human readable name
        name = const.name,
        -- The filesystem root.
        root = const.root,
        -- Remote interface name
        exported_api_name = const.dico_name,
    }
end

function This:init()
end

return This
