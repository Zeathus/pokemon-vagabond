Battle::ItemEffects::AccuracyCalcFromUser.add(:ALLSEEINGTOTEM,
  proc { |item, mods, user, target, move, type|
    next unless move.powderMove?
    mods[:accuracy_multiplier] *= 1.25
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:BEETLEBARK,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :BUG
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:BLACKLOTUS,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :DARK
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:DRACOSHIELD,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :DRAGON
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:FACEMASK,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :POISON
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:SPELLBOOKOFWISDOM,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :PSYCHIC
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:CARVEDRAFFLESIA,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :GRASS
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:SILVERGAUNTLETS,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :STEEL
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:HEATMEDALLION,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :FIRE
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:JOYPENDANT,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :FAIRY
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:BRICKDUMBBELL,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :FIGHTING
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:SPIRITBURNER,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :GHOST
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:SCALENECKLACE,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :WATER
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:GROUNDWIRE,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :ELECTRIC
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:GUSTFAN,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :FLYING
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:EERILYREGULARRING,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :NORMAL
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:TUNDRATORC,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :ICE
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:SANDSTONESLAB,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :GROUND
  }
)

Battle::ItemEffects::DamageCalcFromTarget.add(:ROCKHEAD,
  proc { |item, user, target, move, mults, baseDmg, type|
    mults[:final_damage_multiplier] *= 0.8 if type == :ROCK
  }
)

Battle::ItemEffects::WeatherExtender.add(:VELVETYROCK,
  proc { |item, weather, duration, battler, battle|
    next duration + 3 if weather == :Winds
  }
)

Battle::ItemEffects::WeightCalc.add(:HEAVYSTONE,
  proc { |item, battler, w|
    next [w * 2, 999].min
  }
)