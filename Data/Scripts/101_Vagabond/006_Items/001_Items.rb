ItemHandlers::UseOnPokemon.add(:HELIODORGEMSTONE,proc{|item,pokemon,scene|
    Kernel.pbMessage(_INTL("{1} wants to strengthen its Attack.",pokemon.name))
    Kernel.pbMessage(_INTL("Which trait should be weakened in return?\\wt[4]{1}",
      "\\ch[1,6,Attack,Defense,Sp. Atk,Sp. Def,Speed,Cancel]"))
    case $game_variables[1]
    when 0
      pokemon.natureflag=PBNatures::HARDY
    when 1
      pokemon.natureflag=PBNatures::LONELY
    when 2
      pokemon.natureflag=PBNatures::ADAMANT
    when 3
      pokemon.natureflag=PBNatures::NAUGHTY
    when 4
      pokemon.natureflag=PBNatures::BRAVE
    when 5
      next false
    end
    scene.pbDisplay(_INTL("{1} nature was changed to {2}.",pokemon.name,PBNatures.getName(pokemon.natureflag)))
    scene.pbRefresh
    next true
})

ItemHandlers::UseOnPokemon.add(:HOWLITEGEMSTONE,proc{|item,pokemon,scene|
    Kernel.pbMessage(_INTL("{1} wants to harden its Defense.",pokemon.name))
    Kernel.pbMessage(_INTL("Which trait should be weakened in return?\\wt[4]{1}",
      "\\ch[1,6,Attack,Defense,Sp. Atk,Sp. Def,Speed,Cancel]"))
    case $game_variables[1]
    when 0
      pokemon.natureflag=PBNatures::BOLD
    when 1
      pokemon.natureflag=PBNatures::DOCILE
    when 2
      pokemon.natureflag=PBNatures::IMPISH
    when 3
      pokemon.natureflag=PBNatures::LAX
    when 4
      pokemon.natureflag=PBNatures::RELAXED
    when 5
      next false
    end
    scene.pbDisplay(_INTL("{1} nature was changed to {2}.",pokemon.name,PBNatures.getName(pokemon.natureflag)))
    scene.pbRefresh
    next true
})

ItemHandlers::UseOnPokemon.add(:AMETRINEGEMSTONE,proc{|item,pokemon,scene|
    Kernel.pbMessage(_INTL("{1} wants to empower its Special Attack.",pokemon.name))
    Kernel.pbMessage(_INTL("Which trait should be weakened in return?\\wt[4]{1}",
      "\\ch[1,6,Attack,Defense,Sp. Atk,Sp. Def,Speed,Cancel]"))
    case $game_variables[1]
    when 0
      pokemon.natureflag=PBNatures::MODEST
    when 1
      pokemon.natureflag=PBNatures::MILD
    when 2
      pokemon.natureflag=PBNatures::BASHFUL
    when 3
      pokemon.natureflag=PBNatures::RASH
    when 4
      pokemon.natureflag=PBNatures::QUIET
    when 5
      next false
    end
    scene.pbDisplay(_INTL("{1} nature was changed to {2}.",pokemon.name,PBNatures.getName(pokemon.natureflag)))
    scene.pbRefresh
    next true
})

ItemHandlers::UseOnPokemon.add(:AEGIRINEGEMSTONE,proc{|item,pokemon,scene|
    Kernel.pbMessage(_INTL("{1} wants to optimize its Special Defense.",pokemon.name))
    Kernel.pbMessage(_INTL("Which trait should be weakened in return?\\wt[4]{1}",
      "\\ch[1,6,Attack,Defense,Sp. Atk,Sp. Def,Speed,Cancel]"))
    case $game_variables[1]
    when 0
      pokemon.natureflag=PBNatures::CALM
    when 1
      pokemon.natureflag=PBNatures::GENTLE
    when 2
      pokemon.natureflag=PBNatures::CAREFUL
    when 3
      pokemon.natureflag=PBNatures::QUIRKY
    when 4
      pokemon.natureflag=PBNatures::SASSY
    when 5
      next false
    end
    scene.pbDisplay(_INTL("{1} nature was changed to {2}.",pokemon.name,PBNatures.getName(pokemon.natureflag)))
    scene.pbRefresh
    next true
})

ItemHandlers::UseOnPokemon.add(:PHENACITEGEMSTONE,proc{|item,pokemon,scene|
    Kernel.pbMessage(_INTL("{1} wants to increase its Speed.",pokemon.name))
    Kernel.pbMessage(_INTL("Which trait should be weakened in return?\\wt[4]{1}",
      "\\ch[1,6,Attack,Defense,Sp. Atk,Sp. Def,Speed,Cancel]"))
    case $game_variables[1]
    when 0
      pokemon.natureflag=PBNatures::TIMID
    when 1
      pokemon.natureflag=PBNatures::HASTY
    when 2
      pokemon.natureflag=PBNatures::JOLLY
    when 3
      pokemon.natureflag=PBNatures::NAIVE
    when 4
      pokemon.natureflag=PBNatures::SERIOUS
    when 5
      next false
    end
    scene.pbDisplay(_INTL("{1} nature was changed to {2}.",pokemon.name,PBNatures.getName(pokemon.natureflag)))
    scene.pbRefresh
    next true
})

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