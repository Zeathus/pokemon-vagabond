class Battle
  #=============================================================================
  # Gaining Experience
  #=============================================================================
  def pbGainExp
    # Play wild victory music if it's the end of the battle (has to be here)
    @scene.pbWildBattleSuccess if wildBattle? && pbAllFainted?(1) && !pbAllFainted?(0)
    return if !@internalBattle || !@expGain
    # Go through each battler in turn to find the Pokémon that participated in
    # battle against it, and award those Pokémon Exp/EVs
    @battlers.each do |b|
      next unless b && b.opposes?
      next if b.participants.length==0
      next unless b.fainted? || b.captured
      pbGainEffortEssence(b)
      # Count the number of participants
      p1 = pbParty(0)
      numPartic = 0
      expshare = false
      b.participants.each do |partic|
        next unless p1[partic] && p1[partic].able? && pbIsOwner?(0,partic)
        numPartic += 1
        next if !p1[partic].hasItem?(:EXPSHARE) && GameData::Item.try_get(@initialItems[0][partic]) != :EXPSHARE
        expshare = true
      end
      # Add EXP to final pools
      real_level = b.level
      real_level += 1 if $PokemonSystem.difficulty == 0
      real_level -= 1 if $PokemonSystem.difficulty == 2
      exp = (real_level * b.pokemon.base_exp).floor
      next if exp <= 0

      exp = (exp*1.5).floor if trainerBattle?
      exp = (exp*1.5).floor if @smartWildBattle
      exp = (exp*3/2).floor if pbActiveDrink == "exp"

      multiplier = 0.20
      if $game_variables[Supplementals::PLAYER_LEVEL] > 20
        multiplier -= 0.10 * [($game_variables[Supplementals::PLAYER_LEVEL] - 20),50].min / 50
      end
      totalexp = (exp * multiplier).floor

      if expshare
        @sharedExpGained += totalexp
      else
        @expGained += totalexp
      end

      # Calculate EV and Exp gains for the participants
      if numPartic > 0
        eachInTeam(0,0) do |pkmn,i|
          next unless b.participants.include?(i)
          pbGainEVsOne(i,b)
        end
      end
      b.participants = []
    end
  end

  def pbGainEffortEssence(defeatedBattler)
    essenceYield = defeatedBattler.pokemon.evYield
    attacker = defeatedBattler.causeOfFaint
    if attacker
      # Modify EV yield based on pkmn's held item
      if !Battle::ItemEffects.triggerEVGainModifier(attacker.item, attacker, essenceYield)
        Battle::ItemEffects.triggerEVGainModifier(@initialItems[0][attacker.pokemonIndex], attacker, essenceYield)
      end
      # Double EV gain because of Pokérus
      if attacker.pokerusStage >= 1   # Infected or cured
        essenceYield.each_key { |stat| essenceYield[stat] *= 2 }
      end
    end
    essenceHeld = pbGetEffortEssence
    essenceYield.each_key { |stat|
      essenceHeld[stat] = [essenceHeld[stat] + essenceYield[stat], 1000].min
    }
  end

  def pbGainEVsOne(idxParty, defeatedBattler)
    return if !Supplementals::GAIN_EVS
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining EVs from defeatedBattler
    evYield = defeatedBattler.pokemon.evYield
    # Num of effort points pkmn already has
    evTotal = 0
    GameData::Stat.each_main { |s| evTotal += pkmn.ev[s.id] }
    # Modify EV yield based on pkmn's held item
    if !Battle::ItemEffects.triggerEVGainModifier(pkmn.item, pkmn, evYield)
      Battle::ItemEffects.triggerEVGainModifier(@initialItems[0][idxParty], pkmn, evYield)
    end
    # Double EV gain because of Pokérus
    if pkmn.pokerusStage >= 1   # Infected or cured
      evYield.each_key { |stat| evYield[stat] *= 2 }
    end
    # Gain EVs for each stat in turn
    if pkmn.shadowPokemon? && pkmn.heartStage <= 3 && pkmn.saved_ev
      pkmn.saved_ev.each_value { |e| evTotal += e }
      GameData::Stat.each_main do |s|
        evGain = evYield[s.id].clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[s.id] - pkmn.saved_ev[s.id])
        evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
        pkmn.saved_ev[s.id] += evGain
        evTotal += evGain
      end
    else
      GameData::Stat.each_main do |s|
        evGain = evYield[s.id].clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[s.id])
        evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
        pkmn.ev[s.id] += evGain
        evTotal += evGain
      end
    end
  end

  def pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages = true)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining Exp from defeatedBattler
    growth_rate = pkmn.growth_rate
    # Don't bother calculating if gainer is already at max Exp
    if pkmn.exp >= growth_rate.maximum_exp
      pkmn.calc_stats   # To ensure new EVs still have an effect
      return
    end
    isPartic    = defeatedBattler.participants.include?(idxParty)
    hasExpShare = expShare.include?(idxParty)
    level = defeatedBattler.level
    # Main Exp calculation
    exp = 0
    a = level * defeatedBattler.pokemon.base_exp
    if expShare.length > 0 && (isPartic || hasExpShare)
      if numPartic == 0   # No participants, all Exp goes to Exp Share holders
        exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? expShare.length : 1)
      elsif Settings::SPLIT_EXP_BETWEEN_GAINERS   # Gain from participating and/or Exp Share
        exp = a / (2 * numPartic) if isPartic
        exp += a / (2 * expShare.length) if hasExpShare
      else   # Gain from participating and/or Exp Share (Exp not split)
        exp = (isPartic) ? a : a / 2
      end
    elsif isPartic   # Participated in battle, no Exp Shares held by anyone
      exp = a / (Settings::SPLIT_EXP_BETWEEN_GAINERS ? numPartic : 1)
    elsif expAll   # Didn't participate in battle, gaining Exp due to Exp All
      # NOTE: Exp All works like the Exp Share from Gen 6+, not like the Exp All
      #       from Gen 1, i.e. Exp isn't split between all Pokémon gaining it.
      exp = a / 2
    end
    return if exp <= 0
    # Pokémon gain more Exp from trainer battles
    exp = (exp * 1.5).floor if @smartWildBattle
    exp = (exp * 1.5).floor if Settings::MORE_EXP_FROM_TRAINER_POKEMON && trainerBattle?
    # Scale the gained Exp based on the gainer's level (or not)
    if Settings::SCALED_EXP_FORMULA
      exp /= 5
      levelAdjust = ((2 * level) + 10.0) / (pkmn.level + level + 10.0)
      levelAdjust **= 5
      levelAdjust = Math.sqrt(levelAdjust)
      exp *= levelAdjust
      exp = exp.floor
      exp += 1 if isPartic || hasExpShare
    else
      exp /= 7
    end
    # Foreign Pokémon gain more Exp
    isOutsider = (pkmn.owner.id != pbPlayer.id ||
                 (pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language))
    if isOutsider
      if pkmn.owner.language != 0 && pkmn.owner.language != pbPlayer.language
        exp = (exp * 1.7).floor
      else
        exp = (exp * 1.5).floor
      end
    end
    # Exp. Charm increases Exp gained
    exp = exp * 3 / 2 if $bag.has?(:EXPCHARM)
    # Modify Exp gain based on pkmn's held item
    i = Battle::ItemEffects.triggerExpGainModifier(pkmn.item, pkmn, exp)
    if i < 0
      i = Battle::ItemEffects.triggerExpGainModifier(@initialItems[0][idxParty], pkmn, exp)
    end
    exp = i if i >= 0
    # Boost Exp gained with high affection
    if Settings::AFFECTION_EFFECTS && @internalBattle && pkmn.affection_level >= 4 && !pkmn.mega?
      exp = exp * 6 / 5
      isOutsider = true   # To show the "boosted Exp" message
    end
    # Make sure Exp doesn't exceed the maximum
    expFinal = growth_rate.add_exp(pkmn.exp, exp)
    expGained = expFinal - pkmn.exp
    return if expGained <= 0
    # "Exp gained" message
    if showMessages
      if isOutsider
        pbDisplayPaused(_INTL("{1} got a boosted {2} Exp. Points!", pkmn.name, expGained))
      else
        pbDisplayPaused(_INTL("{1} got {2} Exp. Points!", pkmn.name, expGained))
      end
    end
    curLevel = pkmn.level
    newLevel = growth_rate.level_from_exp(expFinal)
    if newLevel < curLevel
      debugInfo = "Levels: #{curLevel}->#{newLevel} | Exp: #{pkmn.exp}->#{expFinal} | gain: #{expGained}"
      raise _INTL("{1}'s new level is less than its current level, which shouldn't happen.", pkmn.name) + "\n[#{debugInfo}]"
    end
    # Give Exp
    if pkmn.shadowPokemon?
      if pkmn.heartStage <= 3
        pkmn.exp += expGained
        $stats.total_exp_gained += expGained
      end
      return
    end
    $stats.total_exp_gained += expGained
    tempExp1 = pkmn.exp
    battler = pbFindBattler(idxParty)
    loop do   # For each level gained in turn...
      # EXP Bar animation
      levelMinExp = growth_rate.minimum_exp_for_level(curLevel)
      levelMaxExp = growth_rate.minimum_exp_for_level(curLevel + 1)
      tempExp2 = (levelMaxExp < expFinal) ? levelMaxExp : expFinal
      pkmn.exp = tempExp2
      @scene.pbEXPBar(battler, levelMinExp, levelMaxExp, tempExp1, tempExp2)
      tempExp1 = tempExp2
      curLevel += 1
      if curLevel > newLevel
        # Gained all the Exp now, end the animation
        pkmn.calc_stats
        battler&.pbUpdate(false)
        @scene.pbRefreshOne(battler.index) if battler
        break
      end
      # Levelled up
      pbCommonAnimation("LevelUp", battler) if battler
      oldTotalHP = pkmn.totalhp
      oldAttack  = pkmn.attack
      oldDefense = pkmn.defense
      oldSpAtk   = pkmn.spatk
      oldSpDef   = pkmn.spdef
      oldSpeed   = pkmn.speed
      battler.pokemon.changeHappiness("levelup") if battler&.pokemon
      pkmn.calc_stats
      battler&.pbUpdate(false)
      @scene.pbRefreshOne(battler.index) if battler
      pbDisplayPaused(_INTL("{1} grew to Lv. {2}!", pkmn.name, curLevel)) { pbSEPlay("Pkmn level up") }
      @scene.pbLevelUp(pkmn, battler, oldTotalHP, oldAttack, oldDefense,
                       oldSpAtk, oldSpDef, oldSpeed)
      # Learn all moves learned at this level
      moveList = pkmn.getMoveList
      moveList.each { |m| pbLearnMoveBattle(idxParty, m[1]) if m[0] == curLevel }
    end
  end

  #=============================================================================
  # Learning a move
  #=============================================================================
  def pbLearnMoveBattle(idxParty, newMove)
    pkmn = pbParty(0)[idxParty]
    return if !pkmn
    pkmnName = pkmn.name
    battler = pbFindBattler(idxParty)
    moveName = GameData::Move.get(newMove).name
    # Pokémon already knows the move
    return if pkmn.hasMove?(newMove)
    # Pokémon has space for the new move; just learn it
    if pkmn.numMoves < Pokemon::MAX_MOVES
      pkmn.learn_move(newMove)
      pbDisplay(_INTL("{1} learned {2}!", pkmnName, moveName)) { pbSEPlay("Pkmn move learnt") }
      if battler
        battler.moves.push(Move.from_pokemon_move(self, pkmn.moves.last))
        battler.pbCheckFormOnMovesetChange
      end
      return
    end
    pbDisplay(_INTL("{1} can now learn {2}!", pkmnName, moveName)) { pbSEPlay("Pkmn move learnt") }
    return
    # Pokémon already knows the maximum number of moves; try to forget one to learn the new move
    pbDisplayPaused(_INTL("{1} wants to learn {2}, but it already knows {3} moves.",
                          pkmnName, moveName, pkmn.numMoves.to_word))
    if pbDisplayConfirm(_INTL("Should {1} forget a move to learn {2}?", pkmnName, moveName))
      loop do
        forgetMove = @scene.pbForgetMove(pkmn, newMove)
        if forgetMove >= 0
          oldMoveName = pkmn.moves[forgetMove].name
          pkmn.moves[forgetMove] = Pokemon::Move.new(newMove)   # Replaces current/total PP
          battler.moves[forgetMove] = Move.from_pokemon_move(self, pkmn.moves[forgetMove]) if battler
          pbDisplayPaused(_INTL("1, 2, and... ... ... Ta-da!")) { pbSEPlay("Battle ball drop") }
          pbDisplayPaused(_INTL("{1} forgot how to use {2}. And...", pkmnName, oldMoveName))
          pbDisplay(_INTL("{1} learned {2}!", pkmnName, moveName)) { pbSEPlay("Pkmn move learnt") }
          battler&.pbCheckFormOnMovesetChange
          break
        elsif pbDisplayConfirm(_INTL("Give up on learning {1}?", moveName))
          pbDisplay(_INTL("{1} did not learn {2}.", pkmnName, moveName))
          break
        end
      end
    else
      pbDisplay(_INTL("{1} did not learn {2}.", pkmnName, moveName))
    end
  end
end
