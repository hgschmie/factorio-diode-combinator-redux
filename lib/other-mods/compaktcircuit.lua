--------------------------------------------------------------------------------
-- CompactCircuit (https://mods.factorio.com/mod/compaktcircuit) support
--------------------------------------------------------------------------------

local util = require('util')

local const = require('lib.constants')

local AC_SPRITES = {
    'plus_symbol_sprites',
    'minus_symbol_sprites',
    'multiply_symbol_sprites',
    'divide_symbol_sprites',
    'modulo_symbol_sprites',
    'power_symbol_sprites',
    'left_shift_symbol_sprites',
    'right_shift_symbol_sprites',
    'and_symbol_sprites',
    'or_symbol_sprites',
    'xor_symbol_sprites',
}

---@class dico.CompactCircuitInfo
---@field name string?
---@field index number?
---@field position MapPosition
---@field direction defines.direction
---@field parameters ArithmeticCombinatorParameters

---@param entity LuaEntity
---@return dico.CompactCircuitInfo
local function ccs_get_info(entity)

    local control_behavior = assert(entity.get_or_create_control_behavior()) --[[@as LuaArithmeticCombinatorControlBehavior]]

    return {
        position = entity.position,
        direction = entity.direction,
        parameters = assert(util.copy(control_behavior.parameters)),
    }
end

---@param info dico.CompactCircuitInfo
---@param surface LuaSurface
---@param position MapPosition
---@param force LuaForce
---@return LuaEntity packed_combinator
local function ccs_create_packed_entity(info, surface, position, force)
    local packed_entity = assert(surface.create_entity {
        name = const.dico_name_packed,
        force = force,
        position = position,
        direction = info.direction,
    })

    local control_behavior = assert(packed_entity.get_or_create_control_behavior()) --[[@as LuaArithmeticCombinatorControlBehavior]]
    control_behavior.parameters = util.copy(info.parameters)

    return packed_entity
end

---@param info dico.CompactCircuitInfo
---@param surface LuaSurface
---@param force LuaForce
---@return LuaEntity combinator
local function ccs_create_entity(info, surface, force)
    local entity = assert(surface.create_entity {
        name = const.dico_name,
        force = force,
        position = info.position,
        direction = info.direction,
    })

    local control_behavior = assert(entity.get_or_create_control_behavior()) --[[@as LuaArithmeticCombinatorControlBehavior]]
    control_behavior.parameters = util.copy(info.parameters)

    script.raise_script_built { entity = entity }

    return entity
end

local function ccs_init()
    Framework.ExportedApis.get_info = ccs_get_info
    Framework.ExportedApis.create_packed_entity = ccs_create_packed_entity
    Framework.ExportedApis.create_entity = ccs_create_entity
end

return {
    data_updates = function()
        assert(data.raw)

        local data_util = require('framework.prototypes.data-util')

        local dico_packed = data_util.copy_entity_prototype(data.raw['arithmetic-combinator'][const.dico_name],
            const.dico_name_packed, true) --[[@as data.ArithmeticCombinatorPrototype ]]

        -- ArithmeticCombinatorPrototype
        for _, field in pairs(AC_SPRITES) do
            dico_packed[field] = util.empty_sprite()
        end

        dico_packed.flags = {
            'placeable-off-grid',
            'not-repairable',
            'not-on-map',
            'not-deconstructable',
            'not-blueprintable',
            'hide-alt-info',
            'not-flammable',
            'not-upgradable',
            'not-in-kill-statistics',
            'not-in-made-in',
        }

        data:extend { dico_packed }
    end,
    runtime = function()
        assert(script)

        local Event = require('stdlib.event.event')

        Event.on_init(ccs_init)
        Event.on_load(ccs_init)
    end,
}
