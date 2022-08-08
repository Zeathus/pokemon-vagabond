class Battle::Battler

  alias sup_itemActive? itemActive?
  alias sup_takesSandstormDamage? takesSandstormDamage?
  alias sup_takesHailDamage? takesHailDamage?
  alias sup_takesShadowSkyDamage? takesShadowSkyDamage?

  def itemActive?(ignoreFainted = false)
    return false if @battle.predictingDamage && !@knownItem
    return sup_itemActive?(ignoreFainted)
  end

  def takesSandstormDamage?
    return false if hasActiveAbility?(:FORECAST) && Supplementals::FORECAST_BLOCKS_WEATHER_DAMAGE
    return sup_takesSandstormDamage?
  end

  def takesHailDamage?
    return false if hasActiveAbility?(:FORECAST) && Supplementals::FORECAST_BLOCKS_WEATHER_DAMAGE
    return sup_takesHailDamage?
  end
  
  def takesShadowSkyDamage?
    return false if hasActiveAbility?(:FORECAST) && Supplementals::FORECAST_BLOCKS_SHADOW_SKY_DAMAGE
    return sup_takesShadowSkyDamage?
  end

end