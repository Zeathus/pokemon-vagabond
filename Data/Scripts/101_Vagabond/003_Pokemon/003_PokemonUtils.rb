def pbHasInParty?(species, inactive_party=true)
    for pokemon in $player.party
        return true if pokemon.species == species
    end
    return false if !inactive_party
    
    for pokemon in $player.inactive_party
        return true if pokemon.species == species
    end
    return false
end