Battle::AbilityEffects::PriorityChange.add(:HASTE,
  proc { |ability, battler, move, pri|
    next pri + 1 if battler.turnCount <= 1
  }
)

Battle::AbilityEffects::EndOfRoundEffect.add(:EVERLASTING,
  proc { |ability, battler, battle|
    if battler.species == :REVINJA
      if battler.form == 1 && battle.turnCount > battler.effects[PBEffects::EverlastingFainted]
        battle.pbShowAbilitySplash(battler)
        pbSEPlay("Recovery", 100, 100)
        battler.pbChangeForm(0,_INTL("{1} restored its original form!", battler.pbThis))
        battle.pbHideAbilitySplash(battler)
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

Battle::AbilityEffects::DamageCalcFromUser.add(:LAYOFTHELAND,
  proc { |ability, user, target, move, mults, power, type|
    if user.effects[PBEffects::LayOfTheLand]
      mults[:attack_multiplier] *= 1.5
    end
  }
)