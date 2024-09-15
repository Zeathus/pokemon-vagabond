
Battle::AbilityEffects::CertainSwitching.add(:RUNAWAY,
  proc { |ability, switcher,battle|
    next Supplementals::RUN_AWAY_CERTAIN_SWITCHING
  }
)

Battle::AbilityEffects::DamageCalcFromTarget.add(:ILLUMINATE,
  proc { |ability, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] /= 2 if type == :DARK && Supplementals::ILLUMINATE_DARK_RESIST
  }
)