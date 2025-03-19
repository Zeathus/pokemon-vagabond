class Battle

  def pbStartPredictingDamage
    @predictingDamage = true
    eachBattler do |b|
      b.turnCount += 1
    end
  end

  def pbEndPredictingDamage
    @predictingDamage = false
    eachBattler do |b|
      b.turnCount -= 1
    end
  end

  def pbChooseMovesNew(idxBattlers)
    pbStartPredictingDamage

    single = idxBattlers.length == 1
    double = idxBattlers.length == 2
    triple = idxBattlers.length == 3

    # The highest damage a Pokemon can do this turn, used for switching
    dmg_potential = [0, 0, 0, 0, 0, 0]
    # The most damage a Pokemon can take this turn, used for switching
    hurt_potential = [0, 0, 0, 0, 0, 0]

    scores = [] # Scores for all move combinations
    targets = [] # Optimal targets for all move combinations
    for a in 0...4
      if double || triple
        x1 = []
        x2 = []
        for b in 0...4
          if triple
            y1 = []
            y2 = []
            for c in 0...4
              y1.push(0)
              y2.push([-1,-1,-1])
            end
            x1.push(y1)
            x2.push(y2)
          else
            x1.push(0)
            x2.push([-1,-1])
          end
        end
        scores.push(x1)
        targets.push(x2)
      else
        scores.push(0)
        targets.push([-1])
      end
    end

    # Whether a pokemon is actionable at the start of turn
    actionableStart=[false,false,false,false,false,false]
    faintedStart=[true,true,true,true,true,true]
    eachBattler do |b|
      actionableStart[b.index] = true
      faintedStart[b.index] = false
    end

    if !trainerBattle? && !@smartWildBattle
      # If wild battle
      # Random moves
      opposing_pokemon = allOtherSideBattlers(idxBattlers[0])
      eachMoveIndexCombo(idxBattlers) do |i0,i1,i2|
        next if !pbCanChooseMove?(idxBattlers[0],i0,false)
        next if i1 && !pbCanChooseMove?(idxBattlers[1],i1,false)
        next if i2 && !pbCanChooseMove?(idxBattlers[2],i2,false)
        possible_targets0 = pbPossibleTargets(@battlers[idxBattlers[0]], @battlers[idxBattlers[0]].moves[i0])
        possible_targets1 = pbPossibleTargets(@battlers[idxBattlers[1]], @battlers[idxBattlers[1]].moves[i1]) if i1
        possible_targets2 = pbPossibleTargets(@battlers[idxBattlers[2]], @battlers[idxBattlers[2]].moves[i2]) if i2
        next if possible_targets0.length == 0
        next if i1 && possible_targets1.length == 0
        next if i2 && possible_targets2.length == 0
        scores[i0] = rand(100) if single
        scores[i0][i1] = rand(100) if double
        scores[i0][i1][i2] = rand(100) if triple
        targets[i0][0] = possible_targets0.shuffle[0][0].index if single
        targets[i0][i1][0] = possible_targets1.shuffle[0][0].index if double
        targets[i0][i1][i2][0] = possible_targets2.shuffle[0][0].index if triple
        targets[i0][0] = 0 if single && targets[i0][0].nil?
        targets[i0][i1][0] = 0 if double && targets[i0][i1][0].nil?
        targets[i0][i1][i2][0] = 0 if triple && targets[i0][i1][i2][0].nil?
      end
    else

      ### Predict the turn order
      # Find all participants
      participants=[]
      eachBattler do |b|
        participants.push(b.index)
      end

      # Determine queue
      base_queue=[]
      while participants.length > 0
        max_index = -1
        max_speed = -1
        for i in participants
          speed = @battlers[i].pbSpeed
          if speed > max_speed
            max_index = i
            max_speed = speed
          end
        end
        base_queue.push(max_index)
        participants.delete(max_index)
      end

      eachMoveIndexCombo(idxBattlers) do |i0,i1,i2|
        b0 = @battlers[idxBattlers[0]]
        b1 = i1 ? @battlers[idxBattlers[1]] : nil
        b2 = i2 ? @battlers[idxBattlers[2]] : nil
        m0 = b0.moves[i0]
        m1 = i1 ? b1.moves[i1] : nil
        m2 = i2 ? b2.moves[i2] : nil

        # Priority for each move
        pri0 = pbRoughPriority(b0, m0)
        pri1 = i1 ? pbRoughPriority(b1, m1) : nil
        pri2 = i2 ? pbRoughPriority(b2, m2) : nil

        dmg_potential = [0, 0, 0, 0, 0, 0]
        hurt_potential = [0, 0, 0, 0, 0, 0]

        queue = []
        base_queue.each { |q| queue.push(q) }

        # Update queue with positive priority backwards to ensure speed is accounted for
        for p in 1..7
          i = queue.length - 1
          min_i = 0
          while i >= min_i
            q = queue[i]
            if (p == pri0 && idxBattlers[0] == q) ||
                (p == pri1 && idxBattlers[1] == q) ||
                (p == pri2 && idxBattlers[2] == q)
              queue.delete(q)
              queue.unshift(q)
              i += 1
              min_i += 1
            end
            i -= 1
          end
        end

        # Update queue with negative priority backwards to ensure speed is accounted for
        for p1 in 1..7
          i = queue.length - 1
          min_i = 0
          while i >= min_i
            j = queue.length - i
            q = queue[j]
            if (p == pri0 && idxBattlers[0] == q) ||
                (p == pri1 && idxBattlers[1] == q) ||
                (p == pri2 && idxBattlers[2] == q)
              queue.delete(q)
              queue.push(q)
              i += 1
              min_i += 1
            end
            i -= 1
          end
        end

        # Create temporary actionable and fainted array for this simulation
        actionable = []
        actionableStart.each { |a| actionable.push(a) }
        fainted = []
        faintedStart.each { |f| fainted.push(f) }

        # If the first opposing pokemon has affinity boosted any partners
        affinityboost = [false, false, false, false, false, false] # Keep

        # Simulate each battler using their moves in the correct order
        queue_pos = -1
        while queue_pos < queue.length
          queue_pos += 1
          break if queue_pos >= queue.length
          q = queue[queue_pos]
          user = @battlers[q]

          if user.opposes?(b0)

            next if !actionable[q] || fainted[q] # Skip battler in cases such as flinching

            # Player pokemon, predict damage
            # Add known moves and STAB moves to checklist
            moves = []
            user.eachMoveWithIndex do |m,i|
              if (user.pbIsMoveRevealed?(m.id) ||
                  user.pbHasType?(m.type)) &&
                  pbCanChooseMove?(q, i, false)
                moves.push(m)
              end
            end

            # TODO
            # - Add fixed_target variable for stuff like Follow Me
            #   * (needs to assume the best move on any target is used on a specific target)

            # Stop predicting if no moves are known
            if moves.length > 0
              # List of allies that can be affinity boosted by any move (even if that move is not best_move)
              to_affinityboost = []

              best_move = nil
              best_damage = -1
              best_target_group = []
              best_kills = []
              fixed_move = nil

              if (user.hasActiveItem?(:CHOICEBAND) || user.hasActiveItem?(:CHOICESPECS) ||
                  user.hasActiveItem?(:CHOICESCARF)) && user.effects[PBEffects::ChoiceBand]
                fixed_move = user.effects[PBEffects::ChoiceBand]
              elsif user.effects[PBEffects::Encore] > 0
                fixed_move = user.effects[PBEffects::EncoreMove]
              end

              if fixed_move
                # Find damage when move is fixed
                for m in moves
                  if m.id == fixed_move
                    best_move = m
                    possible_target_groups = pbPossibleTargets(user, m)
                    for group in possible_target_groups
                      total_damage = 0
                      kills = []
                      for t in group
                        if t.opposes?(user)
                          damage = m.pbPredictDamage(user, t, group.length, queue, false) || 0
                          hurt = [damage, t.hp].min * 100 / t.totalhp
                          if hurt > hurt_potential[t.index]
                            hurt_potential[t.index] = hurt
                          end
                          total_damage += hurt
                          kills.push(t) if damage >= t.hp
                        end
                      end
                      if total_damage > best_damage
                        best_damage = total_damage
                        best_target_group = group
                        best_kills = kills
                      end
                    end
                  end
                end
              else
                # Find optimal damaging play for player
                for m in moves
                  possible_target_groups = pbPossibleTargets(user, m)
                  next if possible_target_groups.length <= 0

                  for group in possible_target_groups
                    total_damage = 0
                    kills = []
                    for t in group
                      next if !t.opposes?(user)
                      damage = m.pbPredictDamage(user, t, group.length, queue, affinityboost[user.index]) || 0
                      hurt = [damage, t.hp].min * 100 / t.totalhp
                      if hurt > hurt_potential[t.index]
                        hurt_potential[t.index] = hurt
                      end
                      kills.push(t) if damage >= t.hp && t.opposes?(user)
                      total_damage += hurt
                      # Check for affinity boosts
                      if damage > 0
                        user.eachAlly do |ally|
                          next if to_affinityboost.include?(ally.index)
                          next if !ally.pokemon.hasAffinity?(m.type)
                          bTypes = t.pbTypes(true)
                          typeMod = Effectiveness.calculate(m.type, *bTypes)
                          if Effectiveness.normal?(typeMod) || Effectiveness.super_effective?(typeMod)
                            to_affinityboost.push(ally.index)
                          end
                        end
                      end
                    end
                    if total_damage > best_damage
                      best_move = m
                      best_damage = total_damage
                      best_target_group = group
                      best_kills = kills
                    end
                  end
                end
              end

              score_mod = 0
              if best_move
                best_kills.each do |b|
                  # The pokemon will faint, subtract a high score
                  # Inactionable on own pokemon only halves scores
                  score_mod -= [b.hp * 100 / b.totalhp,50].max
                  actionable[b.index] = false
                end
                best_target_group.each do |b|
                  if !best_kills.include?(b)
                    score_mod -= best_damage
                  end
                end
              end

              # Move affinity boosted pokemon up in the queue
              for ally in to_affinityboost
                next_pos = queue_pos + 1
                ally_pos = -1
                # Start at next_pos + 1, as there is no need to move if it is already next
                for pos in (next_pos+1)...queue.length
                  if queue[pos] == ally
                    ally_pos = pos
                    break
                  end
                end
                next if ally_pos < 0
                affinityboost[ally] = true
                # Remove ally and reinsert at new position
                queue.delete(ally)
                queue.insert(next_pos, ally)
              end

              scores[i0] += score_mod if single
              scores[i0][i1] += score_mod if double
              scores[i0][i1][i2] += score_mod if triple
            end
          else
            ## Opposing pokemon, test move results

            user_index = nil
            for i in 0...idxBattlers.length
              if q == idxBattlers[i]
                user_index = i
                break
              end
            end

            next if !user_index
            move_index = [i0, i1, i2][i]
            next if !move_index
            move = user.moves[move_index]

            target = 0
            damage = 0

            # TODO
            # - Account for multi-hit moves

            possible_target_groups = pbPossibleTargets(user, move)

            next if possible_target_groups.length <= 0

            high_score = -99999
            high_target_group = 0
            high_damage = [0,0,0,0,0,0]
            high_eff_score = 0

            for g in 0...possible_target_groups.length
              group = possible_target_groups[g]
              score = 0
              kills = 0
              all_damage = [0,0,0,0,0,0]
              for target in group
                next if fainted[target.index]
                this_score = 0
                # group is an array of targets (for multi target moves like Earthquake)
                # target is each target in said group
                damage = 0
                if !move.pbMoveFailed?(user, group) && (target == user || !move.pbFailsAgainstTarget?(user, target, false))
                  if target != user && !move.statusMove?
                    damage = move.pbPredictDamage(user, target, group.length, queue, affinityboost[user.index])
                    damage = 0 if !damage
                  end
                  eff_score = pbGetEffectScore(move, damage, user, target, actionable, fainted)
                  this_score += [damage * 100 / target.totalhp, target.hp * 100 / target.totalhp - hurt_potential[target.index]].min
                  if damage > (target.hp - hurt_potential[target.index] * target.totalhp / 100) && target != user
                    if target.opposes?(user)
                      kills += 1
                    else
                      kills -= 1
                    end
                  end
                  this_score = 0 if this_score < 0
                  this_score += eff_score
                end
                all_damage[target.index] += damage
                if !target.opposes?(user) && target != user
                  this_score = -this_score
                end
                score += this_score
              end
              if group.length == 1 && !group[0].opposes?(user) && group[0] != user
                # Ally target with negative score, never choose this
                if score <= 0
                  high_target_group += 1 if high_target_group == g && possible_target_groups.length > g + 1
                  next
                end
              end
              if score + kills * 80 > high_score
                high_target_group = g
                high_score = score + kills * 80
                high_damage = all_damage
              end
            end

            damage = high_damage
            target_group = possible_target_groups[high_target_group]

            if high_score > dmg_potential[user.index]
              dmg_potential[user.index] = high_score
            end

            # Run effect score again, but with chosen=true to update actionable and fainted values
            for t in target_group
              if !move.pbMoveFailed?(user, group) && (t == user || !move.pbFailsAgainstTarget?(user, t, false))
                pbGetEffectScore(move, damage[t.index], user, t, actionable, fainted, true)
              end
            end

            for t in target_group
              next if fainted[t.index]
              if (high_damage[t.index] > (t.hp - hurt_potential[t.index] * target.totalhp / 100))
                high_score += t.opposes?(user) ? 80 : -80
                actionable[t.index] = false
                fainted[t.index] = true
              end
              hurt_potential[t.index] = damage[t.index] * 100 / t.totalhp
            end
            
            #echoln _INTL("> {1} use {2} on {3}, score: {4}, actionable: {5}", user.name, move.name, target_group[0].name, high_score, actionable[user.index])

            high_score /= 2 if !actionable[user.index]

            scores[i0] += high_score if single
            scores[i0][i1] += high_score if double
            scores[i0][i1][i2] += high_score if triple

            to_affinityboost = []

            if move.physicalMove? || move.specialMove?
              for t in target_group
                if t.opposes?(user)
                  type_mod = move.pbCalcTypeMod(move.type, user, t)
                  if Effectiveness.normal?(type_mod) || Effectiveness.super_effective?(type_mod)
                    user.eachAlly do |ally|
                      if ally.pokemon.hasAffinity?(move.type)
                        to_affinityboost.push(ally.index)
                      end
                    end
                  end
                end
              end
            end

            # Move affinity boosted pokemon up in the queue
            for ally in to_affinityboost
              next_pos = queue_pos + 1
              ally_pos = -1
              # Start at next_pos + 1, as there is no need to move if it is already next
              for pos in (next_pos+1)...queue.length
                if queue[pos] == ally
                  ally_pos = pos
                  break
                end
              end
              next if ally_pos < 0
              affinityboost[ally] = true
              # Remove ally and reinsert at new position
              queue.delete(ally)
              queue.insert(next_pos, ally)
            end

            # Update target matrix
            targets[i0][user_index] = target_group[0].index if single
            targets[i0][i1][user_index] = target_group[0].index if double
            targets[i0][i1][i2][user_index] = target_group[0].index if triple

          end
        end
      end
    end

    # Find the optimal move combination
    max_score = -999999
    max_index = [0, 0, 0]
    max_target = [-1, -1, -1]
    eachMoveIndexCombo(idxBattlers) do |i0,i1,i2|
      next if !pbCanChooseMove?(idxBattlers[0], i0, false)
      next if i1 && !pbCanChooseMove?(idxBattlers[1], i1, false)
      next if i2 && !pbCanChooseMove?(idxBattlers[2], i2, false)
      if single
        next if targets[i0][0] < 0
        if scores[i0] > max_score
          max_score = scores[i0]
          max_index = [i0]
          max_target = targets[i0]
        end
      elsif double
        next if targets[i0][i1][0] < 0 || targets[i0][i1][1] < 0
        if scores[i0][i1] > max_score
          max_score = scores[i0][i1]
          max_index = [i0, i1]
          max_target = targets[i0][i1]
        end
      elsif triple
        next if targets[i0][i1][i2][0] < 0 || targets[i0][i1][i2][1] < 0 || targets[i0][i1][i2][2] < 0
        if scores[i0][i1][i2] > max_score
          max_score = scores[i0][i1][i2]
          max_index = [i0, i1, i2]
          max_target = targets[i0][i1][i2]
        end
      end
    end

    pbShowScores(scores, idxBattlers) if $DEBUG && Input.press?(Input::CTRL)

    will_switch = [false, false, false, false, false, false]

    actionable = actionableStart
    fainted = faintedStart
    prev_switch = -1

    # Check if switching is optimal
    for i in idxBattlers
      battler = @battlers[i]
      if trainerBattle? && battler.turnCount
        useless_switch = false
        hurtful_switch = 0
        ability_switch = false
        healing_switch = 0
        effect_switch = -1
        # Switch if about to die to Perish Song
        if battler.effects[PBEffects::PerishSong] == 1
          hurtful_switch = 125
        end
        # Stay in for at least one turn
        if battler.turnCount > 1
          # Can't choose any moves
          if !pbCanChooseMove?(i,0,false) &&
              !pbCanChooseMove?(i,1,false) &&
              !pbCanChooseMove?(i,2,false) &&
              !pbCanChooseMove?(i,3,false)
            #switchscore += [30 * battler.turnCount, 100].min
            useless_switch = true
          end
          # Consider switching if the Pokemon has low damage potential
          if dmg_potential[i] <= 12.5
            # I think dmg_potential should factor in effect scores already
            useless_switch = true
            next
            """
            # Determine whether or not the Pokemon performs good as support
            max_score = 0
            scores = [0]
            for m in battler.moves
              # Buffing yourself if you can't deal damage is (mostly) useless
              if m.target != PBTargets::User && (move.addlEffect == 0 || move.addlEffect >= 50)
                next if !pbCanChooseMove?(i,battler.moves.index(m),false)
                case m.target
                when PBTargets::SingleNonUser
                  scores.push(pbGetEffectScore(m,0,battler,@battlers[(i + 1) % 4],actionable,fainted))
                  scores.push(pbGetEffectScore(m,0,battler,@battlers[(i + 3) % 4],actionable,fainted))
                  scores.push(-pbGetEffectScore(m,0,battler,battler.pbPartner,actionable,fainted))
                when PBTargets::SingleOpposing
                  scores.push(pbGetEffectScore(m,0,battler,@battlers[(i + 1) % 4],actionable,fainted))
                  scores.push(pbGetEffectScore(m,0,battler,@battlers[(i + 3) % 4],actionable,fainted))
                when PBTargets::NoTarget, PBTargets::UserSide, PBTargets::BothSides, PBTargets::OpposingSide
                  scores.push(pbGetEffectScore(m,0,battler,nil,actionable,fainted))
                when PBTargets::AllOpposing
                  scores.push(pbGetEffectScore(m,0,battler,@battlers[(i + 1) % 4],actionable,fainted) +
                                          pbGetEffectScore(m,0,battler,@battlers[(i + 3) % 4],actionable,fainted))
                when PBTargets::AllNonUser
                  scores.push(pbGetEffectScore(m,0,battler,@battlers[(i + 1) % 4],actionable,fainted) +
                                          pbGetEffectScore(m,0,battler,@battlers[(i + 3) % 4],actionable,fainted) -
                                          pbGetEffectScore(m,0,battler,@battlers[(i + 3) % 4],actionable,fainted))
                when PBTargets::Partner, PBTargets::UserOrPartner
                  scores.push(-pbGetEffectScore(m,0,battler,battler.pbPartner,actionable,fainted))
                end
              end
            end
            highscore = scores.max
              # The Pokemon does not do good support, should be switched
            if highscore < 20
              useless_switch = true
            end
            """
          end
          # Determine whether the Pokemon can take an unhealthy amount of damage or not
          if hurt_potential[i] >= 80 && hurt_potential[i] > dmg_potential[i]
            hurtful_switch = [hurt_potential[i], 100].min
            hurtful_switch = 30 if battler.hp >= battler.totalhp && (battler.hasActiveItem?(:FOCUSSASH) || battler.hasActiveAbility?(:STURDY))
          end
          # Try to preserve abilities activated on switch-in
          if battler.hasActiveAbility?(:DROUGHT) || battler.hasActiveAbility?(:DRIZZLE) ||
              battler.hasActiveAbility?(:SNOWWARNING) || battler.hasActiveAbility?(:SANDSTREAM) ||
              battler.hasActiveAbility?(:ZEPHYR) || battler.hasActiveAbility?(:GRASSYSURGE) ||
              battler.hasActiveAbility?(:ELECTRICSURGE) || battler.hasActiveAbility?(:PSYCHICSURGE) ||
              battler.hasActiveAbility?(:MISTYSURGE) || battler.hasActiveAbility?(:INTIMIDATE)
            ability_switch = true
          end
          # Try to make use of abilities activated on switch-in
          party = pbParty(battler.index)
          for p in 0...party.length
            if pbCanSwitch?(i, p, nil)
              pkmn = party[p]
              if (pkmn.hasAbility?(:DROUGHT) && pbWeather != :Sun) ||
                  (pkmn.hasAbility?(:DRIZZLE) && pbWeather != :Rain) ||
                  (pkmn.hasAbility?(:SNOWWARNING) && pbWeather != :Hail) ||
                  (pkmn.hasAbility?(:SANDSTREAM) && pbWeather != :Sandstorm) ||
                  (pkmn.hasAbility?(:ZEPHYR) && pbWeather != :Winds) ||
                  (pkmn.hasAbility?(:GRASSYSURGE) && @field.terrain != :Grassy) ||
                  (pkmn.hasAbility?(:ELECTRICSURGE) && @field.terrain != :Electric) ||
                  (pkmn.hasAbility?(:PSYCHICSURGE) && @field.terrain != :Psychic) ||
                  (pkmn.hasAbility?(:MISTYSURGE) && @field.terrain != :Misty)
                effect_switch = p
              end
            end
          end
          # Try to heal if it's optimal
          if battler.hasActiveAbility?(:REGENERATOR) && battler.hp <= battler.totalhp * 0.4
            healing_switch = 30
            healing_switch += 10 if battler.hp < battler.totalhp * 0.6
          end
          if battler.hasActiveAbility?(:NATURALCURE) && battler.status != :NONE
            healing_switch = 20 if battler.status == :POISON
            healing_switch += 10 * battler.effects[PBEffects::Toxic] if battler.status == :POISON if battler.effects[PBEffects::Toxic] > 0
            healing_switch = 15 if battler.status == :BURN
            healing_switch = 15 if battler.status == :FROSTBITE
            healing_switch = 15 if battler.status == :PARALYSIS
            healing_switch = 40 if battler.status == :SLEEP
            healing_switch = 40 if battler.status == :FREEZE
          end
        end

        # Check if any switch requirement is fulfilled
        should_switch = (useless_switch || hurtful_switch >= 50 ||
                        ability_switch || healing_switch > 0 || effect_switch >= 0)

        if should_switch

          party = pbParty(i)
          dmg_scores = [0, 0, 0, 0, 0, 0] # The damage the new Pokemon can deal
          hurt_scores = [0, 0, 0, 0, 0, 0] # The damage the new Pokemon will take
          hazard_scores = [0, 0, 0, 0, 0, 0] # The damage the new Pokemon will take
          effect_scores = [0, 0, 0, 0, 0, 0] # Extra score for switch-in effects
          can_switch = [false, false, false, false, false, false]

          spikes = battler.pbOwnSide.effects[PBEffects::Spikes]
          toxic_spikes = battler.pbOwnSide.effects[PBEffects::ToxicSpikes]
          rocks = battler.pbOwnSide.effects[PBEffects::StealthRock]

          for p in 0...party.length
            if pbCanSwitch?(i, p, nil) && p != prev_switch
              pkmn = party[p]
              can_switch[p] = true

              # Create an imaginary battler for the party member, for damage calcs
              pkmnbattler = Battle::Battler.new(self, i)
              pkmnbattler.pbInitPokemon(pkmn, p)

              # Take damage from hazards
              if !pkmn.hasAbility?(:MAGICGUARD)
                if !pkmn.hasType?(:FLYING) && !pkmn.hasAbility?(:LEVITATE)
                  if spikes > 0
                    hazard_scores[p] += (100.0 / (10.0 - spikes * 2.0))
                  end
                  if toxic_spikes > 0 && !pkmn.hasType?(:POISON) && !pkmn.hasType?(:STEEL)
                    hazard_scores[p] += 12.0 * toxic_spikes
                  end
                end
                if rocks
                  types = [pkmn.type1, pkmn.type2]
                  types.compact!
                  eff = Effectiveness.calculate(:ROCK, *types)
                  if eff > 0
                    hazard_scores[p] += (100.0 * eff) / (64.0)
                  end
                end
              end

              dmg_score = 0
              dmg_target = 0
              hurt_score = 0

              pkmnbattler.eachOpposing do |o|
                # Determine how much damage the opponent can deal to the new Pokemon
                # Check for limitted choice of move
                fixed_move = 0
                if (battler.hasActiveItem?(:CHOICEBAND) || battler.hasActiveItem?(:CHOICESPECS) ||
                    battler.hasActiveItem?(:CHOICESCARF)) && battler.effects[PBEffects::ChoiceBand]
                  # Choiced
                  fixed_move = battler.effects[PBEffects::ChoiceBand]
                elsif battler.effects[PBEffects::Encore] > 0
                  # Encore
                  fixed_move = battler.effects[PBEffects::EncoreMove]
                end

                for m in o.moves
                  # Check that the move is valid
                  if m.pp > 0 && (o.effects[PBEffects::Disable] <= 0 || o.effects[PBEffects::DisableMove] != m.id)
                    if fixed_move
                      if m.id == fixed_move
                        dmg = m.pbPredictDamage(o, pkmnbattler, 1, [i, o.index], false)
                        hurt_score = dmg if dmg && dmg > hurt_score
                        break
                      end
                    elsif o.pbIsMoveRevealed?(m.id) ||
                          o.pbHasType?(m.type)
                      dmg = m.pbPredictDamage(o, pkmnbattler, 1, [i, o.index], false)
                      hurt_score = dmg if dmg && dmg > hurt_score
                    end
                  end
                end

                # Determine how much damage the new Pokemon can deal to the opponent
                for m in pkmnbattler.moves
                  # Check that the move is valid
                  if m.pp > 0
                    dmg = m.pbPredictDamage(pkmnbattler, o, 1, [i, o.index], false)
                    if dmg && dmg > dmg_score
                      dmg_score = dmg
                      dmg_target = o.index
                    end
                  end
                end
              end

              # Convert high scores to percentages
              hurt_scores[p] += hurt_score * 100 / pkmn.totalhp
              dmg_scores[p] += dmg_score * 100 / @battlers[dmg_target].totalhp

            end
          end

          best_switch = -1
          best_score = -50
          for p in 0...party.length
            if can_switch[p] && p != prev_switch
              pkmn = party[p]
              hp_percent = pkmn.hp * 100 / pkmn.totalhp
              hazard_score = hazard_scores[p]
              dmg_score = dmg_scores[p]
              hurt_score = hurt_scores[p]
              effect_score = effect_scores[p]

              # Must not die immediately from hazards
              if hazard_score < hp_percent

                viable = false
                bonus = 0
                # Switching because of uselessness
                if useless_switch
                  if hurt_score + hazard_score < 60 && dmg_score > 15
                    viable = true
                  end
                end

                # Switching for an effect
                if effect_switch == p && dmg_potential[i] < 55
                  if hurt_score + hazard_score < 80
                    viable = true
                    bonus += 80
                  end
                end

                # Switching to preserve abilities
                if ability_switch
                  if hurt_score + hazard_score < 60 && dmg_score > 10
                    viable = true
                    for poke in party
                      bonus += 25 if poke.hp > 0
                    end
                  end
                end

                # Switching to heal
                if healing_switch > 0
                  if hurt_score + hazard_score <= healing_switch && dmg_score > 10 &&
                      dmg_potential[i] < 100 - (@battlers[i].hp * 100 / @battlers[i].totalhp)
                      viable = true
                  end
                end

                # Switching to avoid damage
                if hurtful_switch > 0
                  if hurt_score + hazard_score < hurtful_switch / 1.5 &&
                      (hurtful_switch >= 150 || dmg_score > 10)
                    viable = true
                  end
                end

                if viable
                  total_score = dmg_score + effect_score - hurt_score - hazard_score + bonus
                  if total_score > best_score
                    best_score = total_score
                    best_switch = p
                  end
                end
              end
            end
          end

          if best_switch >= 0
            passmove = -1
            passtarget = -1
            passdamage = 0
            for k in 0...4
              m = battler.moves[k]
              if pbCanChooseMove?(i, k, false)
                if m.function_code == "0ED" # Baton Pass
                  passmove = k
                  break
                elsif m.function_code == "0EE" # U-turn / Volt Switch
                  # Avoid being redirected and not switching
                  stopped = false
                  eachBattler do |b|
                    next if b == battler
                    if (m.type == :ELECTRIC && b.hasActiveAbility?(:LIGHTNINGROD)) ||
                        (m.type == :WATER && b.hasActiveAbility?(:STORMDRAIN))
                      stopped = true
                      break
                    end
                  end
                  next if stopped
                  # Confirm move can damage at least one target, and choose the best one
                  battler.eachOpposing do |b|
                    damage = m.pbPredictDamage(battler, b, 1, [i, b.index], false)
                    if damage > passdamage
                      passmove = k
                      passtarget = b.index
                      passdamage = damage
                    end
                  end
                elsif m.function_code == "151" # Parting Shot
                  passmove = k
                  break
                end
              end
            end

            will_switch[i] = true
            if passmove >= 0
              pbRegisterMove(i, k, false)
              pbRegisterTarget(i, passtarget) if passtarget >= 0
            else
              pbRegisterSwitch(i, best_switch)
              prev_switch = i
            end

          end

        end
      end
      if prev_switch >= 0
        break
      end
    end

    pbWriteLogTurn(scores, idxBattlers, will_switch, max_score, max_index, max_target) if Supplementals::WRITE_BATTLE_LOGS

    # Finally register the moves
    for i in 0...idxBattlers.length
      idx = idxBattlers[i]
      if !will_switch[idx]
        pbRegisterMove(idx, max_index[i], false)
        pbRegisterTarget(idx, max_target[i])
      end
    end

    pbEndPredictingDamage

  end

end 