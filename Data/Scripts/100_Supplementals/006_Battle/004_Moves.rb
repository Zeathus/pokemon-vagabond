#===============================================================================
# Inflicts Frostbite on the target.
#===============================================================================
class Battle::Move::FrostbiteTarget < Battle::Move
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    return false if damagingMove?
    return !target.pbCanFrostbite?(user, show_message, self)
  end

  def pbEffectAgainstTarget(user, target)
    return if damagingMove?
    target.pbFrostbite
  end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    target.pbFrostbite if target.pbCanFrostbite?(user, false, self)
  end
end

#===============================================================================
# Inflicts Frostbite on the target. Effectiveness against Water-type is 2x. (Freeze-Dry)
#===============================================================================
class Battle::Move::FrostbiteTargetSuperEffectiveAgainstWater < Battle::Move::FrostbiteTarget
  def pbCalcTypeModSingle(moveType, defType, user, target)
    return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :WATER
    return super
  end
end

#===============================================================================
# Inflicts Frostbite on the target. Accuracy perfect in hail. (Blizzard)
#===============================================================================
class Battle::Move::FrostbiteTargetAlwaysHitsInHail < Battle::Move::FrostbiteTarget
  def pbBaseAccuracy(user, target)
    return 0 if target.effectiveWeather == :Hail
    return super
  end
end

#===============================================================================
# Inflicts Frostbite on the target. May cause the target to flinch. (Ice Fang)
#===============================================================================
class Battle::Move::FrostbiteFlinchTarget < Battle::Move
  def flinchingMove?; return true; end

  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    chance = pbAdditionalEffectChance(user, target, 10)
    return if chance == 0
    if target.pbCanFrostbite?(user, false, self) && @battle.pbRandom(100) < chance
      target.pbFrostbite
    end
    target.pbFlinch(user) if @battle.pbRandom(100) < chance
  end
end

#===============================================================================
# Burns, frostbites or paralyzes the target. (Tri Attack)
#===============================================================================
class Battle::Move::ParalyzeBurnOrFrostbiteTarget < Battle::Move
  def pbAdditionalEffect(user, target)
    return if target.damageState.substitute
    case @battle.pbRandom(3)
    when 0 then target.pbBurn(user) if target.pbCanBurn?(user, false, self)
    when 1 then target.pbFrostbite if target.pbCanFrostbite?(user, false, self)
    when 2 then target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
    end
  end
end