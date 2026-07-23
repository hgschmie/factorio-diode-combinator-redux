------------------------------------------------------------------------
-- make existing combinators operable
------------------------------------------------------------------------

local const = require('lib.constants')

local combinator_names = { const.dico_name }

for _, surface in pairs(game.surfaces) do
    local combinators = surface.find_entities_filtered {
        name = combinator_names,
    }
    for _, combinator in pairs(combinators) do
        combinator.operable = true
    end
end
