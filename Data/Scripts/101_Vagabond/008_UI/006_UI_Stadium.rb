class StadiumTransition

  def initialize(cup, index=nil)
    @index = index
    @name = cup[0]
    @trainers = cup[3]
    @trainertypes = []
    for t in @trainers
      @trainertypes.push(t[0])
    end

    if @index
      @opponent = [@trainertypes[@index], @trainers[@index][1]]
    else
      @opponent = nil
    end

    @index = @trainers.length - 1 if !@opponent

    self.initSprites
  end

  def initSprites
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999

    @sprites = {}

    @sprites["bg"] = AnimatedPlane.new(@viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Stadium/bg")
    @sprites["bg"].z = 1
    @sprites["bg"].opacity = 0
    @sprites["bg"].update

    @rows = [[1],[2],[3],[4],[3,2],[3,3],[4,3],[4,4]]
    @rows = @rows[@trainers.length - 1]
    xcoords = [128,329,269,218,165]
    ycoords = @rows.length == 1 ? [305,347,195] : [250,292,140,334]

    @sprites["title"] = IconSprite.new(0,0,@viewport)
    @sprites["title"].setBitmap("Graphics/Pictures/Stadium/title")
    @sprites["title"].z = 2
    @sprites["title"].x = xcoords[4]
    @sprites["title"].y = ycoords[0]

    @sprites["subtitle"] = IconSprite.new(0,0,@viewport)
    @sprites["subtitle"].setBitmap("Graphics/Pictures/Stadium/subtitle")
    @sprites["subtitle"].z = 2
    @sprites["subtitle"].x = xcoords[4]
    @sprites["subtitle"].y = ycoords[1]

    # Drawing cup name and battle number
    pbSetSystemFont(@sprites["title"].bitmap)
    pbDrawTextPositions(@sprites["title"].bitmap,
      [[_INTL("{1} CUP", @name.upcase),212,8,2,Color.new(0,0,0),Color.new(120,120,120),1]])
    pbSetSystemFont(@sprites["subtitle"].bitmap)
    if @opponent
      battletitle = _INTL("BATTLE {1}",@index+1)
      battletitle = "SEMIFINAL" if (@index+2)==@trainers.length
      battletitle = "FINAL" if (@index+1)==@trainers.length
      pbDrawTextPositions(@sprites["subtitle"].bitmap,
        [[battletitle,212,8,2,Color.new(0,0,0),Color.new(120,120,120),1]])
    else
      battletitle = "RESULTS"
      pbDrawTextPositions(@sprites["subtitle"].bitmap,
        [[battletitle,212,8,2,Color.new(0,0,0),Color.new(120,120,120),1]])
    end

    @sprites["row1"] = IconSprite.new(0,0,@viewport)
    @sprites["row1"].setBitmap(_INTL("Graphics/Pictures/Stadium/bar{1}",@rows[0]))
    @sprites["row1"].z = 2
    @sprites["row1"].x = xcoords[@rows[0]]
    @sprites["row1"].y = ycoords[2]

    if @rows.length == 2
      @sprites["row2"] = IconSprite.new(0,0,@viewport)
      @sprites["row2"].setBitmap(_INTL("Graphics/Pictures/Stadium/bar{1}",@rows[1]))
      @sprites["row2"].z = 2
      @sprites["row2"].x = xcoords[@rows[1]]
      @sprites["row2"].y = ycoords[3]
    end

    for i in 0...@trainertypes.length
      @sprites[_INTL("lock{1}",i)] = IconSprite.new(0,0,@viewport)
      if @opponent
        @sprites[_INTL("lock{1}",i)].setBitmap("Graphics/Pictures/Stadium/locked")
      else
        @sprites[_INTL("lock{1}",i)].setBitmap("Graphics/Pictures/Stadium/defeat")
      end
      @sprites[_INTL("lock{1}",i)].z = 5
      @sprites[_INTL("lock{1}",i)].x = (i >= @rows[0]) ? ((i-@rows[0]) * 104) : (i * 104)
      @sprites[_INTL("lock{1}",i)].x += xcoords[(i >= @rows[0]) ? @rows[1] : @rows[0]] + 8
      @sprites[_INTL("lock{1}",i)].y = ((i >= @rows[0]) ? ycoords[3] : ycoords[2]) + 8
      if i <= @index
        @sprites[_INTL("trainer{1}",i)] = IconSprite.new(0,0,@viewport)
        sprite = @sprites[_INTL("trainer{1}",i)]
        sprite.setBitmap(
          sprintf("Graphics/Trainers/%s",@trainertypes[i].to_s))
        sprite.src_rect = Rect.new(
          sprite.bitmap.width / 2 - 47,0,
          94,94)
        offset = pbStadiumTrainerOffset(@trainertypes[i])
        sprite.src_rect.x -= offset[0]
        sprite.src_rect.y -= offset[1]
        sprite.x = @sprites[_INTL("lock{1}",i)].x
        sprite.y = @sprites[_INTL("lock{1}",i)].y
        sprite.z = 3
        if @opponent
          @sprites[_INTL("lock{1}",i)].src_rect = Rect.new(0,0,94,94)
          if i == @index
            @sprites["select"] = IconSprite.new(sprite.x,sprite.y,@viewport)
            @sprites["select"].setBitmap("Graphics/Pictures/Stadium/marker")
            @sprites["select"].z = 4
          else
            sprite.tone = Tone.new(-60,-60,-60,140)
          end
        else
          @sprites[_INTL("lock{1}",i)].visible = false
          sprite.tone = Tone.new(-60,-60,-60,140)
        end
      end
    end

    if @rows.length == 2
      @sprites["row1"].y -= 300
      @sprites["row2"].y += 300
      @sprites["title"].y -= 300
      @sprites["subtitle"].y += 300
      for i in 0...@trainers.length
        if i >= @rows[0]
          @sprites[_INTL("lock{1}",i)].y += 300
        else
          @sprites[_INTL("lock{1}",i)].y -= 300
        end
        if i <= @index
          @sprites[_INTL("trainer{1}",i)].y = @sprites[_INTL("lock{1}",i)].y
        end
        if i == @index && @sprites["select"] && @sprites[_INTL("lock{1}",i)]
          @sprites["select"].y = @sprites[_INTL("lock{1}",i)].y
        end
      end
    else
      @sprites["row1"].y -= 300
      @sprites["title"].y += 300
      @sprites["subtitle"].y += 300
      for i in 0...@trainers.length
        @sprites[_INTL("lock{1}",i)].y -= 300
        if i <= @index
          @sprites[_INTL("trainer{1}",i)].y -= 300
        end
        if @opponent && i == @index
          @sprites["select"].y -= 300
        end
      end
    end

    if @opponent
      type = @opponent[0]
      name = @opponent[1]

      trainer = pbLoadTrainer(type,name,0)
      party = trainer.party

      @sprites["player"] = IconSprite.new(44+128,44+96,@viewport)
      @sprites["player"].setBitmap("Graphics/Pictures/Stadium/team_player")
      @sprites["player"].z = 2

      player_type = PBParty.getTrainerType(getPartyActive(0))
      offset = pbStadiumTrainerOffset(player_type)
      @sprites["player_img"] = IconSprite.new(60+128,52+96,@viewport)
      @sprites["player_img"].setBitmap(
        sprintf("Graphics/Trainers/%s",player_type.to_s))
      @sprites["player_img"].z = 3
      @sprites["player_img"].src_rect = Rect.new(
        @sprites["player_img"].bitmap.width/2 - 47, 0, 94, 94)
      @sprites["player_img"].src_rect.x -= offset[0]
      @sprites["player_img"].src_rect.y -= offset[1]

      @sprites["opponent"] = IconSprite.new(44+128,196+96,@viewport)
      @sprites["opponent"].setBitmap("Graphics/Pictures/Stadium/team_opponent")
      @sprites["opponent"].z = 2

      @sprites["opponent_img"] = IconSprite.new(358+128,246+96,@viewport)
      @sprites["opponent_img"].setBitmap(
        sprintf("Graphics/Trainers/%s",type.to_s))
      @sprites["opponent_img"].z = 3
      @sprites["opponent_img"].src_rect = Rect.new(
        @sprites["opponent_img"].bitmap.width/2 - 47, 0, 94, 94)
      offset = pbStadiumTrainerOffset(type)
      @sprites["opponent_img"].src_rect.x -= offset[0]
      @sprites["opponent_img"].src_rect.y -= offset[1]

      @sprites["vs"] = IconSprite.new(206+128,160+96,@viewport)
      @sprites["vs"].setBitmap("Graphics/Pictures/Stadium/stadium_vs")
      @sprites["vs"].z = 6
      @sprites["vs"].opacity = 0

      typename = GameData::TrainerType.get(type).name
      if typename.length > 11 && typename.include?(" ")
        typename = typename[(typename.index(" ")+1)..typename.length]
      end

      # Drawing cup name and battle number
      pbSetSmallFont(@sprites["player"].bitmap)
      pbDrawTextPositions(@sprites["player"].bitmap,
        [["Trainer",16,104,0,Color.new(250,250,250),Color.new(40,40,40),1],
         [PBParty.getName(getPartyActive(0)).upcase,14,126,0,Color.new(250,250,250),Color.new(40,40,40),1]])
      pbSetSmallFont(@sprites["opponent"].bitmap)
      pbDrawTextPositions(@sprites["opponent"].bitmap,
        [[typename,312,4,0,Color.new(250,250,250),Color.new(40,40,40),1],
         [name.upcase,312,24,0,Color.new(250,250,250),Color.new(40,40,40),1]])

      x_coords = [308,408,508,308,408,508]
      y_coords = [148,148,148,220,220,220]

      top_sprites = ["player", "player_img"]
      bottom_sprites = ["opponent", "opponent_img"]
      blue_sprites = ["player", "opponent"]

      
      playerparty = []
      getAllPartyPokemon(getPartyActive(0)).each do |pkmn|
        playerparty.push(pkmn)
      end
      while playerparty.length < 6
        playerparty.push(false)
      end

      for i in 0...6
        # Player party
        @sprites[_INTL("plock{1}",i)] = IconSprite.new(358,246,@viewport)
        @sprites[_INTL("plock{1}",i)].setBitmap("Graphics/Pictures/Stadium/team_lock")
        @sprites[_INTL("plock{1}",i)].z = 5
        @sprites[_INTL("plock{1}",i)].src_rect = Rect.new(0, 0, 90, 64)
        @sprites[_INTL("plock{1}",i)].x = x_coords[i] - 12
        @sprites[_INTL("plock{1}",i)].y = y_coords[i]
        if playerparty[i]
          @sprites[_INTL("ppokemon{1}",i)] =
            PokemonIconSprite.new(playerparty[i],@viewport)
          @sprites[_INTL("ppokemon{1}",i)].z = 4
          @sprites[_INTL("ppokemon{1}",i)].x = x_coords[i]
          @sprites[_INTL("ppokemon{1}",i)].y = y_coords[i]
          top_sprites.push(_INTL("ppokemon{1}",i))
        end

        # Opponent party
        @sprites[_INTL("olock{1}",i)] = IconSprite.new(358,246,@viewport)
        @sprites[_INTL("olock{1}",i)].setBitmap("Graphics/Pictures/Stadium/team_lock")
        @sprites[_INTL("olock{1}",i)].z = 5
        @sprites[_INTL("olock{1}",i)].src_rect = Rect.new(0, 0, 90, 64)
        @sprites[_INTL("olock{1}",i)].x = x_coords[i] - 126
        @sprites[_INTL("olock{1}",i)].y = y_coords[i] + 152
        if party.length > i
          @sprites[_INTL("opokemon{1}",i)] =
            PokemonIconSprite.new(party[i],@viewport)
          @sprites[_INTL("opokemon{1}",i)].z = 4
          @sprites[_INTL("opokemon{1}",i)].x = x_coords[i] - 114
          @sprites[_INTL("opokemon{1}",i)].y = y_coords[i] + 152
          bottom_sprites.push(_INTL("opokemon{1}",i))
        end
        top_sprites.push(_INTL("plock{1}",i))
        bottom_sprites.push(_INTL("olock{1}",i))
        blue_sprites.push(_INTL("plock{1}",i))
        blue_sprites.push(_INTL("olock{1}",i))
      end

      for s in top_sprites
        @sprites[s].y -= 300
      end

      for s in bottom_sprites
        @sprites[s].y += 300
      end

      @top_sprites = top_sprites
      @bottom_sprites = bottom_sprites
      @team_blue_sprites = blue_sprites
      @playerparty = playerparty
      @opponentparty = party
    else
      @sprites["victory"] = IconSprite.new(
        0,Graphics.height/2-40,@viewport)
      @sprites["victory"].setBitmap("Graphics/Pictures/Stadium/victory")
      @sprites["victory"].opacity = 0
      @sprites["victory"].z = 9
    end
  end

  def update
    Graphics.update
    @viewport.update
    Input.update
    pbUpdateSpriteHash(@sprites)
    @sprites["bg"].ox -= 16
    @sprites["bg"].ox = 0 if @sprites["bg"].ox <= -512
  end

  def updateSelect
    if @sprites["select"].opacity % 2 == 0
      @sprites["select"].opacity += 8
      @sprites["select"].opacity += 1 if @sprites["select"].opacity > 240
    else
      @sprites["select"].opacity -= 8
      @sprites["select"].opacity -= 1 if @sprites["select"].opacity < 100
    end
  end

  def start
    pbBGMPlay("Stadium Loop")
    while @sprites["bg"].opacity < 255
      self.update
      @sprites["bg"].opacity += 4
    end
  end

  def getBlueSprites
    blue_sprites = ["row1","title","subtitle"]
    blue_sprites.push("row2") if @rows.length >= 2
    for i in 0...@trainers.length
      blue_sprites.push(_INTL("lock{1}",i))
    end
    return blue_sprites
  end

  def showTrainers
    120.times do
      self.update
    end

    pbSEPlay("Stadium Versus")

    15.times do
      self.update
      self.rowsAppearFrame
    end

    pbSEPlay("Blow4")

    blue_sprites = self.getBlueSprites()

    i = 0
    while i < (132 + (@index * 6))
      self.update
      self.updateSelect

      if i > 6
        for j in 0..@index
          if (i-6) > j*6
            @sprites[_INTL("lock{1}",j)].src_rect.y += 12
            @sprites[_INTL("lock{1}",j)].src_rect.height -= 12
          end
        end
      end

      if i < 8
        for s in blue_sprites
          @sprites[s].tone.red += 12
          @sprites[s].tone.green += 12
          @sprites[s].tone.blue += 24
        end
      elsif i < 16
        for s in blue_sprites
          @sprites[s].tone.red -= 12
          @sprites[s].tone.green -= 12
          @sprites[s].tone.blue -= 24
        end
      end

      i+=1
    end

    pbSEPlay("Wind1")

    32.times do
      self.update
      self.updateSelect
      self.rowsDisappearFrame
    end
  end

  def showVictory
    150.times do
      self.update
    end

    15.times do
      self.update
      self.rowsAppearFrame
    end

    pbSEPlay("Blow4")

    blue_sprites = self.getBlueSprites()

    speed = 111
    i = 0
    done = false
    while !done
      self.update

      if i >= speed
        for j in 0..@index
          if (i-speed) == j*speed/2
            pbSEPlay("PRSFX- Feint2",120,80+((j*80)/@index))
            @sprites[_INTL("lock{1}",j)].visible = true
            if j==@index
              done = true
            end
          end
        end
      end

      if i < 8
        for s in blue_sprites
          @sprites[s].tone.red += 12
          @sprites[s].tone.green += 12
          @sprites[s].tone.blue += 24
        end
      elsif i < 16
        for s in blue_sprites
          @sprites[s].tone.red -= 12
          @sprites[s].tone.green -= 12
          @sprites[s].tone.blue -= 24
        end
      end

      i+=1
    end

    (((@index % 2 == 0) ? (speed*1.5) : speed).round).times do
      self.update
    end

    pbMEPlay("Slots big win", 100)

    180.times do
      self.update
      @sprites["victory"].opacity += 12
    end

    pbSEPlay("Wind1")

    32.times do
      self.update
      self.rowsDisappearFrame
      @sprites["victory"].opacity -= 16
    end
  end

  def showTeam
    15.times do
      self.update
      for s in @top_sprites
        @sprites[s].y += 20
      end
      for s in @bottom_sprites
        @sprites[s].y -= 20
      end
    end

    pbSEPlay("Blow4")

    played_se = false
    i = 0
    while i < 160
      self.update

      if i > 6
        for j in 0...6
          if (i-6) > j*6
            if @playerparty[j]
              @sprites[_INTL("plock{1}",j)].src_rect.y += 12
              @sprites[_INTL("plock{1}",j)].src_rect.height -= 12
            end
            if @opponentparty.length > j
              @sprites[_INTL("olock{1}",j)].src_rect.y += 12
              @sprites[_INTL("olock{1}",j)].src_rect.height -= 12
            end
          end
        end
      end

      if i < 8
        for s in @team_blue_sprites
          @sprites[s].tone.red += 12
          @sprites[s].tone.green += 12
          @sprites[s].tone.blue += 24
        end
      elsif i < 16
        for s in @team_blue_sprites
          @sprites[s].tone.red -= 12
          @sprites[s].tone.green -= 12
          @sprites[s].tone.blue -= 24
        end
      end

      if i > 10 + (@playerparty.length * 6) && i > 10 + (@opponentparty.length * 6) && i < 80
        pbSEPlay("Harden",160) if !played_se
        played_se = true
        @sprites["vs"].opacity += 16
      end

      if i > 150
        @sprites["vs"].opacity -= 16
      end

      i+=1
    end

    pbSEPlay("Wind1")

    32.times do
      self.update

      @sprites["vs"].opacity -= 16

      for s in @top_sprites
        @sprites[s].x -= 24
      end
      for s in @bottom_sprites
        @sprites[s].x += 24
      end
    end
  end

  def rowsAppearFrame
    if @rows.length == 2
      @sprites["row1"].y += 20
      @sprites["row2"].y -= 20
      @sprites["title"].y += 20
      @sprites["subtitle"].y -= 20
      for i in 0...@trainers.length
        if i >= @rows[0]
          @sprites[_INTL("lock{1}",i)].y -= 20
        else
          @sprites[_INTL("lock{1}",i)].y += 20
        end
        if i <= @index
          @sprites[_INTL("trainer{1}",i)].y = @sprites[_INTL("lock{1}",i)].y
        end
        if @opponent && i == @index
          @sprites["select"].y = @sprites[_INTL("lock{1}",i)].y
        end
      end
    else
      @sprites["row1"].y += 20
      @sprites["title"].y -= 20
      @sprites["subtitle"].y -= 20
      for i in 0...@trainers.length
        @sprites[_INTL("lock{1}",i)].y += 20
        if i <= @index
          @sprites[_INTL("trainer{1}",i)].y += 20
        end
        if @opponent && i == @index
          @sprites["select"].y += 20
        end
      end
    end
  end

  def rowsDisappearFrame
    @sprites["row1"].x += 24
    @sprites["title"].x -= 24
    @sprites["subtitle"].x += 24
    if @rows.length == 2
      @sprites["row2"].x -= 24
      for i in 0...@trainers.length
        if i >= @rows[0]
          @sprites[_INTL("lock{1}",i)].x -= 24
        else
          @sprites[_INTL("lock{1}",i)].x += 24
        end
        if i <= @index
          @sprites[_INTL("trainer{1}",i)].x = @sprites[_INTL("lock{1}",i)].x
        end
        if @opponent && i == @index
          @sprites["select"].x = @sprites[_INTL("lock{1}",i)].x
        end
      end
    else
      for i in 0...@trainers.length
        @sprites[_INTL("lock{1}",i)].x += 24
        if i <= @index
          @sprites[_INTL("trainer{1}",i)].x += 24
        end
        if @opponent && i == @index
          @sprites["select"].x += 24
        end
      end
    end
  end

  def end
    while @sprites["bg"].opacity > 0
      self.update
      @sprites["bg"].opacity -= 4
    end
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

end

def pbStadiumBattle(cup,index=0)
  transition = StadiumTransition.new(cup,index)
  transition.start
  transition.showTrainers
  transition.showTeam
  transition.end
  transition.dispose
end

def pbStadiumFinish(cup)
  transition = StadiumTransition.new(cup)
  transition.start
  transition.showVictory
  transition.end
  transition.dispose
end

def pbStadiumTrainerOffset(type)

  case type
  when :BLACKBELT, :CRUSHGIRL
    return [  0,-10]
  when :JANITOR
    return [ -6,-10]
  when :NURSERYAID, :BUGCATCHER, :TAMER
    return [  0,-14]
  when :YOUNGSTER, :SCHOOLBOY, :SCHOOLGIRL,
       :LIBRARIAN, :DOCTOR, :ROUGHNECK,
       :CHANNELER, :ENGINEER, :BURGLAR,
       :JANUS
    return [  0,-28]
  when :RUINMANIAC
    return [ 10,-24]
  when :PRESCHOOLER_M, :PRESCHOOLER_F,
       :SWIMMER_M
    return [  0,-44]
  when :TWINS
    return [  4,-44]
  when :PKMNRANGER_M, :MINER, :GUITARIST,
       :PKMNFAN_M, :MAID, :RIVAL, :FORETELLER
    return [  8,  0]
  when :GAMBLER
    return [ -8,  0]
  when :OLDPROTAGONIST
    return [  0, -8]
  when :BACKPACKER_F, :CYCLIST_F
    return [-14,  0]
  when :FISHERMAN
    return [-36, -6]
  when :ACETRAINER_M
    return [  0,  4]
  when :AMETHYST
    return [ -4,-14]
  end

  return [0,0]
end

def pbStadiumMenu

  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  sprites = {}

  ret = 0

  cups = pbStadiumCups
  cup_names = []
  cups[0].each do |c|
    cup_names.push(_INTL("{1} Cup", c))
  end

  sprites["searchtitle"]=Window_AdvancedTextPokemon.newWithSize("",2,80,Graphics.width,64,viewport)
  sprites["searchtitle"].windowskin=nil
  sprites["searchtitle"].baseColor=Color.new(248,248,248)
  sprites["searchtitle"].shadowColor=Color.new(0,0,0)
  sprites["searchtitle"].text=_ISPRINTF("<outln><ac>Pokémon Stadium</ac></outln>")
  sprites["searchlist"]=Window_ComplexCommandPokemon.newEmpty(58,128,322,352,viewport)
  sprites["searchlist"].baseColor=Color.new(248,248,248)
  sprites["searchlist"].shadowColor=Color.new(40,44,48)
  sprites["searchlist"].commands=[
    "Select a Cup",
    cup_names + ["Cancel"]
  ]
  sprites["auxlist"]=Window_UnformattedTextPokemon.newWithSize("",382,128,328,194,viewport)
  sprites["auxlist"].baseColor=Color.new(248,248,248)
  sprites["auxlist"].shadowColor=Color.new(40,44,48)
  sprites["messagebox"]=Window_UnformattedTextPokemon.newWithSize("",382,322,328,158,viewport)
  sprites["messagebox"].baseColor=Color.new(248,248,248)
  sprites["messagebox"].shadowColor=Color.new(40,44,48)
  sprites["messagebox"].letterbyletter=false

  sprites["difficulty"]=IconSprite.new(512,438,viewport)
  sprites["difficulty"].setBitmap("Graphics/Pictures/Stadium/difficulty")
  sprites["difficulty"].src_rect = Rect.new(0,0,120,22)
  sprites["difficulty"].z=999

  for i in 0...10
    sprites[_INTL("complete{1}",i)]=IconSprite.new(204+128,50+96+32*i,viewport)
    sprites[_INTL("complete{1}",i)].setBitmap("Graphics/Pictures/Quests/icon_complete")
    sprites[_INTL("complete{1}",i)].z=999
    sprites[_INTL("complete{1}",i)].visible=false
  end

  sprites["searchlist"].index=1
  searchlist=sprites["searchlist"]
  sprites["messagebox"].visible=true
  sprites["auxlist"].visible=true
  sprites["searchlist"].visible=true
  sprites["searchtitle"].visible=true
  pbRefreshStadiumMenu(sprites,cups)
  pbFadeInAndShow(sprites)
  pbActivateWindow(sprites,"searchlist"){
     loop do
       Graphics.update
       Input.update
       oldindex=searchlist.index
       pbUpdateSpriteHash(sprites)
       if searchlist.index==0
         if oldindex == 1
            searchlist.index = cups[0].length + 1
         else
           searchlist.index = 1
         end
       end
       if searchlist.index == 1
         searchlist.top_row = 0
         searchlist.index = 1
       end
       if searchlist.index!=oldindex
         pbRefreshStadiumMenu(sprites,cups)
       end
       if Input.trigger?(Input::USE)
         pbPlayDecisionSE()
         if searchlist.index==cups[0].length + 1
           break
         else
           index = searchlist.index - 1
           Kernel.pbMessage(_INTL(
             "Do you want to attend the {1}?\\ch[1,2,Yes,No]",
             cups[0][index]))
           if $game_variables[1]==0
             ret = [
               cups[0][index],
               cups[1][index],
               cups[2][index],
               cups[3][index],
               0
             ]
             break
           end
         end
       elsif Input.trigger?(Input::BACK)
         pbPlayCancelSE()
         break
       end
     end
  }
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose
  Input.update
  return ret

end

def pbRefreshStadiumMenu(sprites,cups)
  searchlist=sprites["searchlist"]
  messagebox=sprites["messagebox"]
  auxlist=sprites["auxlist"]
  difficulty=sprites["difficulty"]
  names=cups[0]
  helptexts=cups[1]
  index = searchlist.index-1
  stats=cups[2][index]
  if helptexts[index]
    num_battles = cups[3][index].length
    auxlist.text = names[index].upcase + " CUP\n" + helptexts[index]
    messagebox.text = sprintf(
      "Max Level: %d\nBattles: %d\nReward: %s SP\nDifficulty: ",
      stats[0], num_battles, pbStadiumPointsCore(stats[1], num_battles).to_s_formatted)
    difficulty.src_rect.width = 20 * stats[1]
  else
    auxlist.text=""
    messagebox.text=""
    difficulty.src_rect.width=0
  end

  # Draw checkmarks for completed cups
  startindex=searchlist.top_item
  for i in 0...10
    sprite=sprites[_INTL("complete{1}",i)]
    index = i + startindex
    if index != 0
      if names[index - 1]
        if pbStadiumHasWonCup(names[index - 1])
          sprite.visible = true
          next
        end
      end
    end
    sprite.visible = false
  end

end

def pbStadiumHasWonCup(name)
  if name.is_a?(Array)
    name.each do |n|
      return false if !pbStadiumHasWonCup(n)
    end
    return true
  else
    if $game_variables[STADIUM_WON_CUPS].is_a?(Array)
      for cup in $game_variables[STADIUM_WON_CUPS]
        return true if cup == name
      end
    end
    return false
  end
end

def pbStadiumCup
  return $game_variables[STADIUM_CUP]
end

def pbStadiumCupIndex
  cup = pbStadiumCup
  return cup[cup.length - 1]
end

def pbStadiumCupNextIndex
  cup = pbStadiumCup
  cup[cup.length - 1]+=1
end

def pbStadiumCupIsDone
  cup = pbStadiumCup
  cup[cup.length - 1]>=cup[3].length
end

def pbStadiumCupTrainer
  cup = pbStadiumCup
  index = pbStadiumCupIndex
  setBattleRule("fixedlevel")
  setBattleRule("noexp")
  setBattleRule("nomoney")
  setBattleRule("levelsync", cup[2][0])
  setBattleRule("noItems")
  setBattleRule("canLose")
  setBattleRule("fullPlayer")
  setBattleRule("showParty")
  setBattleRule("noPlayerLevelUpdate")
  trainer_data = cup[3][index]
  return TrainerBattle.start(
    trainer_data[0],
    trainer_data[1],
    trainer_data[2] || 0
  )
end

def pbStadiumPointsCore(difficulty, battles)
  points = (8 * (2**(difficulty-1))) * 10
  points = points * 3 / 4 if battles <= 2
  points = points * 3 / 2 if battles >= 6
  return points
end

def pbStadiumPoints(cup)
  return pbStadiumPointsCore(cup[2][1], cup[3].length)
end

def pbStadiumWin(cup)

  if !$game_variables[STADIUM_WON_CUPS].is_a?(Array)
    $game_variables[STADIUM_WON_CUPS] = []
  end

  if !$game_variables[STADIUM_WON_CUPS].include?(cup[0])
    $game_variables[STADIUM_WON_CUPS].push(cup[0])
    points = pbStadiumPoints(cup)
    $game_variables[STADIUM_POINTS] += points
    return points
  end

  return false

end

def pbStadiumSetup

  events = $game_map.events.values
  cup = pbStadiumCup
  index = pbStadiumCupIndex
  trainer = cup[3][index][0]
  difficulty = cup[2][1]
  chance = 9 - difficulty
  chance -= 1 if cup[3].length - 2 == index
  chance -= 2 if cup[3].length - 1 == index
  chance = 2 if chance < 2

  spectators = [
    "NPC 02", "NPC 04", "NPC 05", "NPC 06", "NPC 07",
    "NPC 33", "NPC 35", "NPC 36", "NPC 37"#,
    #"trchar005", "trchar006", "trchar007", "trchar008",
    #"trchar012", "trchar013", "trchar011", "trchar019",
    #"trchar020", "trchar022", "trchar030", "trchar031",
    #"trchar032", "trchar036", "trchar037", "trchar048",
    #"trchar050", "trchar051", "trchar061"
  ]

  rare_spectators = [
    "NPC 08", "NPC 10", "NPC 11"#,
    #"trchar015", "trchar016", "trchar045", "trchar047",
    #"trchar052", "trchar053"
  ]

  for event in events

    if event.id == 1 || event.id == 3 # Player Sprites
      event.character_name = $game_player.character_name
    elsif event.id == 2 || event.id == 4 # Opponent Sprites
      event.character_name = sprintf("trainer_%s",trainer.to_s)
    elsif event.name == "Spectator"
      if rand(chance)==0
        if rand(4)==0
          event.character_name = rare_spectators[rand(rare_spectators.length)]
        else
          event.character_name = spectators[rand(spectators.length)]
        end
      else
        event.character_name = ""
      end
    end
  end

end

def pbStadiumRuleset
  cup = pbStadiumCup
  maxpkmn = cup[2][1]
  maxlvl = cup[2][0]
  $game_variables[LEAGUE_MAX_PKMN] = maxpkmn
  $game_variables[LEAGUE_MAX_LVL] = maxlvl
end

def pbDisplayStadiumPointsWindow(msgwindow,goldwindow)
  coinString=$game_variables[STADIUM_POINTS].to_s
  coinwindow=Window_AdvancedTextPokemon.new(_INTL("Points:\n<ar>{1}</ar>",coinString))
  coinwindow.setSkin("Graphics/Windowskins/goldskin")
  coinwindow.resizeToFit(coinwindow.text,Graphics.width)
  coinwindow.width=160 if coinwindow.width<=160
  if msgwindow.y==0
    coinwindow.y=(goldwindow) ? goldwindow.y-coinwindow.height : Graphics.height-coinwindow.height
  else
    coinwindow.y=(goldwindow) ? goldwindow.height : 0
  end
  coinwindow.viewport=msgwindow.viewport
  coinwindow.z=msgwindow.z
  return coinwindow
end

class Window_ComplexCommandPokemon < Window_DrawableCommand
  attr_reader :commands

  def initialize(commands,width=nil)
    @starting=true
    @commands=commands
    dims=[]
    getAutoDims(commands,dims,width)
    super(0,0,dims[0],dims[1])
    @selarrow=AnimatedBitmap.new("Graphics/Pictures/selarrow_white")
    @starting=false
  end

  def self.newEmpty(x,y,width,height,viewport=nil)
    ret=self.new([],width)
    ret.x=x
    ret.y=y
    ret.width=width
    ret.height=height
    ret.viewport=viewport
    return ret
  end

  def index=(value)
    super
    refresh if !@starting
  end

  def indexToCommand(index)
    curindex=0
    i=0; loop do break unless i<@commands.length
      return [i/2,-1] if index==curindex
      curindex+=1
      return [i/2,index-curindex] if index-curindex<commands[i+1].length
      curindex+=commands[i+1].length
      i+=2
    end
    return [-1,-1]
  end

  def getText(array,index)
    cmd=indexToCommand(index)
    return "" if cmd[0]==-1
    return array[cmd[0]*2] if cmd[1]<0
    return array[cmd[0]*2+1][cmd[1]]
  end

  def commands=(value)
    @commands=value
    @item_max=commands.length  
    self.index=self.index
  end

  def width=(value)
    super
    if !@starting
      self.index=self.index
    end
  end

  def height=(value)
    super
    if !@starting
      self.index=self.index
    end
  end

  def resizeToFit(commands)
    dims=[]
    getAutoDims(commands,dims)
    self.width=dims[0]
    self.height=dims[1]
  end

  def itemCount
    mx=0
    i=0; loop do break unless i<@commands.length
      mx+=1+@commands[i+1].length
      i+=2
    end
    return mx
  end

  def drawItem(index,count,rect)
    command=indexToCommand(index)
    return if command[0]<0
    text=getText(@commands,index)
    if command[1]<0
      pbDrawShadowText(self.contents,rect.x+32,rect.y,rect.width,rect.height,text,
         self.baseColor,self.shadowColor)
    else
      rect=drawCursor(index,rect)
      pbDrawShadowText(self.contents,rect.x,rect.y,rect.width,rect.height,text,
         self.baseColor,self.shadowColor)
    end
  end
end

