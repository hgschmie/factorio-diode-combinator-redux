------------------------------------------------------------------------
-- entities
------------------------------------------------------------------------

local util = require('util')
local meld = require('meld')

local const = require('lib.constants')

local diode_sprites =
{
    north = util.draw_as_glow
        {
            scale = 0.5,
            filename = const:png('entities/diode'),
            width = 30,
            height = 22,
            shift = util.by_pixel(0, -4.5),
        },
    east = util.draw_as_glow
        {
            scale = 0.5,
            filename = const:png('entities/diode'),
            width = 30,
            height = 22,
            shift = util.by_pixel(0, -10.5),
        },
    south = util.draw_as_glow
        {
            scale = 0.5,
            filename = const:png('entities/diode'),
            width = 30,
            height = 22,
            shift = util.by_pixel(0, -4.5),
        },
    west = util.draw_as_glow
        {
            scale = 0.5,
            filename = const:png('entities/diode'),
            width = 30,
            height = 22,
            shift = util.by_pixel(0, -10.5),
        },
}

local not_diode_sprites =
{
    north = util.draw_as_glow
        {
            scale = 0.5,
            filename = const:png('entities/not-diode'),
            width = 30,
            height = 22,
            shift = util.by_pixel(0, -4.5),
        },
    east = util.draw_as_glow
        {
            scale = 0.5,
            filename = const:png('entities/not-diode'),
            width = 30,
            height = 22,
            shift = util.by_pixel(0, -10.5),
        },
    south = util.draw_as_glow
        {
            scale = 0.5,
            filename = const:png('entities/not-diode'),
            width = 30,
            height = 22,
            shift = util.by_pixel(0, -4.5),
        },
    west = util.draw_as_glow
        {
            scale = 0.5,
            filename = const:png('entities/not-diode'),
            width = 30,
            height = 22,
            shift = util.by_pixel(0, -10.5),
        },
}

local main_entity = meld(util.copy(data.raw['arithmetic-combinator']['arithmetic-combinator']),
    {
        name = const.dico_name,
        minable = {
            result = const.dico_name,
        },
        multiply_symbol_sprites = meld.overwrite(not_diode_sprites),
        plus_symbol_sprites = meld.overwrite(diode_sprites),
        icon = const:png('icons/diode-combinator-redux'),
    })


data:extend { main_entity }
