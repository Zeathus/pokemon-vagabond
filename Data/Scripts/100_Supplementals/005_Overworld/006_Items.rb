def pbRaiseEffortLevels(pkmn, stat, evGain = 10)
  stat = GameData::Stat.get(stat).id
  return 0 if !no_ev_cap && pkmn.ev[stat] >= 100
  evTotal = 0
  GameData::Stat.each_main { |s| evTotal += pkmn.ev[s.id] }
  evGain = evGain.clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[stat])
  evGain = evGain.clamp(0, 100 - pkmn.ev[stat]) if !no_ev_cap
  evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
  if evGain > 0
    pkmn.ev[stat] += evGain
    pkmn.calc_stats
  end
  return evGain
end

def pbMaxUsesOfELRaisingItem(stat, amt_per_use, pkmn)
  max_per_stat = (no_ev_cap) ? Pokemon::EV_STAT_LIMIT : 100
  amt_can_gain = max_per_stat - pkmn.ev[stat]
  ev_total = 0
  GameData::Stat.each_main { |s| ev_total += pkmn.ev[s.id] }
  amt_can_gain = [amt_can_gain, Pokemon::EV_LIMIT - ev_total].min
  return [(amt_can_gain.to_f / amt_per_use).ceil, 1].max
end

def pbUseELRaisingItem(stat, amt_per_use, qty, pkmn, happiness_type, scene)
  ret = true
  qty.times do |i|
    if pbRaiseEffortValues(pkmn, stat, amt_per_use, no_ev_cap) > 0
      pkmn.changeHappiness(happiness_type)
    else
      ret = false if i == 0
      break
    end
  end
  if !ret
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  scene.pbRefresh
  scene.pbDisplay(_INTL("{1}'s {2} increased.", pkmn.name, GameData::Stat.get(stat).name))
  return true
end

def pbMaxUsesOfELLoweringBerry(stat, pkmn)
  ret = (pkmn.ev[stat].to_f / 10).ceil
  happiness = pkmn.happiness
  uses = 0
  if happiness < 255
    bonus_per_use = 0
    bonus_per_use += 1 if pkmn.obtain_map == $game_map.map_id
    bonus_per_use += 1 if pkmn.poke_ball == :LUXURYBALL
    has_soothe_bell = pkmn.hasItem?(:SOOTHEBELL)
    loop do
      uses += 1
      gain = [10, 5, 2][happiness / 100]
      gain += bonus_per_use
      gain = (gain * 1.5).floor if has_soothe_bell
      happiness += gain
      break if happiness >= 255
    end
  end
  return [ret, uses].max
end

def pbRaiseHappinessAndLowerEL(pkmn, scene, stat, qty, messages)
  h = pkmn.happiness < 255
  e = pkmn.ev[stat] > 0
  if !h && !e
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  if h
    qty.times { |i| pkmn.changeHappiness("evberry") }
  end
  if e
    pkmn.ev[stat] -= 10 * qty
    pkmn.ev[stat] = 0 if pkmn.ev[stat] < 0
    pkmn.calc_stats
  end
  scene.pbRefresh
  scene.pbDisplay(messages[2 - (h ? 0 : 2) - (e ? 0 : 1)])
  return true
end

if Supplementals::USE_EFFORT_LEVELS
  [:HP, :ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED].each do |stat|
    for i in 0...Supplementals::EFFORT_LEVEL_TIERS.length
      tier_max_level = Supplementals::EFFORT_LEVEL_TIERS[i]

      tier_item = Supplementals::EFFORT_LEVEL_INCREASE_ITEMS[stat][i]

      ItemHandlers::UseOnPokemonMaximum.add(tier_item, proc { |item, pkmn|
        next pbMaxUsesOfELRaisingItem(stat, tier_max_level, pkmn)
      })

      ItemHandlers::UseOnPokemon.add(tier_item, proc { |item, qty, pkmn, scene|
        next pbUseELRaisingItem(stat, tier_max_level, qty, pkmn, "vitamin", scene)
      })
    end

    decrease_item = Supplementals::EFFORT_LEVEL_DECREASE_ITEMS[stat]

    ItemHandlers::UseOnPokemonMaximum.add(decrease_item, proc { |item, pkmn|
      next pbMaxUsesOfELLoweringBerry(stat, pkmn)
    })

    ItemHandlers::UseOnPokemon.add(decrease_item, proc { |item, qty, pkmn, scene|
      next pbRaiseHappinessAndLowerEL(
        pkmn, scene, stat, qty, [
          _INTL("{1} adores you! Its base {2} fell!", pkmn.name, stat.to_s),
          _INTL("{1} became more friendly. Its base {2} can't go lower.", pkmn.name),
          _INTL("{1} became more friendly. However, its base {2} fell!", pkmn.name)
        ]
      )
    })
  end
end