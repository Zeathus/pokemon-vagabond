ItemHandlers::UseInField.add(:FISHINGROD,proc { |item|
    notCliff = $game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player)
    if !$game_player.pbFacingTerrainTag.can_fish || (!$PokemonGlobal.surfing && !notCliff)
        pbMessage(_INTL("Can't use that here."))
        next 0
    end
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name.include?("Item") &&
        !$game_self_switches[[$game_map.map_id,facingEvent.id,"A"]]
        item = facingEvent.name + ""
        item.gsub!("Item(",":")
        item.gsub!(")","")
        item = eval(item)
        if pbFishingGame(item,false,true)
            $game_self_switches[[$game_map.map_id,facingEvent.id,"A"]] = true
            $game_map.need_refresh = true
        end
    else
        encounter = $PokemonEncounters.has_encounter_type?(:FishingRod)
        if encounter
            $PokemonTemp.encounterType = :FishingRod
            encounter = $PokemonEncounters.choose_wild_pokemon(:FishingRod)
            encounter = EncounterModifier.trigger(encounter)
            if encounter
                pbScaleWildEncounter(encounter)
                pbFishingGame(encounter)
            end
        end
    end
    next 1
})

ItemHandlers::UseOnPokemon.add(:BAKEDBALM, proc { |item, pkmn, scene|
    next pbHPItem(pkmn, pkmn. totalhp - pkmn.hp,scene)
})

ItemHandlers::UseOnPokemon.add(:PECHERIPASTRY, proc { |item, pkmn, scene|
    next pbHPItem(pkmn, pkmn. happiness, scene)
})

ItemHandlers::UseOnPokemon.add(:MUSHROOMMUFFIN, proc { |item, pkmn, scene|
    next pbHPItem(pkmn, 100, scene)
})

ItemHandlers::UseOnPokemon.add(:HONEYEDBERRY, proc { |item, pkmn, scene|
    scene.pbDisplay(_INTL("{1}'s happiness increased a lot!", pkmn.name))
    next changeHappiness("honeyedberry")
})