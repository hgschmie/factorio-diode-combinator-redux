------------------------------------------------------------------------
-- runtime code
------------------------------------------------------------------------

This, Framework = require('lib.init')()

assert(script)

local Event = require('stdlib.event.event')
local Player = require('stdlib.event.player')

local Matchers = require('framework.matchers')


local const = require('lib.constants')

--------------------------------------------------------------------------------
-- entity create / delete
--------------------------------------------------------------------------------

---@param event EventData.on_built_entity | EventData.on_robot_built_entity | EventData.on_space_platform_built_entity | EventData.script_raised_revive | EventData.script_raised_built
local function on_entity_created(event)
    local entity = event and event.entity
    if not (entity and entity.valid) then return end

    This.DiCo:create(entity)
end

---@param event EventData.on_player_mined_entity | EventData.on_robot_mined_entity | EventData.on_space_platform_mined_entity | EventData.script_raised_destroy
local function on_entity_deleted(event)
    local entity = event and event.entity
    if not (entity and entity.valid) then return end

    Framework.gui_manager:destroyGuiByEntityId(entity.unit_number)
end

--------------------------------------------------------------------------------
-- event registration and management
--------------------------------------------------------------------------------

local function register_events()
    local match_all_main_entities = Matchers:matchEventEntityName {
        const.dico_name,
        const.dico_name_packed,
    }

    local match_main_entity = Matchers:matchEventEntityName(const.dico_name)

    -- entity create / delete
    Event.register(Matchers.CREATION_EVENTS, on_entity_created, match_all_main_entities)
    Event.register(Matchers.DELETION_EVENTS, on_entity_deleted, match_all_main_entities)
    
    -- Configuration changes (startup)
    -- Event.on_configuration_changed(on_configuration_changed)

    -- Entity cloning
    -- Event.register(defines.events.on_entity_cloned, on_entity_cloned, match_main_entity)

    -- Entity settings pasting
    -- Event.register(defines.events.on_entity_settings_pasted, on_entity_settings_pasted, match_main_entity)

end
--------------------------------------------------------------------------------
-- mod init/load code
--------------------------------------------------------------------------------

local function on_init()
    This:init()
    register_events()
end

local function on_load()
    register_events()
end

-- setup player management
Player.register_events(true)

Event.on_init(on_init)
Event.on_load(on_load)

---@diagnostic disable-next-line: undefined-field
Framework.post_runtime_stage()
