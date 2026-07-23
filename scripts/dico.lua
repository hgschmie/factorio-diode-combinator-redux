------------------------------------------------------------------------
-- Diode Combinator code
------------------------------------------------------------------------

local util = require('util')

local signal_converter = require('framework.signal_converter')

local const = require('lib.constants')

---@class dico.DiCo
local DiCo = {}

------------------------------------------------------------------------
-- create / delete
------------------------------------------------------------------------

--- Creates a new entity from the main entity, registers with the mod
--- and configures it.
---@param main LuaEntity
function DiCo:create(main)
    if not (main and main.valid) then return nil end

    self:reconfigure(main)
end

---@enum dico.Mode
local MODE = {
    unknown = 0,
    normal = 1,
    invert = 2,
}

---@param parameters ArithmeticCombinatorParameters?
---@return dico.Mode
function DiCo:getMode(parameters)
    if not parameters then return MODE.unknown end
    if parameters.operation == '+' and parameters.second_constant == 0 then return MODE.normal end
    if parameters.operation == '*' and parameters.second_constant == -1 then return MODE.invert end
    return MODE.unknown
end

---@param parameters ArithmeticCombinatorParameters
---@param mode dico.Mode
function DiCo:setMode(parameters, mode)
    if mode == MODE.invert then
        parameters.operation = '*'
        parameters.second_constant = -1
    else
        parameters.operation = '+'
        parameters.second_constant = 0
    end
end

---@param main LuaEntity
function DiCo:reconfigure(main)
    local control_behavior = assert(main.get_or_create_control_behavior()) --[[@as LuaArithmeticCombinatorControlBehavior]]

    local parameters = assert(util.copy(control_behavior.parameters))

    local mode = self:getMode(parameters)
    if mode == MODE.unknown then
        self:setMode(parameters, MODE.normal)
        parameters.first_signal_networks.red = true
        parameters.first_signal_networks.green = true
    end


    parameters.first_signal = { type = 'virtual', name = 'signal-each' }
    parameters.output_signal = { type = 'virtual', name = 'signal-each' }

    control_behavior.parameters = parameters
end

return DiCo
