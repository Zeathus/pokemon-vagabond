class Battle

  def eachMoveIndexCombo(idxBattlers)
    return if idxBattlers.length == 0
    b0 = idxBattlers[0]
    @battlers[b0].eachMoveWithIndex do |m0,i0|
      if idxBattlers.length == 1
        yield i0, nil, nil
      else
        b1 = idxBattlers[1]
        @battlers[b1].eachMoveWithIndex do |m1,i1|
          if idxBattlers.length == 2
            yield i0, i1, nil
          else
            b2 = idxBattlers[2]
            @battlers[b2].eachMoveWithIndex do |m2,i2|
              yield i0, i1, i2
            end
          end
        end
      end
    end
  end

  def pbRoughPriority(user, move)
    pri = move.priority
    if user.abilityActive?
      pri = Battle::AbilityEffects.triggerPriorityChange(user.ability, user, move, pri)
    end
    return pri
  end

  def pbPossibleTargets(user, move)
    # The user is a catch-all target used to only calculate effect scores once, instead of once for all battlers affected by the move
    ret = []
    if [:None, :User, :UserOrNearAlly, :UserAndAllies, :AllBattlers, :AllBattlers, :UserSide, :FoeSide, :BothSides].include?(move.target)
      ret.push([user])
    end
    if [:NearAlly, :UserOrNearAlly, :NearOther].include?(move.target)
      user.eachAlly do |b|
        ret.push([b]) if b.near?(user)
      end
    end
    if [:NearFoe, :RandomNearFoe, :NearOther].include?(move.target)
      user.eachOpposing do |b|
        ret.push([b]) if b.near?(user)
      end
    end
    if [:Other].include?(move.target)
      user.eachOpposing do |b|
        ret.push([b])
      end
    end
    if [:AllNearFoes].include?(move.target)
      t = []
      user.eachOpposing do |b|
        t.push(b) if b.near?(user)
      end
      ret.push(t)
    end
    if [:AllNearOthers].include?(move.target)
      t = []
      eachBattler do |b|
        t.push(b) if b != user
      end
      ret.push(t)
    end
    # Check for redirection within each possible target
    if [:NearOther, :NearFoe, :RandomNearFoe, :NearOther, :Other].include?(move.target)
      for group in ret
        b = group[0]
        if (move.type == :WATER && b.hasActiveAbility?(:STORMDRAIN)) ||
           move.type == :ELECTRIC && b.hasActiveAbility?(:LIGHTNINGROD)
          return [group]
        end
      end
    end
    return ret
  end

  def pbShowScores(scores, idxBattlers)

    if idxBattlers.length > 2
      pbDisplay("Showing scores only work for up to 2 opponents.")
      return
    end

    viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z = 999999
    viewport.ox = 0
    viewport.oy = 0

    bg = Sprite.new(viewport)
    bg.bitmap = Bitmap.new(512,384)
    bg.bitmap.fill_rect(0,0,512,384,Color.new(0,0,0))
    bg.opacity = 150
    bg.x = 128
    bg.y = 96

    text = Sprite.new(viewport)
    text.bitmap = Bitmap.new(512,384)
    pbSetSmallestFont(text.bitmap)
    text.x = 128
    text.y = 96

    base = Color.new(252,252,252)
    shadow = Color.new(0,0,0)

    textpos = []

    if idxBattlers.length == 1
      user = @battlers[idxBattlers[0]]
      user.eachMoveWithIndex do |m, i|
        textpos.push([m.name,110 + 100 * i,80,0,base,shadow,1])
        textpos.push([sprintf("%.2f",scores[i]),110 + 100 * i,120,0,base,shadow,1])
      end
    elsif idxBattlers.length == 2
      user1 = @battlers[idxBattlers[0]]
      user2 = @battlers[idxBattlers[1]]
      user1.eachMoveWithIndex do |m, i|
        textpos.push([user1.moves[i].name,110 + 100 * i,80,0,base,shadow,1])
      end
      user2.eachMoveWithIndex do |m, j|
        textpos.push([user2.moves[j].name,10,120 + j * 40,0,base,shadow,1])
      end
      user1.eachMoveWithIndex do |m1, i|
        user2.eachMoveWithIndex do |m2, j|
          textpos.push([sprintf("%.2f",scores[i][j]),110 + 100 * i,120 + j * 40,0,base,shadow,1])
        end
      end
    else
      pbDisplay("Showing scores only work for up to 2 opponents.")
    end

    if textpos.length > 0
      pbDrawTextPositions(text.bitmap,textpos)

      8.times do
        bg.update
        text.update
        viewport.update
        Graphics.update
        Input.update
      end

      while !Input.trigger?(Input::C)
        bg.update
        text.update
        viewport.update
        Graphics.update
        Input.update
      end
    end

    bg.dispose
    text.dispose
    viewport.dispose

  end

  def pbWriteLogTurn(scores, idxBattlers, will_switch, max_score, max_index, max_target)
    return if !@battle_log
    @battle_log.write(_INTL(">>> TURN {1} <<<\n", @turnCount))
    @battle_log.write("Global Field:\n")
    @battle_log.write(_INTL("  > Weather: {1} {2}\n", @field.weather.to_s, @field.weatherDuration))
    @battle_log.write(_INTL("  > Terrain: {1} {2}\n", @field.terrain.to_s, @field.terrainDuration))
    field_effects = [
      :Gravity,
      :MagicRoom,
      :WonderRoom,
      :TrickRoom,
      :WaterSportField,
      :MudSportField
    ]
    for i in field_effects
      field_effect = getID(PBEffects, i)
      value = @field.effects[field_effect]
      if value == true
        @battle_log.write(_INTL("  > {1}: Active\n", i.to_s))
      elsif value && value > 0
        @battle_log.write(_INTL("  > {1}: {2}\n", i.to_s, value))
      end
    end
    field_effects = [
      :Reflect,
      :LightScreen,
      :AuroraVeil,
      :Safeguard,
      :LuckyChant,
      :Mist,
      :Rainbow,
      :SeaOfFire,
      :Swamp,
      :Tailwind,
      :Spikes,
      :ToxicSpikes,
      :StealthRock,
      :StickyWeb
    ]
    @battle_log.write("Player's Field:\n")
    for i in field_effects
      field_effect = getID(PBEffects, i)
      value = @sides[0].effects[field_effect]
      if value == true
        @battle_log.write(_INTL("  > {1}: Active\n", i.to_s))
      elsif value && value > 0
        @battle_log.write(_INTL("  > {1}: {2}\n", i.to_s, value))
      end
    end
    @battle_log.write("Opponent's Field:\n")
    for i in field_effects
      field_effect = getID(PBEffects, i)
      value = @sides[1].effects[field_effect]
      if value == true
        @battle_log.write(_INTL("  > {1}: Active\n", i.to_s))
      elsif value && value > 0
        @battle_log.write(_INTL("  > {1}: {2}\n", i.to_s, value))
      end
    end
    @battle_log.write("Player's Pokemon:\n")
    eachSameSideBattler(0) { |b|
      pbWriteLogBattlerState(b)
    }
    @battle_log.write("Opponent's Pokemon:\n")
    eachOtherSideBattler(0) { |b|
      pbWriteLogBattlerState(b)
    }
    if idxBattlers.length == 1
      @battle_log.write("Move Scores:\n")
      user = @battlers[idxBattlers[0]]
      user.eachMoveWithIndex do |m, i|
        @battle_log.write(sprintf("  > %16s: %.2f\n", m.name, scores[i]))
      end
      @battle_log.write("AI Choice:\n")
      if will_switch[idxBattlers[0]]
        @battle_log.write(_INTL("  > Switch\n", ))
      else
        move = user.moves[max_index[0]]
        target = @battlers[max_target[0]]
        @battle_log.write(_INTL("  > Use {1} on {2}\n", move.name, target.species.to_s))
      end
    elsif idxBattlers.length == 2
      @battle_log.write("Move Scores:\n")
      user1 = @battlers[idxBattlers[0]]
      user2 = @battlers[idxBattlers[1]]
      @battle_log.write(sprintf("  %16s", ""))
      user1.eachMoveWithIndex do |m, i|
        @battle_log.write(sprintf(" %16s", m.name))
      end
      @battle_log.write("\n")
      user2.eachMoveWithIndex do |m2, j|
        @battle_log.write(sprintf("  %16s", m2.name))
        user1.eachMoveWithIndex do |m1, i|
          @battle_log.write(sprintf(" %16s", sprintf("%.2f", scores[i][j])))
        end
        @battle_log.write("\n")
      end
      @battle_log.write("AI Choice:\n")
      for i in 0...2
        battler = @battlers[idxBattlers[i]]
        if will_switch[idxBattlers[i]]
          @battle_log.write(_INTL("  > {1}: Switch\n", battler.species.to_s))
        else
          move = battler.moves[max_index[i]]
          target = @battlers[max_target[i]]
          @battle_log.write(_INTL("  > {1}: Use {2} on {3}\n", battler.species.to_s, move.name, target.species.to_s))
        end
      end
    end
    @battle_log.write("\n\n")
  end

  def pbWriteLogBattlerState(b)
    effects = [
      :AquaRing,
      :Confusion,
      :Curse,
      :Embargo,
      :FocusEnergy,
      :GastroAcid,
      :HealBlock,
      :Ingrain,
      :LaserFocus,
      :LeechSeed,
      :LockOn, :LockOnPos,
      :MagnetRise,
      :PerishSong, :PerishSongUser,
      :PowerTrick,
      :Substitute,
      :Telekinesis,
      :Bide,
      :BideDamage, :BideTarget,
      :BurnUp,
      :Charge,
      :DefenseCurl,
      :Disable, :DisableMove,
      :Encore, :EncoreMove,
      :FlashFire,
      :Foresight,
      :FuryCutter,
      :HyperBeam,
      :Imprison,
      :MagicBounce,
      :MeanLook,
      :Minimize,
      :MudSport,
      :WaterSport,
      :Nightmare,
      :Outrage,
      :Pinch,
      :Powder,
      :Prankster,
      :ProtectRate,
      :Rollout,
      :SkyDrop,
      :SlowStart,
      :SmackDown,
      :Stockpile,
      :Taunt,
      :ThroatChop,
      :Torment,
      :Toxic,
      :Trapping, :TrappingMove, :TrappingUser,
      :Truant,
      :TwoTurnAttack,
      :Type3,
      :Unburden,
      :Uproar,
      :WeightChange,
      :Yawn,
      :CorrosiveAcid
    ]
    @battle_log.write(_INTL("  > Lv. {1} {2} {3}\n", b.level, b.species.to_s, ["M", "F", ""][b.gender]))
    if b.types.length == 1
      @battle_log.write(_INTL("    Types:   {1} - {2}\n", b.types[0], b.pokemon.affinities[0]))
    else
      @battle_log.write(_INTL("    Types:   {1}/{2} - {3}\n", b.types[0], b.types[1], b.pokemon.affinities[0]))
    end
    @battle_log.write(_INTL("    HP:      {1} / {2} ({3}%)\n", b.hp.to_i, b.totalhp, (b.hp * 100 / b.totalhp).to_i))
    @battle_log.write(_INTL("    Status:  {1} {2}\n", b.status.to_s, (b.statusCount > 0) ? b.statusCount : 0))
    @battle_log.write(_INTL("    Ability: {1}\n", b.ability.name))
    @battle_log.write(_INTL("    Item:    {1}\n", b.item.to_s))
    @battle_log.write(_INTL("    Moves:  "))
    for i in b.moves
      @battle_log.write(_INTL(" {1}|{2}PP", i.name, i.pp))
    end
    @battle_log.write("\n")
    @battle_log.write(_INTL("    Stages: "))
    GameData::Stat.each_battle do |s|
      if b.stages[s.id] > 0
        @battle_log.write(_INTL(" +{1}{2}", b.stages[s.id], s.real_name_brief))
      elsif b.stages[s.id] < 0
        @battle_log.write(_INTL(" {1}{2}", b.stages[s.id], s.real_name_brief))
      end
    end
    @battle_log.write("\n")
    @battle_log.write(_INTL("    Effects:\n"))
    for i in effects
      effect = getID(PBEffects, i)
      value = b.effects[effect]
      if effect == PBEffects::ProtectRate
        if value != 1
          @battle_log.write(_INTL("      > {1}: {2}\n", i.to_s, value.to_s))
        end
      elsif value == true
        @battle_log.write(_INTL("      > {1}: Active\n", i.to_s))
      elsif value && value.is_a?(Numeric) && value > 0
        @battle_log.write(_INTL("      > {1}: {2}\n", i.to_s, value.to_s))
      elsif value && value.is_a?(Symbol)
        @battle_log.write(_INTL("      > {1}: {2}\n", i.to_s, value.to_s))
      #elsif value && value.is_a?(Move)
      #  @battle_log.write(_INTL("      > {1}: {2}\n", i.to_s, value.name))
      #elsif value && value.is_a?(Battler)
      #  @battle_log.write(_INTL("      > {1}: {2}\n", i.to_s, value.name))
      elsif value && value != 0 && value != -1
        @battle_log.write(_INTL("      > {1}: {2}\n", i.to_s, value.to_s))
      end
    end
  end

  def pbPrintQueue(queue)

    str = "Queue:"
    for i in queue
      str += " "
      str += @battlers[i].name
    end
    pbMessage(str)

  end

end

class Battle::Move

  def pbPredictDamage(user, target, numTargets, queue, boost, options = 0)
    calcType = pbCalcType(user)
    target.damageState.typeMod = pbCalcTypeMod(calcType, user, target)
    if (pbImmunityByAbility(user, target, false)) ||
        (Effectiveness.ineffective?(target.damageState.typeMod)) ||
        (calcType == :GROUND && target.airborne? && !hitsFlyingTargets?)
      target.damageState.reset
      return 0
    end
    dmg = pbCalcDamage(user, target, numTargets)
    if boost
      dmg *= 1.3
    end
    @battle.eachBattler do |b|
      b.damageState.reset
    end
    return dmg
  end

end 