class Battle::Battler

  def hasKnownAbility?(ability)
    ability=getID(PBAbilities,ability) if ability.is_a?(Symbol)
    @knownAbility=true if !knownAbility && isOnlyAbility?(ability)
    @knownAbility=true if hasTrappingAbility
    return true if @knownAbility && self.hasWorkingAbility(ability)
    if canHaveAbility?(ability)
      if rand(100)>=25
        return self.hasWorkingAbility(ability)
      end
    end
    return false
  end

  def knownAbility
    @knownAbility=true if isOnlyAbility?(@ability)
    @knownAbility=true if hasTrappingAbility
    return @knownAbility
  end

  def knownItem
    @knownItem=true if @pokemon.item != self.initialItem
    return @knownItem
  end

  def isOnlyAbility?(ability)
    abils=pokemon.getAbilityList
    for abil in abils
      return false if ability != abil[0]
    end
    return true
  end

  def canHaveAbility?(ability)
    abils=pokemon.getAbilityList
    for abil in abils
      return true if abil[0]==ability
    end
    return false
  end

  def pbRegisterKnownAbility(aionly=false)
    if aionly
      if @index % 2 == 0
        #@knownAbility = true
      end
    else
      @knownAbility = true
    end
  end

  def hasTrappingAbility
    if self.hasWorkingAbility(:ARENATRAP) ||
      self.hasWorkingAbility(:SHADOWTAG) ||
      self.hasWorkingAbility(:MAGNETPULL)
      return true
    end
    return false
  end

  def pbRegisterKnownItem(aionly=false)
    if aionly
      if @index % 2 == 0
        #@knownItem=true
      end
    else
      @knownItem=true
    end
  end

  def pbRegisterKnownMove(moveid)
    @knownMoves.push(moveid)
  end

  def pbIsMoveRevealed?(moveid)
    return @knownMoves.include?(moveid)
  end

end 