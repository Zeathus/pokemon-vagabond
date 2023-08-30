class Battle::Scene::Outer

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
    @sprites["border"] = IconSprite.new(0, 0, @viewport)
    @sprites["border"].setBitmap("Graphics/Pictures/Battle/border")
    #@sprites["border"].z = 999
    @sprites["outerOverlay"] = IconSprite.new(0,0,@viewport)
    @sprites["outerOverlay"].setBitmap("Graphics/Pictures/Battle/outer_overlay")
    # Create message box graphic
    messageBox = pbAddSprite("messageBox",0,576-100,
      "Graphics/Pictures/Battle/overlay_message",@viewport)
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
    xPos = [148,386,148,386]
    yPos = [482,482,528,528]
    for i in 0...4
      @sprites[_INTL("command_{1}",i)] = OuterCommandSprite.new(xPos[i],yPos[i],@viewport,@sprites["commandWindow"],i)
      @sprites[_INTL("command_{1}",i)].z = 1
    end
    @sprites["moveInfo"] = OuterMoveInfo.new(@viewport,@sprites["fightWindow"])
    @sprites["moveInfo"].z = 1
    # Create targeting window
    @sprites["targetWindow"] = Battle::Scene::TargetMenu.new(@viewport, 200, @battle.sideSizes)
    @sprites["targetWindow"].z = 1
    for i in 0...3
      @sprites[_INTL("switch_{1}", i)] = OuterSwitchBox.new(@viewport, i)
      @sprites[_INTL("switch_{1}", i)].z = 3
      @sprites[_INTL("switch_{1}", i)].visible = false
    end
    @sprites["switch_cursor"] = IconSprite.new(0, 0, @viewport)
    @sprites["switch_cursor"].setBitmap("Graphics/Pictures/Battle/switch_cursor")
    @sprites["switch_cursor"].z = 4
    @sprites["switch_cursor"].visible = false
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
    for i in 0...4
        @sprites[_INTL("command_{1}",i)].visible = (windowType==COMMAND_BOX)
    end
    @sprites["moveInfo"].visible = (windowType==FIGHT_BOX)
  end

  def update(cw=nil)
    for i in 0...4
      @sprites[_INTL("command_{1}",i)].update
    end
    for i in 0...4
      @sprites[_INTL("info_{1}",i)].update if @sprites[_INTL("info_{1}",i)]
    end
    @sprites["moveInfo"].update
  end

  def dispose
    @viewport.dispose
  end

  def pbChooseSwitch(idxBattler, canCancel = false, mode=0)
    partyPos = @battle.pbPartyOrder(idxBattler)
    partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    pokemon = @battle.pbPlayerDisplayParty(idxBattler)
    if mode == 1 || mode == 2
      pokemon = $player.party
    elsif mode == 4
      pokemon = $player.inactive_party
      mode = 1
    end

    @battle.scene.pbShowWindow(BLANK)
    for i in 0...3
      @sprites[_INTL("switch_{1}", i)].party_length = pokemon.length
      @sprites[_INTL("switch_{1}", i)].visible = (i < pokemon.length)
      @sprites[_INTL("switch_{1}", i)].pokemon = pokemon[i]
      @sprites[_INTL("switch_{1}", i)].active = (i == 0)
    end
    @sprites["switch_cursor"].x = 128 + (170 * (3 - pokemon.length) * 0.5)
    @sprites["switch_cursor"].y = 478
    @sprites["switch_cursor"].visible = true
    selected_index = 0
    new_index = selected_index

    loop do
      @battle.scene.pbGraphicsUpdate
      @battle.scene.pbInputUpdate
      @battle.scene.pbFrameUpdate
      for i in 0...3
        @sprites[_INTL("switch_{1}", i)].update if i == selected_index
      end
      if Input.trigger?(Input::LEFT)
        new_index = (new_index - 1) % pokemon.length
      end
      if Input.trigger?(Input::RIGHT)
        new_index = (new_index + 1) % pokemon.length
      end
      if new_index != selected_index
        pbPlayCursorSE
        selected_index = new_index
        @sprites["switch_cursor"].x = 128 + 170 * (selected_index + (3 - pokemon.length) * 0.5)
        for i in 0...3
          @sprites[_INTL("switch_{1}", i)].active = (i == selected_index)
        end
      end
      if Input.trigger?(Input::BACK) && canCancel
        pbPlayDecisionSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        idxPartyRet = -1
        if mode == 1 || mode == 2
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
          command = @battle.scene.pbShowCommands("", commands, commands.length)
          if (cmdSwitch >= 0 && command == cmdSwitch) ||   # Switch In
            (cmdBoxes >= 0 && command == cmdBoxes)        # Send to Boxes
            for i in 0...3
              @sprites[_INTL("switch_{1}", i)].visible = false
            end
            @sprites["switch_cursor"].visible = false
            break if yield idxPartyRet, @battle.scene
            for i in 0...3
              @sprites[_INTL("switch_{1}", i)].visible = (i < pokemon.length)
            end
            @sprites["switch_cursor"].visible = true
            @battle.scene.pbShowWindow(BLANK)
          elsif cmdSummary >= 0 && command == cmdSummary   # Summary
            pbSummary(pokemon, selected_index)
          end
        end
      end
    end

    for i in 0...3
      @sprites[_INTL("switch_{1}", i)].visible = false
    end
    @sprites["switch_cursor"].visible = false

    @battle.scene.pbShowWindow(COMMAND_BOX)
  end

  def pbSummary(party, pkmnid)
    oldsprites = pbFadeOutAndHide(@sprites)
    scene = PokemonSummaryScene.new(true)
    screen = PokemonSummary.new(scene)
    screen.pbStartScreen(party, pkmnid)
    pbFadeInAndShow(@sprites, oldsprites)
  end

end

class OuterMoveBox < IconSprite

  def initialize(viewport,parent,pos)
    @parent = parent
    @pos = pos
    x = 132
    y = 482
    x += 186 if @pos&1==1
    y += 46  if @pos>1
    super(x,y,viewport)
    setBitmap("Graphics/Pictures/Battle/move_buttons")
    self.src_rect = Rect.new(0,0,182,42)
    @overlay = SpriteWrapper.new(viewport)
    @overlay.bitmap = Bitmap.new(self.src_rect.width,self.src_rect.height)
    @overlay.x = self.x
    @overlay.y = self.y
    @overlay.z = self.z + 1
  end

  def refresh(move,selected=false)
    @overlay.bitmap.clear
    if !move
      self.src_rect.x = -182
      self.src_rect.y = -42
      return
    end
    type_id = GameData::Type.get(move.type).icon_position
    self.src_rect.x = selected ? 182 : 0
    self.src_rect.y = type_id * 42
    #moveNameBase = PokeBattle_SceneConstants::MESSAGE_BASE_COLOR
    moveNameBase = self.bitmap.get_pixel(2,self.src_rect.y+2)
    moveNameShadow = Battle::Scene::MESSAGE_SHADOW_COLOR
    textPos = [[move.name,92,12,2,moveNameBase,moveNameShadow]]
    pbSetSystemFont(@overlay.bitmap)
    pbDrawTextPositions(@overlay.bitmap,textPos)
  end

  def opacity=(value)
    super(value)
    @overlay.opacity = value
  end

  def color=(value)
    super(value)
    @overlay.color = value
  end

  def visible=(value)
    super(value)
    @overlay.visible = value
  end

  def z=(value)
    super(value)
    @overlay.z = self.z + 1
  end

  def dispose
    @overlay.dispose
    super
  end
end

class OuterMoveInfo < IconSprite

  def initialize(viewport,parent)
    super(502,478,viewport)
    setBitmap("Graphics/Pictures/Battle/outer_move_info")
    @typeBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @categoryBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/category"))
    @overlay = SpriteWrapper.new(viewport)
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
    @overlay.bitmap.blt(64,6,@typeBitmap.bitmap,Rect.new(0,28*GameData::Type.get(move.type).icon_position,64,28))
    @overlay.bitmap.blt(64,62,@categoryBitmap.bitmap,Rect.new(0,28*move.category,64,28))
    textPos = []
    powerString = (move.baseDamage <= 0) ? "-" : move.baseDamage.to_s
    textPos.push([powerString,28,18,2,base,shadow])
    accString = (move.accuracy <= 0) ? "-" : (move.accuracy.to_s + "%")
    textPos.push([accString,28,54,2,base,shadow])
    textPos.push([move.pp.to_s,40,76,2,base,shadow])
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
    self.bitmap  = @contents
    pbSetSmallestFont(self.bitmap)
    @parent = parent
    pos = (pos + 2) % 4 if pos % 2 == 0 && boxCount >= 3
    pos = (pos + 2) % 4 if pos % 2 == 1 && boxCount >= 4
    @pos = pos
    @statX = [96,674,96,674][pos]
    @statY = [484,26,26,484][pos]
    @affinityX = (pos % 2 == 1) ? @statX - 2 : @statX - 66
    @affinityY = (pos != 1 && pos != 2) ? @statY - 60 : @statY + 120
    @battler = parent.battler
    @stages = {}
    for i in [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED,:ACCURACY,:EVASION]
      @stages[i] = @battler.stages[i]
    end
    @fainted = @battler.fainted?
    @boxVisible = @parent.visible
    @typeBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @pkmnSprite = PokemonIconSprite.new(@battler.pokemon,viewport)
    @pkmnSprite.visible = false
    @pkmnX = (pos % 2 == 1) ? @statX - 2 : @statX - 66
    @pkmnY = (pos != 1 && pos != 2) ? @statY - 170 : @statY + 170
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
    self.bitmap.clear
    @pkmnSprite.visible = @parent.visible
    return if !@parent.visible || !@battler || @battler.fainted?
    colors=[
      Color.new(248,248,248),Color.new(33,29,29),
      Color.new(160,160,168),Color.new(80,80,80),
      Color.new(140,225,140),Color.new(0,150,0),
      Color.new(225,140,140),Color.new(150,0,0)]
    pokemon=@parent.battler
    textPos=[]
    i = 0; j = 0
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
        statNameX += (@pos&1 == 1) ? 59 : -61
        textPos.push([stageStr,@statX,@statY+18*i,2,c[0],c[1]])
        textPos.push([statNames[j],statNameX,@statY+18*i,2,c[0],c[1]])
        i+=1
        break if i > 4
      end
      j+=1
    end
    pbDrawTextPositions(self.bitmap,textPos)
    self.bitmap.blt(@affinityX,@affinityY,@typeBitmap.bitmap,Rect.new(0,28*GameData::Type.get(@battler.pokemon.affinities[0]).icon_position,64,28))
  end

  def dispose
    @pkmnSprite.dispose
    @typeBitmap.dispose
    super
  end

  def update
    super
    @frame = (@frame + 1) % 2
    mustRefresh = false
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
  end

end

class OuterCommandSprite < IconSprite
  
  def initialize(x,y,viewport=nil,parent,pos)
    super(x,y,viewport)
    @parent  = parent
    @pos = pos
    setBitmap(_INTL("Graphics/Pictures/Battle/options"))
    refresh
  end

  def getRect(i)
    return (@parent.index==@pos) ? Rect.new(234,i*44,234,44) : Rect.new(0,i*44,234,44)
  end
  
  def dispose
    super
  end

  def visible=(value)
    super(value)
    refresh if value
  end
  
  def refresh
    if @parent.mode==1 && @pos==3
      self.src_rect = getRect(5)
    else
      self.src_rect = getRect(@pos)
    end
  end
  
  def update
    super
    refresh
  end
end

class OuterSwitchBox < IconSprite

  def initialize(viewport=nil,pos)
    super(0, 0, viewport)
    @pos = pos
    @party_member = 0
    @party_length = 3
    @pokemon = nil
    @overlay = Sprite.new(viewport)
    @overlay.bitmap = Bitmap.new(170, 112)
    setBitmap(_INTL("Graphics/Pictures/Battle/switch"))
    @pkmnsprite = PokemonIconSprite.new(@pokemon, viewport)
    @pkmnsprite.setOffset(PictureOrigin::CENTER)
    @pkmnsprite.active = false
    @statuses=AnimatedBitmap.new(_INTL("Graphics/Pictures/Party/statuses"))
    @hpbar = AnimatedBitmap.new("Graphics/Pictures/Battle/switch_overlay_hp")
    refresh
  end

  def dispose
    @overlay.dispose
    @pkmnsprite.dispose
    @hpbar.dispose
    @statuses.dispose
    super
  end

  def visible=(value)
    super(value)
    @overlay.visible = value
    @pkmnsprite.visible = value
  end

  def pokemon=(value)
    @pokemon = value
    refresh
  end

  def active=(value)
    @pkmnsprite.active = value
  end

  def party_length=(value)
    @party_length = value
  end

  def party_member=(value)
    @party_member = value
  end

  def z=(value)
    super(value)
    @overlay.z = value + 3
    @pkmnsprite.z = value + 4
  end

  def tone=(value)
    super(value)
    @overlay.tone = value
    @pkmnsprite.tone = value
  end

  def color=(value)
    super(value)
    @overlay.color = value
    @pkmnsprite.color = value
  end

  def opacity=(value)
    super(value)
    @overlay.opacity = value
    @pkmnsprite.opacity = value
  end
  
  def refresh
    base   = Color.new(248, 248, 248)
    shadow = Color.new( 15,  15,  15)
    self.src_rect = Rect.new(0, @party_member * 96, 172, 96)
    self.x = 128 + 170 * (@pos + (3 - @party_length) * 0.5)
    self.y = 478

    @pkmnsprite.pokemon = @pokemon
    @pkmnsprite.x = self.x + 44
    @pkmnsprite.y = self.y + 28

    @overlay.x = self.x
    @overlay.y = self.y
    @overlay.bitmap.clear
    if @pokemon
      pbSetSmallestFont(@overlay.bitmap)
      textpos = [
        [_INTL("{1}", @pokemon.level), 24, 52, 2, base, shadow],
        [@pokemon.name.upcase, 44, 52, 0, base, shadow]
      ]
      pbDrawTextPositions(@overlay.bitmap, textpos)
      imagepos = []
      for i in 0...@pokemon.types.length
        imagepos.push(["Graphics/Pictures/type_icons.png", 74 + ((@pokemon.types.length == 1) ? 16 : (i * 30)), 8, 56, 28 * GameData::Type.get(@pokemon.types[i]).icon_position, 28, 28])
      end
      imagepos.push(["Graphics/Pictures/type_icons.png", 136, 8, 56, 28 * GameData::Type.get(@pokemon.affinity).icon_position, 28, 28])
      pbDrawImagePositions(@overlay.bitmap, imagepos)

      hptextpos = [[_ISPRINTF("{1: 3d}/{2: 3d}", @pokemon.hp, @pokemon.totalhp),
         @hpX,@hpY,2,base,shadow]]
      hpgauge=@pokemon.totalhp==0 ? 0 : ((@pokemon.hp * 57 / @pokemon.totalhp).floor * 2)
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
      @overlay.bitmap.fill_rect(46,80,hpgauge,2,hpcolors[hpzone*2])
      @overlay.bitmap.fill_rect(46,82,hpgauge,4,hpcolors[hpzone*2+1])
      @overlay.bitmap.fill_rect(46,86,hpgauge,2,hpcolors[hpzone*2])
      @overlay.bitmap.blt(4, 76, @hpbar.bitmap, Rect.new(0, @party_member * 16, @hpbar.width, 16))
      if @pokemon.hp == 0 || @pokemon.status != :NONE
        status = (@pokemon.hp == 0) ? 5 : (GameData::Status.get(@pokemon.status).icon_position)
        statusrect=Rect.new(0, 32 * status, 32, 32)
        @overlay.bitmap.blt(12, 68, @statuses.bitmap, statusrect)
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
      bgFilename = ["Graphics/Pictures/Battle/databox_normal",
                    "Graphics/Pictures/Battle/databox_normal_foe"][@battler.index % 2]
    else   # Multiple Pokémon on side, use the thin dara box BG
      bgFilename = ["Graphics/Pictures/Battle/databox_thin",
                    "Graphics/Pictures/Battle/databox_thin_foe"][@battler.index % 2]
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
      @spriteX = self.viewport.rect.width - 244
      @spriteY = self.viewport.rect.height - 112
      @spriteBaseX = 34
    else
      @spriteX = -12
      @spriteY = 36
      @spriteBaseX = 16
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
      @spriteX += [-12,  12,  0,  0][@battler.index]
      @spriteY += [-20, -34, 34, 20][@battler.index]
    when 3
      @spriteX += [-12,  12, -6,  6,  0,  0][@battler.index]
      @spriteY += [-42, -46,  4,  0, 50, 46][@battler.index]
    end
  end
  
  def initializeOtherGraphics(viewport)
    # Create other bitmaps
    @numbersBitmap = AnimatedBitmap.new("Graphics/Pictures/Battle/icon_numbers")
    @hpBarBitmap   = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/overlay_hp_vb{1}", onPlayerSide ? "" : "_foe"))
    @hpBarExBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Battle/overlay_hp_extra{1}", onPlayerSide ? "" : "_foe"))
    @expBarBitmap  = AnimatedBitmap.new("Graphics/Pictures/Battle/overlay_exp")
    @numbersWhiteBitmap = AnimatedBitmap.new("Graphics/Pictures/Battle/icon_numbers_white")
    # Create sprite to draw HP numbers on
    @hpNumbers = BitmapSprite.new(124, 16, viewport)
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
    super
  end
  
  def x=(value)
    super
    @hpBar.x     = value + @spriteBaseX + (onPlayerSide ? 12 : 38)
    @hpBarEx.x   = @hpBar.x
    @hpBarEx2.x  = @hpBar.x
    @expBar.x    = value + @spriteBaseX + 6
    @hpNumbers.x = value + @spriteBaseX + (@showHP ? 40 : 60)
  end
  
  def y=(value)
    super
    @hpBar.y     = value + @spriteBaseY + 28
    @hpBarEx.y   = @hpBar.y
    @hpBarEx2.y  = @hpBar.y
    @expBar.y    = value + @spriteBaseY + 74
    @hpNumbers.y = value + @spriteBaseY + 28
  end
  
  def z=(value)
    super
    @hpBar.z     = value + 1
    @hpBarEx.z   = @hpBar.z
    @hpBarEx2.z  = @hpBar.z
    @expBar.z    = value + 1
    @hpNumbers.z = value + 2
  end
  
  def opacity=(value)
    super
    @sprites.each do |i|
      i[1].opacity = value if !i[1].disposed?
    end
  end
  
  def visible=(value)
    super
    @sprites.each do |i|
      i[1].visible = value if !i[1].disposed?
    end
    @expBar.visible = (value && @showExp)
  end
  
  def color=(value)
    super
    @sprites.each do |i|
      i[1].color = value if !i[1].disposed?
    end
  end
  
  def battler=(b)
    @battler = b
    self.visible = (@battler && !@battler.fainted?)
  end
  
  def hp
    return (@animatingHP) ? @currentHP : @battler.hp
  end
  
  def exp_fraction
    return 0.0 if @rangeExp == 0
    return (@animatingExp) ? @currentExp.to_f / @rangeExp : @battler.pokemon.exp_fraction
  end
  
  def animateHP(oldHP, newHP, rangeHP)
    @currentHP   = oldHP
    @endHP       = newHP
    @rangeHP     = rangeHP
    # NOTE: A change in HP takes the same amount of time to animate, no matter
    #       how big a change it is.
    @hpIncPerFrame = (newHP - oldHP).abs / (HP_BAR_CHANGE_TIME * Graphics.frame_rate)
    # minInc is the smallest amount that HP is allowed to change per frame.
    # This avoids a tiny change in HP still taking HP_BAR_CHANGE_TIME seconds.
    minInc = (rangeHP * 4) / (@hpBarBitmap.width * HP_BAR_CHANGE_TIME * Graphics.frame_rate)
    @hpIncPerFrame = minInc if @hpIncPerFrame < minInc
    @animatingHP   = true
  end
  
  def animateExp(oldExp, newExp, rangeExp)
    return if rangeExp == 0
    @currentExp     = oldExp
    @endExp         = newExp
    @rangeExp       = rangeExp
    # NOTE: Filling the Exp bar from empty to full takes EXP_BAR_FILL_TIME
    #       seconds no matter what. Filling half of it takes half as long, etc.
    @expIncPerFrame = rangeExp / (EXP_BAR_FILL_TIME * Graphics.frame_rate)
    @animatingExp   = true
    pbSEPlay("Pkmn exp gain") if @showExp
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
    if onPlayerSide
      pbDrawTextPositions(self.bitmap,
        [[@battler.name, @spriteBaseX + 10, @spriteBaseY, 0, NAME_BASE_COLOR, NAME_SHADOW_COLOR, true]]
      )
    else
      pbDrawTextPositions(self.bitmap,
        [[@battler.name, @spriteBaseX + 202, @spriteBaseY, 1, NAME_BASE_COLOR, NAME_SHADOW_COLOR, true]]
      )
    end
  end
  
  def draw_level
    # Level number
    lvl_text = _INTL("{1}", @battler.level)
    lvl_x = onPlayerSide ? 174 : 16
    pbDrawTextPositions(self.bitmap,
      [[lvl_text, @spriteBaseX + lvl_x, @spriteBaseY, 0, NAME_BASE_COLOR, NAME_SHADOW_COLOR, true]])
  end
  
  def draw_gender
    gender = @battler.displayGender
    gender_x = onPlayerSide ? 140 : (24 + self.bitmap.text_size(_INTL("{1}", @battler.level)).width)
    gender_text = ["♂", "♀", "⚲"][gender]
    base_color   = [MALE_BASE_COLOR, FEMALE_BASE_COLOR, NONBINARY_BASE_COLOR][gender]
    shadow_color = [MALE_SHADOW_COLOR, FEMALE_SHADOW_COLOR, NONBINARY_SHADOW_COLOR][gender]
    pbDrawTextPositions(self.bitmap, [[gender_text, @spriteBaseX + gender_x, @spriteBaseY + 2, false, base_color, shadow_color, true]])
  end
  
  def draw_status
    return if @battler.status == :NONE
    if @battler.status == :POISON && @battler.statusCount > 0   # Badly poisoned
      s = GameData::Status.count - 2
    else
      s = GameData::Status.get(@battler.status).icon_position
    end
    return if s < 0
    pbDrawImagePositions(self.bitmap, [
      ["Graphics/Pictures/Battle/icon_statuses", @spriteBaseX + (onPlayerSide ? 176 : 2), @spriteBaseY + 20,
       0, s * STATUS_ICON_HEIGHT, -1, STATUS_ICON_HEIGHT]])
    pbSetSmallFont(self.bitmap)
    pbDrawTextPositions(self.bitmap, [
      [_INTL("{1}", @battler.statusCount),@spriteBaseX + (onPlayerSide ? 176 : 2) + 4, @spriteBaseY + 38, 2, NAME_BASE_COLOR, NAME_SHADOW_COLOR, true]])
    pbSetSystemFont(self.bitmap)
  end
  
  def draw_shiny_icon
    return if !@battler.shiny?
    shiny_x = (@battler.opposes?(0)) ? 206 : -6   # Foe's/player's
    pbDrawImagePositions(self.bitmap, [["Graphics/Pictures/shiny", @spriteBaseX + shiny_x, @spriteBaseY + 36]])
  end
  
  def draw_special_form_icon
    # Mega Evolution/Primal Reversion icon
    if @battler.mega?
      pbDrawImagePositions(self.bitmap, [["Graphics/Pictures/Battle/icon_mega", @spriteBaseX + 8, @spriteBaseY + 34]])
    elsif @battler.primal?
      filename = nil
      if @battler.isSpecies?(:GROUDON)
        filename = "Graphics/Pictures/Battle/icon_primal_Groudon"
      elsif @battler.isSpecies?(:KYOGRE)
        filename = "Graphics/Pictures/Battle/icon_primal_Kyogre"
      end
      primalX = (@battler.opposes?) ? 208 : -28   # Foe's/player's
      pbDrawImagePositions(self.bitmap, [[filename, @spriteBaseX + primalX, 4]]) if filename
    end
  end
  
  def draw_owned_icon
    return if !@battler.owned? || !@battler.opposes?(0)   # Draw for foe Pokémon only
    pbDrawImagePositions(self.bitmap, [["Graphics/Pictures/Battle/icon_own", @spriteBaseX + 206, @spriteBaseY + 6]])
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
    draw_owned_icon
    refreshHP
    refreshExp
  end
  
  def refreshHP
    @hpNumbers.bitmap.clear
    return if !@battler.pokemon
    # Show HP numbers
    if @showHP
      pbDrawNumber(self.hp, @hpNumbers.bitmap, 54, 2, 1)
      pbDrawNumber(-1, @hpNumbers.bitmap, 54, 2)   # / char
      pbDrawNumber(@battler.totalhp, @hpNumbers.bitmap, 70, 2)
    elsif Supplementals::SHOW_OPPOSING_HP_PERCENT
      hpPercent = [(self.hp * 100.0 / @battler.totalhp), 1].max
      hpPercent = 0 if self.hp <= 0
      hpText = sprintf("%d%%", hpPercent.round)
      pbDrawNumber(hpText, @hpNumbers.bitmap, 54, 2, 2)
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
  
  def updateHPAnimation
    return if !@animatingHP
    if @currentHP < @endHP      # Gaining HP
      @currentHP += @hpIncPerFrame
      @currentHP = @endHP if @currentHP >= @endHP
    elsif @currentHP > @endHP   # Losing HP
      @currentHP -= @hpIncPerFrame
      @currentHP = @endHP if @currentHP <= @endHP
    end
    # Refresh the HP bar/numbers
    refreshHP
    @animatingHP = false if @currentHP == @endHP
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
        imagepos.push(["Graphics/Pictures/Battle/boss_gauge.png",x_offset,y_offset,0,0,180,24])
        textpos.push([gauge.name,x_offset + 90,y_offset - 12,2,base,shadow])
      when PBGauge::Half
        imagepos.push(["Graphics/Pictures/Battle/boss_gauge.png",x_offset,y_offset,0,24,92,24])
        textpos.push([gauge.name,x_offset + 45,y_offset - 12,2,base,shadow])
      when PBGauge::Long
        imagepos.push(["Graphics/Pictures/Battle/boss_gauge.png",x_offset,y_offset,0,48,180,16])
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
    updateHPAnimation
    # Animate Exp bar
    updateExpAnimation
    # Update coordinates of the data box
    updatePositions(frameCounter)
    pbUpdateSpriteHash(@sprites)
  end
end