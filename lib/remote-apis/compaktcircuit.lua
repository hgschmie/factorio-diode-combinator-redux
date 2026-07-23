--------------------------------------------------------------------------------
-- CompactCircuit (https://mods.factorio.com/mod/compaktcircuit) support
--------------------------------------------------------------------------------

local const = require('lib.constants')

local function ccs_init()
    if remote.interfaces['compaktcircuit']['add_combinator'] then
        remote.call('compaktcircuit', 'add_combinator', {
            name = const.dico_name,
            packed_names = { const.dico_name_packed },
            interface_name = const.dico_name,
        })
    end
end

return {
    on_init = ccs_init,
    on_load = ccs_init,
}
