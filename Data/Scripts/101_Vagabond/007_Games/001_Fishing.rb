def pbFishingGame(encounter,tutorial=false,item=false)

  $game_temp.in_menu = true

  if encounter

    viewport = Viewport.new(0, 0, Graphics.width,Graphics.height)
    viewport.z = 999

    fish_x = 142 + rand(231)
    zone_x = fish_x

    sprites = {}
    sprites["bg"] = IconSprite.new(118,64,viewport)
    sprites["bg"].setBitmap(_INTL("Graphics/Pictures/fishing_bar"))
    sprites["bg"].z = 0

    if item
      sprites["pokeicon"] = IconSprite.new(0,0,viewport)
      sprites["pokeicon"].setBitmap(sprintf("Graphics/Icons/item%03d",encounter))
      sprites["pokeicon"].x = fish_x - 24
      sprites["pokeicon"].y = 8
      sprites["pokeicon"].z = 1001
    else
      sprites["pokeicon"] = AnimatedSprite.new(
        sprintf("Graphics/Icons/silhouette/icon%03d",encounter[0]),2,64,64,1)
      sprites["pokeicon"].x = fish_x - 32
      sprites["pokeicon"].z = 1001
    end

    sprites["arrow"] = AnimatedSprite.new(
      "Graphics/Pictures/arrow",4,32,32,1)
    sprites["arrow"].y = 54
    sprites["arrow"].x = fish_x - 16
    sprites["arrow"].z = 999

    stats = item ? pbItemFishingStats(encounter) : pbFishingStats(encounter[0])
    difficulty = stats[0]
    max_hp     = stats[1]
    speed      = stats[2]
    behaviour  = stats[3]

    reel = max_hp / 10
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
    sprites["zone"].setBitmap("Graphics/Pictures/fishing_zone_"+difficulty.to_s)
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
    stun = 0
    catch = false

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
        _INTL("Graphics/Pictures/fishing_{1}",i))
      sprites[_INTL("num{1}",i)].z = 1005
      sprites[_INTL("num{1}",i)].visible=false
    end

    for i in 0...3
      Graphics.update
      viewport.update
      Input.update
      pbUpdateSceneMap
      sprites[_INTL("num{1}",(3-i+1))].visible=false if i > 0
      sprites[_INTL("num{1}",(3-i))].visible=true
      pbWait(30)
    end
    sprites[_INTL("num1")].visible=false

    upgrade = $game_switches[ROD_UPGRADE]

    loop do
      Graphics.update
      viewport.update
      Input.update
      pbUpdateSceneMap

      if Input.press?(Input::RIGHT) && !Input.press?(Input::LEFT) && stun<=0
        last_time = 0 if last_input != 1
        last_input = 1
        last_time += 1
        to_add = 1 + (last_time/8).floor
        to_add = 6 if to_add > 6
        if upgrade && Input.press?(Input::A)
          zone_x += to_add * 2.0
        else
          zone_x += to_add
        end
      elsif Input.press?(Input::LEFT) && !Input.press?(Input::RIGHT) && stun<=0
        last_time = 0 if last_input != 2
        last_input = 2
        last_time += 1
        to_add = 1 + (last_time/8).floor
        to_add = 6 if to_add > 6
        if upgrade && Input.press?(Input::A)
          zone_x -= to_add * 2.0
        else
          zone_x -= to_add
        end
      else
        last_input = 0
        last_time = 0
        stun -= 1
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
        to_add = (1.0 + (off_time/8).floor) / 10.0 * (difficulty+1)
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
            pbSEPlay("bump") if knockback_timer == 0
            stun = 5 + (5*difficulty) if knockback_timer == 0
            if knockback_timer > 2 - knockback
              sprites["bg"].y = 64 + (knockback_timer % 2 == 0 ? -1 : 1)
              sprites["zone"].y = 72 + (knockback_timer % 2 == 0 ? -1 : 1)
              sprites["reel"].y = 94 + (knockback_timer % 2 == 0 ? -1 : 1)
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
              move_time = 10
              while (goal - fish_x).abs < 80 || goal <= 0
                goal = 142 + rand(230)
              end
            end
          end
        end
      end

      fish_x = 142 if fish_x < 142
      fish_x = 372 if fish_x > 372

      sprites["pokeicon"].x = fish_x - (item ? 24 : 32)
      sprites["arrow"].x = fish_x - 16
      sprites["zone"].x = zone_x

      if reel >= max_hp
        catch = true
        break
      elsif reel <= 0
        catch = false
        break
      end

    end

    pbDisposeSpriteHash(sprites)
    viewport.dispose

    if catch
      if item
        pbExclaim($game_player)
        pbItemBall(encounter)
      else
        addReeledIn(encounter[0])
        pbExclaim($game_player)
        pbWildBattle(encounter[0],encounter[1])
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

def pbFishingStats(species)

  # [difficulty, hp, speed, behaviour]
  # passive, normal, aggressive, sudden

  case species
  when :MAGIKARP
    return [0,100,2,"passive"]
  when :GOLDEEN, :LUVDISC
    return [0,150,2,"normal"]
  when :MANTYKE, :FINNEON
    return [1,150,2,"normal"]
  when :POLIWAG, :PSYDUCK, :TENTACOOL,
       :SEEL, :OMANYTE, :KABUTO,
       :TYMPOLE
    return [1,150,3,"normal"]
  when :FEEBAS
    return [1,150,4,"normal"]
  when :GRIMER, :SHELLDER, :STARYU,
       :SLOWPOKE, :CLAMPERL
    return [1,200,3,"passive"]
  when :KRABBY, :CORPHISH
    return [1,200,3,"aggressive"]
  when :HORSEA, :REMORAID, :PIPLUP,
       :OSHAWOTT, :FROAKIE, :SKRELP,
       :CLAUNCHER, :POPPLIO
    return [1,200,4,"sudden"]
  when :FRILLISH, :FROGADIER
    return [1,300,3,"sudden"]
  when :DRATINI
    return [1,250,4,"normal"]
  when :SQUIRTLE, :CHINCHOU, :QWILFISH,
       :MUDKIP, :BARBOACH, :TIRTOUGA
    return [1,250,3,"normal"]
  when :WAILMER, :WHISCASH
    return [1,450,3,"normal"]
  when :TOTODILE, :MAREANIE
    return [1,200,3,"aggressive"]
  when :CARVANHA
    return [1,200,4,"aggressive"]
  when :WARTORTLE, :GOLDUCK, :POLIWHIRL,
       :TENTACRUEL, :DEWGONG, :SEAKING,
       :VAPOREON, :MARSHTOMP, :PALPITOAD,
       :STUNFISK
    return [1,300,3,"normal"]
  when :CROCONAW, :HUNTAIL
    return [1,300,3,"aggressive"]
  when :SEADRA, :STARMIE, :GOREBYSS,
       :WISHIWASHI
    return [1,350,5,"sudden"]
  when :KINGLER, :CRAWDAUNT
    return [1,400,3,"aggressive"]
  when :SHARPEDO
    return [1,200,4,"aggressive"]
  when :GYARADOS, :FERALIGATR, :TOXAPEX,
       :BRUXISH, :DHELMISE
    return [2,500,3,"aggressive"]
  when :BLASTOISE, :POLIWRATH, :LAPRAS,
       :LANTURN, :OCTILLERY, :SWAMPERT,
       :MILOTIC, :SEISMITOAD
    return [2,600,3,"normal"]
  when :WAILORD
    return [2,700,3,"aggressive"]
  when :DRAGONAIR
    return [2,500,5,"normal"]
  when :MUK, :SLOWBRO,
       :SLOWKING, :RELICANTH
    return [2,500,3,"passive"]
  when :CLOYSTER, :CARRACOSTA
    return [2,500,3,"aggressive"]
  when :MANTINE, :LUMINEON, :ALOMOMOLA
    return [2,400,4,"normal"]
  when :JELLICENT, :DRAGALGE, :CLAWITZER
    return [2,500,4,"sudden"]
  when :KINGDRA, :GRENINJA
    return [2,400,5,"sudden"]
  when :KABUTOPS, :OMASTAR
    return [2,500,4,"normal"]
  when :PHIONE
    return [2,700,7,"sudden"]
  when :MANAPHY
    return [2,800,8,"sudden"]
  when :TAPUFINI
    return [2,900,5,"normal"]
  when :LUGIA, :KYOGRE
    return [2,1000,4,"aggressive"]
  end

  return [1,200,2,"normal"]

end

def pbItemFishingStats(item)
  return [1,200,2,"normal"]
end

def addReeledIn(species)
  if !$game_variables[REELED_IN_POKEMON].is_a?(Array)
    $game_variables[REELED_IN_POKEMON] = []
  end
  $game_variables[REELED_IN_POKEMON][species]=true
end

def hasReeledIn?(species)
  if !$game_variables[REELED_IN_POKEMON].is_a?(Array)
    $game_variables[REELED_IN_POKEMON] = []
  end
  if $game_variables[REELED_IN_POKEMON][species]
    return $game_variables[REELED_IN_POKEMON][species]
  end
  return false
end




