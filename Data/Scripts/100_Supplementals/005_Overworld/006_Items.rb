def pbRaiseEffortLevels(pkmn, stat, min_el, max_el)
  stat = GameData::Stat.get(stat).id
  els = pkmn.el
  return 0 if els[stat] < min_el || els[stat] >= max_el
  return 0 if els[stat] >= Supplementals::MAX_EFFORT_LEVEL
  total_counting_els = pkmn.total_counting_els
  return 0 if els[stat] >= Supplementals::IGNORE_TOTAL_EFFORT_LEVELS && total_counting_els >= Supplementals::MAX_TOTAL_EFFORT_LEVEL
  elGain = 1
  els[stat] += elGain
  pkmn.el = els
  pkmn.calc_stats
  return elGain
end

def pbMaxUsesOfELRaisingItem(stat, min_el, max_el, pkmn)
  els = pkmn.el
  return 0 if els[stat] < min_el || els[stat] >= max_el
  return 0 if els[stat] >= Supplementals::MAX_EFFORT_LEVEL
  total_counting_els = pkmn.total_counting_els
  return 0 if els[stat] >= Supplementals::IGNORE_TOTAL_EFFORT_LEVELS && total_counting_els >= Supplementals::MAX_TOTAL_EFFORT_LEVEL
  to_next_tier = max_el - els[stat]
  max_can_gain = Supplementals::MAX_TOTAL_EFFORT_LEVEL - total_counting_els
  if els[stat] < Supplementals::IGNORE_TOTAL_EFFORT_LEVELS
    max_can_gain = Supplementals::IGNORE_TOTAL_EFFORT_LEVELS - els[stat]
  end
  val = [to_next_tier, max_can_gain].min
  return val
end

def pbUseELRaisingItem(stat, min_el, max_el, qty, pkmn, happiness_type, scene)
  ret = true
  qty.times do |i|
    if pbRaiseEffortLevels(pkmn, stat, min_el, max_el) > 0
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
  ret = pkmn.el[stat]
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
  els = pkmn.el
  e = els[stat] > 0
  if !h && !e
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  end
  if h
    qty.times { |i| pkmn.changeHappiness("evberry") }
  end
  if e
    qty.times { |i| els[stat] -= 1 if els[stat] > 0 }
    pkmn.el = els
    pkmn.calc_stats
  end
  scene.pbRefresh
  scene.pbDisplay(messages[2 - (h ? 0 : 2) - (e ? 0 : 1)])
  return true
end

if Supplementals::USE_EFFORT_LEVELS
  GameData::Stat.each_main do |s|
    stat = s.id
    (0...Supplementals::EFFORT_LEVEL_TIERS.length).each do |i|
      tier_min_level = (i == 0) ? 0 : (Supplementals::EFFORT_LEVEL_TIERS[i - 1])
      tier_max_level = Supplementals::EFFORT_LEVEL_TIERS[i]

      tier_item = Supplementals::EFFORT_LEVEL_INCREASE_ITEMS[stat][i]

      ItemHandlers::UseOnPokemonMaximum.add(tier_item, proc { |item, pkmn|
        next pbMaxUsesOfELRaisingItem(stat, tier_min_level, tier_max_level, pkmn)
      })

      ItemHandlers::UseOnPokemon.add(tier_item, proc { |item, qty, pkmn, scene|
        next pbUseELRaisingItem(stat, tier_min_level, tier_max_level, qty, pkmn, "vitamin", scene)
      })
    end

    decrease_item = Supplementals::EFFORT_LEVEL_DECREASE_ITEMS[stat]

    ItemHandlers::UseOnPokemonMaximum.add(decrease_item, proc { |item, pkmn|
      next pbMaxUsesOfELLoweringBerry(stat, pkmn)
    })

    ItemHandlers::UseOnPokemon.add(decrease_item, proc { |item, qty, pkmn, scene|
      next pbRaiseHappinessAndLowerEL(
        pkmn, scene, stat, qty, [
          _INTL("{1} adores you! Its base {2} fell!", pkmn.name, GameData::Stat.get(stat).name),
          _INTL("{1} became more friendly. Its base {2} can't go lower.", pkmn.name, GameData::Stat.get(stat).name),
          _INTL("{1} became more friendly. However, its base {2} fell!", pkmn.name, GameData::Stat.get(stat).name)
        ]
      )
    })
  end
end