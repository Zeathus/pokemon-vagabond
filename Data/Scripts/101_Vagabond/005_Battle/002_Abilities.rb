Battle::AbilityEffects::PriorityChange.add(:HASTE,
  proc { |ability, battler, move, pri|
    next pri + 1 if battler.turnCount <= 1
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:EVERLASTING,
  proc { |ability, battler, battle|
    if battler.species == :SHEDINJA_R
      if battler.form == 1 && battler.turnCount > battler.effects[PBEffects::EverlastingFainted]
        battler.pbChangeForm(0,_INTL("{1} returned to its original form!", battler.pbThis))
      end
    end
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:TWILIGHT,
  proc { |ability, battler, battle|
    # A Pokémon's turnCount is 0 if it became active after the beginning of a
    # round
    if battler.turnCount > 0 && battle.choices[battler.index][0] != :Run
      if pbDualFormPokemon.include?(battler.species)
        battler.pbChangeForm(battler.form==0 ? 1 : 0,
          _INTL("{1} returned to its original form!", battler.pbThis))
      end
    end
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:ILLUMINATE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:base_damage_multiplier] /= 2 if type == :DARK
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:OVERSHADOW,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] /= 2 if type == :FAIRY
  }
)

Battle::AbilityEffects::DamageCalcFromUser.add(:LUNARPOWER,
  proc { |ability, user, target, move, mults, baseDmg, type|
    if user.battle.field.terrain == :Misty
      mults[:defense_multiplier] *= 1.5
    end
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:ZEPHYR,
  proc { |ability, battler, battle, switch_in|
    battle.pbStartWeatherAbility(:Winds, battler)
  }
)