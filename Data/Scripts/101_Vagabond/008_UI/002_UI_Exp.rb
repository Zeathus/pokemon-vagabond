def pbEXPScreen(expgain,sharedexp,fulltoall=false)
  
  return if $game_switches[DISABLE_EXP]

  if expgain > 0 || sharedexp > 0

    viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z = 99999

    active = []
    inactive = []
    for i in 0...PBParty.len
      if hasPartyMember(i)
        if isPartyMemberActive(i)
          active.push(i)
        else
          inactive.push(i)
        end
      end
    end

    newexp_active = []
    newexp_inactive = []
    levelups_active = []
    levelups_inactive = []

    shared_factor = fulltoall ? 0.5 : 0.4
    shared_mul = (0.5 * active.length) + (shared_factor * inactive.length)
    shared_mul = (shared_mul / (active.length + inactive.length)).ceil

    highest_level = 0
    for i in $player.party
      highest_level = i.level if i.level > highest_level
    end

    active_exp = exp = ((expgain * 0.5) + (sharedexp * shared_mul)).ceil
    inactive_exp = ((expgain * 0.4) + (sharedexp * shared_mul)).ceil
    min_low_level_mod = -1
    max_low_level_mod = -1
    total_lucky_egg_bonus = 0

    #### Active Party level up calcs
    levelup = false
    for i in 0...active.length
      party = getPartyPokemon(active[i])
      inactive_start = party.length
      party += getInactivePartyPokemon(active[i])
      newexp_active[i] = []
      levelups = [i]
      for j in 0...party.length
        thispoke = party[j]
        growth_rate = thispoke.growth_rate

        exp = (j < inactive_start) ? active_exp : inactive_exp

        if thispoke.item == :LUCKYEGG
          lucky_egg_bonus += (exp * 0.5).ceil
          exp = lucky_egg_bonus
          total_lucky_egg_bonus += lucky_egg_bonus
        end

        # Boost exp for underleveled Pokemon in Player's party
        if thispoke.level < (highest_level - 2)
          low_level_mod = [10, highest_level - thispoke.level - 1].min * 0.1
          min_low_level_mod = low_level_mod if low_level_mod < min_low_level_mod || min_low_level_mod == -1
          max_low_level_mod = low_level_mod if low_level_mod > max_low_level_mod || max_low_level_mod == -1
          low_level_bonus = (exp * low_level_mod).ceil
          exp += low_level_bonus
        end

        newexp = growth_rate.add_exp(thispoke.exp, exp)
        newexp_active[i][j] = newexp

        newlevel = growth_rate.level_from_exp(newexp)
        if newlevel > thispoke.level
          levelup = true
          levelups.push(j)
        else
          thispoke.exp=newexp
        end
      end
      if levelups.length > 1
        levelups_active.push(levelups)
      end
    end

    #### Inactive Party level up calcs
    for i in 0...inactive.length
      party = getAllPartyPokemon(inactive[i])
      newexp_inactive[i] = []
      levelups = [i+active.length]
      for j in 0...party.length
        thispoke = party[j]
        growth_rate = thispoke.growth_rate

        exp = inactive_exp

        if thispoke.item == :LUCKYEGG
          lucky_egg_bonus += (exp * 0.5).ceil
          exp = lucky_egg_bonus
          total_lucky_egg_bonus += lucky_egg_bonus
        end

        # Boost exp for underleveled Pokemon in Player's party
        if thispoke.level < (highest_level - 2)
          low_level_mod = [10, highest_level - thispoke.level - 1].min * 0.1
          min_low_level_mod = low_level_mod if low_level_mod < min_low_level_mod || min_low_level_mod == -1
          max_low_level_mod = low_level_mod if low_level_mod > max_low_level_mod || max_low_level_mod == -1
          low_level_bonus = (exp * low_level_mod).ceil
          exp += low_level_bonus
        end

        newexp = growth_rate.add_exp(thispoke.exp, exp)
        newexp_inactive[i][j] = newexp

        newlevel = growth_rate.level_from_exp(newexp)
        if newlevel > thispoke.level
          levelup = true
          levelups.push(j)
        else
          thispoke.exp=newexp
        end
      end
      if levelups.length > 1
        levelups_inactive.push(levelups)
      end
    end

    # Text colors
    base = Color.new(252,252,252)
    shadow = Color.new(0,0,0)

    if $PokemonSystem.showexpgain == 0
      exp_gain_text = []
      if active_exp > 0
        if inactive.length == 0
          exp_gain_text.push(_INTL("{1} Exp. -> All Pokémon.", active_exp.to_s_formatted))
        else
          exp_gain_text.push(_INTL("{1} Exp. -> Active Pokémon.", active_exp.to_s_formatted))
        end
      end
      if inactive.length > 0 && inactive_exp > 0
        exp_gain_text.push(_INTL("{1} Exp. -> Inactive Pokémon", inactive_exp.to_s_formatted))
      end
      if min_low_level_mod >= 0 && max_low_level_mod >= 0
        if min_low_level_mod == max_low_level_mod
          exp_gain_text.push(_INTL("{1}% Bonus Exp. -> Low-Level Pokémon",
            (min_low_level_mod * 100).round))
        else
          exp_gain_text.push(_INTL("{1}% to {2}% Bonus Exp. -> Low-Level Pokémon",
            (min_low_level_mod * 100).round, (max_low_level_mod * 100).round))
        end
      end
      if total_lucky_egg_bonus > 0
        exp_gain_text.push("{1}% Bonus Exp. -> Lucky Egg Pokémon", 50)
      end

      if exp_gain_text.length > 0
        20.times do
          Graphics.update
          Input.update
        end

        total_exp_sprites = {}
        exp_gain_text.each do |text|
          sprite = Sprite.new(viewport)
          sprite.x = 128
          sprite.y = Graphics.height / 2 + 32
          sprite.bitmap = Bitmap.new(Graphics.width, 32)
          sprite.z = 10
          sprite.opacity = 0
          pbSetSmallFont(sprite.bitmap)
          pbDrawTextPositions(sprite.bitmap, [[text, 12, 4, 0, base, shadow, 1]])
          total_exp_sprites[text.to_s] = sprite
          for j in 0...32
            if j < 16
              total_exp_sprites.each do |key, value|
                value.y -= 2
              end
              sprite.opacity += 16
            end
            Graphics.update
            Input.update
            viewport.update
            pbUpdateSpriteHash(total_exp_sprites)
          end
        end

        20.times do
          Graphics.update
          Input.update
        end

        for j in 0...16
          total_exp_sprites.each do |key, value|
            value.y -= 2
            value.opacity -= 16
          end
          Graphics.update
          Input.update
          viewport.update
          pbUpdateSpriteHash(total_exp_sprites)
        end
        pbDisposeSpriteHash(total_exp_sprites)
      end
    end

    if levelup
      20.times do
        Graphics.update
        Input.update
      end

      #### Title
      sprites = {}
      sprites["levelup"] = IconSprite.new(0,-26,viewport)
      sprites["levelup"].setBitmap("Graphics/Pictures/Exp Screen/levelup")
      sprites["levelup"].src_rect=Rect.new(0,0,768,148)
      sprites["levelup"].z=10

      # Speed up hint
      sprites["hint"] = Sprite.new(viewport)
      sprites["hint"].bitmap = Bitmap.new(120,60)
      sprites["hint"].x = 600
      sprites["hint"].y = 450
      sprites["hint"].z = 10
      sprites["hint"].opacity = 0
      textpos=[["X:",10,20,0,base,shadow,1],
               ["Fast",30,12,0,base,shadow,1],
               ["Forward",30,28,0,base,shadow,1]]
      pbSetSmallFont(sprites["hint"].bitmap)
      pbDrawTextPositions(sprites["hint"].bitmap,textpos)

      pbSEPlay("Up")
      28.times do |i|
        if i % 4 == 0
          sprites["levelup"].src_rect.y += 148
        end
        sprites["levelup"].update
        sprites["hint"].opacity = (i-10) * 16
        viewport.update
        Graphics.update
        Input.update
      end

      if !Input.press?(Input::B)
        16.times do
          Graphics.update
          Input.update
        end
      end

      # Misc data needed for display
      active_all = active + inactive
      newexp_all = newexp_active + newexp_inactive
      levelups_all = levelups_active + levelups_inactive
      numlines = levelups_all.length
      spacing = 80
      startx = 384 - (spacing * (numlines-1) / 2)

      #### Display party lines
      for i in 0...levelups_all.length
        party = levelups_all[i]
        partyindex = party[0]

        linesprite = IconSprite.new(startx + spacing * i - 52, 0, viewport)
        linesprite.setBitmap("Graphics/Pictures/Exp Screen/party")
        linesprite.src_rect = Rect.new(0,576*active_all[partyindex],104,576)
        linesprite.z = 8
        sprites[_INTL("line{1}",partyindex)]=linesprite

        type = PBParty.getTrainerType(active_all[partyindex])
        charsprite = IconSprite.new(0, 0, viewport)
        charsprite.setBitmap(sprintf("Graphics/Characters/trainer_%s",type.to_s))
        charsprite.src_rect = Rect.new(0,0,charsprite.bitmap.width/4,charsprite.bitmap.height/4)
        charsprite.x = startx + spacing * i - charsprite.bitmap.width / 8
        charsprite.y = 288 - charsprite.bitmap.height / 4
        charsprite.z = 9
        charsprite.opacity = 0
        sprites[_INTL("char{1}",partyindex)]=charsprite

        pbSEPlay("Saint3")
        if !Input.press?(Input::B)
          24.times do |k|
            if k % 4 == 0
              linesprite.src_rect.x += 104
              charsprite.y -= (24 - k) / 2
              charsprite.opacity = 16 * k
            end
            linesprite.update
            charsprite.update
            viewport.update
            Graphics.update
            Input.update
          end
        else
          6.times do |k|
            linesprite.src_rect.x += 104
            charsprite.y -= (6 - k) * 2
            charsprite.opacity = 64 * k
            linesprite.update
            charsprite.update
            viewport.update
            Graphics.update
            Input.update
          end
        end

        6.times do
          Graphics.update
          Input.update
        end

      end

      #### Display and level up pokemon
      for i in 0...levelups_all.length
        party = levelups_all[i]
        partyindex = party[0]

        for j in 1...party.length
          # Get pokemon
          pkmnindex = party[j]
          thispoke = getAllPartyPokemon(active_all[partyindex])[pkmnindex]

          # Get pokemon icon sprite
          filename = GameData::Species.icon_filename_from_pokemon(thispoke)

          # Appearance Animation
          sprite = IconSprite.new(startx+spacing*i-32,288,viewport)
          sprite.setBitmap(filename)
          sprite.src_rect=Rect.new(0,0,64,64)
          sprite.opacity = 0
          sprite.z = 9
          sprites[_INTL("pkmn{1}_{2}",partyindex,pkmnindex)]=sprite

          lvlsprite = Sprite.new(viewport)
          lvlbitmap = Bitmap.new(80,40)
          lvlsprite.bitmap = lvlbitmap
          lvlsprite.opacity = 0
          lvlsprite.x = startx+spacing*i-40
          lvlsprite.y = 266
          lvlsprite.z = 10
          sprites[_INTL("lvl{1}_{2}",partyindex,pkmnindex)]=lvlsprite

          textpos=[["Lv."+thispoke.level.to_s,40,10,2,base,shadow,1]]
          pbSetSmallFont(lvlbitmap)
          pbDrawTextPositions(lvlbitmap,textpos)

          if !Input.press?(Input::B)
            18.times do |k|
              if k % 4 == 0
                sprite.y -= (16 - k) / 2
                sprite.opacity = 16 * k
                lvlsprite.y -= (16 - k) / 2
                lvlsprite.opacity = 16 * k
              end
              sprite.update
              lvlsprite.update
              viewport.update
              Graphics.update
              Input.update
            end
          else
            9.times do |k|
              if k % 2 == 0
                sprite.y -= (16 - k * 2) / 2
                sprite.opacity = 32 * k
                lvlsprite.y -= (16 - k * 2) / 2
                lvlsprite.opacity = 32 * k
              end
              sprite.update
              lvlsprite.update
              viewport.update
              Graphics.update
              Input.update
            end
          end

          if !Input.press?(Input::B)
            10.times do
              Graphics.update
              Input.update
            end
          end

          # Level up
          growth_rate = thispoke.growth_rate
          newexp = newexp_all[partyindex][pkmnindex]
          newlevel = growth_rate.level_from_exp(newexp)
          while thispoke.level < newlevel
            tmpexp = growth_rate.minimum_exp_for_level(thispoke.level + 1)
            thispoke.exp = tmpexp

            # Level Animation
            lvlbitmap.clear
            textpos=[["Lv."+thispoke.level.to_s,40,10,2,base,shadow,1]]
            pbSetSmallFont(lvlbitmap)
            pbDrawTextPositions(lvlbitmap,textpos)

            pbSEPlay("Pkmn exp full")
            if !Input.press?(Input::B)
              frames = [-6,-4,-2,0,0,2,4,6]
              16.times do |i|
                if i % 2 == 0
                  sprite.y += frames[i / 2]
                  lvlsprite.y += frames[i / 2]
                end
                sprite.update
                lvlsprite.update
                viewport.update
                Graphics.update
                Input.update
              end

              10.times do
                Graphics.update
                Input.update
              end
            else
              frames = [-8,-4,0,0,4,8]
              6.times do |i|
                sprite.y += frames[i]
                lvlsprite.y += frames[i]
                sprite.update
                lvlsprite.update
                viewport.update
                Graphics.update
                Input.update
              end
            end

            # Learn Moves
            movelist=thispoke.getMoveList
            for k in movelist
              if k[0]==thispoke.level   # Learned a new move
                pbLearnMove(thispoke,k[1],true)
              end
            end

            # Evolve
            newspecies = thispoke.check_evolution_on_level_up
            if newspecies
              20.times do
                Graphics.update
                Input.update
              end
              pbFadeOutInWithMusic(99999){
                evo=PokemonEvolutionScene.new
                evo.pbStartScreen(thispoke,newspecies)
                evo.pbEvolution
                evo.pbEndScreen
              }
              # Update icon
              if newspecies == thispoke.species
                filename = GameData::Species.icon_filename_from_pokemon(thispoke)
                sprite.setBitmap(filename)
                sprite.src_rect=Rect.new(0,0,64,64)
                sprite.update
              end
              20.times do
                Graphics.update
                Input.update
              end
            end
          end
          thispoke.exp = newexp

          # Hide if there are more pokemon
          if i < party.length - 1
            if !Input.press?(Input::B)
              18.times do |i|
                if i % 4 == 0
                  sprite.y -= (16 - i) / 2
                  sprite.opacity = 256 - 16 * i
                  lvlsprite.y -= (16 - i) / 2
                  lvlsprite.opacity = 256 - 16 * i
                end
                sprite.update
                lvlsprite.update
                viewport.update
                Graphics.update
                Input.update
              end
            else

            9.times do |i|
              if i % 2 == 0
                sprite.y -= (16 - i * 2) / 2
                sprite.opacity = 256 - 32 * i
                lvlsprite.y -= (16 - i * 2) / 2
                lvlsprite.opacity = 256 - 32 * i
              end
              sprite.update
              lvlsprite.update
              viewport.update
              Graphics.update
              Input.update
            end
            end
          end

        end
      end

      for member in active + inactive
        for i in getPartyPokemon(member)
          i.calc_stats
        end
      end

      pbFadeOutAndHide(sprites)
      pbDisposeSpriteHash(sprites)

    end

  end
end