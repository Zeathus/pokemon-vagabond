class PokeBattle_Battler

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

class PokeBattle_Battle

    def pbGetEffectScore(move,damage,user,target,actionable,fainted,chosen=false)
      score = 0
      
      ### Get opponent statistics
      physical_opponents = 0
      special_opponents = 0
      status_opponents = 0
      opponent_speeds = []
      
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
      return score if func == "000" || func == "001" || func == "002" || (target && target.damageState.substitute)
      
      effscore = 0
      
      ### Status conditions
      if func == "01B"
        # Psycho Shift
        if user.status != :NONE
          effscore += 10
          # Pretend it is a regular status move
          case user.status
          when :POISON
            if user.effects[PBEffects::Toxic]>0
              func = "006"
            else
              func = "005"
            end
          when :SLEEP
            func = "003"
          when :PARALYSIS
            func = "007"
          when :BURN
            func = "00A"
          end
        end
      end
      
      if func == "005" && user.hasActiveItem?(:NOXIOUSCHOKER)
        func = "006"
      end
      
      case func
      when "003"
        # Sleep
        if target.pbCanSleep?(user,false,move) &&
           !target.hasActiveAbility?(:EARLYBIRD)
          effscore += 40
          actionable[target.index] = false if chosen
        end
      when "004"
        # Drowsy (Yawn)
        if target.pbCanSleep?(user,false,move) &&
           !target.hasActiveAbility?(:EARLYBIRD)
          effscore += 30
        end
      when "005"
        # Poison
        if target.pbCanPoison?(user,false,move) &&
           !target.hasActiveAbility?(:POISONHEAL) &&
           !target.hasActiveAbility?(:TOXICBOOST) &&
           !target.hasActiveAbility?(:GUTS) &&
           !target.hasActiveAbility?(:MAGICGUARD)
          effscore += 20
        end
      when "006"
        # Toxic
        if target.pbCanPoison?(user,false,move) &&
           !target.hasActiveAbility?(:POISONHEAL) &&
           !target.hasActiveAbility?(:TOXICBOOST) &&
           !target.hasActiveAbility?(:MAGICGUARD)
          if target.hasActiveAbility?(:GUTS)
            effscore += 20
          else
            effscore += 40
          end
        end
      when "007"
        # Paralysis
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
      when "00A"
        # Burn
        if target.pbCanBurn?(user,false,move) &&
           !target.hasActiveAbility?(:GUTS) &&
           !target.hasActiveAbility?(:FLAREBOOST)
          if target_has_physical && target_has_special
            effscore += 20
          elsif target_has_physical
            effscore += 40
          end
        end
      when "013", "014", "015"
        # Confusion
        if target.pbCanConfuse?(user,false,move) &&
           !target.hasActiveAbility?(:TANGLEDFEET)
          effscore += 30
        end
      when "016"
        # Attract
        if target.pbCanAttract?(user,false)
          effscore += 35
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
          if ((func == "005" || func == "006") && user.pbCanPoison?(user,false,nil)) ||
             (func == "007" && user.pbCanParalyze?(user,false,nil)) ||
             (func == "00A" && user.pbCanBurn?(user,false,nil))
            effscore *= 0.5
          end
        end
      end
      
      
      ### Stat changes on user
      statscore = 0
      
      # Decreases Stats
      if func == "03B" || func == "03C" || func == "03D" || func == "03E" || func == "03F"
        if user.hasActiveAbility?(:CONTRARY)
          if func == "03B"
            func = "024"
          elsif func == "03C"
            func = "02A"
          elsif func == "03D"
            statscore += 40
          elsif func == "03E"
            func = "01F"
          elsif func == "03F"
            func = "032"
          end
        else
          statscore -= 10
        end
      end
      
      if user.pbCanRaiseStatStage?(:ATTACK,user,move,false,true)
        # Attack +1
        if func == "01C" || func == "024" || func == "025" || func == "026" ||
           func == "027" || func == "029" || func == "036" ||
           (func == "028" && self.pbWeather!=:Sun) # Growth
          statscore += 20 if has_physical
        end
         
        # Attack +2
        if func == "02E" || func == "035" ||
           (func == "028" && self.pbWeather==:Sun) # Growth
          statscore += 30 if has_physical
        end
      
        # Belly Drum
        if func == "03A"
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
        if func == "01D" || func == "01E" || func == "024" || func == "025" ||
           func == "02A" || func == "136"
          statscore += 5
          statscore += 10 if physical_opponents > 0
          
          if func == "01E" && !user.effects[PBEffects::DefenseCurl]
            # Defense Curl
            for m in user.moves
              if m.function == "0D3"
                # Has Rollout or Ice Ball
                statscore += 30
                break
              end
            end
          end
        end
         
        # Defense +2
        if func == "02F"
           statscore += 5
           statscore += 10 if physical_opponents > 0
           statscore += 5 if physical_opponents > 1
        end
         
        # Defense +3
        if func == "038"
           statscore += 5
           statscore += 15 if physical_opponents > 0
           statscore += 10 if physical_opponents > 1
        end
      end
      
      if user.pbCanRaiseStatStage?(:SPEED,user,move,false,true)
        # Speed +1
        if func == "01F" || func == "026" || func == "02B"
          statscore += 5
          for s in opponent_speeds
            if s >= speed_stat && s < speed_stat * 1.5
              statscore += 15
            end
          end
        end
         
        # Speed +2
        if func == "030" || func == "031" || func == "035" || func == "036"
          statscore += 10
          for s in opponent_speeds
            if s >= speed_stat && s < speed_stat * 2.0
              statscore += 15
            end
          end
        end
      end
      
      if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,move,false,true)
        # Sp. Atk +1
        if func == "020" || func == "027" || func == "02B" || func == "02C" ||
           (func == "028" && self.pbWeather!=:Sun) # Growth
          statscore += 20 if has_special
        end
         
        # Sp. Atk +2
        if func == "032" || func == "035" ||
           (func == "028" && self.pbWeather==:Sun) # Growth
           statscore += 30 if has_special
        end
         
        # Sp. Atk +3
        if func == "039"
           statscore += 50 if has_special
        end
      end
      
      if user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,move,false,true)
        # Sp. Def +1
        if func == "021" || func == "02A" || func == "02B" || func == "02C"
          statscore += 5
          statscore += 10 if special_opponents > 0
        end
        
        # Sp. Def +2
        if func == "033"
           statscore += 5
           statscore += 10 if special_opponents > 0
           statscore += 5 if special_opponents > 1
        end
      end
      
      if user.pbCanRaiseStatStage?(:EVASION,user,move,false,true)
        # Evasiveness +1
        if func == "022"
          statscore += 20
        end
        
        # Evasiveness +2
        if func == "034"
          statscore += 30
        end
      end
      
      if user.pbCanRaiseStatStage?(:ACCURACY,user,move,false,true)
        # Accuracy +1
        if func == "025" || func == "029"
          stage = user.stages[:ACCURACY]+6
          stages = [3.0/9.0, 3.0/8.0, 3.0/7.0, 3.0/6.0, 3.0/5.0, 3.0/4.0, 1.0,
                           4.0/3.0, 5.0/3.0, 6.0/3.0, 7.0/3.0, 8.0/3.0, 9.0/3.0]
          addscore = 20
          for m in user.moves
            acc = m.accuracy * stages[stage]
            if acc < 85
              statscore += addscore
              addscore -= 5
            end
          end
        end
      end
      
      # Accupressure
      if func == "037"
        statscore += 25
      end
      
      # Boost score if the user has Stored Power
      for m in user.moves
        if m.function == "08E"
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
      
      
      ### Stat changes on target
      debuffscore = 0
      
      # Swagger / Flatter
      if func == "040" || func == "041"
        if target.pbCanConfuse?(user,false,move)
          score += 25
          # Prioritize if target has no physical moves and the move is Swagger
          score += 20 if !target_has_physical && func == "040"
        end
        if target.hasActiveAbility?(:CONTRARY)
          score += 10
        end
      end
      
      if target
        if target.pbCanLowerStatStage?(:ATTACK,user,move,false,true)
          # Attack -1
          if func == "042" || func == "04A" || func == "119" || func == "13A" ||
             (func == "140" && target.status == :POISON)
            if target_has_physical && target_has_special
              debuffscore += 10
            elsif target_has_physical
              debuffscore += 20
            end
          end
          
          # Attack -2
          if func == "04B"
            if target_has_physical && target_has_special
              debuffscore += 20
            elsif target_has_physical
              debuffscore += 30
            end
          end
        end
        
        if target.pbCanLowerStatStage?(:DEFENSE,user,move,false,true)
          # Defense -1
          if func == "043" || func == "04A" || func == "13B"
            debuffscore += 10
          end
          
          # Defense -2
          if func == "04C"
            debuffscore += 30
          end
        end
        
        if target.pbCanLowerStatStage?(:SPEED,user,move,false,true)
          # Speed -1
          if func == "044" ||
             (func == "140" && target.status == :POISON)
            debuffscore += 5
            for s in ally_speeds
              if s <= target_speed && s > target_speed * 2 / 3
                debuffscore += 15
              end
            end
          end
          
          # Speed -2
          if func == "04D"
            debuffscore += 5
            for s in ally_speeds
              if s <= target_speed && s * 0.5 > target_speed * 0.5
                debuffscore += 15
              end
            end
          end
        end
        
        if target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user,move,false,true)
          # Sp. Atk -1
          if func == "045" || func == "13A" || func == "13C" ||
             (func == "140" && target.status == :POISON)
            if target_has_physical && target_has_special
              debuffscore += 10
            elsif target_has_special
              debuffscore += 20
            end
          end
          
          # Sp. Atk -2
          if func == "13D"
            if target_has_physical && target_has_special
              debuffscore += 20
            elsif target_has_special
              debuffscore += 30
            end
          end
          # Captivate is not handled, useless move
        end
        
        if target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,move,false,true)
          # Sp. Def -1
          if func == "046"
            debuffscore += 10
          end
          
          # Sp. Def -2
          if func == "04F"
            debuffscore += 30
          end
        end
        
        if target.pbCanLowerStatStage?(:ACCURACY,user,move,false,true)
          # Accuracy -1
          if func == "047"
            score += 25
          end
        end
        
        if target.pbCanLowerStatStage?(:EVASION,user,move,false,true)
          # Evasion -2
          if func == "048"
            # Sweet Scent, Defog does not get score for its Evasion debuff
            if target.stages[:EVASION]>0
              score += (target.stages[:EVASION]) * 20
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
      when "011", "0B4"
        # Snore, Sleep Talk
        if user.status == :SLEEP && user.statusCount>1
          score += 100
        end
      when "012"
        # Fake Out
        if user.turnCount < 1 && !target.hasActiveAbility?(:INNERFOCUS)
          score += 50
          actionable[target.index] = false if chosen
        elsif target.opposes?(user)
          score -= 100
        end
      when "018"
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
          elsif user.status == :POISON
            # Don't stay toxiced for long
            if user.effects[PBEffects::Toxic]>5
              score += 50
            elsif user.effects[PBEffects::Toxic]>2
              score += 30
            end
          end
        end
      when "019"
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
          elsif p.status == :POISON
            score += 30
          end
        end
      when "01A"
        # Safeguard
        if user.pbOwnSide.effects[PBEffects::Safeguard]<=0
          score += 40
        end
      when "023"
        # Focus Energy
        if user.effects[PBEffects::FocusEnergy]==0 &&
           user.pbOpposingSide.effects[PBEffects::LuckyChant]<=0 # Do not use during Lucky Chant
          addscore = 30
          if user.hasActiveItem?(:RAZORCLAW) || user.hasActiveItem?(:SCOPELENS) ||
             user.hasActiveAbility?(:SUPERLUCK)
            # Has a crit rate item or ability, probably uses a critical hit strategy
            addscore += 20
          end
          if user.hasActiveAbility?(:SNIPER)
            # Has Sniper, crit rate is ideal
            addscore += 20
          end
          # Crit Rate is not optimal against opponents with crit immunity
          user.eachOpposing do |b|
            if b.hasActiveAbility?(:SHELLARMOR) || b.hasActiveAbility?(:BATTLEARMOR)
              addscore *= 0.5
            end
          end
          score += addscore
        end
      when "035"
        # Shell Smash
        if user.hasActiveItem?(:WHITEHERB)
          score += 30
        end
      when "049"
        # Defog
        score += 10 * user.pbOwnSide.effects[PBEffects::Spikes]
        score += 15 * user.pbOwnSide.effects[PBEffects::ToxicSpikes]
        score += 20 if user.pbOwnSide.effects[PBEffects::StealthRock]
        score -= 10 * user.pbOpposingSide.effects[PBEffects::Spikes]
        score -= 15 * user.pbOpposingSide.effects[PBEffects::ToxicSpikes]
        score -= 20 if user.pbOpposingSide.effects[PBEffects::StealthRock]
      when "050"
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
      when "051"
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
      when "052"
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
      when "053"
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
      when "054"
        # Heart Swap
        # Better the more buffs the target has than the user
        ownstat = 0
        oppstat = 0
        GameData::Stat.each_main do |s|
          ownstat += user.stages[s] || 0
          oppstat += target.stages[s] || 0
        end
        score = (oppstat - ownstat) * 20
      when "055"
        # Psych Up
        # Better the more buffs the target has than the user
        ownstat = 0
        oppstat = 0
        GameData::Stat.each_main do |s|
          ownstat += user.stages[s] || 0
          oppstat += target.stages[s] || 0
        end
        score = (oppstat - ownstat) * 10
      when "056"
        # Mist
        if user.pbOwnSide.effects[PBEffects::Mist]<=0
          score += 30
        end
      when "057"
        # Power Trick
        # Assume a Power Trick strategy is intended, prioritize if not yet used
        if !user.effects[PBEffects::PowerTrick]
          score += 50
        end
      when "058"
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
      when "059"
        # Guard Split
        dif = target.defense * 1.0 / user.defense
        if dif > 1.0
          score += (dif - 1.0) * 20
        end
        dif = target.spdef * 1.0 / user.spdef
        if dif > 1.0
          score += (dif - 1.0) * 20
        end
      when "05A"
        # Pain Split
        # Calculate as if it's damage and healing points
        if target_item != :AEGISTALISMAN
          ownpercent = user.hp * 100 / user.totalhp
          opppercent = target.hp * 100 / target.totalhp
          splithp = (user.hp + target.hp) / 2
          score += (splithp * 100 / user.totalhp) - ownpercent
          score -= (splithp * 100 / target.totalhp) - opppercent
        end
      when "05B"
        # Tailwind
        # Good move, just use it (unless Trick Room persists after this turn)
        if user.pbOwnSide.effects[PBEffects::Tailwind]<=0 &&
           self.field.effects[PBEffects::TrickRoom]<=1
          score += 50
        end
      when "05C"
        # Mimic
        score += 40
      when "05D"
        # Sketch
        score += 40
      when "05E"
        # Conversion
        score += 40
      when "05F"
        # Conversion 2
        score += 40
      when "060"
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
      when "061"
        # Soak
        if !target.pbHasType?(:WATER)
          if !target.opposes?(user) && target.hasActiveAbility?(:WONDERGUARD)
            score -= 1000 # Negative score is good for partner targets
          else
            score += 10
            # Prioritize if a partner can hit water-types super effectively
            user.eachSameSideMove do |m|
              if (m.physicalMove? || m.specialMove?) &&
                 (m.type == :GRASS || m.type == :ELECTRIC)
                score += 30
                break
              end
            end
            # Prioritize if you remove the target's STAB possibilities
            has_water_move = false
            for m in target.moves
              if (m.physicalMove? || m.specialMove?) &&
                 (m.type == :WATER)
                 has_water_move = true
                 break
              end
            end
            if !has_water_move
              score += 20
            end
          end
        end
      when "062"
        # Reflect Type
        if user.type1 != target.type1 || user.type2 != target.type2
          score += 30
        end
      when "063"
        # Simple Beam
        if target.ability != :SIMPLE
          if !target.opposes?(user)
            # Use on partner if they have a buffing move
            for m in target.moves
              if m.is_a?(PokeBattle_StatUpMove)
                score -= 50
              end
            end
          else
            score += 30
          end
        end
      when "064"
        # Worry Seed
        if target.ability != :INSOMNIA
          score += 30
        end
      when "065"
        # Role Play
        if user.ability != target.ability
          score += 30
        end
      when "066"
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
      when "067"
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
      when "068"
        # Gastro Acid
        if !target.effects[PBEffects::GastroAcid] &&
           !(target.ability == :TRUANT ||
             target.ability == :SLOWSTART ||
             target.ability == :DEFEATIST)
          score += 40
        end
      when "069"
        # Transform
        score += 50
      when "06A"
        # Sonic Boom
        # Handled by regular damage calculation
      when "06B"
        # Dragon Rage
        # Handled by regular damage calculation
      when "06C"
        # Super Fang
        # Handled by regular damage calculation
      when "06D", "06F"
        # Night Shade / Seismic Toss, Psywave
        # Handled by regular damage calculation
      when "06E"
        # Endeavor
        # Handled by regular damage calculation
      when "070"
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
      when "071"
        # Counter
        if physical_opponents == 2
          score += 40
        elsif physical_opponents == 1
          score += 20
        end
      when "072"
        # Mirror Coat
        if special_opponents == 2
          score += 40
        elsif special_opponents == 1
          score += 20
        end
      when "073"
        # Metal Burst
        score += 30
      when "074"
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
      when "083"
        # Round
        user.eachAlly do |b|
          b.eachMove do |m|
            if m.function == "083"
              score += 30
              break
            end
          end
        end
      when "084"
        # Payback
        # Double damage score if target will attack first
        if target_speed > speed_stat
          score += damage * 100 / target.totalhp
        end
      when "091", "092"
        # Fury Cutter, Echoed Voice
        # Give some extra score to actually use them
        score += 10
        if user.hasActiveItem?(:METRONOME)
          score += 30
        end
      when "094", "095"
        # Present, Magnitude
        # Random by nature
        score += self.pbRandom(50)
      when "09C"
        # Helping Hand
        score += 20
      when "09D"
        # Mud Sport
        user.eachOpposing do |b|
          b.eachMove do |m|
            score += 10 if m.type == :ELECTRIC && m.baseDamage > 40
          end
        end
        score += 10
      when "09E"
        # Water Sport
        user.eachOpposing do |b|
          b.eachMove do |m|
            score += 10 if m.type == :FIRE && m.baseDamage > 40
          end
        end
        score += 10
      when "0A0"
        # Frost Breath / Storm Throw
        # Avoid attacking Anger Point, unless it's the ally
        if target.hasActiveAbility?(:ANGERPOINT) &&
           target.hp > target.totalhp * 0.6 && target.stages[:ATTACK] < 3
          score -= target.opposes?(user) ? 200 : 120
        end
      when "0A1"
        # Lucky Chant
        if user.pbOwnSide.effects[PBEffects::LuckyChant]<=0
          score += 40
        end
      when "0A2"
        # Reflect
        if user.pbOwnSide.effects[PBEffects::Reflect]<=0
          score += 10
          score += 10 if user.hasActiveItem?(:LIGHTCLAY)
          score += 30 * physical_opponents
        end
      when "0A3"
        # Light Screen
        if user.pbOwnSide.effects[PBEffects::Reflect]<=0
          score += 10
          score += 10 if user.hasActiveItem?(:LIGHTCLAY)
          score += 30 * special_opponents
        end
      when "0A5", "0A9"
        # Sure-hit moves, Chip Away / Saced Sword
        if target.stages[:EVASION]>=2
          score += 10 * (target.stages[:EVASION] - 1)
        end
      when "0A6"
        # Lock-On / Mind Reader
        if target.effects[PBEffects::LockOn]<=0
          if target.stages[:EVASION]>=2
            score += 10 * (target.stages[:EVASION] - 1)
          end
          for m in user.moves
            if m.function == "070"
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
      when "0A7"
        # Foresight / Odor Sleuth
        if target.pbHasType?(:GHOST) && !target.effects[PBEffects::Foresight]
          score += 30
        end
      when "0A8"
        # Miracle Eye
        if target.pbHasType?(:DARK) && !target.effects[PBEffects::MiracleEye]
          score += 30
        end
      when "0AA"
        # Protect / Detect
        if user.effects[PBEffects::ProtectRate]==1
          score += 20
          eachBattler do |b|
            addscore = 0
            addscore += 8  if b.status == :BURN
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
      when "0AB"
        # Quick Guard
        score += 20 if user.effects[PBEffects::ProtectRate]==1
      when "0AC"
        # Wide Guard
        score += 20 if user.effects[PBEffects::ProtectRate]==1
      when "0AD"
        # Feint
        # Prioritize Feint if target has Protect
        for m in target.moves
          if m.function == "0AA"
            score += 30
            break
          end
        end
      when "0AE"
        # Mirror Move - Random because it is unpredictable
        # Could maybe code outside this function to replace move if a move is guaranteed
        score += 10 + self.pbRandom(40)
      when "0AF"
        # Copycat - Random because it is unpredictable
        # Could maybe code outside this function to replace move if a move is guaranteed
        score += 10 + self.pbRandom(40)
      when "0B0"
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
      when "0B1"
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
      when "0B2"
        # Snatch
        # Use if opponents have buffing moves
        user.eachOpposing do |b|
          b.eachMove do |m|
            if m.function <= "039" && m.function >= "01C"
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
      when "0B5"
        # Assist
        score += self.pbRandom(50)
      when "0B6"
        # Metronome
        score += self.pbRandom(70)
      when "0B7"
        # Torment
        if !target.effects[PBEffects::Torment] && target_item != :AEGISTALISMAN
          score += 30
          if target.effects[PBEffects::Encore]>0
            score += 50
          end
        end
      when "0B8"
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
      when "0B9"
        # Disable
        if target.effects[PBEffects::Disable]<=0 && target_item != :AEGISTALISMAN
          score += 30
          if target.effects[PBEffects::Encore]>0
            score += 50
          end
        end
      when "0BA"
        # Taunt
        if target.effects[PBEffects::Taunt]<=0
          for m in target.moves
            if !m.physicalMove? && !m.specialMove?
              score += 25
            end
          end
        end
      when "0BB"
        # Heal Block
        if target.effects[PBEffects::HealBlock]<=0
          for m in target.moves
            if m.healingMove?
              score += 30
            end
          end
        end
      when "0BC"
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
      when "0C1"
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
      when "0C3"
        # Razor Wind
        if self.pbWeather != :Winds &&
           !user.hasActiveItem?(:POWERHERB) &&
           !user.hasActiveAbility?(:TIMESKIP)
          # Cut damage score in half as the attack takes two turns
          score -= damage * 50 / target.totalhp
        end
      when "0C4"
        # Solar Beam
        if self.pbWeather != :Sun &&
           !user.hasActiveItem?(:POWERHERB) &&
           !user.hasActiveAbility?(:TIMESKIP)
          # Cut damage score in half as the attack takes two turns
          score -= damage * 50 / target.totalhp
        end
      when "0C5", "0C6", "0C7", "0C8"
        # Freeze Shock, Ice Burn, Sky Attack, Skull Bash
        if !user.hasActiveItem?(:POWERHERB) &&
           !user.hasActiveAbility?(:TIMESKIP)
          # Cut damage score in half as the attack takes two turns
          score -= damage * 50 / target.totalhp
        end
      when "0CF", "0D0"
        # Trapping Moves (Fire Spin, etc.)
        score += 20
        # If ally has Perish Song, assume Perish Trap strategy
        user.eachAllyMove do |m|
          if m.function == "0E5"
            score += 50
            break
          end
        end
        score += 10 if target && target.effects[PBEffects::Toxic]>0
        score += 20 if target && target.effects[PBEffects::Curse]
        score += 30 if target && target.effects[PBEffects::PerishSong]>0
      when "0D1"
        # Uproar
        # Try not to wake opponents
        user.eachOpposing do |b|
          score -= 20 if b.status == :SLEEP && b.statusCount>1
        end
        # Try to wake partner
        user.eachAlly do |b|
          score += 20 if b.status == :SLEEP && b.statusCount>1
        end
      when "0D2"
        # Outrage / Petal Dance / Thrash
        if user.hasActiveItem?(:PERSIMBERRY) || user.hasActiveItem?(:LUMBERRY)
          score += 10
        end
      when "0D3"
        # Rollout / Ice Ball
        if user.hasActiveItem?(:METRONOME)
          score += 20
        end
        if user.effects[PBEffects::DefenseCurl]
          score += 30
        end
      when "0D4"
        # Bide
        score += 20
      when "0D5"
        # Recover / Slack Off / etc.
        if user.hp < user.totalhp * 0.75
          score += [50, 100 - [user.hp * 100 / user.totalhp, 100].min].min
        end
      when "0D6"
        # Roost
        if user.hp < user.totalhp * 0.75
          score += [50, 100 - [user.hp * 100 / user.totalhp, 100].min].min
        end
      when "0D7"
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
      when "0D8"
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
      when "0D9"
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
               user.status == :PARALYSIS
              score += 30
            end
          elsif user.status == :POISON ||
                user.status == :BURN ||
                user.status == :PARALYSIS
            score += 30 if user.hp < user.totalhp * 0.75
          end
        end
      when "0DA"
        # Aqua Ring
        if !user.effects[PBEffects::AquaRing]
          score += 40
        end
      when "0DB"
        # Ingrain
        if !user.effects[PBEffects::Ingrain]
          score += 35
        end
      when "0DC"
        # Leech Seed
        if target.effects[PBEffects::LeechSeed]<0
          score += 30
          # Extra points if the target has a large HP Pool
          score += target.totalhp * 20 / user.totalhp
        end
      when "0DC"
        # 50% Drain Moves
        # Grant score based on how much HP will be healed
        if target.opposes?(user)
          amt = [damage * 50 / user.totalhp, 100 - [user.hp * 100 / user.totalhp, 100].min].min
          score += target.hasActiveAbility?(:LIQUIDOOZE) ? -amt : amt
        end
      when "0DE"
        # Dream Eater
        # Will not wake up this turn, or user outspeeds
        if target.status == :SLEEP && (target.statusCount > 1 || speed_stat > target_speed)
          # Grant score based on how much HP will be healed
          score += [damage * 50 / user.totalhp, 100 - [user.hp * 100 / user.totalhp, 100].min].min
        end
      when "0DF"
        # Heal Pulse
        # Do not use against opponents
        if target.opposes?(user)
          score -= 30
        end
        if target.hp < target.totalhp * 0.75
          score -= [50, 100 - [target.hp * 100 / target.totalhp, 100].min].min
        end
      when "0E0"
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
      when "0E1"
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
      when "0E2"
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
      when "0E3", "0E4"
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
      when "0E5"
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
      when "0E6"
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
      when "0E7"
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
      when "0E8"
        # Endure
        if user.effects[PBEffects::ProtectRate]==1
          if !(pbWeather == :Sandstorm && user.takesSandstormDamage?) &&
             !(pbWeather == :Hail && user.takeHailDamage?) &&
             user.status != :POISON && user.status != :BURN
            score += 15
            user.eachOpposing do |b|
              score += 15 if b.status == :POISON
              score += 25 if b.effects[PBEffects::Curse]
              score += 35 if b.effects[PBEffects::PerishSong]>0
            end
          end
        end
      when "0EB", "0EC"
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
      when "0ED"
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
      when "0EE"
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
      when "0EF"
        # Block / Mean Look / Spider Web
        if target.effects[PBEffects::MeanLook] < 0 && !target.pbHasType?(:GHOST)
          score += 30
          score += 10 if target.status == :POISON
          score += 20 if target.effects[PBEffects::Curse]
          score += 30 if target.effects[PBEffects::PerishSong]>0
        end
      when "0F0"
        # Knock Off
        if !target.hasActiveAbility?(:STICKYHOLD) &&
           !target.hasActiveAbility?(:SUCTIONCUPS)
          if target.item
            score += 25
          end
        end
      when "0F1"
        # Covet / Thief
        if !target.hasActiveAbility?(:STICKYHOLD) &&
           !target.hasActiveAbility?(:SUCTIONCUPS)
          if target.item && user.item == 0
            score += 25
          end
        end
      when "0F2"
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
      when "0F3"
        # Bestow
        if !target.opposes?(user) && !target.item && user.item
          score -= 50
        end
      when "0F4"
        # Bug Bite / Pluck
        if target.item && GameData::Item.get(target.item).is_berry?
          score += 40
        end
      when "0F5"
        # Incinerate
        if target.item && GameData::Item.get(target.item).is_berry?
          score += 30
        end
      when "0F6"
        # Recycle
        if user.item && user.recycleItem
          score += 30
        end
      when "0F7"
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
      when "0F8"
        # Embargo
        if target.effects[PBEffects::Embargo] <= 0
          score += 35
        end
      when "0F9"
        # Magic Room
        if @field.effects[PBEffects::MagicRoom] <= 0
          score += 30
        end
      when "0FA"
        # 25% Recoil
        if !user.hasActiveAbility?(:MAGICGUARD) &&
           !user.hasActiveAbility?(:ROCKHEAD)
          score -= damage * 25 / user.totalhp
          score -= 20 if damage * 0.25 > user.hp
        end
      when "0FB", "0FD", "0FE"
        # 33% Recoil
        if !user.hasActiveAbility?(:MAGICGUARD) &&
           !user.hasActiveAbility?(:ROCKHEAD)
          score -= damage * 33 / user.totalhp
          score -= 20 if damage * 0.33 > user.hp
        end
      when "0FC"
        # 50% Recoil
        if !user.hasActiveAbility?(:MAGICGUARD) &&
           !user.hasActiveAbility?(:ROCKHEAD)
          score -= damage * 50 / user.totalhp
          score -= 20 if damage * 0.5 > user.hp
        end
      when "0FF"
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
      when "100"
        # Rain Dance
        if self.pbWeather != :Rain
          score += 40
          # Extra points if removing other weather
          if self.pbWeather != :None
            score += 10
          end
        end
      when "101"
        # Sandstorm
        if self.pbWeather != :Sandstorm
          score += 40
          # Extra points if removing other weather
          if self.pbWeather != :None
            score += 10
          end
        end
      when "102"
        # Hail
        if self.pbWeather != :Hail
          score += 40
          # Extra points if removing other weather
          if self.pbWeather != :None
            score += 10
          end
        end
      when "103"
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
      when "104"
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
      when "105"
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
                types = [p.type1]
                types.push(p.type2) if p.type2 && p.type2 != p.type1
                for t in types
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
      when "106"
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
      when "107"
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
      when "108"
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
      when "10A"
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
      when "10B"
        # (High) Jump Kick
        if !target.opposes?(user)
          if target.pbHasType?(:GHOST) && !target.effects[PBEffects::Foresight]
            score -= 50
          end
        end
      when "10C"
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
      when "10D"
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
      when "10E"
        # Spite
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
      when "10F"
        # Nightmare
        if target.status == :SLEEP && target.statusCount > 1 && target_item != :AEGISTALISMAN
          score += 20
          score += 20 if target.statusCount > 2
        end
      when "110"
        # Rapid Spin
        score += 10 * user.pbOwnSide.effects[PBEffects::Spikes]
        score += 15 * user.pbOwnSide.effects[PBEffects::ToxicSpikes]
        score += 20 if user.pbOwnSide.effects[PBEffects::StealthRock]
      when "111"
        # Doom Desire / Future Sight
        if target.opposes?(user)
          if !user.hasActiveAbility?(:TIMESKIP) &&
              !user.hasActiveItem?(:ODDSTONE) &&
              !user.hasActiveItem?(:TIMESTONE)
            score -= 20
          end
        end
      when "112"
        # Stockpile
        if user.effects[PBEffects::Stockpile] < 3
          score += 30
        end
      when "113"
        # Spit Up
        if target.opposes?(user) && user.effects[PBEffects::Stockpile] > 0
          # Negative score to indicate lost stat stages
          score -=  user.effects[PBEffects::Stockpile] * 15
          # Damage is handled elsewhere
        end
      when "114"
        # Swallow
        if user.effects[PBEffects::Stockpile] > 0
          # Negative score to indicate lost stat stages
          score -=  user.effects[PBEffects::Stockpile] * 15
          amt = 25
          amt = 50 if user.effects[PBEffects::Stockpile] == 2
          amt = 100 if user.effects[PBEffects::Stockpile] == 3
          score += [amt, 100 - [user.hp * 100 / user.totalhp,100].min].min
        end
      when "115"
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
      when "116"
        # Sucker Punch
        # May or may not use Sucker Punch consecutively
        if target.opposes?(user)
          if user.lastMoveUsed == :SUCKERPUNCH
            score -= 30 + self.pbRandom(50)
          end
        end
      when "117"
        # Follow Me / Rage Powder
        score += 35
      when "118"
        # Gravity
        if @field.effects[PBEffects::Gravity] <= 0
          airborne = 0
          user.eachOpposing do |b|
            airborne += 1 if b.airborne?
          end
          score += 30 if airborne > 0
          score += 20 * airborne
        end
      when "119"
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
      when "11A"
        # Telekinesis
        if target.effects[PBEffects::Telekinesis] <= 0
          score += 30
        end
      when "11C"
        # Smack Down
        if !target.effects[PBEffects::SmackDown]
          if target.airborne?
            score += 30
          end
        end
      when "11F"
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
      when "120"
        # Ally Switch
        score += 10 + self.pbRandom(40)
      when "124"
        # Wonder Room
        if @field.effects[PBEffects::WonderRoom] <= 0
          score += 40
        end
      when "125"
        # Last Resort
        # Should hopefully be handled by pbMoveFailed
      when "137"
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
      when "138"
        # Aromatic Mist
        if !target.opposes?(user) && target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,move,false,true)
          score += 5
          score += 10 * special_opponents
        end
      when "13E"
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
      when "13F"
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
      when "141"
        # Topsy-Turvy
        total = 0
        GameData::Stat.each_main do |s|
          total += target.stages[s] || 0
        end
        score += total * 10
      when "142"
        # Trick-or-Treat
        if !target.pbHasType?(:GHOST) && target_item != :AEGISTALISMAN
          score += 30
        end
      when "143"
        # Forest's Curse
        if !target.pbHasType?(:GRASS) && target_item != :AEGISTALISMAN
          score += 35
        end
      when "145"
        # Electrify
        score += 30
      when "146"
        # Ion Deluge / Plasma Fists
        score += 5
        for m in target.moves
          if m.type == :NORMAL
            score += 10
          end
        end
      when "148"
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
      when "149"
        # Mat Block
        score += 20 if user.effects[PBEffects::ProtectRate]==1
      when "14A"
        # Crafty Shield
        score += 20 if user.effects[PBEffects::ProtectRate]==1
      when "14B"
        # King's Shield
        if user.effects[PBEffects::ProtectRate]==1
          score += 25
          score += 10 * physical_opponents
          score += 30 if user.form == 1
        end
      when "14C"
        # Spiky Shield
        if user.effects[PBEffects::ProtectRate]==1
          score += 25
          score += 10 * physical_opponents
        end
      when "14E"
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
      when "14F"
        # 75% Drain
        # Grant score based on how much HP will be healed
        if target.opposes?(user)
          amt = [damage * 75 / user.totalhp, 100 - [user.hp * 100 / user.totalhp, 100].min].min
          score += target.hasActiveAbility?(:LIQUIDOOZE) ? -amt : amt
        end
      when "150"
        # Fell Stinger
        if damage > target.hp
          score += 70
        end
      when "151"
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
      when "152"
        # Fairy Lock
        score += 10 + self.pbRandom(30)
      when "153"
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
      when "154"
        # Electric Terrain
        if @field.terrain != :Electric
          score += 40
          score += 20 if user.hasActiveItem?(:TERRAINEXTENDER)
        end
      when "155"
        # Grassy Terrain
        if @field.terrain != :Grassy
          score += 40
          score += 20 if user.hasActiveItem?(:TERRAINEXTENDER)
          eachSameSideBattler(user.index) do |b|
            score += 30 if b.hasActiveAbility?(:GRASSPELT)
          end
        end
      when "156"
        # Misty Terrain
        if @field.terrain != :Misty
          score += 40
          score += 20 if user.hasActiveItem?(:TERRAINEXTENDER)
        end
      when "158"
        # Belch - Unhandled
      when "159"
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
      when "15A"
        # Sparkling Aria
        if target.status == :BURN
          score -= 20
        end
      when "15B"
        # Purify
        if target.status != :NONE
          score -= 10
          score += [50, 100 - [user.hp * 100 / user.totalhp, 100].min].min
        end
      when "15C"
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
      when "15D"
        # Spectral Thief
        # Better the more buffs the target has
        oppstat = 0
        GameData::Stat.each_main do |s|
          oppstat += target.stages[s] || 0
        end
        score = oppstat * 10
      when "15E"
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
      when "15F"
        # Clanging Scales - Unhandled
      when "160"
        # Strength Sap
        if target.pbCanLowerStatStage?(:ATTACK,user,move,false,true)
          if !target.hasActiveAbility?(:CONTRARY)
            score += 15 if target_has_physical
            amt = target.attack * 100 / user.totalhp
            score += [amt, 100 - [target.hp * 100 / target.totalhp, 100].min].min
          end
        end
      when "161"
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
      when "162"
        # Burn Up - No Special Handling
      when "163"
        # Moongeist Beam / Sunsteel Strike - No Special Handling
      when "164"
        # Photon Geyser - No Special Handling
      when "165"
        # Core Enforcer - No Special Handling
      when "166"
        # Stomping Tantrum - No Special Handling
      when "167"
        # Aurora Veil
        if pbWeather == :Hail
          if user.pbOwnSide.effects[PBEffects::AuroraVeil]<=0
            score += 80
            score += 30 if user.hasActiveItem?(:LIGHTCLAY)
          end
        end
      when "168"
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
      when "169"
        # Revelation Dance - No Special Handling
      when "16A"
        # Spotlight - Unhandled
        score += 10
      when "16B"
        # Instruct
        if !target.opposes?(user)
          score -= 40
        else
          # Do not use on opponents
          score -= 50
        end
      when "16C"
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
      when "16D"
        # Shore Up
        if user.hp < user.totalhp * 0.75
          amt = 50
          if self.pbWeather==:Sandstorm
            amt = 200.0 / 3.0
          end
          score += [amt, 100 - [user.hp * 100 / user.totalhp, 100].min].min
        end
      when "16E"
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
      when "16F"
        # Pollen Puff
        if !target.opposes?(user)
          # Nullify score lost from damaging partner
          score -= damage * 100 / target.totalhp
          if target.hp < target.totalhp * 0.75
            score -= [50, 100 - [target.hp * 100 / target.totalhp, 100].min].min
          end
        end
      when "170"
        # Mind Blown / Steel Beam
        score -= 40
      when "171"
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
      when "172"
        # Beak Blast
        if target.pbCanBurn?(user,false,nil)
          score += 5 * physical_opponents
        end
      when "173"
        # Psychic Terrain
        if @field.terrain != :Psychic
          score += 40
          score += 20 if user.hasActiveItem?(:TERRAINEXTENDER)
        end
      when "174"
        # First Impression - No Special Handling
      when "300"
        # Corrosive Acid
        if !target.effects[PBEffects::CorrosiveAcid]
          if target.pbHasType?(:STEEL) || target.pbHasType?(:POISON)
            score += 30
          end
        end
      when "301"
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