class Battle
  def pbCheckMenu
    return @scene.pbCheckMenu
  end
end

class Battle::Scene
  def pbCheckMenu
    pbShowWindow(BLANK)
    @sprites["check_menu"] = CheckMenu.new(@viewport, @battle)
    loop do
      pbUpdate
      @sprites["check_menu"].update
      break if Input.trigger?(Input::BACK)
    end
    sprites["check_menu"].dispose
    sprites["check_menu"] = nil
    pbShowWindow(COMMAND_BOX)
  end
end

class Battle::Scene::Outer

  attr_reader :viewport

  BLANK       = 0
  MESSAGE_BOX = 1
  COMMAND_BOX = 2
  FIGHT_BOX   = 3
  TARGET_BOX  = 4

  def initialize(sprites,parent,battle)
    @sprites = sprites
    @parent = parent
    @battle = battle
  end

  def pbInitMenuSprites
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = @parent.z
    # Create message box graphic
    messageBox = pbAddSprite("messageBox",0,576-96,
      "Graphics/UI/Battle/overlay_message",@viewport)
    messageBox.z = 195
    # Create message window (displays the message)
    msgWindow = Window_AdvancedTextPokemon.newWithSize("",
      16+128,576-100+2,512-32,96,@viewport)
    msgWindow.z              = 200
    msgWindow.opacity        = 0
    msgWindow.baseColor      = Color.new(248,248,248)
    msgWindow.shadowColor    = Color.new(33,29,29)
    msgWindow.letterbyletter = true
    @sprites["messageWindow"] = msgWindow
    xPos = [390,544,390,544,390,544]
    yPos = [404,404,456,456,508,508]
    for i in 0...6
      @sprites[_INTL("command_{1}",i)] = OuterCommandSprite.new(xPos[i] + 128,yPos[i] + 30,@viewport,@sprites["commandWindow"],i)
      @sprites[_INTL("command_{1}",i)].z = 1
    end
    @sprites["command_6"] = QuickItemSprite.new(710,376,@viewport,@sprites["commandWindow"],6)
    @sprites["command_6"].z = 1
    @sprites["command_pkmn"] = PokemonIconSprite.new(nil, @viewport)
    @sprites["command_pkmn"].active = true
    @sprites["command_pkmn"].x = 522
    @sprites["command_pkmn"].y = 340
    @sprites["command_pkmn"].z = 2
    @sprites["command_turn"] = Sprite.new(@viewport)
    @sprites["command_turn"].bitmap = Bitmap.new(128, 32)
    @sprites["command_turn"].x = 580
    @sprites["command_turn"].y = 370
    @sprites["command_turn"].z = 3
    pbSetSystemFont(@sprites["command_turn"].bitmap)
    pbDrawTextPositions(@sprites["command_turn"].bitmap, [[_INTL("'s Turn"),2,2,0,msgWindow.baseColor,msgWindow.shadowColor,true]])
    @sprites["moveInfo"] = OuterMoveInfo.new(@viewport,@sprites["fightWindow"])
    @sprites["moveInfo"].z = 1
    # Create targeting window
    @sprites["targetWindow"] = Battle::Scene::TargetMenu.new(@viewport, 200, @battle.sideSizes)
    @sprites["targetWindow"].z = 1
    for i in 0...6
      @sprites[_INTL("switch_{1}", i)] = OuterSwitchBox.new(@viewport, i)
      @sprites[_INTL("switch_{1}", i)].z = 3
      @sprites[_INTL("switch_{1}", i)].visible = false
    end
    #@sprites["lineupPlayer"] = OuterTeamLineup.new(@viewport, @battle.pbParty(0), true, true)
    #@sprites["lineupPlayer"].z = 5
    #@sprites["lineupPlayer"].x = 0
    #@sprites["lineupOpponent"] = OuterTeamLineup.new(@viewport, @battle.pbParty(1), false, @battle.showParty)
    #@sprites["lineupOpponent"].z = 5
    #@sprites["lineupOpponent"].x = Graphics.width / 2 + 8
    #@sprites["vs"] = IconSprite.new(0, 0, @viewport)
    #@sprites["vs"].setBitmap("Graphics/UI/Battle/vs")
    #@sprites["vs"].ox = @sprites["vs"].bitmap.width / 2
    #@sprites["vs"].x = Graphics.width / 2
    #@sprites["vs"].y = 20
  end

  def active_pokemon=(p)
    @sprites["command_pkmn"].pokemon = p
  end

  def pbAddSprite(id,x,y,filename,viewport)
    sprite = IconSprite.new(x,y,viewport)
    if filename
      sprite.setBitmap(filename) rescue nil
    end
    @sprites[id] = sprite
    return sprite
  end

  def pbInitInfoSprites
    return
    boxCount = 0
    for i in 0...6
      boxCount += 1 if @sprites["dataBox_#{i}"]
    end
    for i in 0...4
      dataBox = @sprites["dataBox_#{i}"]
      if dataBox
        @sprites[_INTL("info_{1}",i)] = OuterDataBox.new(0,0,@viewport,dataBox,i,boxCount)
        @sprites[_INTL("info_{1}",i)].z = 1
      end
    end
  end

  def pbShowWindow(windowType)
    for i in 0...7
      @sprites[_INTL("command_{1}",i)].visible = (windowType==COMMAND_BOX)
    end
    @sprites["command_pkmn"].visible = (windowType==COMMAND_BOX)
    @sprites["command_turn"].visible = (windowType==COMMAND_BOX)
    @sprites["moveInfo"].visible = (windowType==FIGHT_BOX)
  end

  def update(cw=nil, mustRefresh=false)
    for i in 0...7
      @sprites[_INTL("command_{1}",i)].update
      @sprites["command_pkmn"].update
      @sprites["command_turn"].update
    end
    for i in 0...6
      @sprites[_INTL("switch_{1}", i)].update
    end
    #for i in 0...4
    #  @sprites[_INTL("info_{1}",i)].update(mustRefresh) if @sprites[_INTL("info_{1}",i)]
    #end
    @sprites["moveInfo"].update
    #@battle.allBattlers.each do |b|
    #  if b.index % 2 == 0
    #    @sprites["lineupPlayer"].setShown(b.pokemonIndex) if @sprites["dataBox_#{b.index}"].visible
    #  else
    #    @sprites["lineupOpponent"].setShown(b.pokemonIndex) if @sprites["dataBox_#{b.index}"].visible
    #  end
    #end
    #@sprites["lineupPlayer"].update if !([0, 2, 4].any? { |i| @sprites["dataBox_#{i}"]&.animatingHP })
    #@sprites["lineupOpponent"].update if !([1, 3, 5].any? { |i| @sprites["dataBox_#{i}"]&.animatingHP })
  end

  def dispose
    @viewport.dispose
  end

  def pbChooseSwitch(idxBattler, canCancel = false, mode = 0)
    partyPos = @battle.pbPartyOrder(idxBattler)
    partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    pokemon = @battle.pbPlayerDisplayParty(idxBattler)
    if mode == 1 || mode == 2 # Send to boxes or see summaries
      pokemon = $player.party
    elsif mode == 4 # Send from inactive to boxes
      pokemon = $player.inactive_party
      mode = 1
    elsif mode == 3 # Use item
      pokemon = @battle.pbParty(idxBattler)
    end

    @battle.scene.pbShowWindow(BLANK)
    for i in 0...6
      @sprites[_INTL("switch_{1}", i)].party_length = pokemon.length
      @sprites[_INTL("switch_{1}", i)].visible = (i < pokemon.length)
      @sprites[_INTL("switch_{1}", i)].pokemon = pokemon[i]
      @sprites[_INTL("switch_{1}", i)].party_member = 0
      getActivePokemon(0).each do |p|
        if p == pokemon[i]
          @sprites[_INTL("switch_{1}", i)].party_member = getPartyActive(0)
          break
        end
      end
      getActivePokemon(1).each do |p|
        if p == pokemon[i]
          @sprites[_INTL("switch_{1}", i)].party_member = getPartyActive(1)
          break
        end
      end
      @sprites[_INTL("switch_{1}", i)].active = 0
    end
    selected_index = 0
    new_index = selected_index

    loop do
      @battle.scene.pbGraphicsUpdate
      @battle.scene.pbInputUpdate
      @battle.scene.pbFrameUpdate
      if Input.trigger?(Input::UP)
        new_index -= 1
        if new_index == -1 || new_index == 2
          new_index = ((new_index < 0) ? [pokemon.length, 3].min : pokemon.length) - 1
        end
      end
      if Input.trigger?(Input::DOWN)
        new_index += 1
        if new_index == pokemon.length || new_index == 3
          new_index = (new_index > 3) ? 3 : 0
        end
      end
      if Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
        if pokemon.length > 3
          new_index = (new_index + 3) % 6
          new_index = pokemon.length - 1 if new_index >= pokemon.length
        end
      end
      if new_index != selected_index
        pbPlayCursorSE
        selected_index = new_index
        for i in 0...6
          @sprites[_INTL("switch_{1}", i)].active = selected_index
        end
      end
      if Input.trigger?(Input::BACK) && canCancel
        pbPlayDecisionSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        idxPartyRet = -1
        if mode == 1 || mode == 2 || mode == 3
          idxPartyRet = selected_index
        else
          partyPos.each_with_index do |pos, i|
            next if pos != selected_index + partyStart
            idxPartyRet = i
            break
          end
        end
        if mode == 3
          break if yield idxPartyRet, @battle.scene
        else
          # Choose a command for the selected Pokémon
          cmdSwitch  = -1
          cmdBoxes   = -1
          cmdSummary = -1
          commands = []
          commands[cmdSwitch  = commands.length] = _INTL("Switch In") if mode == 0 && pokemon[selected_index].able?
          commands[cmdBoxes   = commands.length] = _INTL("Send to Boxes") if mode == 1
          commands[cmdSummary = commands.length] = _INTL("Summary")
          commands[commands.length]              = _INTL("Cancel")
          command = @battle.scene.pbShowCommands("", commands, commands.length, pokemon.length > 3 ? -420 : -350, 36)
          if (cmdSwitch >= 0 && command == cmdSwitch) ||   # Switch In
            (cmdBoxes >= 0 && command == cmdBoxes)        # Send to Boxes
            for i in 0...6
              @sprites[_INTL("switch_{1}", i)].visible = false
            end
            break if yield idxPartyRet, @battle.scene
            for i in 0...6
              @sprites[_INTL("switch_{1}", i)].visible = (i < pokemon.length)
            end
            @battle.scene.pbShowWindow(BLANK)
          elsif cmdSummary >= 0 && command == cmdSummary   # Summary
            pbSummary(pokemon, selected_index)
          end
        end
      end
    end

    for i in 0...6
      @sprites[_INTL("switch_{1}", i)].visible = false
    end

    @battle.scene.pbShowWindow(COMMAND_BOX)
  end

  def pbSummary(party, pkmnid)
    oldsprites = pbFadeOutAndHide(@sprites)
    scene = PokemonSummaryScene.new(true)
    screen = PokemonSummary.new(scene)
    screen.pbStartScreen(party, pkmnid)
    pbFadeInAndShow(@sprites, oldsprites)
  end

  def set_quick_pocket(pocket)
    if pocket == -1
      @sprites["command_6"].visible = false
      return false
    else
      @sprites["command_6"].set_pocket(pocket)
      if @sprites["command_6"].count == 0
        @sprites["command_6"].visible = false
        return false
      end
      return true
    end
  end

  def change_quick_item(offset)
    @sprites["command_6"].change_item(offset)
  end

  def get_quick_item
    return @sprites["command_6"].get_item
  end

end

class OuterMoveBox < IconSprite

  def initialize(viewport,parent,pos)
    @parent = parent
    @pos = pos
    @selected = false
    @timer = 0
    x = 558
    y = 414
    #x += 186 if @pos&1==1
    y += 48 * @pos # if @pos>1
    super(x,y,viewport)
    setBitmap("Graphics/UI/Battle/move_buttons")
    self.src_rect = Rect.new(0,0,224,80)
    self.ox = 112
    self.oy = 40
    @cursor = IconSprite.new(0, 0, viewport)
    @cursor.setBitmap("Graphics/UI/Battle/move_cursor")
    @cursor.x = self.x - 2
    @cursor.y = self.y + 4
    @cursor.z = self.z - 1
    @cursor.ox = 112
    @cursor.oy = 40
    @cursor.visible = false
    @overlay = Sprite.new(viewport)
    @overlay.bitmap = Bitmap.new(self.src_rect.width,self.src_rect.height)
    @overlay.x = self.x
    @overlay.y = self.y
    @overlay.z = self.z + 2
    @overlay.ox = 112
    @overlay.oy = 40
    @effectiveness_icon = IconSprite.new(0, 0, viewport)
    @effectiveness_icon.setBitmap("Graphics/UI/Battle/effectiveness_icons")
    @effectiveness_icon.x = self.x - 6
    @effectiveness_icon.y = self.y - 4
    @effectiveness_icon.z = self.z + 3
    @effectiveness_icon.src_rect = Rect.new(0, 0, 26, 26)
    @effectiveness_icon.opacity = 0
    @effectiveness_icon.ox = 112
    @effectiveness_icon.oy = 40
    @boost_icon = IconSprite.new(0, 0, viewport)
    @boost_icon.setBitmap("Graphics/UI/Battle/affinityboost_text_small")
    @boost_icon.x = self.x + 128
    @boost_icon.y = self.y - 4
    @boost_icon.z = self.z + 3
    @boost_icon.opacity = 0
    @boost_icon.ox = 112
    @boost_icon.oy = 40
    @icons_timer = 0
  end

  def refresh(move,selected=false)
    @selected = selected
    @overlay.bitmap.clear
    if !move
      self.src_rect.x = -224
      self.src_rect.y = -80
      self.visible = false
      return
    end
    self.visible = true
    @cursor.visible = @selected
    type_id = GameData::Type.get(move.type).icon_position
    self.src_rect.x = @selected ? 224 : 0
    self.src_rect.y = type_id * 80
    #moveNameBase = PokeBattle_SceneConstants::MESSAGE_BASE_COLOR
    base=Color.new(64,64,64)
    shadow=Color.new(176,176,176)
    @effectiveness = 0
    @can_affinity_boost = false
    if move.category != 2
      @parent.battler.eachOpposing do |target|
        bTypes = target.pbTypes(true)
        typeMod = Effectiveness.calculate(move.type, *bTypes)
        eff = 0
        if Effectiveness.super_effective?(typeMod)
          eff = 1
        elsif Effectiveness.ineffective?(typeMod)
          eff = -2
        elsif Effectiveness.resistant?(typeMod)
          eff = -1
        end
        @effectiveness = eff if eff > @effectiveness
      end
      @parent.battler.eachAlly do |partner|
        @can_affinity_boost = true if partner.pokemon.hasAffinity?(move.type)
      end
    end
    if @can_affinity_boost
      @can_affinity_boost = false
      @parent.battler.eachOpposing do |target|
        bTypes = target.pbTypes(true)
        typeMod = Effectiveness.calculate(move.type, *bTypes)
        if Effectiveness.normal?(typeMod) || Effectiveness.super_effective?(typeMod)
          @can_affinity_boost = true
        end
      end
    end
    textPos = [[move.name,126,20,2,base,shadow]]
    pbSetSmallFont(@overlay.bitmap)
    pbDrawTextPositions(@overlay.bitmap,textPos)
    pbSetSystemFont(@overlay.bitmap)
  end

  def update
    super
    if self.visible && @selected
      @timer += 1
      self.angle = Math.sin(@timer / 8.0) * 2
    else
      @timer = 0
      self.angle = 0
    end
    if self.visible
      if @effectiveness != 0
        if @icons_timer < 32
          @effectiveness_icon.opacity += 8
        elsif @icons_timer >= 48 && @icons_timer < 80
          @effectiveness_icon.opacity -= 8
        end
        @icons_timer += 1
        @icons_timer = 0 if @icons_timer >= 88
      else
        @effectiveness_icon.opacity = 0
      end
      if @can_affinity_boost
        if @icons_timer < 32
          @boost_icon.opacity += 8
        elsif @icons_timer >= 48 && @icons_timer < 80
          @boost_icon.opacity -= 8
        end
        @icons_timer += 1 if @effectiveness == 0
        @icons_timer = 0 if @icons_timer >= 88
      else
        @boost_icon.opacity = 0
      end
    else
      @effectiveness_icon.opacity = 0
      @boost_icon.opacity = 0
      @icons_timer = 0
    end
  end

  def opacity=(value)
    super(value)
    @overlay.opacity = value
    @cursor.opacity = value
  end

  def color=(value)
    super(value)
    @overlay.color = value
    @boost_icon.color = value
    @effectiveness_icon.color = value
    @cursor.color = value
  end

  def visible=(value)
    super(value)
    @overlay.visible = value
    @boost_icon.visible = value
    @effectiveness_icon.visible = value
    @cursor.visible = false if !value
  end

  def z=(value)
    super(value)
    @cursor.z = self.z - 1
    @overlay.z = self.z + 2
    @boost_icon.z = self.z + 3
    @effectiveness_icon.z = self.z + 3
  end

  def dispose
    @cursor.dispose
    @overlay.dispose
    @boost_icon.dispose
    @effectiveness_icon.dispose
    super
  end
end

class OuterTeamLineup < Sprite

  HP_BAR_WIDTH = 40
  HP_BAR_Y = 70

  def initialize(viewport, party, rightAlign = false, showAll = false)
    super(viewport)
    @viewport = viewport
    @party = party
    @hp = []
    @status = []
    @party.each do |pkmn|
      @hp.push(pkmn.hp)
      @status.push(pkmn.status)
    end
    @shown = [showAll] * 6
    @rightAlign = rightAlign
    @statusBitmap = AnimatedBitmap.new("Graphics/UI/Party/statuses_small")
    @hpcolors=[
       Color.new(14,152,22),Color.new(24,192,32),   # Green
       Color.new(202,138,0),Color.new(232,168,0),   # Orange
       Color.new(218,42,36),Color.new(248,72,56)    # Red
    ]
    initSprites
    self.bitmap = Bitmap.new(Graphics.width, Graphics.height / 4)
    self.refresh
  end

  def initSprites
    @sprites = {}
    @ball_sprites = []
    @poke_sprites = []
    for i in 0...@party.length
      ball_sprite = IconSprite.new(0, 0, @viewport)
      ball_sprite.setBitmap("Graphics/UI/Battle/icon_ball")
      ball_sprite.ox = ball_sprite.bitmap.width / 2
      ball_sprite.oy = ball_sprite.bitmap.height / 2
      @ball_sprites.push(ball_sprite)
      @sprites[_INTL("ball_{1}", i)] = ball_sprite
      poke_sprite = PokemonIconSprite.new(@party[i], @viewport)
      poke_sprite.setOffset(PictureOrigin::CENTER)
      poke_sprite.mirror = true if @rightAlign
      @poke_sprites.push(poke_sprite)
      @sprites[_INTL("poke_{1}", i)] = poke_sprite
    end
    self.x = self.x
    self.y = self.y
  end

  def setShown(idx)
    return if @shown[idx]
    @shown[idx] = true
    self.refresh
  end

  def refresh
    xPos = 24
    xPos += Graphics.width / 2 - 8 if @rightAlign
    xPos += @rightAlign ? -16 - 56 : 16
    for i in 0...@party.length
      next if !@party[i] || !@ball_sprites[i] || !@poke_sprites[i]
      pkmn = @party[i]
      @ball_sprites[i].visible = !@shown[i]
      @poke_sprites[i].visible = @shown[i]
      next if !@shown[i]
      self.bitmap.fill_rect(xPos - (HP_BAR_WIDTH + 4) / 2, HP_BAR_Y, HP_BAR_WIDTH + 4, 12, Color.new(0, 0, 0))
      self.bitmap.fill_rect(xPos - HP_BAR_WIDTH / 2, HP_BAR_Y + 2, HP_BAR_WIDTH, 8, Color.new(40, 40, 40))
      hpzone = 0
      hpzone = 1 if pkmn.hp <= (pkmn.totalhp / 2).floor
      hpzone = 2 if pkmn.hp <= (pkmn.totalhp / 4).floor
      hpfill = ((pkmn.hp * HP_BAR_WIDTH / pkmn.totalhp) / 2).floor
      hpfill = 1 if hpfill <= 0 && pkmn.hp > 0
      hpfill = HP_BAR_WIDTH / 2 if pkmn.hp >= pkmn.totalhp
      self.bitmap.fill_rect(xPos - HP_BAR_WIDTH / 2, HP_BAR_Y + 2, hpfill * 2, 8, @hpcolors[hpzone * 2])
      self.bitmap.fill_rect(xPos - HP_BAR_WIDTH / 2, HP_BAR_Y + 4, hpfill * 2, 4, @hpcolors[hpzone * 2 + 1])
      if pkmn.status == :NONE
        self.bitmap.fill_rect(xPos + 10, 52, 14, 14, Color.new(0, 0, 0, 0))
      else
        status_idx = GameData::Status.get(pkmn.status).icon_position
        self.bitmap.blt(xPos + 10, 52, @statusBitmap.bitmap, Rect.new(0, status_idx * 14, 14, 14))
      end
      @poke_sprites[i].tone = (pkmn.hp == 0) ? Tone.new(0, 0, 0, 255) : Tone.new(0, 0, 0, 0)
      xPos += @rightAlign ? -56 : 56
    end
  end

  def opacity=(value)
    super(value)
    @sprites.each do |key, sprite|
      sprite.opacity = value
    end
  end

  def color=(value)
    super(value)
    @sprites.each do |key, sprite|
      sprite.color = value
    end
  end

  def x=(value)
    super(value)
    xPos = value + 24
    xPos += Graphics.width / 2 - 8 if @rightAlign
    xPos += @rightAlign ? -16 - 56 : 16
    for i in 0...@party.length
      @ball_sprites[i].x = xPos
      @poke_sprites[i].x = xPos
      xPos += @rightAlign ? -56 : 56
    end
  end

  def y=(value)
    super(value)
    for i in 0...@party.length
      @ball_sprites[i].y = value + 46
      @poke_sprites[i].y = value + 42
    end
  end

  def z=(value)
    super(value)
    @sprites.each do |key, sprite|
      sprite.z = value - 1
    end
  end

  def update
    super
    mustRefresh = false
    for i in 0...@party.length
      next if !@party[i]
      if @party[i].hp != @hp[i]
        @hp[i] = @party[i].hp
        mustRefresh = true
      end
      if @party[i].status != @status[i]
        @status[i] = @party[i].status
        mustRefresh = true
      end
    end
    self.refresh if mustRefresh
  end

  def dispose
    super
    @statusBitmap.dispose
    pbDisposeSpriteHash(@sprites)
  end

end

class OuterMoveInfo < IconSprite

  def initialize(viewport,parent)
    super(674,378,viewport)
    setBitmap("Graphics/UI/Battle/outer_move_info")
    @typeBitmap = AnimatedBitmap.new(_INTL("Graphics/UI/types"))
    @categoryBitmap = AnimatedBitmap.new(_INTL("Graphics/UI/category"))
    @overlay = Sprite.new(viewport)
    @overlay.bitmap = Bitmap.new(self.bitmap.width,self.bitmap.height)
    @overlay.x = self.x
    @overlay.y = self.y
    @sprites = []
    for i in 0...4
      sprite = OuterMoveBox.new(viewport,parent,i)
      sprite.z = self.z + 1
      @sprites.push(sprite)
    end
    @overlay.z = self.z + 1
    self.visible = false
    @parent = parent
    refresh
  end

  def refresh
    @overlay.bitmap.clear
    @index = @parent.index
    @battler = @parent.battler
    return if !@battler
    move = @battler.moves[@index]
    return if !move
    base = Color.new(248,248,248)
    shadow = Color.new(80,80,88)
    @overlay.bitmap.blt(10,94,@typeBitmap.bitmap,Rect.new(0,28*GameData::Type.get(move.type).icon_position,64,28))
    @overlay.bitmap.blt(10,152,@categoryBitmap.bitmap,Rect.new(0,28*move.category,64,28))
    textPos = []
    powerString = (move.power <= 0) ? "-" : move.power.to_s
    textPos.push([powerString,6,4,0,base,shadow])
    accString = (move.accuracy <= 0) ? "-" : (move.accuracy.to_s + "%")
    textPos.push([accString,6,28,0,base,shadow])
    textPos.push([sprintf("%2d/%2d", move.pp, move.total_pp),6,52,0,base,shadow])
    pbSetSmallestFont(@overlay.bitmap)
    pbDrawTextPositions(@overlay.bitmap,textPos)
    for i in 0...4
      @sprites[i].refresh(@battler.moves[i],i==@index)
    end
  end

  def opacity=(value)
    super(value)
    @overlay.opacity = value
    for i in 0...4
      @sprites[i].opacity = value
    end
  end

  def color=(value)
    super(value)
    @overlay.color = value
    for i in 0...4
      @sprites[i].color = value
    end
  end

  def visible=(value)
    super(value)
    @overlay.visible = value
    for i in 0...4
      @sprites[i].visible = value
    end
    refresh if value
  end

  def z=(value)
    super(value)
    @overlay.z = value + 1
    for i in 0...4
      @sprites[i].z = value + 1
    end
  end

  def dispose
    @overlay.dispose
    @typeBitmap.dispose
    @categoryBitmap.dispose
    for i in 0...4
      @sprites[i].dispose
    end
    super
  end

  def update
    super
    @overlay.update
    for i in 0...4
      @sprites[i].update
    end
    if @index != @parent.index || @battler != @parent.battler
      refresh
    end
  end

end

class OuterDataBox < RPG::Sprite

  def initialize(x,y,viewport,parent,pos,boxCount)
    super(viewport)
    @frame = 0
    @contents = BitmapWrapper.new(Graphics.width,Graphics.height)
    @pages = [@contents]
    @numPages = 0
    @curPage = 0
    self.bitmap  = @pages[0]
    pbSetSmallestFont(self.bitmap)
    @parent = parent
    pos = (pos + 2) % 4 if pos % 2 == 0 && boxCount >= 3
    pos = (pos + 2) % 4 if pos % 2 == 1 && boxCount >= 4
    @pos = pos
    @statX = [96,674+64,96,674+64][pos]
    @statY = [364,192,120,436][pos]
    @affinityX = @statX - 66
    @affinityY = @statY + 102
    @battler = parent.battler
    @stages = {}
    for i in [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED,:ACCURACY,:EVASION]
      @stages[i] = @battler.stages[i]
    end
    @fainted = @battler.fainted?
    @boxVisible = @parent.visible
    @typeBitmap = AnimatedBitmap.new(_INTL("Graphics/UI/types"))
    @pkmnSprite = PokemonIconSprite.new(@battler.pokemon,viewport)
    @pkmnSprite.visible = false
    @pkmnSprite.mirror = true if pos % 2 == 0
    @pkmnX = @statX - 66
    @pkmnY = (pos % 2 == 1) ? @statY - 96 : @statY + 136
    @pkmnSprite.x = @pkmnX
    @pkmnSprite.y = @pkmnY
    refresh
  end

  def opacity=(value)
    super
    @pkmnSprite.opacity = value
  end
  
  def visible=(value)
    super
    @pkmnSprite.visible = visible
  end
  
  def color=(value)
    super
    @pkmnSprite.color = color
  end

  def refresh
    @pkmnSprite.visible = @parent.visible
    return if !@parent.visible || !@battler || @battler.fainted?
    colors=[
      Color.new(248,248,248),Color.new(33,29,29),
      Color.new(160,160,168),Color.new(80,80,80),
      Color.new(140,225,140),Color.new(0,100,0),
      Color.new(225,140,140),Color.new(100,0,0)]
    pokemon=@parent.battler
    textPos=[]
    textPosPages = []
    i = 0; j = 0; yOffset = 0
    statNames = ["ATTACK","DEFENSE","SP.ATK","SP.DEF","SPEED","ACC.","EVASION"]
    for s in [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED,:ACCURACY,:EVASION]
      stage=pokemon.stages[s]
      if stage != 0
        c = stage>0 ? [colors[4],colors[5]] : [colors[6],colors[7]]
        stageStr = stage.to_s
        statview = 0 #$PokemonSystem.statstages
        if statview==2
          if stage>0
            stageStr = sprintf("+%d",stage)
          elsif stage<0
            stageStr = sprintf("-%d",stage)
          else
            stageStr = "-"
          end
        else
          base = [:ACCURACY,:EVASION].include?(s) ? 3.0 : 2.0
          stat=(stage>=0) ? ((base+stage)/base) : (base/(base-stage))
          if statview==1
            stat*=(stat*100).round
            stageStr = sprintf("%d%%",stat)
          else
            if (base==2.0 ? (stage>=-3 && stage!=-1) : (stage%3==0))
              stageStr = sprintf("%.01fx",stat)
            else
              stageStr = sprintf("%.02fx",stat)
            end
          end
        end
        statNameX = @statX
        statNameX -= 61
        textPos.push([stageStr,@statX,@statY+18*yOffset,2,c[0],c[1]])
        textPos.push([statNames[j],statNameX,@statY+18*yOffset,2,c[0],c[1]])
        i += 1
        yOffset += 1
        if i % 4 == 0
          textPosPages.push(textPos)
          textPos = []
          yOffset = 0
        end
      end
      j += 1
    end
    for e in self.positivePokemonEffects
      c = [colors[4],colors[5]]
      e_id = getID(PBEffects, e[0])
      val = pokemon.effects[e_id]
      next if val.nil?
      next if e_id == PBEffects::WellRested && pokemon.status == :SLEEP
      if (val != e[2])
        textPos.push([e[1].upcase,@statX - 32,@statY+18*yOffset,2,c[0],c[1]])
        i += 1
        yOffset += 1
        if i % 4 == 0
          textPosPages.push(textPos)
          textPos = []
          yOffset = 0
        end
      end
    end
    for e in self.negativePokemonEffects
      c = [colors[6],colors[7]]
      e_id = getID(PBEffects, e[0])
      val = pokemon.effects[e_id]
      next if val.nil?
      if (val != e[2])
        textPos.push([e[1].upcase,@statX - 32,@statY+18*yOffset,2,c[0],c[1]])
        i += 1
        yOffset += 1
        if i % 4 == 0
          textPosPages.push(textPos)
          textPos = []
          yOffset = 0
        end
      end
    end
    textPosPages.push(textPos) if textPos.length > 0
    @numPages = textPosPages.length
    while @pages.length < @numPages
      @pages.push(BitmapWrapper.new(Graphics.width,Graphics.height))
      pbSetSmallestFont(@pages[@pages.length - 1])
    end
    for i in 0...@numPages
      @pages[i].clear
      pbDrawTextPositions(@pages[i], textPosPages[i])
      @pages[i].blt(@affinityX,@affinityY,@typeBitmap.bitmap,Rect.new(0,28*GameData::Type.get(@battler.pokemon.affinities[0]).icon_position,64,28))
    end
    if @numPages == 0
      @pages[0].clear
      @pages[0].blt(@affinityX,@affinityY,@typeBitmap.bitmap,Rect.new(0,28*GameData::Type.get(@battler.pokemon.affinities[0]).icon_position,64,28))
      self.bitmap = @pages[0]
    end
  end

  def positivePokemonEffects
    return [
      [:AquaRing, "Aqua Ring", false],
      [:Bide, "Bide", 0],
      [:Charge, "Charged", 0],
      [:DestinyBond, "Destiny Bond", false],
      [:Endure, "Endure", false],
      [:FlashFire, "Flash Fire", false],
      [:FocusEnergy, "Focus Energy", 0],
      [:FollowMe, "Follow Me", 0],
      [:Grudge, "Grudge", false],
      [:HelpingHand, "Has Help", false],
      [:Ingrain, "Ingrained", false],
      [:LaserFocus, "Laser Focused", 0],
      [:LockOn, "Locked On", 0],
      [:MagicCoat, "Magic Coat", false],
      [:MagnetRise, "Levitating", 0],
      [:Minimize, "Minimized", false],
      [:PowerTrick, "Power Trick", false],
      [:Rage, "Raging", false],
      [:RagePowder, "Rage Powder", false],
      [:Substitute, "Substitute", 0],
      [:Unburden, "Unburden", false],
      [:Uproar, "Uproar", 0],
      [:WellRested, "Well Rested", 0],
      [:Permanence, "Permanence", false]
    ]
  end

  def negativePokemonEffects
    return [
      [:Attract, "Attracted", -1],
      [:Confusion, "Confused", 0],
      [:Curse, "Cursed", false],
      [:Disable, "Disabled", 0],
      [:Encore, "Encored", 0],
      [:Foresight, "Identified", false],
      [:GastroAcid, "Nullified", false],
      [:HealBlock, "Heal Blocked", 0],
      [:HyperBeam, "Recharging", 0],
      [:JawLock, "Jaw Locked", -1],
      [:LeechSeed, "Seeded", -1],
      [:MeanLook, "Cannot Escape", -1],
      [:Nightmare, "Nightmare", false],
      [:NoRetreat, "No Retreat", false],
      [:Obstruct, "Obstructed", false],
      [:Octolock, "Octolocked", -1],
      [:PerishSong, "Perishing", 0],
      [:Quash, "Quashed", 0],
      [:SlowStart, "Slow Start", 0],
      [:SmackDown, "Grounded", false],
      [:Taunt, "Taunted", 0],
      [:Telekinesis, "Telekinesis", 0],
      [:ThroatChop, "Silenced", 0],
      [:Torment, "Tormented", false],
      [:Trapping, "Trapped", 0],
      [:Yawn, "Drowsy", 0],
      [:CorrosiveAcid, "Corroded", false],
      [:Nihility, "Nihility", 0]
    ]
  end

  def dispose
    @pkmnSprite.dispose
    @typeBitmap.dispose
    super
    @pages.each do |bitmap|
      bitmap.dispose if !bitmap.disposed?
    end
  end

  def update(mustRefresh=false)
    super()
    @frame = (@frame + 1) % 2
    if @battler != @parent.battler || @fainted != @battler.fainted? || @boxVisible != @parent.visible
      mustRefresh = true
    elsif 
      for i in [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED,:ACCURACY,:EVASION]
        if @stages[i] != @battler.stages[i]
          mustRefresh = true
          break
        end
      end
    end
    if mustRefresh
      @battler = @parent.battler
      @pkmnSprite.pokemon = @battler.pokemon
      for i in [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED,:ACCURACY,:EVASION]
        @stages[i] = @battler.stages[i]
      end
      @fainted = @battler.fainted?
      @boxVisible = @parent.visible
      refresh
    end
    @pkmnSprite.update if (@parent.selected==1 || @parent.selected==2) && @frame == 0
    if @numPages > 1
      if Graphics.frame_count % 180 == 0
        @curPage = (@curPage + 1) % @numPages
        self.bitmap = @pages[@curPage]
      end
    else
      @pageTimer = 0
    end
  end

end

class OuterCommandSprite < IconSprite
  
  def initialize(x,y,viewport=nil,parent,pos)
    @timer = 0
    @text_sprite = IconSprite.new(x, y, viewport)
    @text_sprite.setBitmap("Graphics/UI/Battle/options_new")
    @text_sprite.ox = 128
    @text_sprite.oy = 22
    super(x,y,viewport)
    self.ox = 128
    self.oy = 22
    @parent = parent
    @pos = pos
    setBitmap("Graphics/UI/Battle/options_new")
    refresh
  end

  def getRect(i, j = 0)
    return (@parent.index==@pos) ? Rect.new(256+512*j,i*44,256,44) : Rect.new(512*j,i*44,256,44)
  end
  
  def dispose
    @text_sprite.dispose
    super
  end

  def visible=(value)
    @text_sprite.visible = value
    super(value)
    refresh if value
  end

  def opacity=(value)
    @text_sprite.opacity = value
    super(value)
  end

  def tone=(value)
    @text_sprite.tone = value
    super(value)
  end

  def color=(value)
    @text_sprite.color = value
    super(value)
  end

  def x=(value)
    @text_sprite.x = value
    super(value)
  end

  def y=(value)
    @text_sprite.y = value
    super(value)
  end

  def z=(value)
    @text_sprite.z = value + 1
    super(value)
  end
  
  def refresh
    if @parent.mode==1 && @pos==4
      self.src_rect = getRect(6)
      @text_sprite.src_rect = getRect(6, 1)
    else
      self.src_rect = getRect(@pos)
      @text_sprite.src_rect = getRect(@pos, 1)
    end
  end
  
  def update
    @text_sprite.update
    if @parent.index == @pos
      @timer += 1
      self.angle = Math.sin(@timer / 8.0) * 4
    else
      @timer = 0
      self.angle = 0
    end
    super
    refresh
  end
end

class QuickItemSprite < IconSprite

  def initialize(x,y,viewport=nil,parent,pos)
    @selected = false
    @timer = 0
    @animation_timer = 0
    @animation_mult = 0
    @items = []
    @item_index = 0
    @item_sprite = ItemIconSprite.new(x, y, nil, viewport)
    @item_sprite.ox = 24
    @item_sprite.oy = 24
    @right_arrow = AnimatedSprite.new("Graphics/UI/right_arrow", 8, 40, 28, 2, viewport)
    @right_arrow.visible = false
    @right_arrow.play
    @left_arrow = AnimatedSprite.new("Graphics/UI/right_arrow", 8, 40, 28, 2, viewport)
    @left_arrow.visible = false
    @left_arrow.zoom_x = -1
    @left_arrow.play
    @quantity = Sprite.new(viewport)
    @quantity.bitmap = Bitmap.new(64, 32)
    super(x,y,viewport)
    self.ox = 32
    self.oy = 32
    @parent = parent
    @pos = pos
    setBitmap("Graphics/UI/Battle/quick_item_bg")
    refresh
  end

  def set_pocket(value)
    @items = $bag.pockets[value]
    if @items.length > 0
      @item_index = 0
      for i in 0...@items.length
        if @items[i][0] == $PokemonSystem.last_quick_item
          @item_index = i
          break
        end
      end
    end
    refresh
  end

  def change_item(offset)
    pbSEPlay("GUI party switch", 80, 120)
    if @animation_timer > 0
      @animation_timer = 0
      @item_sprite.x = self.x
      @item_sprite.y = self.y
      refresh
    end
    @item_index = (@item_index + offset) % @items.length
    $PokemonSystem.last_quick_item = @items[@item_index][0]
    @animation_timer = 9
    @animation_mult = offset
    refresh
  end

  def get_item
    return nil if @items.length == 0
    return @items[@item_index][0]
  end

  def count
    return @items.length
  end
  
  def dispose
    @item_sprite.dispose
    @right_arrow.dispose
    @left_arrow.dispose
    @quantity.dispose
    super
  end

  def visible=(value)
    @item_sprite.visible = value
    @right_arrow.visible = value && @selected
    @left_arrow.visible = value && @selected
    @quantity.visible = value
    super(value)
    refresh if value
  end

  def opacity=(value)
    @item_sprite.opacity = value
    @right_arrow.opacity = value
    @left_arrow.opacity = value
    @quantity.opacity = value
    super(value)
  end

  def tone=(value)
    @item_sprite.tone = value
    @right_arrow.tone = value
    @left_arrow.tone = value
    @quantity.tone = value
    super(value)
  end

  def color=(value)
    @item_sprite.color = value
    @right_arrow.color = value
    @left_arrow.color = value
    @quantity.color = value
    super(value)
  end

  def x=(value)
    @item_sprite.x = value
    @right_arrow.x = value + 18
    @left_arrow.x = value - 18
    @quantity.x = value - 6
    super(value)
  end

  def y=(value)
    @item_sprite.y = value
    @right_arrow.y = value - 12
    @left_arrow.y = value - 12
    @quantity.y = value + 10
    super(value)
  end

  def z=(value)
    @item_sprite.z = value + 1
    @right_arrow.z = value + 2
    @left_arrow.z = value + 2
    @quantity.z = value + 3
    super(value)
  end
  
  def refresh
    self.src_rect = Rect.new((@parent.index == @pos) ? 64 : 0, 0, 64, 64)
    return if @animation_timer > 4
    @quantity.bitmap.clear
    if @items.length > 0
      @item_sprite.item = @items[@item_index][0]
      if @selected
        pbSetSmallFont(@quantity.bitmap)
        pbDrawTextPositions(@quantity.bitmap, [
          [_INTL("x{1}", @items[@item_index][1]), 36, 4, 1, Color.new(252,252,252), Color.new(15,15,15), 1]
        ])
      else
        pbSetSmallestFont(@quantity.bitmap)
        pbDrawTextPositions(@quantity.bitmap, [
          [_INTL("x{1}", @items[@item_index][1]), 32, 2, 1, Color.new(252,252,252), Color.new(15,15,15), 1]
        ])
      end
    end
  end
  
  def update
    @item_sprite.update
    @right_arrow.update
    @left_arrow.update
    @quantity.update
    if @parent.index == @pos
      @timer += 1
      self.angle = Math.sin(@timer / 8.0) * 6
      @right_arrow.visible = true && self.visible
      @left_arrow.visible = true && self.visible
    else
      @timer = 0
      self.angle = 0
      @right_arrow.visible = false
      @left_arrow.visible = false
    end
    if @animation_timer > 5
      @animation_timer -= 1
      @item_sprite.x -= [8, 6, 4, 2][@animation_timer - 5] * @animation_mult
      @item_sprite.opacity = [32, 64, 128, 255][@animation_timer - 5]
    elsif @animation_timer == 5
      @animation_timer -= 1
      @item_sprite.opacity = 0
      @item_sprite.x = self.x + 20 * @animation_mult
      refresh
    elsif @animation_timer > 0
      @animation_timer -= 1
      @item_sprite.x -= [2, 4, 6, 8][@animation_timer] * @animation_mult
      @item_sprite.opacity = [255, 128, 64, 32][@animation_timer]
    end
    if @selected != (@parent.index == @pos)
      @selected = (@parent.index == @pos)
      refresh
    end
    super
  end

end

class OuterSwitchBox < IconSprite

  def initialize(viewport=nil,pos)
    super(0, 0, viewport)
    @pos = pos
    @party_member = 0
    @party_length = 3
    @timer = 0
    @pokemon = nil
    @active = -1
    setBitmap(_INTL("Graphics/UI/Battle/switch"))
    self.ox = self.bitmap.width / 4
    self.oy = self.bitmap.height / 18
    @hp_gauge = Sprite.new(viewport)
    @hp_gauge.bitmap = Bitmap.new(352, 96)
    @hp_gauge.ox = self.ox
    @hp_gauge.oy = self.oy
    @overlay = Sprite.new(viewport)
    @overlay.bitmap = Bitmap.new(352, 96)
    @overlay.ox = self.ox
    @overlay.oy = self.oy
    @pkmnsprite = PokemonIconSprite.new(@pokemon, viewport)
    @pkmnsprite.setOffset(PictureOrigin::CENTER)
    @pkmnsprite.active = false
    @statuses = AnimatedBitmap.new(_INTL("Graphics/UI/Party/statuses"))
    @hpbar = AnimatedBitmap.new("Graphics/UI/Battle/switch_overlay_hp")
    refresh
  end

  def dispose
    @overlay.dispose
    @hp_gauge.dispose
    @pkmnsprite.dispose
    @hpbar.dispose
    @statuses.dispose
    super
  end

  def visible=(value)
    super(value)
    @overlay.visible = value
    @hp_gauge.visible = value
    @pkmnsprite.visible = value
  end

  def pokemon=(value)
    @pokemon = value
    refresh
  end

  def active=(value)
    @active = value
    @pkmnsprite.active = (@active == @pos)
    @pkmnsprite.disabled = (@active != @pos)
    refresh
    update
  end

  def party_length=(value)
    @party_length = value
  end

  def party_member=(value)
    @party_member = value
  end

  def z=(value)
    super(value)
    @overlay.z = value + 5
    @hp_gauge.z = value + 4
    @pkmnsprite.z = value + 3
  end

  def tone=(value)
    super(value)
    @overlay.tone = value
    @hp_gauge.tone = value
    @pkmnsprite.tone = value
  end

  def color=(value)
    super(value)
    @overlay.color = value
    @hp_gauge.color = value
    @pkmnsprite.color = value
  end

  def opacity=(value)
    super(value)
    @overlay.opacity = value
    @hp_gauge.opacity = value
    @pkmnsprite.opacity = value
  end
  
  def refresh
    selected = (@active == @pos)
    base   = Color.new(248, 248, 248)
    shadow = Color.new( 15,  15,  15)
    if (@pos < 3) == (@active < 3)
      self.src_rect = Rect.new(selected ? 352 : 0, @party_member * 96, 352, 96)
    else
      self.src_rect = Rect.new(704, @party_member * 96, 96, 96)
    end
    if @party_length > 3
      if @pos >= 3
        self.x = ((@pos < 3) == (@active < 3)) ? 616 : 870
        self.y = 372 + 76 * (@pos - 3)
      else
        self.x = 542
        self.y = 372 + 76 * @pos
      end
    else
      self.x = 610
      self.y = 372 + 76 * @pos
    end

    @pkmnsprite.pokemon = @pokemon
    @pkmnsprite.x = self.x + 48 - self.ox
    @pkmnsprite.y = self.y + 48 - self.oy

    @overlay.x = self.x
    @overlay.y = self.y
    @overlay.bitmap.clear
    @hp_gauge.x = self.x
    @hp_gauge.y = self.y
    @hp_gauge.bitmap.clear
    if @pokemon
      if !@pokemon.egg?
        pbSetSmallestFont(@overlay.bitmap)
        textpos = [
          [_INTL("Lv{1}", @pokemon.egg? ? "-" : @pokemon.level), 24, 56, 0, base, shadow, 1]
        ]
        pbDrawTextPositions(@overlay.bitmap, textpos)
      end
      if (@pos < 3) == (@active < 3)
        selected ? pbSetSystemFont(@overlay.bitmap) : pbSetSmallFont(@overlay.bitmap)
        textpos = [
          [@pokemon.name, 157, selected ? 28 : 32, 2, base, shadow]
        ]
        pbDrawTextPositions(@overlay.bitmap, textpos)
        if !@pokemon.egg?
          pbSetSmallestFont(@overlay.bitmap)
          textpos = [
            [_INTL("TYPE"), 252, 26, 0, base, shadow],
            [_INTL("AFF."), 300, 26, 0, base, shadow]
          ]
          pbDrawTextPositions(@overlay.bitmap, textpos)
          
          imagepos = []
          for i in 0...@pokemon.types.length
            imagepos.push(["Graphics/UI/types_small.png", 238 + ((@pokemon.types.length == 1) ? 14 : (i * 28)), 38, 0, 32 * GameData::Type.get(@pokemon.types[i]).icon_position, 32, 32])
          end
          imagepos.push(["Graphics/UI/types_small.png", 298, 38, 0, 32 * GameData::Type.get(@pokemon.affinity).icon_position, 32, 32])
          pbDrawImagePositions(@overlay.bitmap, imagepos)

          hptextpos = [[_ISPRINTF("{1: 3d}/{2: 3d}", @pokemon.hp, @pokemon.totalhp),166,60,2,base,shadow]]
          gauge_size = 118
          hpgauge=@pokemon.totalhp==0 ? 0 : ((@pokemon.hp * (gauge_size / 2) / @pokemon.totalhp).floor * 2)
          hpgauge=1 if hpgauge==0 && @pokemon.hp>0
          hpzone=0
          hpzone=1 if @pokemon.hp<=(@pokemon.totalhp/2).floor
          hpzone=2 if @pokemon.hp<=(@pokemon.totalhp/4).floor
          hpcolors=[
            Color.new(14,152,22),Color.new(24,192,32),   # Green
            Color.new(202,138,0),Color.new(232,168,0),   # Orange
            Color.new(218,42,36),Color.new(248,72,56)    # Red
          ]
          # fill with HP color
          @hp_gauge.bitmap.fill_rect(112,64,hpgauge,2,hpcolors[hpzone*2])
          @hp_gauge.bitmap.fill_rect(112,66,hpgauge,2,hpcolors[hpzone*2+1])
          @hp_gauge.bitmap.fill_rect(112,68,hpgauge,2,hpcolors[hpzone*2+1])
          if selected
            @hp_gauge.bitmap.fill_rect(112,70,hpgauge,2,hpcolors[hpzone*2+1])
            @hp_gauge.bitmap.fill_rect(112,72,hpgauge,2,hpcolors[hpzone*2+1])
            @hp_gauge.bitmap.fill_rect(112,74,hpgauge,2,hpcolors[hpzone*2])
            pbSetSmallFont(@overlay.bitmap)
            hptextpos[0][2] += 2
          else
            @hp_gauge.bitmap.fill_rect(112,70,hpgauge,2,hpcolors[hpzone*2])
            pbSetSmallestFont(@overlay.bitmap)
          end
          pbDrawTextPositions(@overlay.bitmap, hptextpos)
          if @pokemon.hp == 0 || @pokemon.status != :NONE
            status = (@pokemon.hp == 0) ? 5 : (GameData::Status.get(@pokemon.status).icon_position)
            statusrect=Rect.new(0, 32 * status, 32, 32)
            @overlay.bitmap.blt(80, 52, @statuses.bitmap, statusrect)
          end
        end
      else

      end
    end
  end

  def draw_hp
    base   = Color.new(248, 248, 248)
    shadow = Color.new( 15,  15,  15)
    return if @pokemon.egg? || (@text && @text.length > 0)
    # HP numbers
    hp_text = sprintf("% 3d /% 3d", @pokemon.hp, @pokemon.totalhp)
    pbDrawTextPositions(@overlay.bitmap,
                        [[hp_text, 224, 66, 1, base, shadow]])
    # HP bar
    if @pokemon.able?
      w = @pokemon.hp * HP_BAR_WIDTH / @pokemon.totalhp.to_f
      w = 1 if w < 1
      w = ((w / 2).round) * 2   # Round to the nearest 2 pixels
      hpzone = 0
      hpzone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor
      hpzone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor
      hprect = Rect.new(0, hpzone * 8, w, 8)
      @overlaysprite.bitmap.blt(128, 52, @hpbar.bitmap, hprect)
    end
  end

  def draw_status
    return if @pokemon.egg? || (@text && @text.length > 0)
    status = -1
    if @pokemon.fainted?
      status = GameData::Status.count - 1
    elsif @pokemon.status != :NONE
      status = GameData::Status.get(@pokemon.status).icon_position
    elsif @pokemon.pokerusStage == 1
      status = GameData::Status.count
    end
    return if status < 0
    statusrect = Rect.new(0, STATUS_ICON_HEIGHT * status, STATUS_ICON_WIDTH, STATUS_ICON_HEIGHT)
    @overlaysprite.bitmap.blt(78, 68, @statuses.bitmap, statusrect)
  end
  
  def update
    super
    if self.visible && (@active == @pos)
      @timer += 1
      self.angle = Math.sin(@timer / 8.0) * 1.5
      @hp_gauge.angle = Math.sin(@timer / 8.0) * 1.5
    else
      @timer = 0
      self.angle = 0
      @hp_gauge.angle = 0
    end
    @overlay.update
    @pkmnsprite.update
  end

end

#===============================================================================
# Data box for regular battles
#===============================================================================
class Battle::Scene::PokemonDataBox < Sprite
  attr_reader   :battler
  attr_accessor :selected
  attr_reader   :animatingHP
  attr_reader   :animatingExp
  
  # Time in seconds to fully fill the Exp bar (from empty).
  EXP_BAR_FILL_TIME  = 1.75
  # Maximum time in seconds to make a change to the HP bar.
  HP_BAR_CHANGE_TIME = 1.0
  STATUS_ICON_HEIGHT = 32
  NAME_BASE_COLOR         = Color.new(248, 248, 248)
  NAME_SHADOW_COLOR       = Color.new( 15,  15,  15)
  MALE_BASE_COLOR         = Color.new( 24, 112, 216)
  MALE_SHADOW_COLOR       = Color.new(136, 168, 208)
  FEMALE_BASE_COLOR       = Color.new(248,  56,  32)
  FEMALE_SHADOW_COLOR     = Color.new(224, 152, 144)
  NONBINARY_BASE_COLOR    = Color.new(136,  84, 128)
  NONBINARY_SHADOW_COLOR  = Color.new(180, 160, 176)
  
  def initialize(battler, sideSize, viewport = nil)
    super(viewport)
    @battler      = battler
    @sprites      = {}
    @spriteX      = 0
    @spriteY      = 0
    @spriteBaseX  = 0
    @selected     = 0
    @frame        = 0
    @showHP       = false   # Specifically, show the HP numbers
    @animatingHP  = false
    @showExp      = false   # Specifically, show the Exp bar
    @animatingExp = false
    @expFlash     = 0
    @sideSize     = sideSize
    initializeDataBoxGraphic(sideSize)
    initializeOtherGraphics(viewport)
    refresh
  end
  
  def onPlayerSide
    return (@battler.index % 2 == 0)
  end
  
  def initializeDataBoxGraphic(sideSize)
    onPlayerSide = @battler.index.even?
    # Get the data box graphic and set whether the HP numbers/Exp bar are shown
    if sideSize == 1   # One Pokémon on side, use the regular dara box BG
      bgFilename = ["Graphics/UI/Battle/databox_normal_foe",
                    "Graphics/UI/Battle/databox_normal"][@battler.index % 2]
    else   # Multiple Pokémon on side, use the thin dara box BG
      bgFilename = ["Graphics/UI/Battle/databox_thin_foe",
                    "Graphics/UI/Battle/databox_thin"][@battler.index % 2]
    end
    if onPlayerSide
      @showHP = true
    end
    @showExp = false
    @databoxBitmap&.dispose
    @databoxBitmap = AnimatedBitmap.new(bgFilename)
    # Determine the co-ordinates of the data box and the left edge padding width
    @spriteBaseY = 4
    if onPlayerSide
      @spriteX = 0
      @spriteY = self.viewport.rect.height - 112
      @spriteBaseX = 16
    else
      @spriteX = self.viewport.rect.width - 256
      @spriteY = 36
      @spriteBaseX = 34
    end
    @smallLevel = (sideSize == 3)
    case sideSize
    when 1
      if @battler.index == 1
        offset = 0
        for gauge in pbBoss.gauges
          if gauge.type == PBGauge::Half
            offset += 6
          else
            offset += 12
          end
        end
        @spriteY -= [offset, 40].min
        @smallLevel = true if offset >= 36
      end
    when 2
      @spriteX += [-12, 12,  0,  0][@battler.index]
      @spriteY += [-20, 20, 34,-34][@battler.index]
    when 3
      @spriteX += [-12, 12, -6,  6,  0,  0][@battler.index]
      @spriteY += [-42, 54,  6,  6, 54,-42][@battler.index]
    end
  end
  
  def initializeOtherGraphics(viewport)
    # Create other bitmaps
    @numbersBitmap = AnimatedBitmap.new("Graphics/UI/Battle/icon_numbers")
    @hpBarBitmap   = AnimatedBitmap.new(_INTL("Graphics/UI/Battle/overlay_hp_vb{1}", onPlayerSide ? "_foe" : ""))
    @hpBarExBitmap = AnimatedBitmap.new(_INTL("Graphics/UI/Battle/overlay_hp_extra{1}", onPlayerSide ? "_foe" : ""))
    @expBarBitmap  = AnimatedBitmap.new("Graphics/UI/Battle/overlay_exp")
    @numbersWhiteBitmap = AnimatedBitmap.new("Graphics/UI/Battle/icon_numbers_white")
    # Create sprite to draw HP numbers on
    @hpNumbers = BitmapSprite.new(150, 16, viewport)
  #    pbSetSmallFont(@hpNumbers.bitmap)
    @sprites["hpNumbers"] = @hpNumbers
    # Create sprite wrapper that displays HP bar
    @hpBar = Sprite.new(viewport)
    @hpBar.bitmap = @hpBarBitmap.bitmap
    @hpBar.src_rect.height = @hpBarBitmap.height / 3
    @hpBarEx = Sprite.new(viewport)
    @hpBarEx.bitmap = @hpBarExBitmap.bitmap
    @hpBarEx.src_rect.height = @hpBarExBitmap.height / 8
    @hpBarEx.src_rect.width = 0
    @hpBarEx2 = Sprite.new(viewport)
    @hpBarEx2.bitmap = @hpBarExBitmap.bitmap
    @hpBarEx2.src_rect.height = @hpBarExBitmap.height / 8
    @hpBarEx2.src_rect.width = 0
    @sprites["hpBar"] = @hpBar
    @sprites["hpBarEx"] = @hpBarEx
    @sprites["hpBarEx2"] = @hpBarEx2
    # Create sprite wrapper that displays Exp bar
    @expBar = Sprite.new(viewport)
    @expBar.bitmap = @expBarBitmap.bitmap
    @sprites["expBar"] = @expBar
    # Create status HUD display
    @statuses = BattleStatusRow.new(viewport, self)
    @statuses.battler = @battler
    # Create sprite wrapper that displays everything except the above
    @contents = BitmapWrapper.new(@databoxBitmap.width, @databoxBitmap.height + 256)
    self.bitmap  = @contents
    self.visible = false
    self.z       = 150 + ((@battler.index / 2) * 5)
    pbSetSystemFont(self.bitmap)
  end
  
  def dispose
    pbDisposeSpriteHash(@sprites)
    @databoxBitmap.dispose
    @numbersBitmap.dispose
    @hpBarBitmap.dispose
    @hpBarExBitmap.dispose
    @expBarBitmap.dispose
    @contents.dispose
    @statuses.dispose
    super
  end
  
  def x=(value)
    super
    @hpBar.x     = value + @spriteBaseX + (onPlayerSide ? 38 : -8)
    @hpBarEx.x   = @hpBar.x
    @hpBarEx2.x  = @hpBar.x
    @expBar.x    = value + @spriteBaseX + 6
    @hpNumbers.x = value + @spriteBaseX + (@showHP ? 56 : 44)
    @statuses.x  = value + (@battler.index % 2 == 0 ? 242 : -238)
  end
  
  def y=(value)
    super
    @hpBar.y     = value + @spriteBaseY + 28
    @hpBarEx.y   = @hpBar.y
    @hpBarEx2.y  = @hpBar.y
    @expBar.y    = value + @spriteBaseY + 74
    @hpNumbers.y = value + @spriteBaseY + 28
    @statuses.y  = value + (@battler.index % 2 == 0 ? 24 : 26)
  end
  
  def z=(value)
    super
    @hpBar.z     = value + 1
    @hpBarEx.z   = @hpBar.z
    @hpBarEx2.z  = @hpBar.z
    @expBar.z    = value + 1
    @hpNumbers.z = value + 2
    @statuses.z  = value + 1
  end
  
  def opacity=(value)
    super
    @statuses.opacity = value if @statuses
    @sprites.each do |i|
      i[1].opacity = value if !i[1].disposed?
    end
  end
  
  def visible=(value)
    super
    @statuses.visible = value if @statuses
    @sprites.each do |i|
      i[1].visible = value if !i[1].disposed?
    end
    @expBar.visible = (value && @showExp)
  end
  
  def color=(value)
    super
    @statuses.color = value if @statuses
    @sprites.each do |i|
      i[1].color = value if !i[1].disposed?
    end
  end
  
  def battler=(b)
    @battler = b
    self.visible = (@battler && !@battler.fainted?)
    @statuses.battler = @battler
  end
  
  def hp
    return (animating_hp?) ? @anim_hp_current : @battler.hp
  end
  
  def exp_fraction
    return 0.0 if @rangeExp == 0
    return (@animatingExp) ? @currentExp.to_f / @rangeExp : @battler.pokemon.exp_fraction
  end
  
  def animate_hp(old_val, new_val)
    return if old_val == new_val
    @anim_hp_start = old_val
    @anim_hp_end = new_val
    @anim_hp_current = old_val
    @anim_hp_timer_start = System.uptime
  end

  def animating_hp?
    return @anim_hp_timer_start != nil
  end
  
  def pbDrawNumber(number, btmp, startX, startY, align = 0, white = false)
    # -1 means draw the / character
    n = (number == -1) ? [10] : number.to_i.digits.reverse
    n.push(11) if number.to_s.include?("%")
    charWidth  = @numbersBitmap.width / 12
    charHeight = @numbersBitmap.height
    startX -= charWidth * n.length if align == 1
    startX -= (charWidth * n.length) / 2 if align == 2
    n.each do |i|
      btmp.blt(startX, startY, white ? @numbersWhiteBitmap.bitmap : @numbersBitmap.bitmap, Rect.new(i * charWidth, 0, charWidth, charHeight))
      startX += charWidth
    end
  end
  
  def draw_background
    self.bitmap.blt(0, @spriteBaseY, @databoxBitmap.bitmap, Rect.new(0, 0, @databoxBitmap.width, @databoxBitmap.height))
  end
  
  def draw_name
    name_x = onPlayerSide ? 220 : -12
    name_y = 0
    align = onPlayerSide ? 1 : 0
    if @smallLevel
      pbSetSmallFont(self.bitmap)
      name_x -= 2
      name_y += 4
    else
      pbSetSystemFont(self.bitmap)
    end
    pbDrawTextPositions(self.bitmap,
      [[@battler.name, @spriteBaseX + name_x, @spriteBaseY + name_y, align, NAME_BASE_COLOR, NAME_SHADOW_COLOR, true]]
    )
    pbSetSystemFont(self.bitmap)
  end
  
  def draw_level
    # Level number
    lvl_text = _INTL("{1}", @battler.level)
    lvl_x = onPlayerSide ? 16 : 174
    lvl_y = 0
    if @smallLevel
      pbSetSmallFont(self.bitmap)
      lvl_x += 2
      lvl_y += 4
    else
      pbSetSystemFont(self.bitmap)
    end
    pbDrawTextPositions(self.bitmap,
      [[lvl_text, @spriteBaseX + lvl_x, @spriteBaseY + lvl_y, 0, NAME_BASE_COLOR, NAME_SHADOW_COLOR, true]])
    pbSetSystemFont(self.bitmap)
  end
  
  def draw_gender
    gender = @battler.displayGender
    gender_x = onPlayerSide ? (22 + self.bitmap.text_size(_INTL("{1}", @battler.level)).width) : 140
    gender_y = 0
    if @smallLevel
      pbSetSmallFont(self.bitmap)
      gender_x -= 2
      gender_y += 6
    else
      pbSetSystemFont(self.bitmap)
    end
    gender_text = ["♂", "♀", "⚲"][gender]
    base_color   = [MALE_BASE_COLOR, FEMALE_BASE_COLOR, NONBINARY_BASE_COLOR][gender]
    shadow_color = [MALE_SHADOW_COLOR, FEMALE_SHADOW_COLOR, NONBINARY_SHADOW_COLOR][gender]
    pbDrawTextPositions(self.bitmap, [[gender_text, @spriteBaseX + gender_x, @spriteBaseY + gender_y, false, base_color, shadow_color, true]])
    pbSetSystemFont(self.bitmap)
  end
  
  def draw_status
    return if @battler.status == :NONE
    if @battler.status == :POISON && @battler.statusCount < 0   # Badly poisoned
      s = GameData::Status.count - 2
    else
      s = GameData::Status.get(@battler.status).icon_position
    end
    return if s < 0
    pbDrawImagePositions(self.bitmap, [
      ["Graphics/UI/Battle/icon_statuses", @spriteBaseX + (onPlayerSide ? 2 : 176), @spriteBaseY + 20,
       0, s * STATUS_ICON_HEIGHT, -1, STATUS_ICON_HEIGHT]])
    pbSetSmallFont(self.bitmap)
    pbDrawTextPositions(self.bitmap, [
      [_INTL("{1}", @battler.statusCount.abs),@spriteBaseX + (onPlayerSide ? 2 : 176) + 4, @spriteBaseY + 38, 2, NAME_BASE_COLOR, NAME_SHADOW_COLOR, true]])
    pbSetSystemFont(self.bitmap)
  end
  
  def draw_shiny_icon
    return
    return if !@battler.shiny?
    shiny_x = (@battler.opposes?(0)) ? 206 : -6   # Foe's/player's
    pbDrawImagePositions(self.bitmap, [["Graphics/UI/shiny", @spriteBaseX + shiny_x, @spriteBaseY + 36]])
  end
  
  def draw_special_form_icon
    # Mega Evolution/Primal Reversion icon
    if @battler.mega?
      pbDrawImagePositions(self.bitmap, [["Graphics/UI/Battle/icon_mega", @spriteBaseX + 8, @spriteBaseY + 34]])
    elsif @battler.primal?
      filename = nil
      if @battler.isSpecies?(:GROUDON)
        filename = "Graphics/UI/Battle/icon_primal_Groudon"
      elsif @battler.isSpecies?(:KYOGRE)
        filename = "Graphics/UI/Battle/icon_primal_Kyogre"
      end
      primalX = (@battler.opposes?) ? 208 : -28   # Foe's/player's
      pbDrawImagePositions(self.bitmap, [[filename, @spriteBaseX + primalX, 4]]) if filename
    end
  end
  
  def draw_owned_icon
    return if !@battler.owned? || !@battler.opposes?(0)   # Draw for foe Pokémon only
    pbDrawImagePositions(self.bitmap, [["Graphics/UI/Battle/icon_own", @spriteBaseX - 34, @spriteBaseY + 4]])
  end
  
  def draw_uncatchable_icon
    return if !@battler.opposes?(0)   # Draw for foe Pokémon only
    pbDrawImagePositions(self.bitmap, [["Graphics/UI/Battle/icon_uncatchable", @spriteBaseX - 34, @spriteBaseY + 4]])
  end
  
  def refresh
    self.bitmap.clear
    return if !@battler.pokemon
    draw_background
    draw_name
    draw_level
    draw_gender
    draw_status
    draw_shiny_icon
    draw_special_form_icon
    @battler.battle.disablePokeBalls ? draw_uncatchable_icon : draw_owned_icon
    refresh_hp
    refreshExp
    @statuses.refresh
  end
  
  def refresh_hp
    @hpNumbers.bitmap.clear
    return if !@battler.pokemon
    # Show HP numbers
    if @showHP
      pbDrawNumber(self.hp, @hpNumbers.bitmap, 62, 2, 1)
      pbDrawNumber(-1, @hpNumbers.bitmap, 62, 2)   # / char
      pbDrawNumber(@battler.totalhp, @hpNumbers.bitmap, 78, 2)
    elsif Supplementals::SHOW_OPPOSING_HP_PERCENT
      hpPercent = [(self.hp * 100.0 / @battler.totalhp), 1].max
      hpPercent = 0 if self.hp <= 0
      hpText = sprintf("%d%%", hpPercent.round)
      pbDrawNumber(hpText, @hpNumbers.bitmap, 46, 2, 2)
    end
    # Resize HP bar
    w = 0
    if self.hp > 0
      w = @hpBarBitmap.width.to_f * self.hp / @battler.totalhp
      w = 1 if w < 1
      # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
      #       fit in with the rest of the graphics which are doubled in size.
      w = ((w / 2.0).round) * 2
    end
    @hpBar.src_rect.width = w
    hpColor = 0                                  # Green bar
    hpColor = 1 if self.hp <= @battler.totalhp / 2   # Yellow bar
    hpColor = 2 if self.hp <= @battler.totalhp / 4   # Red bar
    @hpBar.src_rect.y = hpColor * @hpBarBitmap.height / 3
    if self.hp > @battler.totalhp
      top_layer = ((self.hp - 1) / @battler.totalhp).floor - 1
      if top_layer < 0
        @hpBarEx.src_rect.width = 0
        @hpBarEx2.src_rect.width = 0
      else
        # Resize HP bar
        w = @hpBarBitmap.width.to_f * (self.hp - (@battler.totalhp * (top_layer + 1))) / @battler.totalhp
        w = 1 if w < 1
        # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
        #       fit in with the rest of the graphics which are doubled in size.
        w = ((w / 2.0).round) * 2
        @hpBarEx2.src_rect.width = w
        @hpBarEx2.src_rect.y = (top_layer % 8) * @hpBarExBitmap.height / 8
        if top_layer == 0
          @hpBarEx.src_rect.width = 0
        else
          @hpBarEx.src_rect.y = ((top_layer - 1) % 8) * @hpBarExBitmap.height / 8
          @hpBarEx.src_rect.width = @hpBarExBitmap.width
        end
      end
    else
      @hpBarEx.src_rect.width = 0
      @hpBarEx2.src_rect.width = 0
    end
  end
  
  def refreshExp
    return if !@showExp
    w = exp_fraction * @expBarBitmap.width
    # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
    #       fit in with the rest of the graphics which are doubled in size.
    w = ((w / 2).round) * 2
    @expBar.src_rect.width = w
  end
  
  def update_hp_animation
    return if !animating_hp?
    @anim_hp_current = lerp(@anim_hp_start, @anim_hp_end, HP_BAR_CHANGE_TIME,
                            @anim_hp_timer_start, System.uptime)
    # Refresh the HP bar/numbers
    refresh_hp
    # End the HP bar filling animation
    if @anim_hp_current == @anim_hp_end
      @anim_hp_start = nil
      @anim_hp_end = nil
      @anim_hp_timer_start = nil
      @anim_hp_current = nil
    end
  end
  
  def updateExpAnimation
    return if !@animatingExp
    if !@showExp   # Not showing the Exp bar, no need to waste time animating it
      @currentExp = @endExp
      @animatingExp = false
      return
    end
    if @currentExp < @endExp   # Gaining Exp
      @currentExp += @expIncPerFrame
      @currentExp = @endExp if @currentExp >= @endExp
    elsif @currentExp > @endExp   # Losing Exp
      @currentExp -= @expIncPerFrame
      @currentExp = @endExp if @currentExp <= @endExp
    end
    # Refresh the Exp bar
    refreshExp
    return if @currentExp != @endExp   # Exp bar still has more to animate
    # Exp bar is completely filled, level up with a flash and sound effect
    if @currentExp >= @rangeExp
      if @expFlash == 0
        pbSEStop
        @expFlash = Graphics.frame_rate / 5
        pbSEPlay("Pkmn exp full")
        self.flash(Color.new(64, 200, 248, 192), @expFlash)
        @sprites.each do |i|
          i[1].flash(Color.new(64, 200, 248, 192), @expFlash) if !i[1].disposed?
        end
      else
        @expFlash -= 1
        @animatingExp = false if @expFlash == 0
      end
    else
      pbSEStop
      # Exp bar has finished filling, end animation
      @animatingExp = false
    end
  end
  
  def refreshBossGauges
    return if @battler.index != 1 || @sideSize > 1
  
    x_offset = @spriteBaseX
    y_offset = 48
  
    base = Color.new(248,248,248)
    shadow = Color.new(15,15,15)
  
    for gauge in pbBoss.gauges
      next if !gauge.enabled
  
      imagepos = []
      textpos = []
  
      case gauge.type
      when PBGauge::Full
        imagepos.push(["Graphics/UI/Battle/boss_gauge.png",x_offset,y_offset,0,0,180,24])
        textpos.push([gauge.name,x_offset + 90,y_offset - 12,2,base,shadow])
      when PBGauge::Half
        imagepos.push(["Graphics/UI/Battle/boss_gauge.png",x_offset,y_offset,0,24,92,24])
        textpos.push([gauge.name,x_offset + 45,y_offset - 12,2,base,shadow])
      when PBGauge::Long
        imagepos.push(["Graphics/UI/Battle/boss_gauge.png",x_offset,y_offset,0,48,180,16])
        textpos.push([gauge.name,x_offset + 8,y_offset - 12,0,base,shadow])
      end
      pbDrawImagePositions(self.bitmap,imagepos)
      pbSetSmallestFont(self.bitmap)
      pbDrawTextPositions(self.bitmap,textpos)
  
      colors = gauge.get_colors
  
      case gauge.type
      when PBGauge::Full
        self.bitmap.fill_rect(
          x_offset+4,y_offset+16,
          172 * gauge.value / gauge.max, 6, colors[1])
        self.bitmap.fill_rect(
          x_offset+4,y_offset+18,
          172 * gauge.value / gauge.max, 2, colors[0])
        y_offset += 24
      when PBGauge::Half
        self.bitmap.fill_rect(
          x_offset+4,y_offset+16,
          84 * gauge.value / gauge.max, 6, colors[1])
        self.bitmap.fill_rect(
          x_offset+4,y_offset+18,
          84 * gauge.value / gauge.max, 2, colors[0])
        x_offset += 88
        if x_offset > @spriteBaseX + 88
          x_offset = @spriteBaseX
          y_offset += 24
        end
      when PBGauge::Long
        x_start = 12 + self.bitmap.text_size(gauge.name).width
        self.bitmap.fill_rect(x_offset+x_start,y_offset+2,178-x_start,12,shadow)
        self.bitmap.fill_rect(
          x_start+x_offset+2,y_offset+4,
          174-x_start, 8, Color.new(71,58,58))
        self.bitmap.fill_rect(
          x_start+x_offset+2,y_offset+6,
          174-x_start, 4, Color.new(61,50,50))
        self.bitmap.fill_rect(
          x_start+x_offset+2,y_offset+4,
          (174-x_start) * gauge.value / gauge.max, 8, colors[1])
        self.bitmap.fill_rect(
          x_start+x_offset+2,y_offset+6,
          (174-x_start) * gauge.value / gauge.max, 4, colors[0])
        y_offset += 14
      end
    end
  end
  
  QUARTER_ANIM_PERIOD = Graphics.frame_rate * 3 / 20
  
  def updatePositions(frameCounter)
    self.x = @spriteX
    self.y = @spriteY
    # Data box bobbing while Pokémon is selected
    if @selected == 1 || @selected == 2   # Choosing commands/targeted or damaged
      case (frameCounter / QUARTER_ANIM_PERIOD).floor
      when 1 then self.y = @spriteY - 2
      when 3 then self.y = @spriteY + 2
      end
    end
  end
  
  def update(frameCounter = 0)
    super()
    # Animate HP bar
    update_hp_animation
    # Animate Exp bar
    updateExpAnimation
    # Update coordinates of the data box
    updatePositions(frameCounter)
    pbUpdateSpriteHash(@sprites)
    @statuses.update
  end
end

class Battle::Scene::CheckMenuTarget < IconSprite

  def initialize(x, y, viewport, content)
    super(x, y, viewport)
    setBitmap("Graphics/UI/Battle/cursor_target")
    self.src_rect = Rect.new(0, 96 * 7, 96, 96)
    self.ox = 48
    self.oy = 48
    self.z = 999991
    @selected = false
    if content.is_a?(Numeric)
      @target_type = content
      @battler = nil
      content = ["Whole Field", "Your Field", "Their Field"][@target_type]
      self.src_rect.y = 96 * 2 if @target_type == 1
      self.src_rect.y = 96 * 4 if @target_type == 2
      @overlay = Sprite.new(viewport)
      @overlay.bitmap = Bitmap.new(self.src_rect.width, self.src_rect.height)
      @overlay.x = self.x
      @overlay.y = self.y
      @overlay.ox = self.ox
      @overlay.oy = self.oy
      @overlay.z = self.z + 1
      pbSetSystemFont(@overlay.bitmap)
      if content.include?(" ")
        pbDrawTextPositions(@overlay.bitmap, [
          [content.split(" ")[0], 47, 36 - 14, 2, Color.new(252, 252, 252), Color.new(15, 15, 15), true],
          [content.split(" ")[1], 47, 36 + 16, 2, Color.new(252, 252, 252), Color.new(15, 15, 15), true]
        ])
      else
        pbDrawTextPositions(@overlay.bitmap, [
          [content, 47, 36, 2, Color.new(252, 252, 252), Color.new(15, 15, 15), true]
        ])
      end
    else
      @target_type = -1
      @battler = content
      self.src_rect.y = 96 * ((@battler.index % 2 == 0) ? 2 : 4)
      @overlay = PokemonIconSprite.new(@battler.pokemon, viewport)
      @overlay.x = self.x
      @overlay.y = self.y
      @overlay.ox = 32
      @overlay.oy = 32
      @overlay.z = self.z + 1
    end
  end

  def x=(value)
    super(value)
    @overlay.x = self.x if @overlay
  end

  def y=(value)
    super(value)
    @overlay.y = self.y if @overlay
  end

  def target_type
    return @target_type
  end

  def battler
    return @battler
  end

  def selected=(value)
    @selected = value
    self.src_rect.x = value ? 96 : 0
  end

  def visible=(value)
    @overlay.visible = value
    super(value)
  end

  def dispose
    @overlay&.dispose
    super
  end

  def update
    super
    if @selected
      self.angle = Math.sin(System.uptime * 4) * 6
    else
      self.angle = 0
    end
  end

end

class Battle::Scene::CheckMenu < IconSprite

  def initialize(viewport, battle)
    @battle = battle
    super(Graphics.width / 2, Graphics.height / 2 + 76, viewport)
    setBitmap("Graphics/UI/Battle/check")
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height / 2
    self.z = 999990
    @stages_bitmap = AnimatedBitmap.new("Graphics/UI/Battle/stat_change")
    @condition_bitmap = AnimatedBitmap.new("Graphics/UI/Battle/condition")
    @effect_scroll = 0
    @effect_index = 0
    @effects = []
    @min_target_index = 3
    @max_target_index = 5
    @target_index = 4
    @target_boxes = []
    allies = []
    enemies = []
    for i in 0...3
      if @battle.battlers[i * 2] && !@battle.battlers[i * 2].fainted?
        allies.push(@battle.battlers[i * 2])
        @min_target_index = 2 - i
      end
      if @battle.battlers[i * 2 + 1] && !@battle.battlers[i * 2 + 1].fainted?
        enemies.push(@battle.battlers[i * 2 + 1])
        @max_target_index = 6 + i
      end
    end
    allies.reverse.each_with_index do |battler, i|
      @target_boxes[2 - i] = Battle::Scene::CheckMenuTarget.new(self.x - 96 * (i + 2), 124, viewport, battler)
    end
    enemies.reverse.each_with_index do |battler, i|
      @target_boxes[6 + i] = Battle::Scene::CheckMenuTarget.new(self.x + 96 * (i + 2), 124, viewport, battler)
    end
    @target_boxes[3] = Battle::Scene::CheckMenuTarget.new(self.x - 96, 124, viewport, 1)
    @target_boxes[4] = Battle::Scene::CheckMenuTarget.new(self.x, 124, viewport, 0)
    @target_boxes[5] = Battle::Scene::CheckMenuTarget.new(self.x + 96, 124, viewport, 2)
    @overlay = Sprite.new(viewport)
    @overlay.bitmap = Bitmap.new(self.bitmap.width, self.bitmap.height)
    @overlay.x = self.x
    @overlay.y = self.y
    @overlay.ox = self.ox
    @overlay.oy = self.oy
    @overlay.z = self.z + 2
    @target_arrow_left = AnimatedSprite.new("Graphics/UI/right_arrow", 8, 40, 28, 2, viewport)
    @target_arrow_left.z = self.z + 3
    @target_arrow_left.x = Graphics.width / 2 - self.ox - 2
    @target_arrow_left.y = 112
    @target_arrow_left.zoom_x = -1
    @target_arrow_left.play
    @target_arrow_right = AnimatedSprite.new("Graphics/UI/right_arrow", 8, 40, 28, 2, viewport)
    @target_arrow_right.z = self.z + 3
    @target_arrow_right.x = Graphics.width / 2 + self.ox + 2
    @target_arrow_right.y = 112
    @target_arrow_right.play
    @effect_arrow = AnimatedSprite.new("Graphics/UI/right_arrow", 8, 40, 28, 2, viewport)
    @effect_arrow.z = self.z + 3
    @effect_arrow.x = Graphics.width / 2 - self.ox - 26
    @effect_arrow.play
    @info = Window_AdvancedTextPokemon.newWithSize("", 162, 388, 454, 126, viewport, 1)
    @info.windowskin = nil
    @info.z = self.z + 2
    @effect_cursor = IconSprite.new(self.x - self.ox, 0, viewport)
    @effect_cursor.setBitmap("Graphics/UI/Battle/check_cursor")
    @effect_cursor.z = self.z + 1
    refresh
  end

  def update
    @target_arrow_left.update
    @target_arrow_right.update
    @effect_arrow.update
    @effect_cursor.opacity = (1 + Math.sin(System.uptime * 4)) * 64 + 128
    for i in 0...9
      if @target_boxes[i]
        @target_boxes[i].update
      end
    end
    new_target_index = @target_index
    new_effect_index = @effect_index
    if Input.repeat?(Input::RIGHT) && !Input.press?(Input::LEFT)
      new_target_index += 1
      if new_target_index > @max_target_index
        new_target_index = @min_target_index
      end
    end
    if Input.repeat?(Input::LEFT) && !Input.press?(Input::RIGHT)
      new_target_index -= 1
      if new_target_index < @min_target_index
        new_target_index = @max_target_index
      end
    end
    if Input.repeat?(Input::DOWN) && !Input.press?(Input::UP)
      new_effect_index += 1
      if new_effect_index >= @effects.length
        new_effect_index = 0
      end
    end
    if Input.repeat?(Input::UP) && !Input.press?(Input::DOWN)
      new_effect_index -= 1
      if new_effect_index < 0
        new_effect_index = @effects.length - 1
      end
    end
    if new_target_index != @target_index
      @target_index = new_target_index
      @effect_index = 0
      @effect_scroll = 0
      refresh
    elsif new_effect_index != @effect_index
      @effect_index = new_effect_index
      if @effect_index >= @effect_scroll + 5
        @effect_scroll = [[@effect_index - 4, @effects.length - 6].min, 0].max
      elsif @effect_index <= @effect_scroll
        @effect_scroll = [@effect_index - 1, 0].max
      end
      refresh_effects
    end
    super
  end

  def refresh
    @target_boxes.each_with_index do |box, i|
      next if box.nil?
      box.selected = (i == @target_index)
    end
    @effects.clear
    target_box = @target_boxes[@target_index]
    if target_box.target_type == -1
      get_battler_effects(target_box.battler)
    elsif target_box.target_type == 0
      get_field_effects
    else
      get_side_effects(@battle.sides[target_box.target_type - 1])
    end
    refresh_effects
  end

  def refresh_effects
    target_center = [[@target_index, @max_target_index - 2].min, @min_target_index + 2].max
    for i in 0...9
      if @target_boxes[i]
        @target_boxes[i].visible = (target_center - i).abs <= 2
        @target_boxes[i].x = self.x + 96 * (i - target_center)
      end
    end
    @target_arrow_left.visible = @target_index > @min_target_index
    @target_arrow_right.visible = @target_index < @max_target_index
    @effect_arrow.y = self.y - self.oy + 28 + 32 * (@effect_index - @effect_scroll)
    @effect_cursor.y = @effect_arrow.y - 6
    textpos = []
    @info.text = ""
    @overlay.bitmap.clear
    @effects.each_with_index do |effect_data, i|
      next if i < @effect_scroll || i >= @effect_scroll + 6
      offset = i - @effect_scroll
      effect = effect_data[0]
      value = effect_data[1]
      shown_value = (value.is_a?(Numeric) && !effect["has_levels"]) ? "?" : "∞"
      if effect["show_value"]
        shown_value = value.to_s
      end
      textpos.push([
        shown_value, 24, 26 + 32 * offset, 2, Color.new(248, 248, 248), Color.new(72, 80, 88)
      ])
      shown_name = effect["name"]
      icons = effect["icons"]
      if effect["has_levels"]
        shown_name = shown_name[value - 1]
        icons = icons[value - 1]
      end
      textpos.push([
        shown_name, 192, 26 + 32 * offset, 2, Color.new(248, 248, 248), Color.new(72, 80, 88)
      ])
      icons.each_with_index do |icon_id, j|
        icon_id = getID(BattleStatus, icon_id) if icon_id.is_a?(Symbol)
        if icon_id > 0
          icon_x = (icon_id * 32) % 512
          icon_y = (icon_id / 16).floor * 32
          @overlay.bitmap.blt(376 - (icons.length - 1) * 16 + j * 32, 26 + 32 * offset, @condition_bitmap.bitmap, Rect.new(icon_x, icon_y, 32, 32))
        else
          # Stat Change
          icon_x = (-icon_id * 32) % 192
          icon_y = (-icon_id / 6).floor * 32
          @overlay.bitmap.blt(376 - (icons.length - 1) * 16 + j * 32, 26 + 32 * offset, @stages_bitmap.bitmap, Rect.new(icon_x, icon_y, 32, 32))
        end
      end
      if i == @effect_index
        if effect["has_levels"]
          @info.text = effect["description"][value - 1]
        else
          @info.text = effect["description"]
        end
      end
    end
    pbDrawTextPositions(@overlay.bitmap, textpos)
  end

  def get_battler_effects(battler)
    if battler.status != :NONE
      if battler.statusCount >= 0
        @effects.push([BattleStatus::STATUS_EFFECTS[battler.status], battler.statusCount])
      else
        @effects.push([BattleStatus::STRONG_STATUS_EFFECTS[battler.status], battler.statusCount.abs])
      end
    end
    [:ATTACK, :SPECIAL_ATTACK, :DEFENSE, :SPECIAL_DEFENSE, :SPEED].each_with_index do |stat, i|
      if battler.stages[stat] != 0
        stage = battler.stages[stat]
        change = [
          "75%", "5/7 (~71.5%)", "2/3", "60%", "50%", "1/3",
          "",
          "50%", "100%", "150%", "200%", "250%", "300%"
        ][stage + 6]
        @effects.push([{
          "name"        => stage > 0 ?
            _INTL("+{1} {2}", stage,  GameData::Stat.get(stat).name) :
            _INTL("-{1} {2}", -stage, GameData::Stat.get(stat).name),
          "default"     => false,
          "icons"       => [
            stage > 0 ?
              -(12 * i - 1 + stage) :
              -(12 * i + 5 - stage)
          ],
          "description" => stage > 0 ?
            _INTL("The Pokémon's {1} stat is raised by {2}.",  GameData::Stat.get(stat).name, change) :
            _INTL("The Pokémon's {1} stat is lowered by {2}.", GameData::Stat.get(stat).name, change)
        }, true])
      end
    end
    [:ACCURACY, :EVASION].each_with_index do |stat, i|
      if battler.stages[stat] != 0
        stage = battler.stages[stat]
        change = [
          "2/3", "62.5%", "3/7 (~57%)", "50%", "40%", "25%",
          "",
          "1/3", "2/3", "100%", "7/3 (~233%)", "8/3 (~266%)", "200%"
        ][stage + 6]
        @effects.push([{
          "name"        => stage > 0 ?
            _INTL("+{1} {2}", stage,  GameData::Stat.get(stat).name) :
            _INTL("-{1} {2}", -stage, GameData::Stat.get(stat).name),
          "default"     => false,
          "icons"       => [
            stage > 0 ?
              -(12 * (i + 5) - 1 + stage) :
              -(12 * (i + 5) + 5 - stage)
          ],
          "description" => stage > 0 ?
            _INTL("The Pokémon's {1} stat is raised by {2}.", GameData::Stat.get(stat).name, change) :
            _INTL("The Pokémon's {1} stat is lowered by {2}.", GameData::Stat.get(stat).name, change)
        }, true])
      end
    end
    BattleStatus::BATTLER_EFFECTS.each do |key, value|
      if !battler.effects[key].nil? && battler.effects[key] != value["default"]
        @effects.push([value, battler.effects[key]])
      end
    end
    if @effects.length == 0
      @effects.push([{
        "name"        => _INTL("No Effects"),
        "default"     => false,
        "show_value"  => true,
        "icons"       => [],
        "description" => _INTL("The Pokémon has no special effects.")
      }, ""])
    end
  end

  def get_field_effects
    if @battle.field.weather != :None
      @effects.push([
        BattleStatus::WEATHER_EFFECTS[@battle.field.weather],
        @battle.field.weatherDuration == -1 ? "∞" : @battle.field.weatherDuration
      ])
    end
    if @battle.field.terrain != :None
      @effects.push([
        BattleStatus::TERRAIN_EFFECTS[@battle.field.terrain],
        @battle.field.terrainDuration == -1 ? "∞" : @battle.field.terrainDuration
      ])
    end
    BattleStatus::FIELD_EFFECTS.each do |key, value|
      if !@battle.field.effects[key].nil? && @battle.field.effects[key] != value["default"]
        @effects.push([value, @battle.field.effects[key]])
      end
    end
    if @effects.length == 0
      @effects.push([{
        "name"        => _INTL("No Effects"),
        "default"     => false,
        "show_value"  => true,
        "icons"       => [],
        "description" => _INTL("The field has no special effects.")
      }, ""])
    end
  end

  def get_side_effects(side)
    BattleStatus::SIDE_EFFECTS.each do |key, value|
      if !side.effects[key].nil? && side.effects[key] != value["default"]
        @effects.push([value, side.effects[key]])
      end
    end
    if @effects.length == 0
      @effects.push([{
        "name"        => _INTL("No Effects"),
        "default"     => false,
        "show_value"  => true,
        "icons"       => [],
        "description" => _INTL("This side of the field has no special effects.")
      }, ""])
    end
  end

  def dispose
    @stages_bitmap.dispose
    @condition_bitmap.dispose
    @target_boxes.each do |i|
      i&.dispose
    end
    @overlay.dispose
    @target_arrow_left.dispose
    @target_arrow_right.dispose
    @effect_arrow.dispose
    @info.dispose
    @effect_cursor.dispose
    super
  end

end