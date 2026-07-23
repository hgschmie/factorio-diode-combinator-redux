--------------------------------------------------------------------------------
-- Even Pickier Dollies (https://mods.factorio.com/mod/even-pickier-dollies) support
--------------------------------------------------------------------------------

local const = require('lib.constants')

local function picker_dollies_init()
    if remote.interfaces['PickerDollies']['add_oblong_name'] then
        remote.call('PickerDollies', 'add_oblong_name', const.dico_name)
    end
end

return {
    on_init = picker_dollies_init,
    on_load = picker_dollies_init,
}
