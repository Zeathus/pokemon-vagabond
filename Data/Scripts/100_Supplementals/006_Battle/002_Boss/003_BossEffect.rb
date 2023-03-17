class BossEffect
  attr_reader :target_idx

  def initialize(trigger)
    @trigger = trigger
    @target_idx = nil
  end

  def set_target(target_idx)
    target_idx = [target_idx] if target_idx.is_a?(Numeric)
    @target_idx = target_idx
    return self
  end

  def activate(battle, triggerer, target)
    # Nothing
  end
end

class BossEff_Eval < BossEffect
  def initialize(trigger, code)
    super(trigger)
    @code = code
  end
  def activate(battle, triggerer, target)
    eval(@code)
  end
end

class BossEff_Message < BossEffect
  def initialize(trigger, msg)
    super(trigger)
    @msg = msg
  end
  def activate(battle, triggerer, target)
    msg = @msg.gsub("TARGET", target.pbThis)
    msg = msg.gsub("TRIGGERER", triggerer.pbThis)
    msg = msg.gsub("PLAYER", $player.name)
    battle.pbDisplay(msg)
  end
end

class BossEff_Dialog < BossEffect
  def initialize(trigger, dialog)
    super(trigger)
    @dialog = dialog
  end
  def activate(battle, triggerer, target)
    pbDialog(@dialog)
  end
end

class BossEff_Moveset < BossEffect
  def initialize(trigger, moves)
    super(trigger)
    @moves = moves
  end
  def activate(battle, triggerer, target)
    target.moves = []
    for m in @moves
      newMove = Pokemon::Move.new(m)
      target.moves.push(Battle::Move.from_pokemon_move(battle,newMove))
    end
  end
end

class BossEff_Item < BossEffect
  def initialize(trigger, item, force=false, showmsg=true)
    super(trigger)
    @item = item
    @force = force
    @showmsg = showmsg
  end
  def activate(battle, triggerer, target)
    if !force
      if target.unlosableItem?(target.item)
        battle.pbDisplay(_INTL("But it failed!")) if @showmsg
        return false
      end
      if target.hasActiveAbility?(:STICKYHOLD) && !battle.moldBreaker
        if @showmsg
          battle.pbShowAbilitySplash(target)
          if Battle::Scene::USE_ABILITY_SPLASH
            battle.pbDisplay(_INTL("But it failed to affect {1}!",target.pbThis(true)))
          else
            battle.pbDisplay(_INTL("But it failed to affect {1} because of its {2}!",
              target.pbThis(true),target.abilityName))
          end
          battle.pbHideAbilitySplash(target)
        end
        return false
      end
    end
    target.item = @item
  end
end

class BossEff_Ability < BossEffect
  def initialize(trigger, ability, showmsg=true)
    super(trigger)
    @ability = ability
    @showmsg = showmsg
  end
  def activate(battle, triggerer, target)
    battle.pbShowAbilitySplash(target,true,false) if @showmsg
    oldAbil = target.ability
    target.ability = @ability
    if @showmsg
      battle.pbReplaceAbilitySplash(target)
      battle.pbDisplay(_INTL("{1} acquired {2}!",target.pbThis,target.abilityName))
      battle.pbHideAbilitySplash(target)
    end
    target.pbOnLosingAbility(oldAbil)
    target.pbTriggerAbilityOnGainingIt
  end
end

class BossEff_Species < BossEffect
  def initialize(trigger, species)
    super(trigger)
    @species = species
  end
  def activate(battle, triggerer, target)
    hp_percent = target.hp * 1.0 / target.totalhp
    level = target.level
    target.pokemon.species = @species
    target.species = @species
    target.pbUpdate(true)
    target.level = level
    target.pokemon.level = level
    target.pbUpdate
    target.hp = [(target.totalhp * hp_percent).round,1].max
    pbBoss.changePokemon(battle,target,target.pokemon)
  end
end

class BossEff_Form < BossEffect
  def initialize(trigger, form)
    super(trigger)
    @form = form
  end
  def activate(battle, triggerer, target)
    target.pbChangeForm(@form, nil)
  end
end

class BossEff_Level < BossEffect
  def initialize(trigger, level)
    super(trigger)
    @level = level
  end
  def activate(battle, triggerer, target)
    if @level + target.pokemon.level > 100
      target.pokemon.level = 100
      target.level = 100
    elsif @level + target.pokemon.level < 1
      target.pokemon.level = 1
      target.level = 1
    else
      target.pokemon.level += @level
      target.level += @level
    end
    hp_percent = target.hp * 1.0 / target.totalhp
    target.pbUpdate
    target.hp = [(target.totalhp * hp_percent).round,1].max
  end
end

class BossEff_ChangeStat < BossEffect
  def initialize(trigger, stats, stages, showAnim=true)
    super(trigger)
    stats = [stats] if !stats.is_a?(Array)
    if !stages.is_a?(Array)
      stages = [stages] * stats.length
    end
    @stats = stats
    @stages = stages
    @showAnim = showAnim
  end
  def activate(battle, triggerer, target)
    showAnim = @showAnim
    for i in 0...@stats.length
      stat = @stats[i]
      stage = @stages[i]
      if stage > 0
        if target.pbRaiseStatStage(stat,stage,triggerer,showAnim)
          showAnim = false
        end
      elsif stage < 0
        if target.pbLowerStatStage(stat,-stage,triggerer,showAnim)
          showAnim = false
        end
      else
        target.stages[stat] = stage
      end
    end
  end
end

class BossEff_SetStat < BossEffect
  def initialize(trigger, stats, stages)
    super(trigger)
    stats = [stats] if !stats.is_a?(Array)
    if !stages.is_a?(Array)
      stages = [stages] * stats.length
    end
    @stats = stats
    @stages = stages
  end
  def activate(battle, triggerer, target)
    for i in 0...@stats.length
      stat = @stats[i]
      stage = @stages[i]
      target.stages[stat] = stage
    end
  end
end

class BossEff_Invincible < BossEffect
  def initialize(trigger, state)
    super(trigger)
    @state = state
  end
  def activate(battle, triggerer, target)
    pbMessage("Invincible is unimplemented")
  end
end

class BossEff_WinBattle < BossEffect
  def initialize(trigger)
    super(trigger)
  end
  def activate(battle, triggerer, target)
    battle.decision = 1
  end
end

class BossEff_LoseBattle < BossEffect
  def initialize(trigger)
    super(trigger)
  end
  def activate(battle, triggerer, target)
    battle.decision = 2
  end
end

class BossEff_EndBattle < BossEffect
  def initialize(trigger)
    super(trigger)
  end
  def activate(battle, triggerer, target)
    battle.decision = 3
  end
end

class BossEff_Damage < BossEffect
  def initialize(trigger, damage)
    super(trigger)
    @damage = damage
  end
  def activate(battle, triggerer, target)
    if !target.fainted?
      losehp = (@damage * target.totalhp / 100.0).floor
      losehp = target.hp if losehp > target.hp
      battle.scene.pbDamageAnimation(target)
      target.pbReduceHP(losehp)
    end
  end
end

class BossEff_FixedDamage < BossEffect
  def initialize(trigger, damage)
    super(trigger)
    @damage = damage
  end
  def activate(battle, triggerer, target)
    if !target.fainted?
      losehp = @damage
      losehp = target.hp if losehp > target.hp
      battle.scene.pbDamageAnimation(target)
      target.pbReduceHP(losehp)
    end
  end
end

class BossEff_Faint < BossEffect
  def initialize(trigger)
    super(trigger)
  end
  def activate(battle, triggerer, target)
    if !target.fainted?
      losehp = target.hp
      battle.scene.pbDamageAnimation(target)
      target.pbReduceHP(losehp)
      target.pbFaint
    end
  end
end

class BossEff_DamageParty < BossEffect
  def initialize(trigger, damage)
    super(trigger)
    @damage = damage
  end
  def activate(battle, triggerer, target)
    party = battle.pbParty(@target_idx)
    for i in 0...party.length
      if i != target.pokemonIndex
        pkmn = party[i]
        losehp = (@damage * target.totalhp / 100.0).floor
        losehp = target.hp if losehp > target.hp
        pkmn.hp -= losehp
      end
    end
  end
end

class BossEff_FixedDamageParty < BossEffect
  def initialize(trigger, damage)
    super(trigger)
    @damage = damage
  end
  def activate(battle, triggerer, target)
    party = battle.pbParty(@target_idx)
    for i in 0...party.length
      if i != target.pokemonIndex
        pkmn = party[i]
        losehp = @damage
        losehp = target.hp if losehp > target.hp
        pkmn.hp -= losehp
      end
    end
  end
end

class BossEff_Status < BossEffect
  def initialize(trigger, status, statusCount=0, showmsg=true)
    super(trigger)
    @status = status
    @statusCount = statusCount
    @showmsg = showmsg
  end
  def activate(battle, triggerer, target)
    if target.pbCanInflictStatus?(@status, triggerer, @showmsg, nil)
      target.pbInflictStatus(@status, @statusCount, nil, triggerer)
    end
  end
end

class BossEff_HealStatus < BossEffect
  def initialize(trigger, statuses=[:BURN,:SLEEP,:POISON,:PARALYSIS,:FREEZE])
    super(trigger)
    statuses = [statuses] if !statuses.is_a?(Array)
    @statuses = statuses
  end
  def activate(battle, triggerer, target)
    if @statuses.include?(target.status)
      old_status = user.status
      target.pbCureStatus(false)
      case old_status
      when :BURN
        battle.pbDisplay(_INTL("{1} healed its burn!",target.pbThis))
      when :POISON
        battle.pbDisplay(_INTL("{1} cured its poisoning!",target.pbThis))
      when :PARALYSIS
        battle.pbDisplay(_INTL("{1} cured its paralysis!",target.pbThis))
      when :FREEZE
        battle.pbDisplay(_INTL("{1} thawed itself out!",target.pbThis))
      when :SLEEP
        battle.pbDisplay(_INTL("{1} woke itself up!",target.pbThis))
      when :FROSTBITE
        battle.pbDisplay(_INTL("{1} healed its frostbite!",target.pbThis))
      end
    end
  end
end

class BossEff_Weather < BossEffect
  def initialize(trigger, weather, duration=5)
    super(trigger)
    @weather = weather
    @duration = duration
  end
  def activate(battle, triggerer, target)
    case battle.field.weather
    when :HarshSun
      return false
    when :HeavyRain
      return false
    when :StrongWinds
      return false
    when @weather
      return false
    end
    battle.pbStartWeather(target, @weather, true, false, @duration)
  end
end

class BossEff_Terrain < BossEffect
  def initialize(trigger, terrain, duration=5)
    super(trigger)
    @terrain = terrain
    @duration = duration
  end
  def activate(battle, triggerer, target)
    if battle.field.terrain == @terrain
      return false
    end
    battle.pbStartTerrain(target, @terrain, true, @duration)
  end
end

class BossEff_UseMove < BossEffect
  def initialize(trigger, move, move_target_idx=-1)
    super(trigger)
    @move = move
    @move_target_idx = move_target_idx
  end
  def activate(battle, triggerer, target)
    if @move_target_idx == -1
      target.effects[PBEffects::Instructed] = true
      target.pbUseMoveSimple(@move,-1,-1,false)
      target.effects[PBEffects::Instructed] = false
    else
      possible_targets = []
      if @move_target_idx.is_a?(Array)
        for t in @move_target_idx
          if !battle.battlers[t].fainted?
            possible_targets.push(battle.battlers[t])
          end
        end
      else
        if !battle.battlers[@move_target_idx].fainted?
          possible_targets.push(battle.battlers[@move_target_idx])
        end
      end
      move_target = possible_targets.shuffle[0]
      target.effects[PBEffects::Instructed] = true
      target.pbUseMoveSimple(@move,move_target.index,-1,false)
      target.effects[PBEffects::Instructed] = false
    end
  end
end

class BossEff_RemoveTrigger < BossEffect
  def initialize(trigger)
    super(trigger)
  end
  def activate(battle, triggerer, target)
    @trigger.disable
  end
end

class BossEff_AddTrigger < BossEffect
  def initialize(trigger, add_trigger)
    super(trigger)
    @add_trigger = add_trigger
  end
  def activate(battle, triggerer, target)
    pbBoss.add(@add_trigger)
  end
end

class BossEff_NextPhase < BossEffect
  def activate(battle, triggerer, target)
    if pbBoss.nextphase
      $game_variables[Supplementals::BOSS_BATTLE] = pbBoss.nextphase
    end
  end
end

class BossEff_Gauge < BossEffect
  def initialize(trigger, gauge, operator, value)
    super(trigger)
    @gauge = gauge
    @operator = operator
    @value = value
  end
  def activate(battle, triggerer, target)
    @gauge.value = @gauge.value.send(@operator, @value)
    @gauge.update(battle)
    battle.scene.pbRefresh
  end
end

class BossEff_SetGauge < BossEffect
  def initialize(trigger, gauge, value)
    super(trigger)
    @gauge = gauge
    @value = value
  end
  def activate(battle, triggerer, target)
    @gauge.value = @value
    @gauge.update(battle)
    battle.scene.pbRefresh
  end
end

class BossEff_DisableGauge < BossEffect
  def initialize(trigger, gauge)
    super(trigger)
    @gauge = gauge
  end
  def activate(battle, triggerer, target)
    @gauge.enabled = false
    battle.scene.pbRefresh
  end
end

class BossEff_EnableGauge < BossEffect
  def initialize(trigger, gauge)
    super(trigger)
    @gauge = gauge
  end
  def activate(battle, triggerer, target)
    @gauge.enabled = true
    battle.scene.pbRefresh
  end
end

class BossEff_AddGauge < BossEffect
  def initialize(trigger, gauge)
    super(trigger)
    @gauge = gauge
  end
  def activate(battle, triggerer, target)
    pbBoss.add_gauge(@gauge)
    battle.scene.pbRefresh
  end
end


### VISUAL / AUDIO EFFECTS

class BossEff_Background < BossEffect
  def initialize(trigger, arg)
    super(trigger)
    @arg = arg
  end
  def activate(battle, triggerer, target)
    pbMessage("Background Unimplemented")
  end
end

class BossEff_BGM < BossEffect
  def initialize(trigger, name, vol=100, pitch=100)
    super(trigger)
    @name = name
    @vol = vol
    @pitch = pitch
  end
  def activate(battle, triggerer, target)
    pbBGMPlay(@name, @vol, @pitch)
  end
end

class BossEff_SE < BossEffect
  def initialize(trigger, name, vol=100, pitch=100)
    super(trigger)
    @name = name
    @vol = vol
    @pitch = pitch
  end
  def activate(battle, triggerer, target)
    pbSEPlay(@name, @vol, @pitch)
  end
end

class BossEff_Cry < BossEffect
  def initialize(trigger, species, vol=100, pitch=100)
    super(trigger)
    @species = species
    @vol = vol
    @pitch = pitch
  end
  def activate(battle, triggerer, target)
    GameData::Species.play_cry(@species, @vol, @pitch)
  end
end

class BossEff_MoveAnim < BossEffect
  def initialize(trigger, move, move_target_idx)
    super(trigger)
    @move = move
    @move_target_idx = move_target_idx
  end
  def activate(battle, triggerer, target)
    move_target = battle.battlers[@move_target_idx]
    battle.pbAnimation(move, target, move_target)
  end
end

class BossEff_CommonAnim < BossEffect
  def initialize(trigger, anim)
    super(trigger)
    @anim = anim
  end
  def activate(battle, triggerer, target)
    battle.pbCommonAnimation(@anim,triggerer,nil)
  end
end

class BossEff_MoveOut < BossEffect
  def initialize(trigger)
    super(trigger)
  end
  def activate(battle, triggerer, target)
    if !pbBoss.outside
      24.times do
        battle.scene.sprites[_INTL("pokemon{1}", @target_idx)].x+=12
        battle.scene.sprites[_INTL("shadow{1}", @target_idx)].x+=12
        Graphics.update
        Input.update
      end
      pbBoss.outside = true
    end
  end
end

class BossEff_MoveIn < BossEffect
  def initialize(trigger)
    super(trigger)
  end
  def activate(battle, triggerer, target)
    if pbBoss.outside
      24.times do
        battle.scene.sprites[_INTL("pokemon{1}", @target_idx)].x-=12
        battle.scene.sprites[_INTL("shadow{1}", @target_idx)].x-=12
        Graphics.update
        Input.update
      end
      pbBoss.outside = false
    end
  end
end

class BossEff_Flash < BossEffect
  def initialize(trigger, arg)
    super(trigger)
    @arg = arg
  end
  def activate(battle, triggerer, target)

  end
end

class BossEff_Shake < BossEffect
  def initialize(trigger, arg)
    super(trigger)
    @arg = arg
  end
  def activate(battle, triggerer, target)

  end
end

class BossEff_ScreenTone < BossEffect
  def initialize(trigger, arg)
    super(trigger)
    @arg = arg
  end
  def activate(battle, triggerer, target)

  end
end

class BossEff_Wait < BossEffect
  def initialize(trigger, frames)
    super(trigger)
    @frames = frames
  end
  def activate(battle, triggerer, target)
    @frames.times do
      Graphics.update
      Input.update
    end
  end
end 