------------------------------------------------------------------------
-- anything not entities
------------------------------------------------------------------------

local util = require('util')
local meld = require('meld')

local const = require('lib.constants')


local diode_combinator_item = meld(util.copy(data.raw['item']['arithmetic-combinator']), {
    name = const.dico_name,
    place_result = const.dico_name,
    icon = const:png('icons/diode-combinator-redux'),
    order = const.order,
})

data:extend { diode_combinator_item }

local diode_combinator_recipe = {
    type = 'recipe',
    name = const.dico_name,
    enabled = false,
    ingredients = {
        { type = 'item', name = 'arithmetic-combinator', amount = 1 },
        { type = 'item', name = 'electronic-circuit', amount = 1 },
    },
    results = {
        { type = 'item', name = const.dico_name, amount = 1 },
    },
}

data:extend { diode_combinator_recipe }

assert(data.raw['technology']['circuit-network'])
table.insert(data.raw['technology']['circuit-network'].effects, { type = 'unlock-recipe', recipe = const.dico_name })
