def pbFishingBegin
    $game_player.set_movement_type($PokemonGlobal.surfing ? :surf_fishing : :fishing)
    $game_player.lock_pattern = true
    $game_player.pattern = 3
    $game_player.y_offset += 16 if !$PokemonGlobal.surfing
    start_time = System.uptime
    last_progress = 0
    loop do
        progress = System.uptime - start_time
        if last_progress < 0.2 && progress >= 0.2
            $game_player.pattern = 2
        elsif last_progress < 0.6 && progress >= 0.6
            pbSEPlay("Battle throw")
            $game_player.pattern = 1
        elsif last_progress < 0.8 && progress >= 0.8
            $game_player.pattern = 0
        end
        Graphics.update
        Input.update
        pbUpdateSceneMap
        break if progress > 1
        last_progress = progress
    end
end

def pbFishingEnd
    $game_player.pattern = 1
    start_time = System.uptime
    last_progress = 0
    loop do
        progress = System.uptime - start_time
        if last_progress < 0.2 && progress >= 0.2
            pbSEPlay("Water1")
            $game_player.pattern = 2
        elsif last_progress < 0.4 && progress >= 0.4
            $game_player.pattern = 3
        end
        Graphics.update
        Input.update
        pbUpdateSceneMap
        break if progress > 0.8
        last_progress = progress
    end
    $game_player.set_movement_type($PokemonGlobal.surfing ? :surfing_stopped : :walking_stopped)
    $game_player.lock_pattern = false
    $game_player.y_offset -= 16 if !$PokemonGlobal.surfing
    $game_player.straighten
end

ItemHandlers::UseInField.add(:FISHINGROD, proc { |item|
    notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
    if !$game_player.pbFacingTerrainTag.can_fish #|| (!$PokemonGlobal.surfing && !notCliff)
        pbMessage(_INTL("Can't use that here."))
        next 0
    end
    if $game_switches[NO_FISHING]
        pbDialog("NO_FISHING")
        next 0
    end
    pbFishingBegin
    facingEvent = $game_player.pbFacingEvent(true)
    if facingEvent && facingEvent.name.include?("Item") && !$game_self_switches[[$game_map.map_id,facingEvent.id,"A"]]
        item = facingEvent.name + ""
        item.gsub!("Item(",":")
        item.gsub!(")","")
        item = eval(item)
        if pbFishingGame(item,false,true)
            $game_self_switches[[$game_map.map_id,facingEvent.id,"A"]] = true
            $game_map.need_refresh = true
        end
    echoln facingEvent.name if facingEvent
    elsif facingEvent && facingEvent.name.include?("WhenFished") && !$game_self_switches[[$game_map.map_id,facingEvent.id,"B"]]
        command = facingEvent.name + ""
        command.gsub!("WhenFished(","")
        command.gsub!(")","")
        command = command.split(",")
        pokemon = nil
        item = nil
        # Before fishing
        case command[0]
        when "Swampert"
            $game_self_switches[[$game_map.map_id,facingEvent.id,"A"]] = true
            $game_map.need_refresh = true
            pokemon = [command[0].upcase.to_sym, command[1], 0]
        end
        if pokemon
            if pbFishingGame(pokemon, false, false, true)
                # Landing the hook
                case command[0]
                when "Swampert"
                    $game_self_switches[[$game_map.map_id,facingEvent.id,"B"]] = true
                    $game_map.need_refresh = true
                end
            end
        end
        # After fishing
        case command[0]
        when "Swampert"
            $game_self_switches[[$game_map.map_id,facingEvent.id,"A"]] = false
            $game_map.need_refresh = true
        end
    else
        msgwindow = pbCreateMessageWindow
        encounter = $PokemonEncounters.has_encounter_type?(:FishingRod)
        success = true
        loop do
            if encounter
                encounter = $PokemonEncounters.choose_wild_pokemon(:FishingRod)
            end
            time = rand(5..10)
            message = ""
            time.times { message += ".   " }
            (pbFishStats[encounter[0]][0] + 1).times { message += "!" } if encounter
            if pbWaitMessage(msgwindow, time)
                pbFishingEnd
                pbMessage(_INTL("There was no bite..."))
                success = false
                break
            end
            if encounter
                $scene.spriteset.addUserAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y, true, 3)
                duration = rand(5..10) / 10.0
                if pbWaitForInput(msgwindow, message, duration)
                    break
                end
            else
                pbFishingEnd
                pbMessage(_INTL("There appears to be no fish here."))
                success = false
                break
            end
            if pbWaitForInput(msgwindow, message, 1.0)
                pbFishingEnd
                pbMessage(_INTL("You reeled in too late..."))
                success = false
                break
            end
        end
        pbDisposeMessageWindow(msgwindow)
        if success && encounter
            $game_temp.encounter_type = :FishingRod
            EventHandlers.trigger(:on_wild_species_chosen, encounter)
            if encounter
                pbFishingGame(encounter)
            end
            $game_temp.encounter_type = nil
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