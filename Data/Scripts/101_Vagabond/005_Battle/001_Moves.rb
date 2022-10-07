#===============================================================================
# Target steel type becomes susceptible to Poison-type moves (Corrosive Acid)
#===============================================================================
class Battle::Move::StartNegateTargetPoisonImmunity < Battle::Move
  def pbMoveFailed?(user,targets)
    if target.effects[PBEffects::CorrosiveAcid] ||
      !target.pbHasType(:STEEL)
      @battle.pbDisplay(_INTL("But it failed!")) if !@battle.predictingDamage
      return true
    end
    return false
  end

  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::CorrosiveAcid] = true
    @battle.pbDisplay(_INTL("{1} became susceptible to Poison-type moves!",target.pbThis))
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
      if !([:HarshSun, :HeavyRain, :StrongWinds, weather].include?(@battle.field.weather))
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

class Battle::Move::CrashTest < Battle::Move

  def pbEffectGeneral(user)

    @battle.pbDisplay("Starting Unit Test")

    cpus = [@battle.battlers[1], @battle.battlers[3]]

    @battle.battlers[0].item = :LIFEORB
    @battle.battlers[1].item = :LIFEORB
    @battle.battlers[2].item = 0
    @battle.battlers[3].item = 0
    viewport = Viewport.new(0,0,640,480)
    viewport.z = 999999
    sprite = Sprite.new(viewport)
    bitmap = Bitmap.new(512, 200)
    pbSetSystemFont(bitmap)
    sprite.bitmap = bitmap
    sprite.x = Graphics.width / 2 - 256
    sprite.y = Graphics.height / 2 - 100
    base = Color.new(252,252,252)
    shadow = Color.new(0,0,0)

    for c in cpus[1..1]

      @battle.pbDisplay(_INTL("Attacker = {1}", c.name))

      for i in 1..676

        move = self.pbCreateMove(@battle, i)

        bitmap.clear
        textpos=[["Move ID: "+i.to_s + " | " + move.name,256,100,2,base,shadow,1]]
        pbDrawTextPositions(bitmap,textpos)
        sprite.update
        viewport.update
        Graphics.update
        Input.update

        actionable = [true, true, true, true]
        fainted = [false, false, false, false]

        targets = @battle.pbPossibleTargets(c, move)

        damage = move.baseDamage

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

    sprite.dispose
    viewport.dispose

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