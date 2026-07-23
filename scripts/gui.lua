------------------------------------------------------------------------
-- Diode combinator GUI
------------------------------------------------------------------------
assert(script)

local Event = require('stdlib.event.event')
local Player = require('stdlib.event.player')
local table = require('stdlib.utils.table')

local Matchers = require('framework.matchers')
local tools = require('framework.tools')
local signal_converter = require('framework.signal_converter')

local const = require('lib.constants')

---@class dico.Gui
local Gui = {
    NAME = 'diode-combinator-gui',
}

----------------------------------------------------------------------------------------------------
-- UI definition
----------------------------------------------------------------------------------------------------

--- Provides all the events used by the GUI and their mappings to functions. This must be outside the
--- GUI definition as it can not be serialized into storage.
---@return framework.gui_manager.event_definition
local function get_gui_event_definition()
    return {
        events = {
            onWindowClosed = Gui.onWindowClosed,
            onToggleInvert = Gui.onToggleInvert,
            onEnableSignal = Gui.onEnableSignal,
        },
        callback = Gui.guiUpdater,
    }
end

--- Returns the definition of the GUI. All events must be mapped onto constants from the gui_events array.
---@param gui framework.gui
---@return framework.gui.element_definition ui
function Gui.getUi(gui)
    local gui_events = gui.gui_events

    ---@type dico.GuiContext
    local context = gui.context

    local entity = context.entity
    assert(entity and entity.valid)

    local control_behavior = assert(entity.get_or_create_control_behavior()) --[[@as LuaArithmeticCombinatorControlBehavior]]

    local mode = This.DiCo:getMode(control_behavior.parameters)
    local red = control_behavior.parameters.first_signal_networks.red or false
    local green = control_behavior.parameters.first_signal_networks.green or false

    return {
        type = 'frame',
        name = 'gui_root',
        direction = 'vertical',
        handler = { [defines.events.on_gui_closed] = gui_events.onWindowClosed },
        elem_mods = { auto_center = true },
        children = {
            { -- Title Bar
                type = 'flow',
                style = 'frame_header_flow',
                drag_target = 'gui_root',
                children = {
                    {
                        type = 'label',
                        style = 'frame_title',
                        caption = { 'entity-name.' .. const.dico_name },
                        drag_target = 'gui_root',
                        ignored_by_interaction = true,
                    },
                    {
                        type = 'empty-widget',
                        style = 'framework_titlebar_drag_handle',
                        ignored_by_interaction = true,
                    },
                    {
                        type = 'sprite-button',
                        style = 'frame_action_button',
                        sprite = 'utility/close',
                        hovered_sprite = 'utility/close_black',
                        clicked_sprite = 'utility/close_black',
                        mouse_button_filter = { 'left' },
                        tooltip = { 'gui.close-instruction' },
                        handler = { [defines.events.on_gui_click] = gui_events.onWindowClosed },
                    },
                },
            }, -- Title Bar End
            {  -- Body
                type = 'frame',
                style = 'entity_frame',
                children = {
                    {
                        type = 'flow',
                        style = 'two_module_spacing_vertical_flow',
                        direction = 'vertical',
                        children = {
                            {
                                type = 'frame',
                                direction = 'horizontal',
                                style = 'framework_subheader_frame',
                                children = {
                                    {
                                        type = 'label',
                                        style = 'subheader_caption_label',
                                        caption = { '', { 'gui-arithmetic.input' }, { 'colon' } },
                                    },
                                    {
                                        type = 'label',
                                        style = 'label',
                                        name = 'connections_input',
                                    },
                                    {
                                        type = 'label',
                                        style = 'label',
                                        name = 'combinator_input_red',
                                        visible = false,
                                    },
                                    {
                                        type = 'label',
                                        style = 'label',
                                        name = 'combinator_input_green',
                                        visible = false,
                                    },
                                    {
                                        type = 'empty-widget',
                                        style_mods = { horizontally_stretchable = true },
                                    },
                                    {
                                        type = 'label',
                                        style = 'subheader_caption_label',
                                        caption = { '', { 'gui-arithmetic.output' }, { 'colon' } },
                                    },
                                    {
                                        type = 'label',
                                        style = 'label',
                                        name = 'connections_output',
                                    },
                                    {
                                        type = 'label',
                                        style = 'label',
                                        name = 'combinator_output_red',
                                        visible = false,
                                    },
                                    {
                                        type = 'label',
                                        style = 'label',
                                        name = 'combinator_output_green',
                                        visible = false,
                                    },
                                },
                            },
                            {
                                type = 'flow',
                                style = 'framework_indicator_flow',
                                children = {
                                    {
                                        type = 'sprite',
                                        name = 'status-lamp',
                                        style = 'framework_indicator',
                                    },
                                    {
                                        type = 'label',
                                        style = 'label',
                                        name = 'status-label',
                                    },
                                    {
                                        type = 'empty-widget',
                                        style_mods = { horizontally_stretchable = true },
                                    },
                                    {
                                        type = 'label',
                                        style = 'label',
                                        caption = { const:locale('id'), entity.unit_number },
                                    },
                                },
                            },
                            {
                                type = 'frame',
                                style = 'deep_frame_in_shallow_frame',
                                name = 'preview_frame',
                                children = {
                                    {
                                        type = 'entity-preview',
                                        name = 'preview',
                                        style = 'wide_entity_button',
                                        elem_mods = { entity = entity },
                                    },
                                },
                            },
                            {
                                type = 'flow',
                                direction = 'horizontal',
                                children = {
                                    {
                                        type = 'checkbox',
                                        caption = { 'gui-network-selector.red-label' },
                                        name = 'enable-signals-red',
                                        elem_tags = {
                                            wire_connector_id = 'red',
                                        },
                                        handler = { [defines.events.on_gui_checked_state_changed] = gui_events.onEnableSignal },
                                        state = red,
                                    },
                                    {
                                        type = 'checkbox',
                                        caption = { 'gui-network-selector.green-label' },
                                        name = 'enable-signals-green',
                                        elem_tags = {
                                            wire_connector_id = 'green',
                                        },
                                        handler = { [defines.events.on_gui_checked_state_changed] = gui_events.onEnableSignal },
                                        state = green,
                                    },
                                    {
                                        type = 'empty-widget',
                                        style_mods = { width = 8 },
                                    },
                                    {
                                        type = 'checkbox',
                                        caption = { const:locale('invert') },
                                        name = 'invert',
                                        handler = { [defines.events.on_gui_checked_state_changed] = gui_events.onToggleInvert },
                                        state = (mode == 2), -- 2 == MODE.invert
                                    },
                                },
                            },
                            {
                                type = 'table',
                                column_count = 2,
                                vertical_centering = false,
                                style_mods = {
                                    horizontal_spacing = 24,
                                },
                                children = {
                                    {
                                        type = 'label',
                                        style = 'semibold_label',
                                        caption = { 'description.input-signals' },
                                    },
                                    {
                                        type = 'label',
                                        style = 'semibold_label',
                                        caption = { 'description.output-signals' },
                                    },
                                    {
                                        type = 'scroll-pane',
                                        style = 'deep_slots_scroll_pane',
                                        direction = 'vertical',
                                        name = 'input-view-pane',
                                        visible = true,
                                        vertical_scroll_policy = 'auto-and-reserve-space',
                                        horizontal_scroll_policy = 'never',
                                        style_mods = {
                                            width = 400,
                                        },
                                        children = {
                                            {
                                                type = 'table',
                                                style = 'filter_slot_table',
                                                name = 'input-signal-view',
                                                column_count = 10,
                                                style_mods = {
                                                    vertical_spacing = 4,
                                                },
                                            },
                                        },
                                    },
                                    {
                                        type = 'scroll-pane',
                                        style = 'deep_slots_scroll_pane',
                                        direction = 'vertical',
                                        name = 'output-view-pane',
                                        visible = true,
                                        vertical_scroll_policy = 'auto-and-reserve-space',
                                        horizontal_scroll_policy = 'never',
                                        style_mods = {
                                            width = 400,
                                        },
                                        children = {
                                            {
                                                type = 'table',
                                                style = 'filter_slot_table',
                                                name = 'output-signal-view',
                                                column_count = 10,
                                                style_mods = {
                                                    vertical_spacing = 4,
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
    }
end

----------------------------------------------------------------------------------------------------
-- Input/Output signals
----------------------------------------------------------------------------------------------------

local COLOR_MAP = {
    [defines.wire_connector_id.combinator_input_red] = 'red',
    [defines.wire_connector_id.combinator_input_green] = 'green',
    [defines.wire_connector_id.combinator_output_red] = 'red',
    [defines.wire_connector_id.combinator_output_green] = 'green',
}

---@param gui_element LuaGuiElement?
---@param main LuaEntity
---@param wires defines.wire_connector_id[]
local function render_network_signals(gui_element, main, wires)
    assert(gui_element)
    gui_element.clear()

    for _, connector_id in pairs(wires) do
        local signals = main.get_signals(connector_id)
        if signals then
            local signal_count = 0
            for _, signal in ipairs(signals) do
                local button = gui_element.add {
                    type = 'sprite-button',
                    sprite = signal_converter:signal_to_sprite_name(signal),
                    number = signal.count,
                    quality = signal.signal.quality,
                    style = COLOR_MAP[connector_id] .. '_circuit_network_content_slot',
                    tooltip = signal_converter:signal_to_prototype(signal).localised_name,
                    elem_tooltip = signal_converter:signal_to_elem_id(signal),
                    enabled = true,
                }
                signal_count = signal_count + 1
            end
            while (signal_count % 10) > 0 do
                gui_element.add {
                    type = 'sprite',
                    enabled = true,
                }
                signal_count = signal_count + 1
            end
        end
    end
end

----------------------------------------------------------------------------------------------------
-- UI Callbacks
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- close the UI (button or shortcut key)
----------------------------------------------------------------------------------------------------

--- close the UI (button or shortcut key)
---@param event EventData.on_gui_click|EventData.on_gui_closed
---@param gui framework.gui
function Gui.onWindowClosed(event, gui)
    ---@type dico.GuiContext
    local context = gui.context

    local entity = context.entity
    if not (entity and entity.valid) then return end

    Framework.gui_manager:destroyGui(event.player_index, gui.type)
end

---@param event  EventData.on_gui_checked_state_changed
---@param gui framework.gui
function Gui.onToggleInvert(event, gui)
    ---@type dico.GuiContext
    local context = gui.context
    context.config.mode = event.element.state and 2 or 1
end

---@param event EventData.on_gui_checked_state_changed
---@param gui framework.gui
function Gui.onEnableSignal(event, gui)
    ---@type dico.GuiContext
    local context = gui.context

    local wire_connector_id = event.element.tags and event.element.tags['wire_connector_id']
    if not wire_connector_id then return end

    context.config[wire_connector_id] = event.element.state
end

----------------------------------------------------------------------------------------------------
-- GUI state updater
----------------------------------------------------------------------------------------------------

---@param gui framework.gui
local function update_gui(gui)
    ---@type dico.GuiConfig
    local config = gui.context.config

    local invert = gui:findElement('invert')
    invert.state = config.mode == 2

    local red = gui:findElement('enable-signals-red')
    red.state = config.red or false

    local green = gui:findElement('enable-signals-green')
    green.state = config.green or false
end

---@param gui framework.gui
---@param entity LuaEntity
---@return table<defines.wire_connector_id, boolean> connection_state
local function refresh_gui(gui, entity)
    local entity_status = entity.status

    local lamp = gui:findElement('status-lamp')
    lamp.sprite = tools.STATUS_SPRITES[entity_status]

    local status = gui:findElement('status-label')
    status.caption = { tools.STATUS_NAMES[entity_status] }

    -- render input signals
    local input_signals = gui:findElement('input-signal-view')
    render_network_signals(input_signals, entity, { defines.wire_connector_id.combinator_input_red, defines.wire_connector_id.combinator_input_green })

    -- render output signals
    local output_signals = gui:findElement('output-signal-view')
    render_network_signals(output_signals, entity, { defines.wire_connector_id.combinator_output_red, defines.wire_connector_id.combinator_output_green })

    local connection_state = {}

    -- render network ids for Input/Output network header
    for _, pin in pairs { 'input', 'output' } do
        local connections = gui:findElement('connections_' .. pin)
        connections.caption = { 'gui-control-behavior.not-connected' }
        for _, color in pairs { 'red', 'green' } do
            local pin_name = ('combinator_%s_%s'):format(pin, color)

            local connector_id = defines.wire_connector_id[pin_name]
            local wire_connector = entity.get_wire_connector(connector_id, false)
            local connect = false

            local wire_connection = gui:findElement(pin_name)
            wire_connection.caption = nil

            if wire_connector then
                for _, connection in pairs(wire_connector.connections) do
                    connect = connect or (connection.origin == defines.wire_origin.player)
                    if connect then break end
                end

                connection_state[connector_id] = connect
                wire_connection.visible = connect
                if connect then
                    connections.caption = { 'gui-control-behavior.connected-to-network' }
                    wire_connection.caption = { ('gui-control-behavior.%s-network-id'):format(color), wire_connector.network_id }
                end
            end
        end
    end
    return connection_state
end

----------------------------------------------------------------------------------------------------
-- Event ticker
----------------------------------------------------------------------------------------------------

---@param gui framework.gui
---@return boolean
function Gui.guiUpdater(gui)
    ---@type dico.GuiContext
    local context = gui.context

    local entity = context.entity
    if not (entity and entity.valid) then return false end

    -- always update wire state and preview
    local connection_state = refresh_gui(gui, entity)

    local refresh_config = not (context.last_config and table.compare(context.last_config, context.config))
    local refresh_state = not (context.last_connection_state and table.compare(context.last_connection_state, connection_state))

    if refresh_config or refresh_state then
        update_gui(gui)
    end

    if refresh_config then
        local control_behavior = assert(entity.get_or_create_control_behavior()) --[[@as LuaArithmeticCombinatorControlBehavior]]

        local parameters = assert(util.copy(control_behavior.parameters))
        This.DiCo:setMode(parameters, context.config.mode)

        parameters.first_signal_networks.red = context.config.red or false
        parameters.first_signal_networks.green = context.config.green or false

        control_behavior.parameters = parameters

        context.last_config = tools.copy(context.config)
    end

    if refresh_state then
        context.last_connection_state = connection_state
    end

    return true
end

----------------------------------------------------------------------------------------------------
-- open gui handler
----------------------------------------------------------------------------------------------------

---@class dico.GuiConfig
---@field mode dico.Mode
---@field red boolean?
---@field green boolean?

---@param event EventData.on_gui_opened
function Gui.onGuiOpened(event)
    local player = Player.get(event.player_index)
    if not player then return end

    local entity = event and event.entity --[[@as LuaEntity]]
    if not entity then
        player.opened = nil
        return
    end

    local control_behavior = assert(entity.get_or_create_control_behavior()) --[[@as LuaArithmeticCombinatorControlBehavior]]

    ---@class dico.GuiContext
    ---@field entity LuaEntity
    ---@field config dico.GuiConfig
    ---@field last_config dico.GuiConfig?
    ---@field last_connection_state table<defines.wire_connector_id, boolean>?
    local gui_context = {
        entity = entity,
        config = {
            mode = This.DiCo:getMode(control_behavior.parameters),
            red = control_behavior.parameters.first_signal_networks.red or false,
            green = control_behavior.parameters.first_signal_networks.green or false,
        },
    }

    local gui = Framework.gui_manager:createGui {
        type = Gui.NAME,
        player_index = event.player_index,
        parent = player.gui.screen,
        ui_tree_provider = Gui.getUi,
        context = gui_context,
        update_callback = Gui.guiUpdater,
        entity_id = entity.unit_number,
    }

    player.opened = gui.root
end

function Gui.onGhostGuiOpened(event)
    local player = Player.get(event.player_index)
    if not player then return end

    player.opened = nil
end

----------------------------------------------------------------------------------------------------
-- Event registration
----------------------------------------------------------------------------------------------------

local function init_gui()
    Framework.gui_manager:registerGuiType(Gui.NAME, get_gui_event_definition())

    local match_main_entity = Matchers:matchEventEntityName(const.dico_name)
    local match_ghost_main_entity = Matchers:matchEventEntityGhostName(const.dico_name)

    Event.on_event(defines.events.on_gui_opened, Gui.onGuiOpened, match_main_entity)
    Event.on_event(defines.events.on_gui_opened, Gui.onGhostGuiOpened, match_ghost_main_entity)
end

Event.on_init(init_gui)
Event.on_load(init_gui)

return Gui
