#===============================================================================
# Poison moves have normal effectiveness against the Steel-type target. (Corrosive Acid)
#===============================================================================
class Battle::Move::StartNegateTargetPoisonImmunity < Battle::Move
  def ignoresSubstitute?(user); return true; end
  def canMagicCoat?;            return true; end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::CorrosiveAcid] = true
    @battle.pbDisplay(_INTL("{1} became susceptible to Poison-type moves!", target.pbThis))
  end
end

#===============================================================================
# Starts windy weather. (Winds)
#===============================================================================
class Battle::Move::StartWindsWeather < Battle::Move::WeatherMove
  def initialize(battle, move)
    super
    @weatherType = :Winds
  end
end

#===============================================================================
# User loses their Water type. Fails if user is not Water-type. (Tsunami)
#===============================================================================
class Battle::Move::UserLosesWaterType < Battle::Move
  def pbMoveFailed?(user, targets)
    if !user.pbHasType?(:WATER)
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectAfterAllHits(user, target)
    if !user.effects[PBEffects::Tsunami]
      user.effects[PBEffects::Tsunami] = true
      @battle.pbDisplay(_INTL("{1} became dehydrated.\nIt is no longer Water-type!", user.pbThis))
    end
  end
end

#===============================================================================
# Inflicts target with Burn or Frostbite if user has it.
# If not statuses, can also inflict during sun or snowscape/hail (Thermodynamics)
#===============================================================================
class Battle::Move::CopyUserStatusToTargetTemperature < Battle::Move
  def pbMoveFailed?(user, targets)
    if pbStatusToInflict == :NONE
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbStatusToInflict
    if user.status == :BURN
      return :BURN
    elsif user.status == :FROSTBITE
      return :FROSTBITE
    elsif [:Sun, :HarshSun].include?(@battle.pbWeather)
      return :BURN
    elsif [:Hail, :Snow].include?(@battle.pbWeather)
      return :FROSTBITE
    else
      return :NONE
    end
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    if !target.pbCanInflictStatus?(pbStatusToInflict, user, false, self)
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    case pbStatusToInflict
    when :BURN
      target.pbBurn(user)
    when :FROSTBITE
      target.pbFrostbite(user)
    end
  end
end

#===============================================================================
# Affinity boosts partner regardless of affinity (After Me)
#===============================================================================
class Battle::Move::AffinityBoostIgnoreAffinity < Battle::Move
  def pbEffectAgainstTarget(user, target)
    return if target.damageState.hpLost <= 0
    return if !target.opposes?(user)
    return if target.damageState.unaffected
    return if !(Effectiveness.normal?(target.damageState.typeMod) || Effectiveness.super_effective?(target.damageState.typeMod))
    user.eachAlly do |partner|
      if !partner.fainted? && !partner.movedThisRound? && @battle.choices[partner.index][0] == :UseMove
        partner.affinityBooster = user
        partner.effects[PBEffects::MoveNext] = true
      end
    end
  end
end

#===============================================================================
# Hits 2 times. First hit is Poison-type and grounds, second hit is Ground-type. (Killer Combo)
#===============================================================================
class Battle::Move::FirstHitPoisonGroundTargetSecondHitGround < Battle::Move
  def hitsFlyingTargets?; return @hitNum == 0; end

  def pbDisplayUseMessage(user)
    if @hitNum == 1
      @battle.pbDisplayBrief(_INTL("{1} makes a follow-up attack!", user.pbThis))
    else
      super(user)
    end
  end

  def pbBaseType(user)
    return :GROUND if @hitNum == 1
    return super(user)
  end

  def pbOnStartUse(user, targets)
    @calcType = self.pbCalcType(user)
  end

  def pbBaseDamage(baseDmg, user, target)
    return baseDmg * 2 if @hitNum == 1 && target.effects[PBEffects::SmackDown]
    return baseDmg
  end

  def pbEffectAgainstTarget(user, target)
    return if @hitNum != 0
    return if target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSkyTargetCannotAct") ||
              target.effects[PBEffects::SkyDrop] >= 0   # Sky Drop
    return if !target.airborne? && !target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                                                            "TwoTurnAttackInvulnerableInSkyParalyzeTarget")
    target.effects[PBEffects::SmackDown] = true
    if target.inTwoTurnAttack?("TwoTurnAttackInvulnerableInSky",
                               "TwoTurnAttackInvulnerableInSkyParalyzeTarget")   # NOTE: Not Sky Drop.
      target.effects[PBEffects::TwoTurnAttack] = nil
      @battle.pbClearChoice(target.index) if !target.movedThisRound?
    end
    target.effects[PBEffects::MagnetRise]  = 0
    target.effects[PBEffects::Telekinesis] = 0
    @battle.pbDisplay(_INTL("{1} crashed to the ground!", target.pbThis))
  end

  def pbChangeUsageCounters(user, specialUsage)
    @hitNum = specialUsage ? 1 : 0
  end

  def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
    return if user.fainted?
    return if user.status == :SLEEP || user.status == :FROZEN
    return if targets.length < 1
    target = targets[0]
    return if target.fainted?
    user.pbUseMoveSimple(self.id, targets[0].index) if @hitNum == 0
  end
end

################################################################################
# All allies (including self) are affinity boosted for their next move (Morale Boost)
################################################################################
class Battle::Move::AffinityBoostNextTurn < Battle::Move
  def pbMoveFailed?(user, targets)
    if @battle.allSameSideBattlers(user).none? { |b| b.effects[PBEffects::AffinityBoostNext].nil? }
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbFailsAgainstTarget?(user, target, show_message)
    return !(target.effects[PBEffects::AffinityBoostNext].nil?)
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::AffinityBoostNext] = user
    target.effects[PBEffects::MoveNext] = true
    @battle.pbDisplay(_INTL("{1} was inspired!", target.pbThis))
  end
end


################################################################################
# Type depends on the user's Personality ID.
# Boosts up to two stats based on Personality ID. (Diversity)
# Exclusive to Spinda
################################################################################
class Battle::Move::SpindaDiversity < Battle::Move
  # This move definitely does not work right now
  def pbModifyType(type,attacker,opponent)
    types = [
      :NORMAL,
      :FIRE,
      :WATER,
      :GRASS,
      :ICE,
      :STEEL,
      :ROCK,
      :GROUND,
      :FAIRY,
      :FIGHTING,
      :BUG,
      :FLYING,
      :DRAGON,
      :GHOST,
      :DARK,
      :PSYCHIC,
      :ELECTRIC,
      :POISON
    ]
    id=attacker.pokemon.personalID
    type=types[(id % 256) % 18]
    pbMessage(PBTypes.getName(type)) if $DEBUG && Input.press?(Input::CTRL)
    return type
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damageState.calcDamage>0
      id=attacker.pokemon.personalID
      stat1=((id>>24)&255)%5+1
      stat2=((id>>8)&255)%5+1
      showanim=true
      if stat1==stat2
        if attacker.pbCanReduceStatStage?(stat1,attacker,false,self)
          attacker.pbReduceStat(stat1,2,attacker,false,self,showanim)
          showanim=false
        end
      else
        if attacker.pbCanReduceStatStage?(stat1,attacker,false,self)
          attacker.pbReduceStat(stat1,1,attacker,false,self,showanim)
          showanim=false
        end
        if attacker.pbCanReduceStatStage?(stat2,attacker,false,self)
          attacker.pbReduceStat(stat2,1,attacker,false,self,showanim)
          showanim=false
        end
      end
    end
    return ret
  end
end

#===============================================================================
# Grants a side effect if affinity boosted.
# Effect is determined by the move's type. (Boost Moves)
#===============================================================================
class Battle::Move::AffinityBoostSideEffect < Battle::Move

  def pbBaseDamage(baseDmg,user,target)
    return baseDmg if @type != :NORMAL || !(user.affinityBooster || user.effects[PBEffects::HelpingHand])
    return baseDmg * 1.5
  end

  def pbEffectAfterAllHits(user,target)
    return if user.fainted?
    return if target.damageState.unaffected
    return if !(user.affinityBooster || user.effects[PBEffects::HelpingHand])
    weather = pbGetTypeWeather(@type)
    if weather
      if !([:HarshSun, :HeavyRain, :StrongWinds, :NoxiousStorm, weather].include?(@battle.field.weather))
        @battle.pbStartWeather(user, weather, true, false, 2)
      end
      return
    end
    terrain = pbGetTypeTerrain(@type)
    if terrain
      if @battle.field.terrain != terrain
        @battle.pbStartTerrain(user, terrain, true, 2)
      end
      return
    end
    stat = pbGetTypeRaiseStat(@type)
    if stat
      if user.pbCanRaiseStatStage?(stat, user, self)
        user.pbRaiseStatStage(stat, 1, user)
      end
      return
    end
  end

  def pbEffectAgainstTarget(user,target)
    return if target.fainted? || target.damageState.substitute
    return if !(user.affinityBooster || user.effects[PBEffects::HelpingHand])
    stat = pbGetTypeLowerStat(@type)
    return if stat.nil?
    if target.pbCanLowerStatStage?(stat, user, self)
      target.pbLowerStatStage(stat, 1, user)
    end
  end

  def pbGetTypeWeather(type)
    case @type
    when :FIRE
      return :Sun
    when :WATER
      return :Rain
    when :ICE
      return :Hail
    when :ROCK
      return :Sandstorm
    when :FLYING
      return :Winds
    end
    return nil
  end

  def pbGetTypeTerrain(type)
    case @type
    when :GRASS
      return :Grassy
    when :ELECTRIC
      return :Electric
    when :FAIRY
      return :Misty
    when :PSYCHIC
      return :Psychic
    end
    return nil
  end

  def pbGetTypeRaiseStat(type)
    case @type
    when :FIGHTING
      return :ATTACK
    when :STEEL
      return :DEFENSE
    when :POISON
      return :SPECIAL_ATTACK
    when :GROUND
      return :SPECIAL_DEFENSE
    end
    return nil
  end

  def pbGetTypeLowerStat(type)
    case @type
    when :DRAGON
      return :ATTACK
    when :GHOST
      return :DEFENSE
    when :BUG
      return :SPECIAL_ATTACK
    when :DARK
      return :SPECIAL_DEFENSE
    end
    return nil
  end
end

#===============================================================================
# This attack is always a critical hit if affinity boosted. (X-Scissor, Cut)
#===============================================================================
class Battle::Move::AlwaysCriticalHitWhenAffinityBoosted < Battle::Move
  def pbCritialOverride(user, target); return !(user.affinityBooster.nil?); end
end

#===============================================================================
# Halves the damage taken by allies until end of turn if affinity boosted. (Boreal Beam)
#===============================================================================
class Battle::Move::HalveTurnDamageWhenAffinityBoosted < Battle::Move
  def pbEffectGeneral(user)
    if user.affinityBooster && user.pbOwnSide.effects[PBEffects::AuroraVeil] == 0
      user.pbOwnSide.effects[PBEffects::AuroraVeil] = 1
      @battle.pbDisplay(_INTL("{1} made {2} stronger against physical and special moves!",
                            @name, user.pbTeam(true)))
    end
  end
end

#===============================================================================
# Attacks first turn, skips second turn if not affinity boosted (Blowout Blast).
#===============================================================================
class Battle::Move::AttackAndSkipNextTurnIfNotAffinityBoosted < Battle::Move
  def pbEffectGeneral(user)
    if user.affinityBooster
      @battle.pbDisplay(_INTL("The Affinity Boost made {1} not have to recharge!", user.pbThis))
      return
    end
    user.effects[PBEffects::HyperBeam] = 2
    user.currentMove = @id
  end
end

#===============================================================================
# Restored the user's consumed berry if affinity boosted. (Fruit Flourish)
#===============================================================================
class Battle::Move::RestoreBerryWhenAffinityBoosted < Battle::Move
  def pbEffectGeneral(user)
    if user.affinityBooster
      if !user.item && user.recycleItem && GameData::Item.get(user.recycleItem).is_berry?
        user.item = user.recycleItem
        user.setRecycleItem(nil)
        user.setInitialItem(user.item) if !user.initialItem
        @battle.pbDisplay(_INTL("{1} harvested one {2}!", user.pbThis, user.itemName))
        user.pbHeldItemTriggerCheck
      end
    end
  end
end

#===============================================================================
# Prevent the removal and changing of the user's item and ability
# until it switches out. Most logic handled elsewhere (Permanence)
#===============================================================================
class Battle::Move::ProtectUserAbilityAndItem < Battle::Move
  def canSnatch?; return true; end

  def pbMoveFailed?(user, targets)
    if user.effects[PBEffects::Permanence]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::Permanence] = true
    @battle.pbDisplay(_INTL("{1} is protecting its item and ability!", user.pbThis))
  end
end

#===============================================================================
# For 3 rounds, prevents the target from raising their stats. (Nihility)
#===============================================================================
class Battle::Move::PreventTargetStatIncreases < Battle::Move
  def canMagicCoat?; return true; end

  def pbFailsAgainstTarget?(user, target, show_message)
    if target.effects[PBEffects::Nihility] > 0
      @battle.pbDisplay(_INTL("But it failed!")) if show_message
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user, target)
    target.effects[PBEffects::Nihility] = 3
    @battle.pbDisplay(_INTL("{1} was prevented from raising its stats!", target.pbThis))
    target.pbItemStatusCureCheck
  end
end

#===============================================================================
# The move cannot be used in succession (Gigaton Hammer).
#===============================================================================
class Battle::Move::CannotUseTwiceInARow < Battle::Move
  def pbEffectGeneral(user)
    if user.hasActiveAbility?(:RELENTLESS) && user.affinityBooster
      @battle.pbShowAbilitySplash(user)
      @battle.pbDisplay(_INTL("The Affinity Boost made {1} not have to recharge!", user.pbThis))
      @battle.pbHideAbilitySplash(user)
      return
    end
    user.effects[PBEffects::GigatonHammer] = @id
    user.effects[PBEffects::GigatonHammerTime] = 2
  end
end

#===============================================================================
# Entry hazard. Plants a wiretap on the opposing side. (Wiretap)
#===============================================================================
class Battle::Move::AddWiretapToFoeSide < Battle::Move
  def canMagicCoat?; return true; end

  def pbMoveFailed?(user, targets)
    if user.pbOpposingSide.effects[PBEffects::Wiretap]
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::Wiretap] = true
    @battle.pbDisplay(_INTL("A wiretap is listening in on {1}!",
                            user.pbOpposingTeam(true)))
  end
end

#===============================================================================
# Test Move to ensure no AI logic crashes the game.
#===============================================================================
class Battle::Move::CrashTest < Battle::Move

  def pbEffectGeneral(user)

    @battle.pbDisplay("Starting Unit Test")

    cpus = [@battle.battlers[1], @battle.battlers[3]]

    @battle.battlers[0].item = :LIFEORB
    @battle.battlers[1].item = :LIFEORB
    @battle.battlers[2].item = nil
    @battle.battlers[3].item = nil

    for c in cpus

      @battle.pbDisplay(_INTL("Attacker = {1}", c.name))

      moves = GameData::Move.keys

      for i in 0...moves.length

        move = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(moves[i]))

        echoln _INTL("({1} / {2}): {3}", i + 1, moves.length, move.name)
        Graphics.update
        Input.update

        actionable = [true, true, true, true]
        fainted = [false, false, false, false]

        targets = @battle.pbPossibleTargets(c, move)

        damage = move.power

        statuses = [:NONE, :BURN, :PARALYSIS, :FROZEN, :SLEEP, :POISON]
        hp = [1.0, 0.6, 0.3] #[1.0, 0.75, 0.50, 0.25, 0.0]

        for i in 0..3
          @battle.battlers[i].status = statuses[i + 1]
        end

        for hp0 in hp
          @battle.battlers[0].hp = @battle.battlers[0].totalhp * hp0
          for hp1 in hp
            @battle.battlers[1].hp = @battle.battlers[1].totalhp * hp1
            for hp2 in hp
              @battle.battlers[2].hp = @battle.battlers[2].totalhp * hp2
              for hp3 in hp
                @battle.battlers[3].hp = @battle.battlers[3].totalhp * hp3
                if targets.length <= 0
                  @battle.pbGetEffectScore(move,damage,c,nil,actionable,fainted)
                else
                  for group in targets
                    for t in group
                      @battle.pbGetEffectScore(move,damage,c,t,actionable,fainted)
                    end
                  end
                end
              end
            end
          end
        end

        for i in 0..3
          @battle.battlers[i].hp = @battle.battlers[i].totalhp * (4 - i) / 4
        end

        @battle.battlers[0].ability = :CONTRARY
        @battle.battlers[1].ability = :CONTRARY

        if targets.length <= 0
          @battle.pbGetEffectScore(move,damage,c,nil,actionable,fainted)
        else
          for group in targets
            for t in group
              @battle.pbGetEffectScore(move,damage,c,t,actionable,fainted)
            end
          end
        end

        @battle.battlers[0].ability = :MAGICBOUNCE
        @battle.battlers[1].ability = :MAGICBOUNCE

        if targets.length <= 0
          @battle.pbGetEffectScore(move,damage,c,nil,actionable,fainted)
        else
          for group in targets
            for t in group
              @battle.pbGetEffectScore(move,damage,c,t,actionable,fainted)
            end
          end
        end

        @battle.battlers[0].ability = :GUTS
        @battle.battlers[1].ability = :GUTS
        @battle.battlers[2].ability = :MAGICGUARD
        @battle.battlers[3].ability = :MAGICGUARD

        if targets.length <= 0
          @battle.pbGetEffectScore(move,damage,c,nil,actionable,fainted)
        else
          for group in targets
            for t in group
              @battle.pbGetEffectScore(move,damage,c,t,actionable,fainted)
            end
          end
        end

        for s0 in statuses[0..2]
          @battle.battlers[0].status = s0
          for s1 in statuses[3..5]
            @battle.battlers[1].status = s1
            for s2 in statuses[0..2]
              @battle.battlers[2].status = s2
              for s3 in statuses[3..5]
                @battle.battlers[3].status = s3
                if targets.length <= 0
                  @battle.pbGetEffectScore(move,damage,c,nil,actionable,fainted)
                else
                  for group in targets
                    for t in group
                      @battle.pbGetEffectScore(move,damage,c,t,actionable,fainted)
                    end
                  end
                end
              end
            end
          end
        end

        for i in 0..3
          @battle.battlers[i].status = :NONE
        end
      end
    end

    @battle.pbDisplay("Finished Unit Test")

    return 0
  end

  def pbCreateMove(battle, id)
    move=Pokemon::Move.new(id)
    className=sprintf("PokeBattle_Move_%s", move.function_code)
    if Object.const_defined?(className)
      return Kernel.const_get(className).new(battle, move)
    else
      return PokeBattle_UnimplementedMove.new(battle, move)
    end
  end

end