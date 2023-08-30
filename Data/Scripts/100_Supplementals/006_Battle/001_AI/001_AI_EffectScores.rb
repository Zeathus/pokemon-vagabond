class Battle::Battler

  def allyHasActiveAbility?(abil)
    eachAlly do |b|
      return true if b.hasActiveAbility?(abil)
    end
    return false
  end

  def allyHasActiveItem?(abil)
    eachAlly do |b|
      return true if b.hasActiveItem?(item)
    end
    return false
  end

  def opposingHasActiveAbility?(abil)
    eachOpposing do |b|
      return true if b.hasActiveAbility?(abil)
    end
    return false
  end

  def opposingHasActiveItem?(abil)
    eachOpposing do |b|
      return true if b.hasActiveItem?(item)
    end
    return false
  end

  def sameSideHasActiveAbility?(abil)
    @battle.eachSameSideBattler(@index) do |b|
      return true if b.hasActiveAbility?(abil)
    end
    return false
  end

  def eachOpposingMove
    eachOpposing do |b|
      b.eachMove do |m|
        yield m
      end
    end
  end

  def eachAllyMove
    eachAlly do |b|
      b.eachMove do |m|
        yield m
      end
    end
  end

  def eachSameSideMove
    @battle.eachSameSideBattler(@index) do |b|
      b.eachMove do |m|
        yield m
      end
    end
  end

end

class Battle
    def pbGetEffectScore(move,damage,user,target,actionable,fainted,chosen=false)
      score = 0

      if @battleAI.pbCheckMoveImmunity(1, move, user, target, PBTrainerAI.bestSkill)
        return score
      end

      ### Get opponent statistics
      physical_opponents = 0
      special_opponents = 0
      status_opponents = 0
      opponent_speeds = []

      user_hp_percent = [user.hp * 1.0 / user.totalhp, 1.0].min
      target_hp_percent = [target.hp * 1.0 / target.totalhp, 1.0].min

      unnerve = false

      user.eachOpposing do |b|
        opponent_speeds.push(b.pbSpeed)
        has_physical = false
        has_special = false
        has_status = false
        for m in b.moves
          if m.physicalMove?
            has_physical = true if m.baseDamage > 40
          elsif m.specialMove?
            has_special = true if m.baseDamage > 40
          else
            has_status = true
          end
        end
        physical_opponents += 1 if has_physical
        special_opponents += 1 if has_special
        status_opponents += 1 if has_status

        unnerve = true if b.hasActiveAbility?(:UNNERVE)
      end

      target_has_physical = false
      target_has_special = false
      target_has_status = false
      target_speed = 0
      target_item = nil
      if target
        if target.knownItem
          if target.hasActiveItem?(:AEGISTALISMAN)
            target_item = :AEGISTALISMAN
          end
        end
        target_speed = target.pbSpeed
        for m in target.moves
          if m.physicalMove?
            target_has_physical = true if m.baseDamage > 40
          elsif m.specialMove?
            target_has_special = true if m.baseDamage > 40
          else
            target_has_status = true
          end
        end
      end


      ## Get user statistics
      speed_stat = user.pbSpeed
      has_physical = false
      has_special = false
      has_status = false
      for m in user.moves
        if m.physicalMove?
          has_physical = true if m.baseDamage > 40
        elsif m.specialMove?
          has_special = true if m.baseDamage > 40
        else
          has_status = true
        end
      end

      partner = false

      ally_speeds = [speed_stat]
      user.eachAlly do |b|
        ally_speeds.push(b.pbSpeed)
        partner = true
      end

      moldbreaker = user.hasActiveAbility?(:MOLDBREAKER)

      if target
        # Try to destroy balloons
        if target.hasActiveItem?(:AIRBALLOON) &&
           (move.physicalMove? || move.specialMove?)
          score += 10
        end

        # Try to trigger weakening abilities
        if target.hasActiveAbility?(:DEFEATIST) ||
           target.hasActiveAbility?(:WIMPOUT) ||
           target.hasActiveAbility?(:EMERGENCYEXIT)
          if target.hp > target.totalhp * 0.5 && (target.hp - damage) < target.totalhp * 0.5
            score += 20
          end
        end
        if target.hasActiveAbility?(:SCHOOLING)
          if target.hp > target.totalhp * 0.25 && (target.hp - damage) < target.totalhp * 0.25
            score += 20
          end
        end

        if move.pbContactMove?(user)
          # Reduce score for recoil
          if target.hasActiveAbility?(:ROUGHSKIN) ||
             target.hasActiveAbility?(:IRONBARBS)
            score -= 5
          end
          if target.hasActiveItem?(:ROCKYHELMET)
            score -= 10
          end
        end
      end

      # Try to use a Gem to activate Unburden
      if user.hasActiveAbility?(:UNBURDEN)
        if (move.type == :NORMAL && user.hasActiveItem?(:NORMALGEM)) ||
           (move.type == :FIRE && user.hasActiveItem?(:FIREGEM)) ||
           (move.type == :WATER && user.hasActiveItem?(:WATERGEM)) ||
           (move.type == :GRASS && user.hasActiveItem?(:GRASSGEM)) ||
           (move.type == :ELECTRIC && user.hasActiveItem?(:ELECTRICGEM)) ||
           (move.type == :GROUND && user.hasActiveItem?(:GROUNDGEM)) ||
           (move.type == :ROCK && user.hasActiveItem?(:ROCKGEM)) ||
           (move.type == :STEEL && user.hasActiveItem?(:STEELGEM)) ||
           (move.type == :DRAGON && user.hasActiveItem?(:DRAGONGEM)) ||
           (move.type == :FAIRY && user.hasActiveItem?(:FAIRYGEM)) ||
           (move.type == :DARK && user.hasActiveItem?(:DARKGEM)) ||
           (move.type == :ICE && user.hasActiveItem?(:ICEGEM)) ||
           (move.type == :BUG && user.hasActiveItem?(:BUGGEM)) ||
           (move.type == :FLYING && user.hasActiveItem?(:FLYINGGEM)) ||
           (move.type == :FIGHTING && user.hasActiveItem?(:FIGHTINGGEM)) ||
           (move.type == :GHOST && user.hasActiveItem?(:GHOSTGEM)) ||
           (move.type == :DARK && user.hasActiveItem?(:DARKGEM)) ||
           (move.type == :PSYCHIC && user.hasActiveItem?(:PSYCHICGEM))
          score += 20
        end
      end

      # Return here if no extra effect is needed
      func = move.function
      return score if func == "None" || func == "DoesNothingUnusableInGravity" || func == "Struggle" || (target && target.damageState.substitute && !move.soundMove?)

      effscore = 0

      ### Status conditions
      if func == "GiveUserStatusToTarget"
        # Psycho Shift
        if user.status != :NONE
          effscore += 10
          # Pretend it is a regular status move
          case user.status
          when :POISON
            if user.effects[PBEffects::Toxic]>0
              func = "BadPoisonTarget"
            else
              func = "PoisonTarget"
            end
          when :SLEEP
            func = "SleepTarget"
          when :PARALYSIS
            func = "ParalyzeTarget"
          when :BURN
            func = "BurnTarget"
          when :FROSTBITE
            func = "FrostbiteTarget"
          end
        end
      end

      if func == "PoisonTarget" && user.hasActiveItem?(:NOXIOUSCHOKER)
        func = "BadPoisonTarget"
      end

      case func
      when "SleepTarget", "SleepTargetIfUserDarkrai", "SleepTargetChangeUserMeloettaForm"
        # Sleep
        if target.pbCanSleep?(user,false,move) &&
           !target.hasActiveAbility?(:EARLYBIRD)
          effscore += 10.0 + 30.0 * target_hp_percent
          actionable[target.index] = false if chosen
        end
      when "SleepTargetNextTurn"
        # Drowsy (Yawn)
        if target.pbCanSleep?(user,false,move) &&
           !target.hasActiveAbility?(:EARLYBIRD)
          effscore += 30.0 * target_hp_percent
        end
      when "PoisonTarget"
        # Poison
        if target.pbCanPoison?(user,false,move) &&
           !target.hasActiveAbility?(:POISONHEAL) &&
           !target.hasActiveAbility?(:TOXICBOOST) &&
           !target.hasActiveAbility?(:GUTS) &&
           !target.hasActiveAbility?(:MAGICGUARD)
          effscore += 5 + 20.0 * target_hp_percent
        end
      when "BadPoisonTarget"
        # Toxic
        if target.pbCanPoison?(user,false,move) &&
           !target.hasActiveAbility?(:POISONHEAL) &&
           !target.hasActiveAbility?(:TOXICBOOST) &&
           !target.hasActiveAbility?(:MAGICGUARD)
          if target.hasActiveAbility?(:GUTS)
            effscore += 5 + 20.0 * target_hp_percent
          else
            effscore += 5 + 40.0 * target_hp_percent
          end
        end
      when "ParalyzeTarget", "ParalyzeTargetIfNotTypeImmune"
        # Paralysis
        if target.pbCanParalyze?(user,false,move) &&
           !target.hasActiveAbility?(:QUICKFEET)
          target_speed = target.pbSpeed
          user_speed = user.pbSpeed
          if target_speed > user_speed && target_speed / 2 < user_speed
            effscore += 5 + 15 * target_hp_percent
          end
          user.eachAlly do |b|
            partner_speed = b.pbSpeed
            if target_speed > partner_speed
              effscore += 5 + 15 * target_hp_percent
            end
          end
          if !target.hasActiveAbility?(:GUTS)
            effscore += 5 + 10 * target_hp_percent
          end
        end
      when "BurnTarget"
        # Burn
        if target.pbCanBurn?(user,false,move) &&
           !target.hasActiveAbility?(:GUTS) &&
           !target.hasActiveAbility?(:FLAREBOOST)
          if target_has_physical && target_has_special
            effscore += 5 + 20 * target_hp_percent
          elsif target_has_physical
            effscore += 10 + 40 * target_hp_percent
          end
        end
      when "ConfuseTarget", "ConfuseTargetAlwaysHitsInRainHitsTargetInSky"
        # Confusion
        if target.pbCanConfuse?(user,false,move) &&
           !target.hasActiveAbility?(:TANGLEDFEET)
          effscore += 10 + 30 * target_hp_percent
        end
      when "AttractTarget"
        # Attract
        if target.pbCanAttract?(user,false)
          effscore += 10 + 35 * target_hp_percent
        end
      end

      if target
        if target.hasActiveAbility?(:SHEDSKIN)
          effscore *= 0.5
        elsif !target.allyHasActiveAbility?(:HEALER)
          effscore = 0
        elsif target.hasActiveAbility?(:HYDRATION) && self.pbWeather==:Rain
          effscore = 0
        elsif target.hasActiveAbility?(:SYNCHRONIZE)
          if ((func == "PoisonTarget" || func == "BadPoisonTarget") && user.pbCanPoison?(user,false,nil)) ||
             ((func == "ParalyzeTarget" || func == "ParalyzeTargetIfNotTypeImmune") && user.pbCanParalyze?(user,false,nil)) ||
             (func == "BurnTarget" && user.pbCanBurn?(user,false,nil))
            effscore *= 0.5
          end
        end
      end

      # Modifiers to value stat changes less on low HP
      # or when a stat is already increased
      statscore_mods = {
        :ATTACK => user_hp_percent * (([8.0 - user.stages[:ATTACK], 8.0].min) / 6.0),
        :DEFENSE => user_hp_percent * (([8.0 - user.stages[:DEFENSE], 8.0].min) / 6.0),
        :SPECIAL_ATTACK => user_hp_percent * (([8.0 - user.stages[:SPECIAL_ATTACK], 8.0].min) / 6.0),
        :SPECIAL_DEFENSE => user_hp_percent * (([8.0 - user.stages[:SPECIAL_DEFENSE], 8.0].min) / 6.0),
        :SPEED => user_hp_percent * (([8.0 - user.stages[:SPEED], 8.0].min) / 6.0),
        :EVASION => user_hp_percent * (([7.0 - user.stages[:EVASION], 7.0].min) / 6.0),
        :ACCURACY => user_hp_percent * (([7.0 - user.stages[:ACCURACY], 7.0].min) / 6.0)
      }
      str = sprintf("Buff Mods: %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f\n",
        statscore_mods[:ATTACK], statscore_mods[:DEFENSE],
        statscore_mods[:SPECIAL_ATTACK], statscore_mods[:SPECIAL_DEFENSE],
        statscore_mods[:SPEED],
        statscore_mods[:EVASION], statscore_mods[:ACCURACY])
      #echo str

      ### Stat changes on user
      statscore = 0

      # Decreases Stats
      if func == "LowerUserAtkDef1" || func == "LowerUserDefSpDef1" || func == "LowerUserDefSpDefSpd1" || func == "LowerUserSpeed1" || func == "LowerUserSpAtk2" ||
         func == "HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1"
        if user.hasActiveAbility?(:CONTRARY)
          if func == "LowerUserAtkDef1"
            func = "RaiseUserAtkDef1"
          elsif func == "LowerUserDefSpDef1"
            func = "RaiseUserDefSpDef1"
          elsif func == "LowerUserDefSpDefSpd1"
            statscore += 40
          elsif func == "LowerUserSpeed1"
            func = "RaiseUserSpeed1"
          elsif func == "LowerUserSpAtk2"
            func = "RaiseUserSpAtk2"
          elsif func == "HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1"
            statscore -= 10
          end
        else
          statscore -= 10
        end
      end

      if user.pbCanRaiseStatStage?(:ATTACK,user,move,false,true)
        # Attack +1
        if func == "RaiseUserAttack1" || func == "RaiseUserAtkDef1" || func == "RaiseUserAtkDefAcc1" || func == "RaiseUserAtkSpd1" ||
           func == "RaiseUserAtkSpAtk1" || func == "RaiseUserAtkAcc1" || func == "RaiseUserAtk1Spd2" || func == "RaiseUserAndAlliesAtkDef1" ||
           (func == "RaiseUserAtkSpAtk1Or2InSun" && self.pbWeather!=:Sun) # Growth
          statscore += 20 * statscore_mods[:ATTACK] if has_physical
        end

        # Attack +2
        if func == "RaiseUserAttack2" || func == "LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2" ||
           (func == "RaiseUserAtkSpAtk1Or2InSun" && self.pbWeather==:Sun) # Growth
          statscore += 30 * statscore_mods[:ATTACK] if has_physical
        end

        # Belly Drum
        if func == "MaxUserAttackLoseHalfOfTotalHP"
          if user.stages[:ATTACK]<=2
            # Make sure you have enough HP, more HP = higher score
            if user.hp >= user.totalhp * 0.9
              score += 40
            elsif user.hp >= user.totalhp * 0.7
              score += 30
            elsif user.hp >= user.totalhp * 0.55
              score += 15
            end
            # If you have a healing berry, assume Belly Drum is the way to go
            if !unnerve
              if user.hasActiveItem?(:SITRUSBERRY)
                score += 20
              elsif (user.hp < user.totalhp*0.75 || user.hasActiveAbility?(:GLUTTONY)) &&
                      (user.hasActiveItem?(:AGUAVBERRY) ||
                       user.hasActiveItem?(:FIGYBERRY) ||
                       user.hasActiveItem?(:IAPAPABERRY) ||
                       user.hasActiveItem?(:MAGOBERRY) ||
                       user.hasActiveItem?(:WIKIBERRY))
                score += 30
              end
            end
          end
        end
      end

      if user.pbCanRaiseStatStage?(:DEFENSE,user,move,false,true)
        # Defense +1
        if func == "RaiseUserDefense1" || func == "RaiseUserDefense1CurlUpUser" || func == "RaiseUserAtkDef1" || func == "RaiseUserAtkDefAcc1" ||
           func == "RaiseUserDefSpDef1" || func == "RaiseUserDefense2" || func == "RaiseUserAndAlliesAtkDef1"
          statscore += 5 * statscore_mods[:DEFENSE]
          statscore += 10 * statscore_mods[:DEFENSE] if physical_opponents > 0

          if func == "RaiseUserDefense1CurlUpUser" && !user.effects[PBEffects::DefenseCurl]
            # Defense Curl
            for m in user.moves
              if m.function == "MultiTurnAttackPowersUpEachTurn"
                # Has Rollout or Ice Ball
                statscore += 30 * statscore_mods[:DEFENSE]
                break
              end
            end
          end
        end

        # Defense +2
        if func == "RaiseUserDefense2" || (func == "UserConsumeBerryRaiseDefense2" && user.item && GameData::Item.get(user.item).is_berry? && user.itemActive?)
           statscore += 5 * statscore_mods[:DEFENSE]
           statscore += 10 * statscore_mods[:DEFENSE] if physical_opponents > 0
           statscore += 10 * statscore_mods[:DEFENSE] if physical_opponents > 1
        end

        # Defense +3
        if func == "RaiseUserDefense3"
           statscore += 5 * statscore_mods[:DEFENSE]
           statscore += 15 * statscore_mods[:DEFENSE] if physical_opponents > 0
           statscore += 15 * statscore_mods[:DEFENSE] if physical_opponents > 1
        end
      end

      if user.pbCanRaiseStatStage?(:SPEED,user,move,false,true)
        # Speed +1
        if func == "RaiseUserSpeed1" || func == "RaiseUserAtkSpd1" || func == "RaiseUserSpAtkSpDefSpd1" ||
           func == "RemoveUserBindingAndEntryHazards" || func == "TypeDependsOnUserMorpekoFormRaiseUserSpeed1" ||
           func == "HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1"
          statscore += 5 * statscore_mods[:SPEED]
          for s in opponent_speeds
            if s >= speed_stat && s < speed_stat * 1.5
              statscore += 15 * statscore_mods[:SPEED]
            end
          end
        end

        # Speed +2
        if func == "RaiseUserSpeed2" || func == "RaiseUserSpeed2LowerUserWeight" || func == "LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2" || func == "RaiseUserAtk1Spd2"
          statscore += 10 * statscore_mods[:SPEED]
          for s in opponent_speeds
            if s >= speed_stat && s < speed_stat * 2.0
              statscore += 15 * statscore_mods[:SPEED]
            end
          end
        end
      end

      if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,move,false,true)
        # Sp. Atk +1
        if func == "RaiseUserSpAtk1" || func == "RaiseUserAtkSpAtk1" || func == "RaiseUserSpAtkSpDefSpd1" || func == "RaiseUserSpAtkSpDef1" ||
           (func == "RaiseUserAtkSpAtk1Or2InSun" && self.pbWeather!=:Sun) # Growth
          statscore += 20 * statscore_mods[:SPECIAL_ATTACK] if has_special
        end

        # Sp. Atk +2
        if func == "RaiseUserSpAtk2" || func == "LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2" ||
           (func == "RaiseUserAtkSpAtk1Or2InSun" && self.pbWeather==:Sun) # Growth
           statscore += 30 * statscore_mods[:SPECIAL_ATTACK] if has_special
        end

        # Sp. Atk +3
        if func == "RaiseUserSpAtk3"
           statscore += 50 * statscore_mods[:SPECIAL_ATTACK] if has_special
        end
      end

      if user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,move,false,true)
        # Sp. Def +1
        if func == "RaiseUserSpDef1PowerUpElectricMove" || func == "RaiseUserDefSpDef1" || func == "RaiseUserSpAtkSpDefSpd1" || func == "RaiseUserSpAtkSpDef1"
          statscore += 5 * statscore_mods[:SPECIAL_DEFENSE]
          statscore += 10 * statscore_mods[:SPECIAL_DEFENSE] if special_opponents > 0
        end

        # Sp. Def +2
        if func == "RaiseUserSpDef2"
           statscore += 5 * statscore_mods[:SPECIAL_DEFENSE]
           statscore += 10 * statscore_mods[:SPECIAL_DEFENSE] if special_opponents > 0
           statscore += 10 * statscore_mods[:SPECIAL_DEFENSE] if special_opponents > 1
        end
      end

      if user.pbCanRaiseStatStage?(:EVASION,user,move,false,true)
        # Evasiveness +1
        if func == "RaiseUserEvasion1"
          statscore += 20 * statscore_mods[:EVASION]
        end

        # Evasiveness +2
        if func == "RaiseUserEvasion2MinimizeUser"
          statscore += 30 * statscore_mods[:EVASION]
        end
      end

      if user.pbCanRaiseStatStage?(:ACCURACY,user,move,false,true)
        # Accuracy +1
        if func == "RaiseUserAtkDefAcc1" || func == "RaiseUserAtkAcc1"
          stage = user.stages[:ACCURACY]+6
          stages = [3.0/9.0, 3.0/8.0, 3.0/7.0, 3.0/6.0, 3.0/5.0, 3.0/4.0, 1.0,
                           4.0/3.0, 5.0/3.0, 6.0/3.0, 7.0/3.0, 8.0/3.0, 9.0/3.0]
          addscore = 20
          for m in user.moves
            acc = m.accuracy * stages[stage]
            if acc < 85
              statscore += addscore * statscore_mods[:ACCURACY]
              addscore -= 5
            end
          end
        end
      end

      # No Retreat
      if func == "RaiseUserMainStats1TrapUserInBattle" && !user.effects[PBEffects::NoRetreat]
        statscore += 60
      end

      # Clangorous Soul
      if func == "RaiseUserMainStats1LoseThirdOfTotalHP"
        if user.hp == user.totalhp
          statscore += 50
        elsif user.hp > user.totalhp * 2 / 3
          statscore += 30
        elsif user.hp > user.totalhp / 2
          statscore += 15
        end
      end

      # Accupressure
      if func == "RaiseTargetRandomStat2"
        statscore += 25 * user_hp_percent
      end

      # Boost score if the user has Stored Power
      for m in user.moves
        if m.function == "PowerHigherWithUserPositiveStatStages"
          statscore *= 1.5
        end
      end

      if user.hasActiveAbility?(:SIMPLE)
        statscore *= 1.75
      end

      if move.danceMove?
        user.eachAlly do |b|
          statscore *= 1.75 if b.hasActiveAbility?(:DANCER)
        end
        user.eachOpposing do |b|
          statscore *= 0.5 if b.hasActiveAbility?(:DANCER)
        end
      end

      # Modifiers to value stat changes less on low HP
      # or when a stat is already decreased
      debuffscore_mods = {
        :ATTACK => target_hp_percent * (([7.0 + target.stages[:ATTACK], 7.0].min) / 6.0),
        :DEFENSE => target_hp_percent * (([7.0 + target.stages[:DEFENSE], 7.0].min) / 6.0),
        :SPECIAL_ATTACK => target_hp_percent * (([7.0 + target.stages[:SPECIAL_ATTACK], 7.0].min) / 6.0),
        :SPECIAL_DEFENSE => target_hp_percent * (([7.0 + target.stages[:SPECIAL_DEFENSE], 7.0].min) / 6.0),
        :SPEED => target_hp_percent * (([7.0 + target.stages[:SPEED], 7.0].min) / 6.0),
        :EVASION => target_hp_percent * (([6.0 + target.stages[:EVASION], 6.0].min) / 6.0),
        :ACCURACY => target_hp_percent * (([6.0 + target.stages[:ACCURACY], 6.0].min) / 6.0)
      }
      str = sprintf("Debuff Mods: %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f\n",
        debuffscore_mods[:ATTACK], debuffscore_mods[:DEFENSE],
        debuffscore_mods[:SPECIAL_ATTACK], debuffscore_mods[:SPECIAL_DEFENSE],
        debuffscore_mods[:SPEED],
        debuffscore_mods[:EVASION], debuffscore_mods[:ACCURACY])
      #echo str

      ### Stat changes on target
      debuffscore = 0

      # Swagger / Flatter
      if func == "RaiseTargetSpAtk1ConfuseTarget" || func == "RaiseTargetAttack2ConfuseTarget"
        if target.pbCanConfuse?(user,false,move)
          score += 25
          # Prioritize if target has no physical moves and the move is Swagger
          score += 20 if !target_has_physical && func == "RaiseTargetSpAtk1ConfuseTarget"
        end
        if target.hasActiveAbility?(:CONTRARY)
          score += 10
        end
      end

      if target
        if target.pbCanLowerStatStage?(:ATTACK,user,move,false,true)
          # Attack -1
          if func == "LowerTargetAttack1" || func == "LowerTargetAtkDef1" || func == "StartUserAirborne" || func == "LowerTargetAtkSpAtk1" ||
             (func == "LowerPoisonedTargetAtkSpAtkSpd1" && target.status == :POISON)
            if target_has_physical && target_has_special
              debuffscore += 10 * debuffscore_mods[:ATTACK]
            elsif target_has_physical
              debuffscore += 20 * debuffscore_mods[:ATTACK]
            end
          end

          # Attack -2
          if func == "LowerTargetAttack2"
            if target_has_physical && target_has_special
              debuffscore += 20 * debuffscore_mods[:ATTACK]
            elsif target_has_physical
              debuffscore += 30 * debuffscore_mods[:ATTACK]
            end
          end
        end

        if target.pbCanLowerStatStage?(:DEFENSE,user,move,false,true)
          # Defense -1
          if func == "LowerTargetDefense1" || func == "LowerTargetAtkDef1" || func == "HoopaRemoveProtectionsBypassSubstituteLowerUserDef1"
            debuffscore += 10 * debuffscore_mods[:DEFENSE]
          end

          # Defense -2
          if func == "LowerTargetDefense2"
            debuffscore += 30 * debuffscore_mods[:DEFENSE]
          end
        end

        if target.pbCanLowerStatStage?(:SPEED,user,move,false,true)
          # Speed -1
          if func == "LowerTargetSpeed1" || func == "LowerTargetSpeed1WeakerInGrassyTerrain" ||
             (func == "LowerPoisonedTargetAtkSpAtkSpd1" && target.status == :POISON) ||
             (func == "LowerTargetSpeed1MakeTargetWeakerToFire" && !(target.effects[PBEffects::TarShot]))
            debuffscore += 5 * debuffscore_mods[:SPEED]
            for s in ally_speeds
              if s <= target_speed && s > target_speed * 2 / 3
                debuffscore += 15 * debuffscore_mods[:SPEED]
              end
            end
          end

          # Speed -2
          if func == "LowerTargetSpeed2"
            debuffscore += 5 * debuffscore_mods[:SPEED]
            for s in ally_speeds
              if s <= target_speed && s * 0.5 > target_speed * 0.5
                debuffscore += 15 * debuffscore_mods[:SPEED]
              end
            end
          end
        end

        if target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user,move,false,true)
          # Sp. Atk -1
          if func == "LowerTargetSpAtk1" || func == "LowerTargetAtkSpAtk1" || func == "LowerTargetSpAtk1" ||
             (func == "LowerPoisonedTargetAtkSpAtkSpd1" && target.status == :POISON)
            if target_has_physical && target_has_special
              debuffscore += 10 * debuffscore_mods[:SPECIAL_ATTACK]
            elsif target_has_special
              debuffscore += 20 * debuffscore_mods[:SPECIAL_ATTACK]
            end
          end

          # Sp. Atk -2
          if func == "LowerTargetSpAtk2"
            if target_has_physical && target_has_special
              debuffscore += 20 * debuffscore_mods[:SPECIAL_ATTACK]
            elsif target_has_special
              debuffscore += 30 * debuffscore_mods[:SPECIAL_ATTACK]
            end
          end
          # Captivate is not handled, useless move
        end

        if target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,move,false,true)
          # Sp. Def -1
          if func == "LowerTargetSpDef1"
            debuffscore += 10 * debuffscore_mods[:SPECIAL_DEFENSE]
          end

          # Sp. Def -2
          if func == "LowerTargetSpDef2"
            debuffscore += 30 * debuffscore_mods[:SPECIAL_DEFENSE]
          end
        end

        if target.pbCanLowerStatStage?(:ACCURACY,user,move,false,true)
          # Accuracy -1
          if func == "LowerTargetAccuracy1"
            score += 25 * debuffscore_mods[:ACCURACY]
          end
        end

        if target.pbCanLowerStatStage?(:EVASION,user,move,false,true)
          # Evasion -1
          if func == "LowerTargetEvasion1"
            if target.stages[:EVASION] > 0
              score += (target.stages[:EVASION]) * 10
            end
          end

          # Evasion -2
          if func == "LowerTargetEvasion2"
            # Sweet Scent, Defog does not get score for its Evasion debuff
            if target.stages[:EVASION] > 0
              score += (target.stages[:EVASION]) * 20
            end
          end
        end

        if func == "RaiseTargetAtkSpAtk2"
          # Decorate
          if target.pbCanRaiseStatStage?(:ATTACK,user,move,false,true)
            if target_has_physical
              debuffscore -= 30 * debuffscore_mods[:ATTACK]
            end
          end
          if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,move,false,true)
            if target_has_special
              debuffscore -= 30 * debuffscore_mods[:SPECIAL_ATTACK]
            end
          end
        end

        if debuffscore > 0
          # Target has Competitive / Defiant, be careful
          if target.hasActiveAbility?(:DEFIANT) || target.hasActiveAbility?(:COMPETITIVE)
            debuffscore -= 40
          end

          # Target has Contrary, DO NOT PROCEED
          if target.hasActiveAbility?(:CONTRARY)
            debuffscore = -debuffscore
          end

          if target.hasActiveAbility?(:SIMPLE)
            debuffscore *= 1.75
          end
        end
      end


      ### Move specific handling
      case func
      when "FlinchTargetFailsIfUserNotAsleep", "UseRandomUserMoveIfAsleep"
        # Snore, Sleep Talk
        if user.status == :SLEEP && user.statusCount>1
          score += 100
        end
      when "FlinchTargetFailsIfNotUserFirstTurn"
        # Fake Out
        if user.turnCount < 1 && !target.hasActiveAbility?(:INNERFOCUS)
          score += 50
          actionable[target.index] = false if chosen
        elsif target.opposes?(user)
          score -= 100
        end
      when "CureUserBurnPoisonParalysis"
        # Refresh
        if user.status != :NONE
          score += 20
          if user.status == :BURN
            # Don't leave a physical user burned
            for m in user.moves
              if m.physicalMove?
                score += 30
                break
              end
            end
          elsif user.status == :FROSTBITE
            # Don't leave a special user burned
            for m in user.moves
              if m.specialMove?
                score += 30
                break
              end
            end
          elsif user.status == :POISON
            # Don't stay toxiced for long
            if user.effects[PBEffects::Toxic]>5
              score += 50
            elsif user.effects[PBEffects::Toxic]>2
              score += 30
            end
          end
        end
      when "CureUserPartyStatus"
        # Heal Bell / Aromatherapy
        party = self.pbParty(user.index)
        for p in party
          score += 10
          if p.status == :BURN
            # Don't leave a physical user burned
            for m in p.moves
              if m.category == 0
                score += 20
                break
              end
            end
          elsif p.status == :FROSTBITE
            # Don't leave a special user burned
            for m in p.moves
              if m.category == 1
                score += 20
                break
              end
            end
          elsif p.status == :POISON
            score += 30
          end
        end
      when "StartUserSideImmunityToInflictedStatus"
        # Safeguard
        if user.pbOwnSide.effects[PBEffects::Safeguard]<=0
          score += 40
        end
      when "RaiseUserCriticalHitRate2"
        # Focus Energy
        if user.effects[PBEffects::FocusEnergy]==0 &&
           user.pbOpposingSide.effects[PBEffects::LuckyChant]<=0 # Do not use during Lucky Chant
          addscore = 10 + 30 * user_hp_percent
          if user.hasActiveItem?(:RAZORCLAW) || user.hasActiveItem?(:SCOPELENS) ||
             user.hasActiveAbility?(:SUPERLUCK)
            # Has a crit rate item or ability, probably uses a critical hit strategy
            addscore += 5 + 15 * user_hp_percent
          end
          if user.hasActiveAbility?(:SNIPER)
            # Has Sniper, crit rate is ideal
            addscore += 5 + 15 * user_hp_percent
          end
          # Crit Rate is not optimal against opponents with crit immunity
          user.eachOpposing do |b|
            if b.hasActiveAbility?(:SHELLARMOR) || b.hasActiveAbility?(:BATTLEARMOR)
              addscore *= 0.5
            end
          end
          score += addscore
        end
      when "LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2"
        # Shell Smash
        if user.hasActiveItem?(:WHITEHERB)
          score += 30 * user_hp_percent
        end
      when "LowerTargetEvasion1RemoveSideEffects"
        # Defog
        score += 10 * user.pbOwnSide.effects[PBEffects::Spikes]
        score += 15 * user.pbOwnSide.effects[PBEffects::ToxicSpikes]
        score += 20 if user.pbOwnSide.effects[PBEffects::StealthRock]
        score -= 10 * user.pbOpposingSide.effects[PBEffects::Spikes]
        score -= 15 * user.pbOpposingSide.effects[PBEffects::ToxicSpikes]
        score -= 20 if user.pbOpposingSide.effects[PBEffects::StealthRock]
      when "ResetTargetStatStages"
        # Clear Smog
        GameData::Stat.each_main do |s|
          # Gain 10 points for each stat increase
          stage = target.stages[s]
          score += (stage || 0) * 10
        end
        # Make the target less evasive (does not care about accuracy buffs)
        if target.stages[:EVASION] >= 2
          score += (target.stages[:EVASION]) * 15
        end
      when "ResetAllBattlersStatStages"
        # Haze
        eachBattler do |b|
          if b == user || !b.opposes?(user)
            # Prioritize if partners have negative changes
            GameData::Stat.each_main do |s|
              score -= (b.stages[s] || 0) * 10
            end
          else
            # Prioritize if opponents have positive changes
            GameData::Stat.each_main do |s|
              score += (b.stages[s] || 0) * 10
            end
          end
        end
      when "UserTargetSwapAtkSpAtkStages"
        # Power Swap
        # The more the target's stats multiply your own, the better
        if has_physical || target_has_physical
          dif = target.attack * 1.0 / user.attack
          if dif > 1.0
            score += (dif - 1.0) * 40
          end
        end
        if has_special || target_has_special
          dif = target.spatk * 1.0 / user.spatk
          if dif > 1.0
            score += (dif - 1.0) * 40
          end
        end
        score *= 0.75 if has_physical && has_special
      when "UserTargetSwapDefSpDefStages"
        # Guard Swap
        # The more the target's stats multiply your own, the better
          dif = target.defense * 1.0 / user.defense
          if dif > 1.0
            score += (dif - 1.0) * 30
          end
          dif = target.spdef * 1.0 / user.spdef
          if dif > 1.0
            score += (dif - 1.0) * 30
          end
      when "UserTargetSwapStatStages"
        # Heart Swap
        # Better the more buffs the target has than the user
        ownstat = 0
        oppstat = 0
        GameData::Stat.each_main do |s|
          ownstat += user.stages[s] || 0
          oppstat += target.stages[s] || 0
        end
        score = (oppstat - ownstat) * 20
      when "UserCopyTargetStatStages"
        # Psych Up
        # Better the more buffs the target has than the user
        ownstat = 0
        oppstat = 0
        GameData::Stat.each_main do |s|
          ownstat += user.stages[s] || 0
          oppstat += target.stages[s] || 0
        end
        score = (oppstat - ownstat) * 10
      when "StartUserSideImmunityToStatStageLowering"
        # Mist
        if user.pbOwnSide.effects[PBEffects::Mist]<=0
          score += 30
        end
      when "UserSwapBaseAtkDef"
        # Power Trick
        # Assume a Power Trick strategy is intended, prioritize if not yet used
        if !user.effects[PBEffects::PowerTrick]
          score += 50
        end
      when "UserTargetAverageBaseAtkSpAtk"
        # Power Split
        if has_physical || target_has_physical
          dif = target.attack * 1.0 / user.attack
          if dif > 1.0
            score += (dif - 1.0) * 30
          end
        end
        if has_special || target_has_special
          dif = target.spatk * 1.0 / user.spatk
          if dif > 1.0
            score += (dif - 1.0) * 30
          end
        end
        score *= 0.75 if has_physical && has_special
      when "UserTargetAverageBaseDefSpDef"
        # Guard Split
        dif = target.defense * 1.0 / user.defense
        if dif > 1.0
          score += (dif - 1.0) * 20
        end
        dif = target.spdef * 1.0 / user.spdef
        if dif > 1.0
          score += (dif - 1.0) * 20
        end
      when "UserTargetAverageHP"
        # Pain Split
        # Calculate as if it's damage and healing points
        if target_item != :AEGISTALISMAN
          ownpercent = user.hp * 100 / user.totalhp
          opppercent = target.hp * 100 / target.totalhp
          splithp = (user.hp + target.hp) / 2
          score += (splithp * 100 / user.totalhp) - ownpercent
          score -= (splithp * 100 / target.totalhp) - opppercent
        end
      when "StartUserSideDoubleSpeed"
        # Tailwind
        # Good move, just use it (unless Trick Room persists after this turn)
        if user.pbOwnSide.effects[PBEffects::Tailwind]<=0 &&
           self.field.effects[PBEffects::TrickRoom]<=1
          score += 50
        end
      when "ReplaceMoveThisBattleWithTargetLastMoveUsed"
        # Mimic
        score += 40
      when "ReplaceMoveWithTargetLastMoveUsed"
        # Sketch
        score += 40
      when "SetUserTypesToUserMoveType"
        # Conversion
        score += 40
      when "SetUserTypesToResistLastAttack"
        # Conversion 2
        score += 40
      when "SetUserTypesBasedOnEnvironment"
        # Camouflage
        type=:NORMAL
        case self.environment
        when :None;        type=:NORMAL
        when :Grass;       type=:GRASS
        when :TallGrass;   type=:GRASS
        when :MovingWater; type=:WATER
        when :StillWater;  type=:WATER
        when :Underwater;  type=:WATER
        when :Cave;        type=:ROCK
        when :Rock;        type=:GROUND
        when :Sand;        type=:GROUND
        when :Forest;      type=:BUG
        when :Snow;        type=:ICE
        when :Volcano;     type=:FIRE
        when :Graveyard;   type=:GHOST
        when :Sky;         type=:FLYING
        when :Space;       type=:DRAGON
        when :UltraSpace;  type=:PSYCHIC
        end
        if self.field.terrain == :Electric
          type=:ELECTRIC
        elsif self.field.terrain == :Grassy
          type=:GRASS
        elsif self.field.terrain == :Misty
          type=:FAIRY
        elsif self.field.terrain == :Psychic
          type=:PSYCHIC
        end
        if !user.pbHasType?(type)
          # Make sure the user isn't already the same type as the terrain
          score += 40
        end
      when "SetTargetTypesToWater", "SetTargetTypesToPsychic"
        new_type = :NORMAL
        new_type = :WATER if func == "SetTargetTypesToWater"
        new_type = :PSYCHIC if func == "SetTargetTypesToPsychic"
        # Soak / Magic Powder
        if !target.pbHasType?(type)
          if !target.opposes?(user) && target.hasActiveAbility?(:WONDERGUARD)
            score -= 1000 # Negative score is good for partner targets
          else
            score += 10
            if new_type == :WATER
              # Prioritize if a partner can hit water-types super effectively
              user.eachSameSideMove do |m|
                if (m.physicalMove? || m.specialMove?) &&
                  (m.type == :GRASS || m.type == :ELECTRIC)
                  score += 30
                  break
                end
              end
            elsif new_type == :PSYCHIC
              # Prioritize if a partner can hit psychic-types super effectively
              user.eachSameSideMove do |m|
                if (m.physicalMove? || m.specialMove?) &&
                  (m.type == :DARK || m.type == :GHOST || m.type == :BUG)
                  score += 30
                  break
                end
              end
            end
            # Prioritize if you remove the target's STAB possibilities
            has_stab_move = false
            for m in target.moves
              if (m.physicalMove? || m.specialMove?) &&
                 (m.type == new_type)
                 has_stab_move = true
                 break
              end
            end
            if !has_stab_move
              score += 20
            end
          end
        end
      when "SetUserTypesToTargetTypes"
        # Reflect Type
        for t in target.types
          if !user.types.include?(t)
            score += 15
          end
        end
      when "SetTargetAbilityToSimple"
        # Simple Beam
        if target.ability != :SIMPLE
          if !target.opposes?(user)
            # Use on partner if they have a buffing move
            for m in target.moves
              if m.is_a?(Battle::Move::StatUpMove)
                score -= 50
              end
            end
          else
            score += 30
          end
        end
      when "SetTargetAbilityToInsomnia"
        # Worry Seed
        if target.ability != :INSOMNIA
          score += 30
        end
      when "SetUserAbilityToTargetAbility"
        # Role Play
        if user.ability != target.ability
          score += 30
        end
      when "SetTargetAbilityToUserAbility"
        # Entrainment
        if user.ability != target.ability && 
            !(target.ability == :TRUANT ||
              target.ability == :SLOWSTART ||
              target.ability == :DEFEATIST)
          score += 20
          if user.ability == :TRUANT ||
             user.ability == :SLOWSTART ||
             user.ability == :DEFEATIST
            score += 100
          end
        end
      when "UserTargetSwapAbilities"
        # Skill Swap
        if user.ability != target.ability
          if !target.opposes?(user)
            if target.ability == :TRUANT ||
               target.ability == :SLOWSTART ||
               target.ability == :DEFEATIST
              score -= 300
            end
          elsif !(target.ability == :TRUANT ||
                    target.ability == :SLOWSTART ||
                    target.ability == :DEFEATIST)
            score += 20
            if user.ability == :TRUANT ||
               user.ability == :SLOWSTART ||
               user.ability == :DEFEATIST
              score += 100
            end
          end
        end
      when "NegateTargetAbility"
        # Gastro Acid
        if !target.effects[PBEffects::GastroAcid] &&
           !(target.ability == :TRUANT ||
             target.ability == :SLOWSTART ||
             target.ability == :DEFEATIST)
          score += 40
        end
      when "TransformUserIntoTarget"
        # Transform
        score += 50
      when "FixedDamage20"
        # Sonic Boom
        # Handled by regular damage calculation
      when "FixedDamage40"
        # Dragon Rage
        # Handled by regular damage calculation
      when "FixedDamageHalfTargetHP"
        # Super Fang
        # Handled by regular damage calculation
      when "FixedDamageUserLevel", "FixedDamageUserLevelRandom"
        # Night Shade / Seismic Toss, Psywave
        # Handled by regular damage calculation
      when "LowerTargetHPToUserHP"
        # Endeavor
        # Handled by regular damage calculation
      when "OHKO", "OHKOIce", "OHKOHitsUndergroundTarget"
        # OHKO
        if !target.hasActiveAbility?(:STURDY)
          # In case of sure hit, FATALITY
          if target.effects[PBEffects::LockOn]>0
            score += 150
            actionable[target.index] = false if chosen
            fainted[target.index] = true if chosen
          elsif
            score += 30
          end
        end
      when "CounterPhysicalDamage"
        # Counter
        if physical_opponents == 2
          score += 40
        elsif physical_opponents == 1
          score += 20
        end
      when "CounterSpecialDamage"
        # Mirror Coat
        if special_opponents == 2
          score += 40
        elsif special_opponents == 1
          score += 20
        end
      when "CounterDamagePlusHalf"
        # Metal Burst
        score += 30
      when "DamageTargetAlly"
        # Flame Burst
        target.eachAlly do |b|
          if b.hp < b.totalhp / 16
            score += 150
            actionable[b.index] = false if chosen
            fainted[b.index] = true if chosen
          else
            score += 100 / 16
          end
        end
      when "UsedAfterAllyRoundWithDoublePower"
        # Round
        user.eachAlly do |b|
          b.eachMove do |m|
            if m.function == "UsedAfterAllyRoundWithDoublePower"
              score += 30
              break
            end
          end
        end
      when "DoublePowerIfTargetActed"
        # Payback
        # Double damage score if target will attack first
        if target_speed > speed_stat
          score += damage * 100 / target.totalhp
        end
      when "PowerHigherWithConsecutiveUse", "PowerHigherWithConsecutiveUseOnUserSide"
        # Fury Cutter, Echoed Voice
        # Give some extra score to actually use them
        score += 10
        if user.hasActiveItem?(:METRONOME)
          score += 30
        end
      when "RandomlyDamageOrHealTarget", "RandomPowerDoublePowerIfTargetUnderground"
        # Present, Magnitude
        # Random by nature
        score += self.pbRandom(50)
      when "PowerUpAllyMove"
        # Helping Hand
        score += 20
      when "StartWeakenElectricMoves"
        # Mud Sport
        user.eachOpposing do |b|
          b.eachMove do |m|
            score += 10 if m.type == :ELECTRIC && m.baseDamage > 40
          end
        end
        score += 10
      when "StartWeakenFireMoves"
        # Water Sport
        user.eachOpposing do |b|
          b.eachMove do |m|
            score += 10 if m.type == :FIRE && m.baseDamage > 40
          end
        end
        score += 10
      when "AlwaysCriticalHit"
        # Frost Breath / Storm Throw
        # Avoid attacking Anger Point, unless it's the ally
        if target.hasActiveAbility?(:ANGERPOINT) &&
           target.hp > target.totalhp * 0.6 && target.stages[:ATTACK] < 3
          score -= target.opposes?(user) ? 200 : 120
        end
      when "StartPreventCriticalHitsAgainstUserSide"
        # Lucky Chant
        if user.pbOwnSide.effects[PBEffects::LuckyChant]<=0
          score += 40
        end
      when "StartWeakenPhysicalDamageAgainstUserSide"
        # Reflect
        if user.pbOwnSide.effects[PBEffects::Reflect]<=0
          score += 10
          score += 10 if user.hasActiveItem?(:LIGHTCLAY)
          score += 30 * physical_opponents
        end
      when "StartWeakenSpecialDamageAgainstUserSide"
        # Light Screen
        if user.pbOwnSide.effects[PBEffects::Reflect]<=0
          score += 10
          score += 10 if user.hasActiveItem?(:LIGHTCLAY)
          score += 30 * special_opponents
        end
      when "IgnoreTargetDefSpDefEvaStatStages"
        # Chip Away / Saced Sword
        if target.stages[:EVASION]>=2
          score += 10 * (target.stages[:EVASION] - 1)
        end
      when "EnsureNextMoveAlwaysHits"
        # Lock-On / Mind Reader
        if target.effects[PBEffects::LockOn]<=0
          if target.stages[:EVASION]>=2
            score += 10 * (target.stages[:EVASION] - 1)
          end
          for m in user.moves
            if m.function == "OHKO" || m.function == "OHKOIce" || m.function == "OHKOHitsUndergroundTarget"
              # Add score if the user has OHKO moves
              score += 40
              break
            elsif m.accuracy <= 50
              # Add score if the user has Zap Cannon, etc
              score += 30
              break
            end
          end
        end
      when "StartNegateTargetEvasionStatStageAndGhostImmunity"
        # Foresight / Odor Sleuth
        if target.pbHasType?(:GHOST) && !target.effects[PBEffects::Foresight]
          score += 30
        end
      when "StartNegateTargetEvasionStatStageAndDarkImmunity"
        # Miracle Eye
        if target.pbHasType?(:DARK) && !target.effects[PBEffects::MiracleEye]
          score += 30
        end
      when "ProtectUser"
        # Protect / Detect
        if user.effects[PBEffects::ProtectRate]==1
          score += 20
          eachBattler do |b|
            addscore = 0
            addscore += 8  if b.status == :BURN
            addscore += 8  if b.status == :FROSTBITE
            addscore += 20 if b.status == :POISON
            addscore += 10 if b.effects[PBEffects::Toxic] > 0
            addscore += 30 if b.effects[PBEffects::Curse]
            addscore += 40 if b.effects[PBEffects::PerishSong] > 0
            addscore += 20 if b.effects[PBEffects::LeechSeed] >= 0
            addscore += 8  if pbWeather == :Sandstorm && b.takesSandstormDamage?
            addscore += 8  if pbWeather == :Hail && b.takesHailDamage?
            addscore = -addscore if b==user || !b.opposes?(user)
            score += addscore
          end
        end
      when "ProtectUserSideFromPriorityMoves"
        # Quick Guard
        score += 20 if user.effects[PBEffects::ProtectRate]==1
      when "ProtectUserSideFromMultiTargetDamagingMoves"
        # Wide Guard
        score += 20 if user.effects[PBEffects::ProtectRate]==1
      when "RemoveProtections"
        # Feint
        # Prioritize Feint if target has Protect
        for m in target.moves
          if m.function == "ProtectUser"
            score += 30
            break
          end
        end
      when "UseLastMoveUsedByTarget"
        # Mirror Move - Random because it is unpredictable
        # Could maybe code outside this function to replace move if a move is guaranteed
        score += 10 + self.pbRandom(40)
      when "UseLastMoveUsed"
        # Copycat - Random because it is unpredictable
        # Could maybe code outside this function to replace move if a move is guaranteed
        score += 10 + self.pbRandom(40)
      when "UseMoveTargetIsAboutToUse"
        # Me First
        # Needs to be faster than at least one opponent
        higher = 0
        for s in opponent_speeds
          higher += 1 if s < speed_stat
        end
        if higher > 0
          score += 20
          score += 15 if higher >= 2
          # Ghost is super-effective against itself
          user.eachOpposing do |b|
            score += 10 if b.pbHasType?(:GHOST)
          end
        end
      when "BounceBackProblemCausingStatusMoves"
        # Magic Coat
        count = 0
        user.eachOpposing do |b|
          b.eachMove do |m|
            if !m.physicalMove? && !m.specialMove?
              if ![:None, :User, :NearAlly, :UserOrNearAlly, :AllBattlers, :UserSide, :BothSides].include?(m.target)
                count += 1
              end
            end
          end
        end
        if count >= 2
          score += 20
          score += 5 * (count - 2)
        end
      when "StealAndUseBeneficialStatusMove"
        # Snatch
        # Use if opponents have buffing moves
        user.eachOpposing do |b|
          b.eachMove do |m|
            if m.function <= "RaiseUserSpAtk3" && m.function >= "RaiseUserAttack1"
              score += 20
              is_buffed = false
              # Assume target will not buff if they're already buffed
              GameData::Stat.each_main do |s|
                if (b.stages[s] || 0)>=2
                  is_buffed = true
                  break
                end
              end
              score += 30 if !is_buffed
              break
            end
          end
        end
      when "UseRandomMoveFromUserParty"
        # Assist
        score += self.pbRandom(50)
      when "UseRandomMove"
        # Metronome
        score += self.pbRandom(70)
      when "DisableTargetUsingSameMoveConsecutively"
        # Torment
        if !target.effects[PBEffects::Torment] && target_item != :AEGISTALISMAN
          score += 30
          if target.effects[PBEffects::Encore]>0
            score += 50
          end
        end
      when "DisableTargetMovesKnownByUser"
        # Imprison
        if !user.effects[PBEffects::Imprison]
          user.eachOpposing do |b|
            b.eachMove do |m|
              user.eachMove do |n|
                if m.id == n.id
                  score += 20
                end
              end
            end
          end
        end
      when "DisableTargetLastMoveUsed"
        # Disable
        if target.effects[PBEffects::Disable]<=0 && target_item != :AEGISTALISMAN
          score += 30
          if target.effects[PBEffects::Encore]>0
            score += 50
          end
        end
      when "DisableTargetStatusMoves"
        # Taunt
        if target.effects[PBEffects::Taunt]<=0
          for m in target.moves
            if !m.physicalMove? && !m.specialMove?
              score += 25
            end
          end
        end
      when "DisableTargetHealingMoves"
        # Heal Block
        if target.effects[PBEffects::HealBlock]<=0
          for m in target.moves
            if m.healingMove?
              score += 30
            end
          end
        end
      when "DisableTargetUsingDifferentMove"
        # Encore
        if target.effects[PBEffects::Encore]<=0
          if target.lastMoveUsed
            score += 30
            # Try to trap the target into using a status move
            lastused = GameData::Move.get(target.lastMoveUsed)
            if lastused.category == 2
              score += 30
            end
            if target.effects[PBEffects::Torment]
              score += 50
            end
          end
        end
      when "HitOncePerUserTeamMember"
        # Beat Up
        if !target.opposes?(user) && target.hasActiveAbility?(:JUSTIFIED)
          if target.pbCanRaiseStatStage?(:ATTACK,user,move,false,true) &&
             target.stages[:ATTACK] < 3 && target.hp > target.totalhp * 0.5
            score -= 30 * self.pbParty(user.index).length
          else
            score += 20
          end
        elsif !target.hasActiveAbility?(:JUSTIFIED)
          score -= 20 * self.pbParty(user.index).length
        else
          score += 3 * self.pbParty(user.index).length
        end
      when "TwoTurnAttack"
        # Razor Wind
        if self.pbWeather != :Winds &&
           !user.hasActiveItem?(:POWERHERB) &&
           !user.hasActiveAbility?(:TIMESKIP)
          # Cut damage score in half as the attack takes two turns
          score -= damage * 50 / target.totalhp
        end
      when "TwoTurnAttackOneTurnInSun"
        # Solar Beam
        if self.pbWeather != :Sun &&
           !user.hasActiveItem?(:POWERHERB) &&
           !user.hasActiveAbility?(:TIMESKIP)
          # Cut damage score in half as the attack takes two turns
          score -= damage * 50 / target.totalhp
        end
      when "TwoTurnAttackParalyzeTarget", "TwoTurnAttackBurnTarget", "TwoTurnAttackFlinchTarget",
           "TwoTurnAttackChargeRaiseUserDefense1", "TwoTurnAttackChargeRaiseUserSpAtk1"
        # Freeze Shock, Ice Burn, Sky Attack, Skull Bash
        if !user.hasActiveItem?(:POWERHERB) &&
           !user.hasActiveAbility?(:TIMESKIP)
          # Cut damage score in half as the attack takes two turns
          score -= damage * 50 / target.totalhp
        end
        if func == "TwoTurnAttackChargeRaiseUserSpAtk1"
          score += 10
        end
      when "BindTarget", "BindTargetDoublePowerIfTargetUnderwater"
        # Trapping Moves (Fire Spin, etc.)
        score += 20
        # If ally has Perish Song, assume Perish Trap strategy
        user.eachAllyMove do |m|
          if m.function == "StartPerishCountsForAllBattlers"
            score += 50
            break
          end
        end
        score += 10 if target && target.effects[PBEffects::Toxic]>0
        score += 20 if target && target.effects[PBEffects::Curse]
        score += 30 if target && target.effects[PBEffects::PerishSong]>0
      when "MultiTurnAttackPreventSleeping"
        # Uproar
        # Try not to wake opponents
        user.eachOpposing do |b|
          score -= 20 if b.status == :SLEEP && b.statusCount>1
        end
        # Try to wake partner
        user.eachAlly do |b|
          score += 20 if b.status == :SLEEP && b.statusCount>1
        end
      when "MultiTurnAttackConfuseUserAtEnd"
        # Outrage / Petal Dance / Thrash
        if user.hasActiveItem?(:PERSIMBERRY) || user.hasActiveItem?(:LUMBERRY)
          score += 10
        end
      when "MultiTurnAttackPowersUpEachTurn"
        # Rollout / Ice Ball
        if user.hasActiveItem?(:METRONOME)
          score += 20
        end
        if user.effects[PBEffects::DefenseCurl]
          score += 30
        end
      when "MultiTurnAttackBideThenReturnDoubleDamage"
        # Bide
        score += 20
      when "HealUserHalfOfTotalHP"
        # Recover / Slack Off / etc.
        if user.hp < user.totalhp * 0.75
          score += [50, 100 - [user.hp * 100 / user.totalhp, 100].min].min
        end
      when "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn"
        # Roost
        if user.hp < user.totalhp * 0.75
          score += [50, 100 - [user.hp * 100 / user.totalhp, 100].min].min
        end
      when "HealUserPositionNextTurn"
        # Wish
        if user.effects[PBEffects::Wish]<=0
          if user.hp < user.totalhp * 0.8
            score += 50
          end
          # Able to pass Wish to party members
          for p in self.pbParty(user.index)
            if p.hp > 0 && p.hp < p.totalhp * 0.75
              score += 10
            end
          end
        end
      when "HealUserDependingOnWeather"
        # Moonlight / Morning Sun / Synthesis
        if user.hp < user.totalhp * 0.75
          amt = 50
          if self.pbWeather==:Sun
            amt = 200.0 / 3.0
          elsif self.pbWeather!=:None
            amt = 25
          end
          score += [amt, 100 - [user.hp * 100 / user.totalhp, 100].min].min
        end
      when "HealUserFullyAndFallAsleep"
        # Rest
        if user.pbCanSleep?(user,true,self,true) && user.status != :SLEEP
          # Give more leeway to amount of HP recovered if (partly) immune to sleep
          amt = 0.5
          amt = 0.6 if user.hasActiveAbility?(:EARLYBIRD) || user.hasActiveAbility?(:SHEDSKIN)
          amt = 0.7 if user.allyHasActiveAbility?(:HEALER)
          amt = 0.8 if user.hasActiveAbility?(:HYDRATION) && self.pbWeather==:Rain
          # Give score based on HP lost and if a status can be healed
          if user.hp < user.totalhp * amt
            score += (100 - [user.hp * 100 / user.totalhp, 100].min) * (amt * 1.5)
            if user.status == :POISON ||
               user.status == :BURN ||
               user.status == :FROSTBITE ||
               user.status == :PARALYSIS
              score += 30
            end
          elsif user.status == :POISON ||
                user.status == :BURN ||
                user.status == :FROSTBITE ||
                user.status == :PARALYSIS
            score += 30 if user.hp < user.totalhp * 0.75
          end
        end
      when "StartHealUserEachTurn"
        # Aqua Ring
        if !user.effects[PBEffects::AquaRing]
          score += 40
        end
      when "StartHealUserEachTurnTrapUserInBattle"
        # Ingrain
        if !user.effects[PBEffects::Ingrain]
          score += 35
        end
      when "StartLeechSeedTarget"
        # Leech Seed
        if target.effects[PBEffects::LeechSeed]<0
          score += 30
          # Extra points if the target has a large HP Pool
          score += target.totalhp * 20 / user.totalhp
        end
      when "StartLeechSeedTarget"
        # 50% Drain Moves
        # Grant score based on how much HP will be healed
        if target.opposes?(user)
          amt = [damage * 50 / user.totalhp, 100 - [user.hp * 100 / user.totalhp, 100].min].min
          score += target.hasActiveAbility?(:LIQUIDOOZE) ? -amt : amt
        end
      when "HealUserByHalfOfDamageDoneIfTargetAsleep"
        # Dream Eater
        # Will not wake up this turn, or user outspeeds
        if target.status == :SLEEP && (target.statusCount > 1 || speed_stat > target_speed)
          # Grant score based on how much HP will be healed
          score += [damage * 50 / user.totalhp, 100 - [user.hp * 100 / user.totalhp, 100].min].min
        end
      when "HealTargetHalfOfTotalHP"
        # Heal Pulse
        # Do not use against opponents
        if target.opposes?(user)
          score -= 30
        end
        if target.hp < target.totalhp * 0.75
          score -= [50, 100 - [target.hp * 100 / target.totalhp, 100].min].min
        end
      when "HealUserAndAlliesQuarterOfTotalHP", "HealUserAndAlliesQuarterOfTotalHPCureStatus"
        if target.hp < target.totalhp * 0.75
          score -= [25, 100 - [target.hp * 100 / target.totalhp, 100].min].min
        end
        if func == "HealUserAndAlliesQuarterOfTotalHPCureStatus"
          if target.status != :NONE
            score -= 15
          end
        end
      when "UserFaintsExplosive", "UserFaintsPowersUpInMistyTerrainExplosive"
        # Explosion / Self-Destruct
        # Additive score is handled by damage calculation
        score -= 90
        # Make sure more Pokemon are available
        party_able = 0
        for p in self.pbParty(user.index)
          party_able += 1 if p.hp > 0
        end
        score -= 50 if party_able <= 2
        score -= 50 if party_able <= 1
        if func == "UserFaintsPowersUpInMistyTerrainExplosive" && @field.terrain == :Misty
          score += 30
        end
      when "UserFaintsFixedDamageUserHP"
        # Final Gambit
        if target.opposes?(user)
          score -= 90
          # Make sure more Pokemon are available
          party_able = 0
          for p in self.pbParty(user.index)
            party_able += 1 if p.hp > 0
          end
          score -= 50 if party_able <= 2
          score -= 50 if party_able <= 1
        end
      when "UserFaintsLowerTargetAtkSpAtk2"
        # Memento
        if target.opposes?(user)
          score -= 50
          # Prioritize more on less HP
          if user.hp < user.totalhp * 0.75
            score += (100 - [user.hp * 100 / user.totalhp, 100].min) * 2
          end
          # Make sure more Pokemon are available
          party_able = 0
          for p in self.pbParty(user.index)
            party_able += 1 if p.hp > 0
          end
          score -= 100 if party_able <= 2
          score -= 100 if party_able <= 1
        end
      when "UserFaintsHealAndCureReplacement", "UserFaintsHealAndCureReplacementRestorePP"
        # Healing Wish, Lunar Dance
        score -= 50
        # Prioritize more on less HP
        if user.hp < user.totalhp * 0.75
          score += 100 - [user.hp * 100 / user.totalhp, 100].min
        end
        # Make sure more Pokemon are available
        party_able = 0
        lowest_hp = 0
        for p in self.pbParty(user.index)
          party_able += 1 if p.hp > 0
          isOut = false
          eachBattler do |b|
            isOut = true if p == b.pokemon
          end
          if !isOut
            this_hp = 100 - [user.hp * 100 / user.totalhp, 100].min
            if this_hp > lowest_hp
              lowest_hp = this_hp
            end
          end
        end
        score += lowest_hp
        score -= 200 if party_able <= 2
      when "StartPerishCountsForAllBattlers"
        # Perish Song
        # Make sure not to be trapped
        if !(user.opposingHasActiveAbility?(:SHADOWTAG) || user.opposingHasActiveAbility?(:ARENATRAP))
          # More score the more opponents are unperished
          user.eachOpposing do |b|
            score += 70 if b.effects[PBEffects::PerishSong]<=0
            if score > 0
              # Bonus score for trapping opponents
              if user.sameSideHasActiveAbility?(:SHADOWTAG) || user.sameSideHasActiveAbility?(:ARENATRAP)
                score += 200
              else
                score += 25 if b.effects[PBEffects::Trapping]>1
              end
            end
          end
        end
      when "SetAttackerMovePPTo0IfUserFaints"
        # Grudge
        if target.opposes?(user)
          score -= 50
          # Prioritize more on less HP
          if user.hp < user.totalhp * 0.5
            score += 100 - [user.hp * 100 / user.totalhp, 100].min
          end
          # Make sure more Pokemon are available
          party_able = 0
          for p in self.pbParty(user.index)
            party_able += 1 if p.hp > 0
          end
          score -= 100 if party_able <= 2
          score -= 100 if party_able <= 1
        end
      when "AttackerFaintsIfUserFaints"
        # Destiny Bond
        score -= 50
        # Prioritize more on less HP
        if user.hp < user.totalhp * 0.5
          score += (100 - [user.hp * 100 / user.totalhp, 100].min) * 2
        end
        # Make sure more Pokemon are available
        party_able = 0
        for p in self.pbParty(user.index)
          party_able += 1 if p.hp > 0
        end
        score -= 200 if party_able <= 1
      when "UserEnduresFaintingThisTurn"
        # Endure
        if user.effects[PBEffects::ProtectRate]==1
          if !(pbWeather == :Sandstorm && user.takesSandstormDamage?) &&
             !(pbWeather == :Hail && user.takeHailDamage?) &&
             user.status != :POISON && user.status != :BURN && user.status != :FROSTBITE
            score += 15
            user.eachOpposing do |b|
              score += 15 if b.status == :POISON
              score += 25 if b.effects[PBEffects::Curse]
              score += 35 if b.effects[PBEffects::PerishSong]>0
            end
          end
        end
      when "SwitchOutTargetStatusMove", "SwitchOutTargetDamagingMove"
        # Roar / Whirlwind, Circle Throw / Dragon Tail
        if target.opposes?(user)
          party_able = 0
          for p in self.pbParty(target.index)
            party_able += 1 if p.hp > 0
          end
          # Make sure opponent has enough Pokemon to switch
          if party_able > 2
            GameData::Stat.each_main do |s|
              # Gain 10 points for each stat increase
              stage = target.stages[s] || 0
              score += stage * 10
            end
            # Use more often if switched Pokemon will be hurt by hazards
            score += 10 if target.pbOwnSide.effects[PBEffects::StealthRock]
            score += 5 * target.pbOwnSide.effects[PBEffects::Spikes]
          end
        end
      when "SwitchOutUserPassOnEffects"
        # Baton Pass
        party_able = 0
        for p in self.pbParty(user.index)
          party_able += 1 if p.hp > 0
        end
        # Make sure user has enough Pokemon to switch
        if party_able > 2
          GameData::Stat.each_main do |s|
            # Gain 10 points for each stat increase to pass
            stage = user.stages[s] || 0
            score += stage * 10
          end
          # Use less often if switched Pokemon will be hurt by hazards
          score -= 10 if user.pbOwnSide.effects[PBEffects::StealthRock]
          score -= 5 * user.pbOwnSide.effects[PBEffects::Spikes]
        end
      when "SwitchOutUserDamagingMove"
        # U-turn / Volt Switch
        party_able = 0
        for p in self.pbParty(user.index)
          party_able += 1 if p.hp > 0
        end
        # Make sure user has enough Pokemon to switch
        if party_able > 2
          GameData::Stat.each_main do |s|
            # Gain 10 points for each stat decrease to remove
            stage = user.stages[s] || 0
            score -= stage * 10
          end
          # Use less often if switched Pokemon will be hurt by hazards
          score -= 10 if user.pbOwnSide.effects[PBEffects::StealthRock]
          score -= 5 * user.pbOwnSide.effects[PBEffects::Spikes]
        end
        if !target.opposes?(user)
          score = 0 if score < 0
        end
      when "TrapTargetInBattle"
        # Block / Mean Look / Spider Web
        if target.effects[PBEffects::MeanLook] < 0 && !target.pbHasType?(:GHOST)
          score += 30
          score += 10 if target.status == :POISON
          score += 20 if target.effects[PBEffects::Curse]
          score += 30 if target.effects[PBEffects::PerishSong]>0
        end
      when "TrapUserAndTargetInBattle"
        # Jaw Lock
        if target.effects[PBEffects::JawLock] < 0 && !target.pbHasType?(:GHOST)
          score += 15
          score += 10 if target.status == :POISON
          score += 20 if target.effects[PBEffects::Curse]
          score += 30 if target.effects[PBEffects::PerishSong]>0
        end
      when "TrapTargetInBattleLowerTargetDefSpDef1EachTurn"
        # Octolock
        if target.effects[PBEffects::Octolock] < 0 && !target.pbHasType?(:GHOST)
          score += 40
          score += 10 if target.status == :POISON
          score += 20 if target.effects[PBEffects::Curse]
          score += 30 if target.effects[PBEffects::PerishSong]>0
        end
      when "RemoveTargetItem", "CorrodeTargetItem"
        # Knock Off
        if !target.hasActiveAbility?(:STICKYHOLD) &&
           !target.hasActiveAbility?(:SUCTIONCUPS)
          if target.item
            score += 25
          end
        end
      when "UserTakesTargetItem"
        # Covet / Thief
        if !target.hasActiveAbility?(:STICKYHOLD) &&
           !target.hasActiveAbility?(:SUCTIONCUPS)
          if target.item && user.item == 0
            score += 25
          end
        end
      when "UserTargetSwapItems"
        # Switcheroo / Trick
        if !target.hasActiveAbility?(:STICKYHOLD) &&
           !target.hasActiveAbility?(:SUCTIONCUPS)
          if target.item != user.item &&
             target.item != :FLAMEORB &&
             target.item != :TOXICORB &&
             target.item != :STICKYBARB &&
             target.item != :CHOICESPECS &&
             target.item != :CHOICESCARF &&
             target.item != :CHOICEBAND
            if user.item == :FLAMEORB
              if target.pbCanBurn?(nil,false,nil) &&
                 !target.hasActiveAbility?(:GUTS) &&
                 !target.hasActiveAbility?(:FLAREBOOST)
                if target_has_physical && target_has_special
                  score += 20
                elsif target_has_physical
                  score += 10
                end
              end
            elsif user.item == :TOXICORB
              if target.pbCanPoison?(nil,false,nil) &&
                 !target.hasActiveAbility?(:POISONHEAL) &&
                 !target.hasActiveAbility?(:TOXICBOOST) &&
                 !target.hasActiveAbility?(:MAGICGUARD)
                if target.hasActiveAbility?(:GUTS)
                  score += 20
                else
                  score += 40
                end
              end
            elsif user.item == :STICKYBARB
              score += 45 if !target.hasActiveAbility?(:MAGICGUARD)
            elsif user.item == :CHOICESCARF
              score += 50
            elsif user.item == :CHOICEBAND
              if !target_has_physical
                score += 60
              else
                score += 35
              end
            elsif user.item == :CHOICESPECS
              if !target_has_special
                score += 60
              else
                score += 35
              end
            end
          end
        end
      when "TargetTakesUserItem"
        # Bestow
        if !target.opposes?(user) && !target.item && user.item
          score -= 50
        end
      when "UserConsumeTargetBerry"
        # Bug Bite / Pluck
        if target.item && GameData::Item.get(target.item).is_berry?
          score += 40
        end
      when "DestroyTargetBerryOrGem"
        # Incinerate
        if target.item && GameData::Item.get(target.item).is_berry?
          score += 30
        end
      when "RestoreUserConsumedItem"
        # Recycle
        if user.item && user.recycleItem
          score += 30
        end
      when "ThrowUserItemAtTarget"
        # Fling
        if user.item
          if user.item == :FLAMEORB
            if target.pbCanBurn?(user,false,move) &&
               !target.hasActiveAbility?(:GUTS) &&
               !target.hasActiveAbility?(:FLAREBOOST)
              if target_has_physical && target_has_special
                score += 20
              elsif target_has_physical
                score += 10
              end
            end
          elsif user.item == :TOXICORB || user.item == :POISONBARB
            if target.pbCanPoison?(user,false,move) &&
               !target.hasActiveAbility?(:POISONHEAL) &&
               !target.hasActiveAbility?(:TOXICBOOST) &&
               !target.hasActiveAbility?(:MAGICGUARD)
              if target.hasActiveAbility?(:GUTS)
                score += 20
              else
                score += 40
              end
            end
          elsif user.item == :LIGHTBALL
            if target.pbCanParalyze?(user,false,move) &&
               !target.hasActiveAbility?(:QUICKFEET)
              target_speed = target.pbSpeed
              user_speed = user.pbSpeed
              if target_speed > user_speed && target_speed / 2 < user_speed
                effscore += 15
              end
              user.eachAlly do |b|
                partner_speed = b.pbSpeed
                if target_speed > partner_speed
                  effscore += 15
                end
              end
              if !target.hasActiveAbility?(:GUTS)
                effscore += 10
              end
            end
          elsif user.item == :KINGSROCK || user.item == :RAZORFANG
            if !target.hasActiveAbility?(:INNERFOCUS)
              actionable[target.index] == false if chosen
            end
          end
        end
      when "StartTargetCannotUseItem"
        # Embargo
        if target.effects[PBEffects::Embargo] <= 0
          score += 35
        end
      when "StartNegateHeldItems"
        # Magic Room
        if @field.effects[PBEffects::MagicRoom] <= 0
          score += 30
        end
      when "RecoilQuarterOfDamageDealt"
        # 25% Recoil
        if !user.hasActiveAbility?(:MAGICGUARD) &&
           !user.hasActiveAbility?(:ROCKHEAD)
          score -= damage * 25 / user.totalhp
          score -= 20 if damage * 0.25 > user.hp
        end
      when "RecoilThirdOfDamageDealt", "RecoilThirdOfDamageDealtParalyzeTarget", "RecoilThirdOfDamageDealtBurnTarget"
        # 33% Recoil
        if !user.hasActiveAbility?(:MAGICGUARD) &&
           !user.hasActiveAbility?(:ROCKHEAD)
          score -= damage * 33 / user.totalhp
          score -= 20 if damage * 0.33 > user.hp
        end
      when "RecoilHalfOfDamageDealt"
        # 50% Recoil
        if !user.hasActiveAbility?(:MAGICGUARD) &&
           !user.hasActiveAbility?(:ROCKHEAD)
          score -= damage * 50 / user.totalhp
          score -= 20 if damage * 0.5 > user.hp
        end
      when "StartSunWeather"
        # Sunny Day
        if self.pbWeather != :Sun
          score += 40
          # Extra points if removing other weather
          if self.pbWeather != :None
            score += 10
          end
          eachSameSideBattler(user.index) do |b|
            score += 30 if b.hasActiveAbility?(:FLOWERGIFT)
          end
        end
      when "StartRainWeather"
        # Rain Dance
        if self.pbWeather != :Rain
          score += 40
          # Extra points if removing other weather
          if self.pbWeather != :None
            score += 10
          end
        end
      when "StartSandstormWeather"
        # Sandstorm
        if self.pbWeather != :Sandstorm
          score += 40
          # Extra points if removing other weather
          if self.pbWeather != :None
            score += 10
          end
        end
      when "StartHailWeather"
        # Hail
        if self.pbWeather != :Hail
          score += 40
          # Extra points if removing other weather
          if self.pbWeather != :None
            score += 10
          end
        end
      when "AddSpikesToFoeSide"
        # Spikes
        removedRecently = false
        user.eachOpposing do |b|
          removedRecently = true if b.lastMoveUsed == :RAPIDSPIN || b.lastMoveUsed == :DEFOG
        end
        # Do not use against Magic Bounce and do not spam against Rapid Spin / Defog
        if !removedRecently && user.opposingHasActiveAbility?(:MAGICBOUNCE)
          if user.pbOpposingSide.effects[PBEffects::Spikes] < 3
            # Check for Flying / Levitate in opposing party
            hittable = 0
            for p in self.pbParty((user.index + 1) % 2)
              if p.hp > 0 && !p.hasType?(:FLYING) && p.ability != :LEVITATE
                hittable += 1
              end
            end
            if hittable > 0
              score += 10
              # Multiple layers is wanted
              score += 5 * user.pbOpposingSide.effects[PBEffects::Spikes]
              score += 10 * hittable
            end
          end
        end
      when "AddToxicSpikesToFoeSide"
        # Toxic Spikes
        removedRecently = false
        user.eachOpposing do |b|
          removedRecently = true if b.lastMoveUsed == :RAPIDSPIN || b.lastMoveUsed == :DEFOG
        end
        # Do not use against Magic Bounce and do not spam against Rapid Spin / Defog
        if !removedRecently && user.opposingHasActiveAbility?(:MAGICBOUNCE)
          if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] < 2
            # Check for Poison / Steel types or Flying / Levitate in opposing party
            hittable = 0
            for p in self.pbParty((user.index + 1) % 2)
              if p.hp > 0 && !p.hasType?(:FLYING) && !p.hasType?(:STEEL) &&
                 !p.hasType?(:POISON) && p.ability != :LEVITATE
                hittable += 1
              elsif p.hp > 0 && p.hasType?(:POISON)
                score -= 15
              end
            end
            if hittable > 0
              score += 10
              # Multiple layers is wanted
              score += 15 if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] == 1
              score += 10 * hittable
            end
          end
        end
      when "AddStealthRocksToFoeSide"
        # Stealth Rock
        removedRecently = false
        user.eachOpposing do |b|
          removedRecently = true if b.lastMoveUsed == :RAPIDSPIN || b.lastMoveUsed == :DEFOG
        end
        # Do not use against Magic Bounce and do not spam against Rapid Spin / Defog
        if !removedRecently && user.opposingHasActiveAbility?(:MAGICBOUNCE)
          if !user.pbOpposingSide.effects[PBEffects::StealthRock]
            # Check effectiveness against party
            effectiveness = 1.0
            party_size = 0
            for p in self.pbParty((user.index + 1) % 2)
              if p.hp > 0
                party_size += 1
                for t in p.types
                  case t
                  when :FIRE, :ICE, :FLYING, :BUG
                    effectiveness *= 2.0
                  when :FIGHTING, :GROUND, :STEEL
                    effectiveness *= 0.5
                  end
                end
              end
            end
            score += 10 * effectiveness * party_size
          end
        end
      when "GrassPledge"
        # Grass Pledge
        if partner
          fire_pledge = false
          water_pledge = false
          user.eachAllyMove do |m|
            if m.id == :FIREPLEDGE
              fire_pledge = true
              break
            elsif m.id == :WATERPLEDGE
              water_pledge = true
              break
            end
          end
          if fire_pledge && user.pbOpposingSide.effects[PBEffects::SeaOfFire] <= 0
            score += 50
          elsif water_pledge && user.pbOpposingSide.effects[PBEffects::Swamp] <= 0
            score += 50
          end
        end
      when "FirePledge"
        # Fire Pledge
        if partner
          grass_pledge = false
          water_pledge = false
          user.eachAllyMove do |m|
            if m.id == :GRASSPLEDGE
              grass_pledge = true
              break
            elsif m.id == :WATERPLEDGE
              water_pledge = true
              break
            end
          end
          if grass_pledge && user.pbOpposingSide.effects[PBEffects::SeaOfFire] <= 0
            score += 50
          elsif water_pledge && user.pbOwnSide.effects[PBEffects::Rainbow] <= 0
            score += 50
          end
        end
      when "WaterPledge"
        # Water Pledge
        if partner
          fire_pledge = false
          grass_pledge = false
          user.eachAllyMove do |m|
            if m.id == :FIREPLEDGE
              fire_pledge = true
              break
            elsif m.id == :GRASSPLEDGE
              grass_pledge = true
              break
            end
          end
          if fire_pledge && user.pbOwnSide.effects[PBEffects::Rainbow] <= 0
            score += 50
          elsif grass_pledge && user.pbOpposingSide.effects[PBEffects::Swamp] <= 0
            score += 50
          end
        end
      when "RemoveScreens"
        # Brick Break
        if !target.pbHasType?(:GHOST) || target.effects[PBEffects::Foresight]
          if target.pbOwnSide.effects[PBEffects::Reflect] > 0
            score += 20
          end
          if target.pbOwnSide.effects[PBEffects::LightScreen] > 0
            score += 20
          end
          if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
            score += 30
          end
        end
      when "CrashDamageIfFailsUnusableInGravity"
        # (High) Jump Kick
        if !target.opposes?(user)
          if target.pbHasType?(:GHOST) && !target.effects[PBEffects::Foresight]
            score -= 50
          end
        end
      when "UserMakeSubstitute"
        # Substitute
        if user.hp > user.totalhp * 0.3
          if user.effects[PBEffects::ProtectRate]==1
            score += 15
            score += 10 if user.hp > user.totalhp * 0.5
            score += 10 if user.hp > user.totalhp * 0.75
            score += 10 if user.hp >= user.totalhp
            user.eachOpposing do |b|
              score += 10 if b.status == :POISON
              score += 15 if b.effects[PBEffects::Curse]
              score += 20 if b.effects[PBEffects::PerishSong]>0
            end
          end
        end
      when "CurseTargetOrLowerUserSpd1RaiseUserAtkDef1"
        # Curse
        if user.pbHasType?(:GHOST) && !user.hasActiveItem?(:AEGISTALISMAN)
          if !target.effects[PBEffects::Curse] && target_item != :AEGISTALISMAN
            if user.hp > user.totalhp * 0.3
              score += 15
              score += 10 if user.hp > user.totalhp * 0.5
              score += 10 if user.hp > user.totalhp * 0.75
              score += 10 if user.hp >= user.totalhp
            end
          end
        else
          if user.pbCanRaiseStatStage?(:DEFENSE,user,move,false,true)
            # Defense +1
            statscore += 5
            statscore += 10 if physical_opponents > 0
          end

          if user.pbCanRaiseStatStage?(:ATTACK,user,move,false,true)
            # Attack +1
            statscore += 20 if has_physical
          end
        end
      when "LowerPPOfTargetLastMoveBy4", "LowerPPOfTargetLastMoveBy3"
        # Spite / Eerie Spell
        if target.lastMoveUsed && target_item != :AEGISTALISMAN
          for m in target.moves
            # Prioritize more the less PP the target's move has
            if m.id == target.lastMoveUsed
              if m.pp < 15
                score += 30
                score += (15 - m.pp) * 2
              end
            end
          end
        end
      when "StartDamageTargetEachTurnIfTargetAsleep"
        # Nightmare
        if target.status == :SLEEP && target.statusCount > 1 && target_item != :AEGISTALISMAN
          score += 20
          score += 20 if target.statusCount > 2
        end
      when "RemoveUserBindingAndEntryHazards"
        # Rapid Spin
        score += 10 * user.pbOwnSide.effects[PBEffects::Spikes]
        score += 15 * user.pbOwnSide.effects[PBEffects::ToxicSpikes]
        score += 20 if user.pbOwnSide.effects[PBEffects::StealthRock]
      when "AttackTwoTurnsLater"
        # Doom Desire / Future Sight
        if target.opposes?(user)
          if !user.hasActiveAbility?(:TIMESKIP) &&
              !user.hasActiveItem?(:ODDSTONE) &&
              !user.hasActiveItem?(:TIMESTONE)
            score -= 20
          end
        end
      when "UserAddStockpileRaiseDefSpDef1"
        # Stockpile
        if user.effects[PBEffects::Stockpile] < 3
          score += 30
        end
      when "PowerDependsOnUserStockpile"
        # Spit Up
        if target.opposes?(user) && user.effects[PBEffects::Stockpile] > 0
          # Negative score to indicate lost stat stages
          score -=  user.effects[PBEffects::Stockpile] * 15
          # Damage is handled elsewhere
        end
      when "HealUserDependingOnUserStockpile"
        # Swallow
        if user.effects[PBEffects::Stockpile] > 0
          # Negative score to indicate lost stat stages
          score -=  user.effects[PBEffects::Stockpile] * 15
          amt = 25
          amt = 50 if user.effects[PBEffects::Stockpile] == 2
          amt = 100 if user.effects[PBEffects::Stockpile] == 3
          score += [amt, 100 - [user.hp * 100 / user.totalhp,100].min].min
        end
      when "FailsIfUserDamagedThisTurn"
        # Focus Punch
        if target.opposes?(user)
          can_attack = false
          user.eachOpposing do |b|
            if actionable[b.index]
              can_attack = true
              score -= 20
            end
          end
          score -= 40 if can_attack
        end
      when "FailsIfTargetActed"
        # Sucker Punch
        # May or may not use Sucker Punch consecutively
        if target.opposes?(user)
          if user.lastMoveUsed == :SUCKERPUNCH
            score -= 30 + self.pbRandom(50)
          end
        end
      when "RedirectAllMovesToUser"
        # Follow Me / Rage Powder
        score += 35
      when "StartGravity"
        # Gravity
        if @field.effects[PBEffects::Gravity] <= 0
          airborne = 0
          user.eachOpposing do |b|
            airborne += 1 if b.airborne?
          end
          score += 30 if airborne > 0
          score += 20 * airborne
        end
      when "StartUserAirborne"
        # Magnet Rise
        if user.effects[PBEffects::MagnetRise] <= 0
          score += 20
          user.eachOpposingMove do |m|
            if m.type == :GROUND
              if user.pbHasType?(:ELECTRIC) && user.pbHasType?(:STEEL)
                score += 60
              elsif user.pbHasType?(:ELECTRIC) || user.pbHasType?(:STEEL) || user.pbHasType?(:ROCK)
                score += 40
              else
                score += 20
              end
            end
          end
        end
      when "StartTargetAirborneAndAlwaysHitByMoves"
        # Telekinesis
        if target.effects[PBEffects::Telekinesis] <= 0
          score += 30
        end
      when "HitsTargetInSkyGroundsTarget"
        # Smack Down
        if !target.effects[PBEffects::SmackDown]
          if target.airborne?
            score += 30
          end
        end
      when "StartSlowerBattlersActFirst"
        # Trick Room
        if @field.effects[PBEffects::TrickRoom] <= 0
          score += 20
          for s in opponent_speeds
            if s > speed_stat
              score += 30
            end
          end
        else
          for s in opponent_speeds
            if s < speed_stat
              score += 30
            end
          end
        end
      when "UserSwapsPositionsWithAlly"
        # Ally Switch
        score += 10 + self.pbRandom(40)
      when "StartSwapAllBattlersBaseDefensiveStats"
        # Wonder Room
        if @field.effects[PBEffects::WonderRoom] <= 0
          score += 40
        end
      when "FailsIfUserHasUnusedMove"
        # Last Resort
        # Should hopefully be handled by pbMoveFailed
      when "RaisePlusMinusUserAndAlliesDefSpDef1"
        # Magnetic Flux
        buff_count = 0
        eachSameSideBattler(user.index) do |b|
          if b.hasActiveAbility?(:PLUS) || b.hasActiveAbility?(:MINUS)
            if b.pbCanRaiseStatStage?(:DEFENSE,user,move,false,true) ||
              b.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,move,false,true)
              buff_count += 1
            end
          end
        end
        score += 30 * buff_count
      when "RaiseTargetSpDef1"
        # Aromatic Mist
        if !target.opposes?(user) && target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,move,false,true)
          score += 5
          score += 10 * special_opponents
        end
      when "RaiseGroundedGrassBattlersAtkSpAtk1"
        # Rototiller
        buff_count = 0
        eachSameSideBattler(user.index) do |b|
          if !b.airborne? && b.pbHasType?(:GRASS)
            if b.pbCanRaiseStatStage?(:ATTACK,user,move,false,true) ||
              b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,move,false,true)
              buff_count += 1
            end
          end
        end
        score += 25 * buff_count
      when "RaiseGrassBattlersDef1"
        # Flower Shield
        buff_count = 0
        eachSameSideBattler(user.index) do |b|
          if b.pbHasType?(:GRASS)
            if b.pbCanRaiseStatStage?(:DEFENSE,user,move,false,true)
              buff_count += 1
            end
          end
        end
        score += 5 * buff_count
        score += 10 * buff_count * physical_opponents
      when "InvertTargetStatStages"
        # Topsy-Turvy
        total = 0
        GameData::Stat.each_main do |s|
          total += target.stages[s] || 0
        end
        score += total * 10
      when "AddGhostTypeToTarget"
        # Trick-or-Treat
        if !target.pbHasType?(:GHOST) && target_item != :AEGISTALISMAN
          score += 30
        end
      when "AddGrassTypeToTarget"
        # Forest's Curse
        if !target.pbHasType?(:GRASS) && target_item != :AEGISTALISMAN
          score += 35
        end
      when "TargetMovesBecomeElectric"
        # Electrify
        score += 30
      when "NormalMovesBecomeElectric"
        # Ion Deluge / Plasma Fists
        score += 5
        for m in target.moves
          if m.type == :NORMAL
            score += 10
          end
        end
      when "TargetNextFireMoveDamagesTarget"
        # Powder
        for m in target.moves
          if m.type == :FIRE
            if user.lastMoveUsed == :POWDER
              score += 10 + rand(30)
            else
              score += 40
            end
          end
        end
      when "ProtectUserSideFromDamagingMovesIfUserFirstTurn"
        # Mat Block
        score += 20 if user.effects[PBEffects::ProtectRate]==1
      when "ProtectUserSideFromStatusMoves"
        # Crafty Shield
        score += 20 if user.effects[PBEffects::ProtectRate]==1
      when "ProtectUserFromDamagingMovesKingsShield"
        # King's Shield
        if user.effects[PBEffects::ProtectRate]==1
          score += 25
          score += 10 * physical_opponents
          score += 30 if user.form == 1
        end
      when "ProtectUserFromTargetingMovesSpikyShield"
        # Spiky Shield
        if user.effects[PBEffects::ProtectRate]==1
          score += 25
          score += 10 * physical_opponents
        end
      when "TwoTurnAttackRaiseUserSpAtkSpDefSpd2"
        # Geomancy
        if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,move,false,true) &&
           user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,move,false,true) &&
           user.pbCanRaiseStatStage?(:SPEED,user,move,false,true)
          if user.hasActiveItem?(:POWERHERB) || user.hasActiveAbility?(:TIMESKIP) 
            score += 120
          else
            score += 35
          end
        end
      when "HealUserByThreeQuartersOfDamageDone"
        # 75% Drain
        # Grant score based on how much HP will be healed
        if target.opposes?(user)
          amt = [damage * 75 / user.totalhp, 100 - [user.hp * 100 / user.totalhp, 100].min].min
          score += target.hasActiveAbility?(:LIQUIDOOZE) ? -amt : amt
        end
      when "RaiseUserAttack3IfTargetFaints"
        # Fell Stinger
        if damage > target.hp
          score += 70
        end
      when "LowerTargetAtkSpAtk1SwitchOutUser"
        # Parting Shot
        party_able = 0
        for p in self.pbParty(target.index)
          party_able += 1 if p.hp > 0
        end
        # Make sure user has enough Pokemon to switch
        if party_able > 2
          score += 25
          GameData::Stat.each_main do |s|
            # Gain 10 points for each stat decrease to remove
            stage = user.stages[s] || 0
            score -= stage * 10
          end
          # Use less often if switched Pokemon will be hurt by hazards
          score -= 10 if target.pbOwnSide.effects[PBEffects::StealthRock]
          score -= 5 * target.pbOwnSide.effects[PBEffects::Spikes]
        end
      when "TrapAllBattlersInBattleForOneTurn"
        # Fairy Lock
        score += 10 + self.pbRandom(30)
      when "AddStickyWebToFoeSide"
        # Sticky Web
        removedRecently = false
        user.eachOpposing do |b|
          removedRecently = true if b.lastMoveUsed == :RAPIDSPIN || b.lastMoveUsed == :DEFOG
        end
        # Do not use against Magic Bounce and do not spam against Rapid Spin / Defog
        if !removedRecently && user.opposingHasActiveAbility?(:MAGICBOUNCE)
          if !user.pbOpposingSide.effects[PBEffects::StickyWeb]
            # Check party size to estimate value
            party_size = 0
            for p in self.pbParty((user.index + 1) % 2)
              if p.hp > 0
                party_size += 1
              end
            end
            if party_size > 2
              score += 40
              score += 15 * party_size
            end
          end
        end
      when "StartElectricTerrain"
        # Electric Terrain
        if @field.terrain != :Electric
          score += 40
          score += 20 if user.hasActiveItem?(:TERRAINEXTENDER)
        end
      when "StartGrassyTerrain"
        # Grassy Terrain
        if @field.terrain != :Grassy
          score += 40
          score += 20 if user.hasActiveItem?(:TERRAINEXTENDER)
          eachSameSideBattler(user.index) do |b|
            score += 30 if b.hasActiveAbility?(:GRASSPELT)
          end
        end
      when "StartMistyTerrain"
        # Misty Terrain
        if @field.terrain != :Misty
          score += 40
          score += 20 if user.hasActiveItem?(:TERRAINEXTENDER)
        end
      when "FailsIfUserNotConsumedBerry"
        # Belch - Unhandled
      when "PoisonTargetLowerTargetSpeed1"
        # Toxic Thread
        if target.pbCanPoison?(user,false,move) &&
           !target.hasActiveAbility?(:POISONHEAL) &&
           !target.hasActiveAbility?(:TOXICBOOST) &&
           !target.hasActiveAbility?(:GUTS) &&
           !target.hasActiveAbility?(:MAGICGUARD)
          score += 20
        end
        if target.pbCanLowerStatStage?(:SPEED,user,move,false,true)
          # Speed -1
          score += 5
          for s in ally_speeds
            if s <= target_speed && s > target_speed * 2 / 3
              score += 15
            end
          end
        end
      when "CureTargetBurn"
        # Sparkling Aria
        if target.status == :BURN
          score -= 20
        end
      when "CureTargetStatusHealUserHalfOfTotalHP"
        # Purify
        if target.status != :NONE
          score -= 10
          score += [50, 100 - [user.hp * 100 / user.totalhp, 100].min].min
        end
      when "RaisePlusMinusUserAndAlliesAtkSpAtk1"
        # Gear Up
        buff_count = 0
        eachSameSideBattler(user.index) do |b|
          if b.hasActiveAbility?(:PLUS) || b.hasActiveAbility?(:MINUS)
            if b.pbCanRaiseStatStage?(:ATTACK,user,move,false,true) ||
              b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,move,false,true)
              buff_count += 1
            end
          end
        end
        score += 35 * buff_count
      when "UserStealTargetPositiveStatStages"
        # Spectral Thief
        # Better the more buffs the target has
        oppstat = 0
        GameData::Stat.each_main do |s|
          oppstat += target.stages[s] || 0
        end
        score = oppstat * 10
      when "EnsureNextCriticalHit"
        # Laser Focus
        if !user.effects[PBEffects::LaserFocus] &&
           user.pbOpposingSide.effects[PBEffects::LuckyChant]<=0 # Do not use during Lucky Chant
          addscore = 30
          if user.hasActiveAbility?(:SNIPER)
            # Has Sniper, crit rate is ideal
            addscore += 30
          end
          # Crit Rate is not optimal against opponents with crit immunity
          user.eachOpposing do |b|
            if b.hasActiveAbility?(:SHELLARMOR) || b.hasActiveAbility?(:BATTLEARMOR)
              addscore *= 0.5
            end
          end
          score += addscore
        end
      when "LowerUserDefense1"
        # Clanging Scales - Unhandled
      when "HealUserByTargetAttackLowerTargetAttack1"
        # Strength Sap
        if target.pbCanLowerStatStage?(:ATTACK,user,move,false,true)
          if !target.hasActiveAbility?(:CONTRARY)
            score += 15 if target_has_physical
            amt = target.attack * 100 / user.totalhp
            score += [amt, 100 - [target.hp * 100 / target.totalhp, 100].min].min
          end
        end
      when "UserTargetSwapBaseSpeed"
        # Speed Swap
        # The more the target's stats multiply your own, the better
        if target_speed > speed_stat
          if @field.effects[PBEffects::TrickRoom] <= 1
            score += 30
            score += (target_speed - speed_stat) * 0.5
          end
        elsif target_speed < speed_stat
          # Swap speed 
          if @field.effects[PBEffects::TrickRoom] > 2
            score += (target_speed - speed_stat) * 0.5
          end
        end
      when "UserLosesFireType"
        # Burn Up - No Special Handling
      when "IgnoreTargetAbility"
        # Moongeist Beam / Sunsteel Strike - No Special Handling
      when "CategoryDependsOnHigherDamageIgnoreTargetAbility"
        # Photon Geyser - No Special Handling
      when "NegateTargetAbilityIfTargetActed"
        # Core Enforcer - No Special Handling
      when "DoublePowerIfUserLastMoveFailed"
        # Stomping Tantrum - No Special Handling
      when "StartWeakenDamageAgainstUserSideIfHail"
        # Aurora Veil
        if pbWeather == :Hail
          if user.pbOwnSide.effects[PBEffects::AuroraVeil]<=0
            score += 80
            score += 30 if user.hasActiveItem?(:LIGHTCLAY)
          end
        end
      when "ProtectUserBanefulBunker"
        # Baneful Bunker
        if user.effects[PBEffects::ProtectRate]==1
          score += 25
          user.eachOpposing do |b|
            if b.pbCanPoison?(user,false,nil)
              has_physical = false
              b.eachMove do |m|
                has_physical = true if m.baseDamage >= 40
              end
              score += 15 if has_physical
            end
          end
        end
      when "ProtectUserFromDamagingMovesObstruct"
        # Obstruct
        if user.effects[PBEffects::ProtectRate]==1
          score += 25
          user.eachOpposing do |b|
            if b.pbCanPoison?(user,false,nil)
              has_physical = false
              b.eachMove do |m|
                has_physical = true if m.baseDamage >= 40
              end
              score += 15 if has_physical
            end
          end
        end
      when "TypeIsUserFirstType"
        # Revelation Dance - No Special Handling
      when "RedirectAllMovesToTarget"
        # Spotlight - Unhandled
        score += 10
      when "TargetUsesItsLastUsedMoveAgain"
        # Instruct
        if !target.opposes?(user)
          score -= 40
        else
          # Do not use on opponents
          score -= 50
        end
      when "DisableTargetSoundMoves"
        # Throat Chop
        if target.effects[PBEffects::ThroatChop] <= 0
          # Prioritize if target has sound moves
          found = false
          for m in target.moves
            if m.soundMove?
              score += found ? 10 : 30
            end
          end
        end
      when "HealUserDependingOnSandstorm"
        # Shore Up
        if user.hp < user.totalhp * 0.75
          amt = 50
          if self.pbWeather==:Sandstorm
            amt = 200.0 / 3.0
          end
          score += [amt, 100 - [user.hp * 100 / user.totalhp, 100].min].min
        end
      when "HealTargetDependingOnGrassyTerrain"
        # Floral Healing
        # Do not use against opponents
        if target.opposes?(user)
          score -= 30
        end
        if target.hp < target.totalhp * 0.75
          amt = 50
          amt = 67 if @field.terrain == :Grassy
          score -= [amt, 100 - [target.hp * 100 / target.totalhp, 100].min].min
        end
      when "HealAllyOrDamageFoe"
        # Pollen Puff
        if !target.opposes?(user)
          # Nullify score lost from damaging partner
          score -= damage * 100 / target.totalhp
          if target.hp < target.totalhp * 0.75
            score -= [50, 100 - [target.hp * 100 / target.totalhp, 100].min].min
          end
        end
      when "UserLosesHalfOfTotalHPExplosive", "UserLosesHalfOfTotalHP"
        # Mind Blown / Steel Beam
        score -= 40
      when "UsedAfterUserTakesPhysicalDamage"
        # Shell Trap
        if physical_opponents > 0
          # Use Shell Trap semi-randomly
          if user.lastMoveUsed == :SHELLTRAP
            score += 10 + self.pbRandom(40)
          else
            score += 40 + self.pbRandom(40)
          end
        else
          score -= 20
        end
      when "BurnAttackerBeforeUserActs"
        # Beak Blast
        if target.pbCanBurn?(user,false,nil)
          score += 5 * physical_opponents
        end
      when "StartPsychicTerrain"
        # Psychic Terrain
        if @field.terrain != :Psychic
          score += 40
          score += 20 if user.hasActiveItem?(:TERRAINEXTENDER)
        end
      when "FailsIfNotUserFirstTurn"
        # First Impression - No Special Handling
      when "LowerTargetSpeed1MakeTargetWeakerToFire"
        if !(target.effects[PBEffects::TarShot])
          score += 20
        end
      when "HitTwoTimesTargetThenTargetAlly"
        # Dragon Darts - No Special Handling
      when "AllBattlersConsumeBerry"
        # Teatime
        if user.item && GameData::Item.get(user.item).is_berry? && user.itemActive?
          score += 20
        end
        user.eachAlly do |ally|
          if ally.item && GameData::Item.get(ally.item).is_berry? && ally.itemActive?
            score += 20
          end
        end
      when "DoublePowerIfTargetNotActed"
        # Bolt Beak / Fishious Rend
        target_speed = target.pbSpeed
        user_speed = user.pbSpeed
        if user_speed > target_speed
          score += 30
        end
      when "HitsAllFoesAndPowersUpInPsychicTerrain"
        # Expanding Force
        if @field.terrain == :Psychic
          score += 30
        end
      when "DoublePowerInElectricTerrain"
        # Rising Voltage
        if @field.terrain == :Psychic
          score += 30
        end
      when "RemoveTerrain"
        if @field.terrain != :None
          score += 30
        end
      when "SwapSideEffects"
        # Court Change
        positive = [PBEffects::LightScreen, PBEffects::Reflect, PBEffects::AuroraVeil, PBEffects::Rainbow, PBEffects::Tailwind]
        positive_t = [0, 0, 0, 0, 0]
        negative = [PBEffects::Swamp, PBEffects::StealthRock, PBEffects::Spikes, PBEffects::ToxicSpikes, PBEffects::StickyWeb]
        negative_t = [0, 1, 0, 0, 1]
        # 0 means the effect is numeric, 1 means the effect is a boolean
        for i in 0...positive.length
          score -= 20 if (positive_t[i] == 0) ? (user.pbOwnSide.effects[positive[i]] > 0) : (user.pbOwnSide.effects[positive[i]])
          score += 20 if (positive_t[i] == 0) ? (user.pbOpposingSide.effects[positive[i]] > 0) : (user.pbOpposingSide.effects[positive[i]])
        end
        for i in 0...negative.length
          score += 20 if (negative_t[i] == 0) ? (user.pbOwnSide.effects[negative[i]] > 0) : (user.pbOwnSide.effects[negative[i]])
          score -= 20 if (negative_t[i] == 0) ? (user.pbOpposingSide.effects[negative[i]] > 0) : (user.pbOpposingSide.effects[negative[i]])
        end
      when "StartNegateTargetPoisonImmunity"
        # Corrosive Acid
        if !target.effects[PBEffects::CorrosiveAcid]
          if target.pbHasType?(:STEEL)
            score += 30
          end
        end
      when "StartWindsWeather"
        # Winds
        if pbWeather != :Winds
          score += 40
          # Extra points if removing other weather
          if pbWeather != :None
            score += 10
          end
        end
      end

      mult = 100.0
      if move.addlEffect != 0
        mult = move.addlEffect
        mult *= 2.0 if user.hasActiveAbility?(:SERENEGRACE)
        mult *= 0.0 if user.hasActiveAbility?(:SHEERFORCE)
      end
      if target && move.category == 2
        mult *= 0.5 if target.hasActiveAbility?(:WONDERSKIN)
        mult *= -1.0 if target.hasActiveAbility?(:MAGICBOUNCE)
      end
      if move.target == :FoeSide && move.category == 2
        if user.opposingHasActiveAbility?(:MAGICBOUNCE)
          mult *= -1.0
        end
      end
      return score + (effscore + statscore + debuffscore) * mult / 100.0
    end

end