def pbFishingGame(encounter, tutorial=false, item=false)

  $game_temp.in_menu = true

  if encounter

    has_stun = pbJob("Fisher").level >= 2
    has_jump = false
    acceleration_up = pbJob("Fisher").level >= 3

    viewport = Viewport.new(128, 160, Graphics.width, Graphics.height)
    viewport.z = 999

    fish_x = 142 + rand(231)
    zone_x = fish_x

    sprites = {}
    sprites["bg"] = IconSprite.new(118, 64, viewport)
    sprites["bg"].setBitmap(_INTL("Graphics/Pictures/Fishing/bar"))
    sprites["bg"].z = 0

    if item
      sprites["pokeicon"] = IconSprite.new(0, 0, viewport)
      sprites["pokeicon"].setBitmap(_INTL("Graphics/Items/{1}", encounter.to_s))
      sprites["pokeicon"].x = fish_x - 24
      sprites["pokeicon"].y = 8
      sprites["pokeicon"].z = 1001
    else
      sprites["pokeicon"] = AnimatedSprite.new(
        _INTL("Graphics/Pokemon/Icons/{1}",encounter[0].to_s),2,64,64,1)
      sprites["pokeicon"].viewport = viewport
      sprites["pokeicon"].x = fish_x - 32
      sprites["pokeicon"].z = 1001
      sprites["pokeicon"].color = Color.new(0, 0, 0)
    end

    sprites["arrow"] = AnimatedSprite.new(
      "Graphics/Pictures/arrow",4,32,32,1)
    sprites["arrow"].viewport = viewport
    sprites["arrow"].y = 54
    sprites["arrow"].x = fish_x - 16
    sprites["arrow"].z = 1000

    control_x = 132
    control_y = 110
    control_y += 22 if has_stun
    sprites["control_exit"] = KeybindSprite.new(Input::BACK, "Let Go", control_x, control_y, viewport)
    sprites["control_move"] = KeybindSprite.new([Input::LEFT, Input::RIGHT], "Move Hook", control_x + 96, control_y, viewport)
    if has_stun
      sprites["control_stun"] = KeybindSprite.new(Input::USE, "Stun", control_x, control_y + 32, viewport)
    end
    if acceleration_up
      sprites["control_speed"] = KeybindSprite.new(Input::ACTION, "Move Faster", control_x + 96, control_y + 32, viewport)
    end

    if has_stun
      sprites["stun_bar"] = IconSprite.new(140, 104, viewport)
      sprites["stun_bar"].setBitmap("Graphics/Pictures/Fishing/stun_cooldown")
      overlay_bitmap = Bitmap.new(sprites["stun_bar"].bitmap.width, sprites["stun_bar"].bitmap.height)
      overlay_bitmap.fill_rect(90, 10, 54, 6, Color.new(14, 152, 22))
      overlay_bitmap.fill_rect(148, 10, 54, 6, Color.new(14, 152, 22))
      sprites["stun_overlay"] = Sprite.new(viewport)
      sprites["stun_overlay"].bitmap = overlay_bitmap
      sprites["stun_overlay"].x = 140
      sprites["stun_overlay"].y = 104
    end

    stats = item ? pbItemFishingStats(encounter) : pbFishingStats(encounter[0])
    difficulty = stats[0]
    max_hp     = stats[1]
    speed      = stats[2]
    behaviour  = stats[3]

    reel = max_hp / 4 + 1
    reel = 30 if reel < 30

    reel_colors = [
      Color.new(14,152,22),Color.new(24,192,32),   # Green
      Color.new(202,138,0),Color.new(232,168,0),   # Orange
      Color.new(218,42,36),Color.new(248,72,56)    # Red
    ]

    sprites["reel"] = BitmapSprite.new(192,6,viewport)
    sprites["reel"].y = 94
    sprites["reel"].x = 160
    sprites["reel"].z = 1002
    sprites["reel"].bitmap.clear
    color = 0
    color = 2 if reel <= max_hp / 2
    color = 4 if reel <= max_hp / 4
    sprites["reel"].bitmap.fill_rect(
      0,0,(reel*192.0/max_hp).floor,4,reel_colors[color])
    sprites["reel"].bitmap.fill_rect(
      0,4,(reel*192.0/max_hp).floor,2,reel_colors[color+1])

    bar_len = [120,90,60,40][difficulty]

    zone_x = fish_x - (bar_len/2)

    if zone_x < 136
      zone_x = 136
    elsif zone_x > 376 - bar_len
      zone_x = 376 - bar_len
    end

    sprites["zone"] = IconSprite.new(118,64,viewport)
    sprites["zone"].setBitmap("Graphics/Pictures/Fishing/zone_"+difficulty.to_s)
    sprites["zone"].y = 72
    sprites["zone"].x = zone_x
    sprites["zone"].z = 999

    last_input = 0
    last_time = 0
    zone_time = 0
    off_time = 0
    perfect = true
    switch = false
    goal = -1
    move_time = 0
    knockback = 0
    knockback_timer = 0
    player_stun = 0
    caught = false

    stun_cooldown = 0
    stun_timer = 0
    pokemon_stun = 0
    jump_cooldown = 0
    jump_direction = 0
    jump_timer = 0

    if tutorial
      pbText("When fishing, you need to focus on where the fish is compared to your line.")
      pbText("[O]Press left and right[/] to move the [G]green bar[/] to keep the fish [R]inside[/] that area.")
      pbText("While the fish is in that area, the meter below [G]will increase[/].")
      pbText("If it [G]reaches the top[/], you reel it in!")
      pbText("Be careful though, if it [R]reaches the bottom[/], the fish will get away.")
      pbText("You start when the [B]countdown reaches 0[/]. Good luck!")
    end

    for i in 1..3
      sprites[_INTL("num{1}",i)] = IconSprite.new(234,62,viewport)
      sprites[_INTL("num{1}",i)].setBitmap(
        _INTL("Graphics/Pictures/Fishing/countdown_{1}",i))
      sprites[_INTL("num{1}",i)].z = 1005
      sprites[_INTL("num{1}",i)].visible=false
    end

    for i in 0...3
      sprites[_INTL("num{1}",(3-i+1))].visible=false if i > 0
      sprites[_INTL("num{1}",(3-i))].visible=true
      60.times do
        Graphics.update
        viewport.update
        Input.update
        pbUpdateSceneMap
      end
    end
    sprites[_INTL("num1")].visible=false

    loop do
      if has_stun
        sprites["stun_overlay"].bitmap.clear
        if stun_cooldown == 0
          sprites["stun_overlay"].bitmap.fill_rect(90, 10, 54, 6, Color.new(14, 152, 22))
          sprites["stun_overlay"].bitmap.fill_rect(148, 10, 54, 6, Color.new(14, 152, 22))
        elsif stun_cooldown <= 180
          sprites["stun_overlay"].bitmap.fill_rect(90, 10, 54, 6, Color.new(14, 152, 22))
          sprites["stun_overlay"].bitmap.fill_rect(148, 10, ((180 - stun_cooldown) * 54 / 360).floor * 2, 6, Color.new(218, 42, 36))
        else
          sprites["stun_overlay"].bitmap.fill_rect(90, 10, ((360 - stun_cooldown) * 54 / 360).floor * 2, 6, Color.new(218, 42, 36))
        end
      end

      Graphics.update
      viewport.update
      Input.update
      pbUpdateSceneMap

      if Input.trigger?(Input::BACK)
        break
      end

      if player_stun <= 0
        if Input.trigger?(Input::USE)
          if has_stun && stun_cooldown <= 180 && pokemon_stun <= 0
            pbSEPlay("Battle damage weak")
            stun_cooldown += 180
            pokemon_stun = 30
            stun_timer = 8
            switch = false
            move_time = 0
            knockback = 0
            knockback_timer = 0
            sprites["pokeicon"].y = 0
          end
        end

        if stun_timer > 0
          sprites["bg"].y = 64 + (stun_timer % 2 == 0 ? -2 : 0)
          sprites["zone"].y = 72 + (stun_timer % 2 == 0 ? -2 : 0)
          sprites["reel"].y = 94 + (stun_timer % 2 == 0 ? -2 : 0)
        else
          sprites["bg"].y = 64
          sprites["zone"].y = 72
          sprites["reel"].y = 94
        end
      end

      stun_timer -= 1 if stun_timer > 0
      pokemon_stun -= 1 if pokemon_stun > 0
      stun_cooldown -= 1 if stun_cooldown > 0

      if Input.press?(Input::RIGHT) && !Input.press?(Input::LEFT) && player_stun <= 0
        if last_input != 1
          last_time = 0
          if has_jump
            if jump_direction == 1 && jump_timer > 0
              zone_x += (bar_len / 2).floor
              last_time += 40
              jump_direction = 0
              jump_timer = 0
            else
              jump_direction = 1
              jump_timer = 12
            end
          end
        end
        last_input = 1
        last_time += 1
        to_add = 1 + (last_time/8).floor
        to_add = 6 if to_add > 6
        if acceleration_up && Input.press?(Input::ACTION)
          zone_x += to_add * 2.0
        else
          zone_x += to_add
        end
      elsif Input.press?(Input::LEFT) && !Input.press?(Input::RIGHT) && player_stun <= 0
        if last_input != 2
          last_time = 0
          if has_jump
            if jump_direction == 2 && jump_timer > 0
              zone_x -= (bar_len / 2).floor
              last_time += 40
              jump_direction = 0
              jump_timer = 0
            else
              jump_direction = 2
              jump_timer = 12
            end
          end
        end
        last_input = 2
        last_time += 1
        to_add = 1 + (last_time/8).floor
        to_add = 6 if to_add > 6
        if acceleration_up && Input.press?(Input::ACTION)
          zone_x -= to_add * 2.0
        else
          zone_x -= to_add
        end
      else
        last_input = 0
        last_time = 0
        player_stun -= 1
      end

      if jump_timer > 0
        jump_timer -= 1
      end

      if zone_x < 136
        zone_x = 136
      elsif zone_x > 376 - bar_len
        zone_x = 376 - bar_len
      end

      if fish_x >= zone_x && fish_x < zone_x + bar_len
        off_time = 0
        zone_time += 1
        to_add = (1.0 + (zone_time/8).floor) / 10.0
        to_add = 6 if to_add > 6
        reel += to_add
      else
        zone_time = 0
        off_time += 1
        to_add = (1.0 + (off_time/8).floor) / 7.5
        to_add = 6 if to_add > 6
        reel -= to_add
        perfect = false
      end

      if reel > max_hp
        reel = max_hp
      elsif reel < 0
        reel = 0
      end

      color = 0
      color = 2 if reel <= max_hp / 2
      color = 4 if reel <= max_hp / 4
      sprites["reel"].bitmap.clear
      sprites["reel"].bitmap.fill_rect(
        0,0,(reel*192.0/max_hp).floor,4,reel_colors[color])
      sprites["reel"].bitmap.fill_rect(
        0,4,(reel*192.0/max_hp).floor,2,reel_colors[color+1])

      if pokemon_stun <= 0
        case behaviour
        when "normal"
          if switch
            if goal < fish_x
              fish_x -= speed / (move_time >= 2.0 ? 1.0 : 1.5)
              switch = false if goal >= fish_x
            elsif goal > fish_x
              fish_x += speed / (move_time >= 2.0 ? 1.0 : 1.5)
              switch = false if goal <= fish_x
            end
            move_time += 1
          else
            move_time = 0
            switch = true
            goal = 142 + rand(231)
          end
        when "passive"
          if switch
            if goal < fish_x
              if move_time < 10
                fish_x -= speed / (10.0 - move_time)
              else
                fish_x -= speed
              end
              switch = false if goal >= fish_x
            elsif goal > fish_x
              if move_time < 10
                fish_x += speed / (10.0 - move_time)
              else
                fish_x += speed
              end
              switch = false if goal <= fish_x
            end
            move_time += 1
          else
            move_time = 0
            if rand(30/(difficulty+1))==1
              switch = true
              goal = 142 + rand(230)
            end
          end
        when "aggressive"
          if switch
            if goal < fish_x
              fish_x -= speed / (move_time >= 2.0 ? 1.0 : 1.5)
              switch = false if goal >= fish_x
            elsif goal > fish_x
              fish_x += speed / (move_time >= 2.0 ? 1.0 : 1.5)
              switch = false if goal <= fish_x
            end
            move_time += 1
          else
            move_time = 0
            switch = true
            goal = 142 + rand(231)
          end
          if knockback <= 0 && rand(100/difficulty)==1
            knockback = 5 + (5*difficulty)
            knockback_timer = 10
          elsif knockback > 0
            if knockback_timer > 0
              frames = [0,6,10,12,14,14,14,12,10,6,0]
              knockback_timer -= 0.5
              sprites["pokeicon"].y = -frames[knockback_timer.ceil]
            else
              pbSEPlay("Player bump") if knockback_timer == 0
              player_stun = 5 + (5*difficulty) if knockback_timer == 0
              if knockback_timer > 2 - knockback
                sprites["bg"].y = 64 + (knockback_timer % 2 == 0 ? -2 : 0)
                sprites["zone"].y = 72 + (knockback_timer % 2 == 0 ? -2 : 0)
                sprites["reel"].y = 94 + (knockback_timer % 2 == 0 ? -2 : 0)
              else
                sprites["bg"].y = 64
                sprites["zone"].y = 72
                sprites["reel"].y = 94
              end
              knockback_timer -= 1
              if knockback_timer <= -30
                knockback = 0
              end
            end
          end
        when "sudden"
          if switch
            if goal < fish_x
              if (goal - fish_x).abs < 2 + speed * 2.0
                speed_div = ((speed * 2.0 + 1.0) - (goal - fish_x).abs)
                speed_div = 1 if speed_div < 1
                fish_x -= speed / speed_div
              else
                fish_x -= speed
              end
              switch = false if goal >= fish_x
            elsif goal > fish_x
              if (goal - fish_x).abs < 2 + speed * 2.0
                speed_div = ((speed * 2.0 + 1.0) - (goal - fish_x).abs)
                speed_div = 1 if speed_div < 1
                fish_x += speed / speed_div
              else
                fish_x += speed
              end
              switch = false if goal <= fish_x
            end
          else
            if move_time > 0
              move_time -= 1
            else
              if zone_time > 10
                switch = true
                move_time = 20 + rand(10)
                while (goal - fish_x).abs < 80 || goal <= 0
                  goal = 142 + rand(230)
                end
              end
            end
          end
        end
      end

      fish_x = 142 if fish_x < 142
      fish_x = 372 if fish_x > 372

      sprites["pokeicon"].x = fish_x - (item ? 24 : 32)
      if pokemon_stun > 0
        sprites["pokeicon"].x += ((pokemon_stun % 2 == 0) ? 2 : -2)
      end
      sprites["arrow"].x = fish_x - 16
      sprites["zone"].x = zone_x

      if reel >= max_hp
        caught = true
        break
      elsif reel <= 0
        caught = false
        break
      end

    end

    pbDisposeSpriteHash(sprites)
    viewport.dispose

    if caught
      if item
        pbExclaim($game_player)
        pbItemBall(encounter)
      else
        pbJob("Fisher").register(encounter[0])
        pbExclaim($game_player)
        WildBattle.start(encounter[0], encounter[1])
      end
      $game_temp.in_menu = false
      return true
    else
      pbMessage("It got away...")
      $game_temp.in_menu = false
      return false
    end

  end

end

def pbFishStats
  return {
    #Surf/Land :SQUIRTLE => [],
    #Surf/Land :WARTORTLE => [],
    #Surf/Land :BLASTOISE => [],
    #Surf/Land :PSYDUCK => [],
    #Surf/Land :GOLDUCK => [],
    :POLIWAG => [0, 300, 2, "normal"],
    :POLIWHIRL => [1, 200, 3, "normal"],
    :POLIWRATH => [1, 500, 2, "aggressive"],
    :TENTACOOL => [1, 250, 3, "normal"],
    :TENTACRUEL => [1, 450, 4, "normal"],
    #Surf/Land :SLOWPOKE => [],
    #Surf/Land :SLOWBRO => [],
    :SEEL => [1, 300, 3, "normal"],
    :DEWGONG => [1, 700, 4, "normal"],
    :SHELLDER => [1, 300, 2, "passive"],
    :CLOYSTER => [2, 700, 3, "passive"],
    :KRABBY => [1, 250, 3, "aggressive"],
    :KINGLER => [2, 500, 3, "aggressive"],
    :HORSEA => [1, 150, 4, "sudden"],
    :SEADRA => [1, 300, 4, "sudden"],
    :GOLDEEN => [0, 200, 3, "normal"],
    :SEAKING => [1, 300, 2, "normal"],
    :STARYU => [1, 250, 3, "sudden"],
    :STARMIE => [1, 500, 7, "sudden"],
    :MAGIKARP => [0, 300, 2, "passive"],
    :GYARADOS => [1, 500, 3, "aggressive"],
    :DRATINI => [1, 250, 3, "sudden"],
    :DRAGONAIR => [1, 400, 4, "sudden"],
    #Surf/Land :TOTODILE => [],
    #Surf/Land :CROCONAW => [],
    #Surf/Land :FERALIGATR => [],
    :CHINCHOU => [1, 250, 3, "normal"],
    :LANTURN => [1, 700, 4, "normal"],
    #Surf/Land :MARILL => [],
    #Surf/Land :AZUMARILL => [],
    :POLITOED => [2, 800, 5, "normal"],
    #Swamp :WOOPER => [],
    #Swamp :QUAGSIRE => [],
    #Surf/Land :SLOWKING => [],
    :QWILFISH => [1, 400, 3, "aggressive"],
    :CORSOLA => [1, 500, 2, "passive"],
    :REMORAID => [1, 200, 4, "sudden"],
    :OCTILLERY => [2, 500, 3, "aggressive"],
    :MANTINE => [2, 700, 4, "sudden"],
    :KINGDRA => [2, 500, 10, "sudden"],
    #Swamp :MUDKIP => [],
    #Swamp :MARSHTOMP => [],
    #Swamp :SWAMPERT => [],
    #Surf/Land :AZURILL => [],
    :CARVANHA => [1, 250, 4, "aggressive"],
    :SHARPEDO => [2, 500, 8, "aggressive"],
    :WAILMER => [1, 700, 3, "normal"],
    :WAILORD => [2, 1000, 3, "normal"],
    :BARBOACH => [1, 200, 3, "normal"],
    :WHISCASH => [1, 600, 3, "normal"],
    :CORPHISH => [1, 250, 3, "aggressive"],
    :CRAWDAUNT => [2, 500, 4, "aggressive"],
    :FEEBAS => [1, 300, 5, "sudden"],
    :MILOTIC => [2, 500, 5, "sudden"],
    #Surf/Land :SPHEAL => [],
    #Surf/Land :SEALEO => [],
    :WALREIN => [2, 750, 4, "aggressive"],
    :CLAMPERL => [1, 300, 2, "passive"],
    :HUNTAIL => [2, 600, 5, "aggressive"],
    :GOREBYSS => [2, 600, 5, "sudden"],
    :RELICANTH => [2, 1000, 4, "passive"],
    :LUVDISC => [1, 300, 4, "sudden"],
    #Surf/Land :PIPLUP => [],
    #Surf/Land :PRINPLUP => [],
    #Surf/Land :EMPOLEON => [],
    #Surf/Land :BIDOOF => [],
    #Surf/Land :BIBAREL => [],
    :FINNEON => [1, 300, 4, "sudden"],
    :LUMINEON => [1, 700, 3, "normal"],
    :MANTYKE => [1, 300, 3, "sudden"],
    :PHIONE => [1, 1000, 10, "normal"],
    :MANAPHY => [2, 2000, 10, "normal"],
    #Surf/Land :OSHAWOTT => [],
    #Surf/Land :DEWOTT => [],
    #Surf/Land :SAMUROTT => [],
    :TYMPOLE => [0, 200, 3, "normal"],
    #Swamp :PALPITOAD => [],
    #Swamp :SEISMITOAD => [],
    :BASCULIN => [1, 400, 4, "aggressive"],
    :FRILLISH => [1, 500, 3, "normal"],
    :JELLICENT => [2, 750, 3, "normal"],
    :ALOMOMOLA => [1, 600, 4, "normal"],
    :STUNFISK => [1, 700, 2, "aggressive"],
    #Surf/Land :FROAKIE => [],
    #Surf/Land :FROGADIER => [],
    #Surf/Land :GRENINJA => [],
    #Beach :BINACLE => [],
    #Beach :BARBARACLE => [],
    :SKRELP => [1, 300, 4, "sudden"],
    :DRAGALGE => [2, 700, 6, "sudden"],
    :CLAUNCHER => [1, 300, 3, "aggressive"],
    :CLAWITZER => [2, 700, 5, "aggressive"],
    #Surf/Land :POPPLIO => [],
    #Surf/Land :BRIONNE => [],
    #Surf/Land :PRIMARINA => [],
    :WISHIWASHI => [1, 300, 3, "normal"],
    :MAREANIE => [1, 300, 3, "aggressive"],
    :TOXAPEX => [2, 1000, 5, "aggressive"],
    #Beach :PYUKUMUKU => [],
    :BRUXISH => [1, 500, 4, "aggressive"],
    :DHELMISE => [2, 1000, 2, "passive"],
    #Surf/Land :SOBBLE => [],
    #Surf/Land :DRIZZILE => [],
    #Surf/Land :INTELEON => [],
    :ARROKUDA => [1, 300, 5, "sudden"],
    :BARRASKEWDA => [2, 500, 10, "sudden"],
    #Surf/Land :CLOBBOPUS => [],
    #Surf/Land :GRAPPLOCT => [],
    #Beach :PINCURCHIN => [],
    :BASCULEGION => [2, 1000, 7, "aggressive"],
    :OVERQWIL => [2, 1300, 5, "aggressive"],
    :FINIZEN => [1, 500, 5, "normal"],
    :PALAFIN => [2, 1000, 5, "aggressive"],
    :DONDOZO => [2, 1200, 3, "aggressive"],
    #Beach :TATSUGIRI => [],
    #Swamp :CLODSIRE => []
  }
end

def pbFishingStats(species)

  # [difficulty, hp, speed, behaviour]
  # passive, normal, aggressive, sudden

  stats = pbFishStats

  return stats[species] if stats.key?(species)
  echoln _INTL("No fishing stats specified for {1}", species.to_s)
  return [1,200,2,"normal"]
end

def pbItemFishingStats(item)
  return [1,200,2,"normal"]
end



