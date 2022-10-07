class MoveSelectionSprite < SpriteWrapper
  attr_reader :preselected
  attr_reader :index
  attr_reader :side
  attr_reader :page
  attr_reader :listindex

  def initialize(viewport=nil,fifthmove=false)
    super(viewport)
    @movesel=AnimatedBitmap.new(
      fifthmove ? "Graphics/Pictures/Summary/cursor_move_learn" :
                  "Graphics/Pictures/Summary/cursor_move")
    @frame=0
    @index=0
    @listindex=[0, 0, 0]
    @side=0 # 0 = Left, 1 = Right
    @page=0 # 0 = Level Up, 1 = TM, 2 = Data Chip
    @scroll=[0, 0, 0]
    @fifthmove=fifthmove
    @preselected=false
    @updating=false
    @spriteVisible=true
    refresh
  end

  def dispose
    @movesel.dispose
    super
  end

  def reset
    @listindex = [0, 0, 0]
    @scroll = [0, 0, 0]
    @index = 0
    @side = 0
    @page = 0
    refresh
  end

  def copy(movesel)
    @listindex = movesel.listindex
    @scroll = movesel.allscroll
    @index = movesel.leftindex
    @side = movesel.side
    @page = movesel.page
    refresh
  end

  def leftindex
    return @index
  end

  def index
    if side == 0
      return @index
    else
      return @listindex[@page]
    end
  end

  def index=(value)
    if side == 0
      @index=value
    else
      @listindex[@page]=value
    end
    refresh
  end

  def side=(value)
    @side=value
  end

  def page=(value)
    @page=value
    @index=self.index
    refresh
  end

  def allscroll
    return @scroll
  end

  def scroll
    return @scroll[@page]
  end

  def scroll=(value)
    @scroll[@page] = value
  end

  def preselected=(value)
    @preselected=value
    refresh
  end

  def visible=(value)
    super
    @spriteVisible=value if !@updating
  end

  def refresh
    w=@movesel.width
    h=@movesel.height/2
    if @side == 0
      if @fifthmove
        self.x=260
        self.y=46
        self.y+=62 * self.index
        self.y+=18 if self.index==4
      else
        self.x=96
        self.y=134
        self.y+=self.index * 86
      end
    else
      self.x=530
      self.y=134
      self.y+=(self.index - self.scroll) * 86
    end
    self.bitmap=@movesel.bitmap
    if self.preselected
      self.src_rect.set(0,h,w,h)
    else
      self.src_rect.set(0,0,w,h)
    end
  end

  def update
    @updating=true
    super
    @movesel.update
    @updating=false
    refresh
  end
end


class PokemonSummaryScene
  def initialize(inbattle=false)
    @inbattle=inbattle
  end

  def pbPokerus(pkmn)
    return pkmn.pokerusStage
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(party,partyindex,machinemove=nil)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @party=party
    @partyindex=partyindex
    @pokemon=@party[@partyindex]
    @machinemove = machinemove
    @listMoves = [
      pbGetLevelUpMoves(@pokemon),
      pbGetTMMoves(@pokemon),
      pbGetDataChipMoves(@pokemon)
    ]
    @sprites={}
    @typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @effortbitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/Summary/effort_bar"))
    @buttonbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Summary/move_slot_learn"))
    @sprites["bg"]=IconSprite.new(0,0,@viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Summary/summarybg")
    @sprites["bg"].z=0
    for i in 0...@party.length
      @sprites[_INTL("pokebar{1}",i)]=IconSprite.new(0,0,@viewport)
      @sprites[_INTL("pokebar{1}",i)].setBitmap("Graphics/Pictures/Summary/bar")
      @sprites[_INTL("pokebar{1}",i)].x=14
      @sprites[_INTL("pokebar{1}",i)].y=36+i*56
      @sprites[_INTL("pokebar{1}",i)].z=1
      @sprites[_INTL("pokeicon{1}",i)]=PokemonBoxIcon.new(@party[i],@viewport)
      @sprites[_INTL("pokeicon{1}",i)].x=10
      @sprites[_INTL("pokeicon{1}",i)].y=18+i*56
      @sprites[_INTL("pokeicon{1}",i)].z=2
      if @partyindex==i
        @sprites[_INTL("pokebar{1}",i)].setBitmap("Graphics/Pictures/Summary/bar_selected")
        @sprites[_INTL("pokebar{1}",i)].x=4
        @sprites[_INTL("pokeicon{1}",i)].x=0
      end
    end
    @sprites["bg2"]=IconSprite.new(0,0,@viewport)
    if @pokemon.egg?
      @sprites["bg2"].setBitmap(_INTL("Graphics/Pictures/Summary/summarybg9"))
    else
      @sprites["bg2"].setBitmap(_INTL("Graphics/Pictures/Summary/summarybg{1}",GameData::Type.get(@pokemon.type1).id_number))
    end
    @sprites["bg2"].z=3
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].z=4
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"].z=5
    @sprites["pokemon"]=PokemonSprite.new(@viewport)
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["pokemon"].setOffset(PictureOrigin::TopLeft)
    @sprites["pokemon"].mirror=false
    @sprites["pokemon"].color=Color.new(0,0,0,0)
    @sprites["pokemon"].z=6
    pbPositionPokemonSprite(@sprites["pokemon"],396,156)
    @sprites["pokeicon"]=PokemonBoxIcon.new(@pokemon,@viewport)
    @sprites["pokeicon"].x=14
    @sprites["pokeicon"].y=52
    @sprites["pokeicon"].mirror=false
    @sprites["pokeicon"].visible=false
    @sprites["pokeicon"].z=7
    @sprites["movepresel"]=MoveSelectionSprite.new(@viewport)
    @sprites["movepresel"].visible=false
    @sprites["movepresel"].preselected=true
    @sprites["movepresel"].z=7
    @sprites["movesel"]=MoveSelectionSprite.new(@viewport)
    @sprites["movesel"].visible=false
    @sprites["movesel"].z=8
    keybinds = [
      [[Input::LEFT, Input::RIGHT], "Go to Moves"]
    ]
    keybinds.push([[Input::UP, Input::DOWN], "Change Pokemon"]) if @party.length > 1
    keybinds.push([Input::BACK, "Exit"])
    for i in 0...keybinds.length
      sprite = KeybindSprite.new(keybinds[i][0], keybinds[i][1], 116, 8+28*i, @viewport)
      sprite.z = 10
      @sprites[_INTL("stats_keybinds_{1}", i)] = sprite
    end
    keybinds = [
      [[Input::LEFT, Input::RIGHT], "Go to Stats"]
    ]
    keybinds.push([[Input::UP, Input::DOWN], "Change Pokemon"]) if @party.length > 1
    keybinds.push([Input::BACK, "Exit"])
    for i in 0...keybinds.length
      sprite = KeybindSprite.new(keybinds[i][0], keybinds[i][1], 116, 8+28*i, @viewport)
      sprite.z = 10
      @sprites[_INTL("moves_keybinds_{1}", i)] = sprite
    end
    sprite = KeybindSprite.new(Input::USE, "Edit Moves", 190, 8+28*(keybinds.length-1), @viewport)
    sprite.z = 10
    @sprites[_INTL("moves_keybinds_{1}", keybinds.length)] = sprite
    keybinds = [
      [[Input::LEFT, Input::RIGHT, Input::UP, Input::DOWN], "Choose"]
    ]
    keybinds.push([Input::ACTION, "Switch to TMs"])
    keybinds.push([Input::BACK, "Exit"])
    for i in 0...keybinds.length
      sprite = KeybindSprite.new(keybinds[i][0], keybinds[i][1], 116, 8+28*i, @viewport)
      sprite.z = 10
      @sprites[_INTL("editmoves_keybinds_{1}", i)] = sprite
    end
    sprite = KeybindSprite.new(Input::USE, "Select Move", 190, 8+28*(keybinds.length-1), @viewport)
    sprite.z = 10
    @sprites[_INTL("editmoves_keybinds_{1}", keybinds.length)] = sprite
    if @machinemove
      @page=1
      @sprites["movesel"].page = 1
      @sprites["movesel"].side = 1
      tm_list = @listMoves[1]
      for i in 0...tm_list.length
        if tm_list[i][0] == @machinemove
          @sprites["movesel"].index = i
          @sprites["movesel"].scroll = [[tm_list.length - 5, i - 1].min, 0].max
          break
        end
      end
      drawPageMoves(@pokemon)
    else
      @page=0
      drawPageInfo(@pokemon)
    end
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbStartForgetScene(party,partyindex,moveToLearn)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @party=party
    @partyindex=partyindex
    @pokemon=@party[@partyindex]
    @sprites={}
    @page=3
    @typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @sprites["bg"]=IconSprite.new(0,0,@viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Summary/summarybg")
    @sprites["bg"].z=0
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].z=4
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"].z=5
    @sprites["pokeicon"]=PokemonBoxIcon.new(@pokemon,@viewport)
    @sprites["pokeicon"].x=14
    @sprites["pokeicon"].y=-12
    @sprites["pokeicon"].mirror=false
    @sprites["pokeicon"].z=7
    @sprites["movesel"]=MoveSelectionSprite.new(@viewport,moveToLearn>0)
    @sprites["movesel"].visible=false
    @sprites["movesel"].visible=true
    @sprites["movesel"].index=0
    @sprites["movesel"].z=8
    drawSelectedMove(@pokemon,moveToLearn,@pokemon.moves[0].id)
    pbFadeInAndShow(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @effortbitmap.dispose
    @buttonbitmap.dispose
    @viewport.dispose
  end

  #def drawMarkings(bitmap,x,y,width,height,markings)
  #  totaltext=""
  #  oldfontname=bitmap.font.name
  #  oldfontsize=bitmap.font.size
  #  oldfontcolor=bitmap.font.color
  #  bitmap.font.size=24
  #  bitmap.font.name="Arial"
  #  PokemonStorage::MARKINGCHARS.each{|item| totaltext+=item }
  #  totalsize=bitmap.text_size(totaltext)
  #  realX=x+(width/2)-(totalsize.width/2)
  #  realY=y+(height/2)-(totalsize.height/2)
  #  i=0
  #  PokemonStorage::MARKINGCHARS.each{|item|
  #     marked=(markings&(1<<i))!=0
  #     bitmap.font.color=(marked) ? Color.new(72,64,56) : Color.new(184,184,160)
  #     itemwidth=bitmap.text_size(item).width
  #     bitmap.draw_text(realX,realY,itemwidth+2,totalsize.height,item)
  #     realX+=itemwidth
  #     i+=1
  #  }
  #  bitmap.font.name=oldfontname
  #  bitmap.font.size=oldfontsize
  #  bitmap.font.color=oldfontcolor
  #end

  def drawMarkings(bitmap,x,y,width,height,markings)
    markings = @pokemon.markings
    markrect = Rect.new(0,0,16,16)
    for i in 0...6
      markrect.x = i*16
      markrect.y = (markings&(1<<i)!=0) ? 16 : 0
      #bitmap.blt(x+i*16,y,@markingbitmap.bitmap,markrect)
    end
  end

  def updatePokeIcons
    if @pokemon.egg?
      @sprites["bg2"].setBitmap(_INTL("Graphics/Pictures/Summary/summarybg9"))
    else
      @sprites["bg2"].setBitmap(_INTL("Graphics/Pictures/Summary/summarybg{1}",GameData::Type.get(@pokemon.type1).id_number))
    end
    for i in 0...@party.length
      @sprites[_INTL("pokebar{1}",i)].x=14
      @sprites[_INTL("pokebar{1}",i)].y=36+i*56
      @sprites[_INTL("pokeicon{1}",i)].x=10
      @sprites[_INTL("pokeicon{1}",i)].y=18+i*56
      if @partyindex==i
        @sprites[_INTL("pokebar{1}",i)].setBitmap("Graphics/Pictures/Summary/bar_selected")
        @sprites[_INTL("pokebar{1}",i)].x=4
        @sprites[_INTL("pokeicon{1}",i)].x=0
      else
        @sprites[_INTL("pokebar{1}",i)].setBitmap("Graphics/Pictures/Summary/bar")
      end
    end
  end

  def drawPageInfo(pokemon)
    for i in 0...5
      if @sprites[_INTL("stats_keybinds_{1}", i)]
        @sprites[_INTL("stats_keybinds_{1}", i)].visible = true
      end
      if @sprites[_INTL("moves_keybinds_{1}", i)]
        @sprites[_INTL("moves_keybinds_{1}", i)].visible = false
      end
      if @sprites[_INTL("editmoves_keybinds_{1}", i)]
        @sprites[_INTL("editmoves_keybinds_{1}", i)].visible = false
      end
    end
    @sprites["pokemon"].visible=true
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    updatePokeIcons
    if pokemon.egg?
      @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_1_egg")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_1")
    end
    imagepos=[]
    circleFile = _INTL("Graphics/Pictures/Summary/summaryCircle{1}",GameData::Type.get(@pokemon.type1).id_number)
    if pokemon.egg?
      circleFile = _INTL("Graphics/Pictures/Summary/summaryCircle9")
    end
    imagepos.push([circleFile,360,108,0,0,-1,-1])
    pbDrawImagePositions(@sprites["bg2"].bitmap,imagepos)
    imagepos=[]
    if pbPokerus(pokemon)==1 || pokemon.hp==0 || @pokemon.status!=:None
      status=6 if pbPokerus(pokemon)==1
      status=(GameData::Status.get(@pokemon.status).id_number - 1) if @pokemon.status!=:None
      status=5 if pokemon.hp==0
      imagepos.push(["Graphics/Pictures/Party/statuses",334,276,0,32*status,32,32])
    end
    if !pokemon.egg?
      extra_x = 308
      if pokemon.shiny?
        imagepos.push([sprintf("Graphics/Pictures/shiny"),extra_x,112,0,0,-1,-1])
        extra_x -= 20
      end
      if pbPokerus(pokemon)==2
        imagepos.push([sprintf("Graphics/Pictures/Summary/icon_pokerus"),extra_x,112,0,0,-1,-1])
      end
    end
    ballused=@pokemon.poke_ball ? @pokemon.poke_ball : :POKEBALL
    ballimage=sprintf("Graphics/Pictures/Summary/icon_ball_%s",ballused.to_s)
    imagepos.push([ballimage,102,100,0,0,-1,-1])
    if (pokemon.isShadow? rescue false)
      imagepos.push(["Graphics/Pictures/Summary/overlay_shadow",224,240,0,0,-1,-1])
      shadowfract=pokemon.heartgauge*1.0/PokeBattle_Pokemon::HEARTGAUGESIZE
      imagepos.push(["Graphics/Pictures/Summary/overlay_shadowbar",242,280,0,0,(shadowfract*248).floor,-1])
    end
    pbDrawImagePositions(overlay,imagepos)
    base=Color.new(248,248,248)
    shadow=Color.new(104,104,104)
    base2 = Color.new(64,64,64)
    shadow2 = Color.new(176,176,176)
    pbSetSystemFont(overlay)
    numberbase=(pokemon.shiny?) ? Color.new(248,56,32) : Color.new(64,64,64)
    numbershadow=(pokemon.shiny?) ? Color.new(224,152,144) : Color.new(176,176,176)
    publicID=pokemon.owner.public_id
    speciesname=GameData::Species.get(pokemon.species).name
    growth_rate=pokemon.growth_rate
    startexp=growth_rate.minimum_exp_for_level(pokemon.level)
    endexp=growth_rate.minimum_exp_for_level(pokemon.level + 1)
    pokename=@pokemon.name
    timeReceived=""
    if pokemon.timeReceived
      month=pbGetAbbrevMonthName(pokemon.timeReceived.mon)
      date=pokemon.timeReceived.day
      year=pokemon.timeReceived.year
      timeReceived=_INTL("{1} {2}, {3}",month,date,year)
    end
    mapname=pbGetMapNameFromId(pokemon.obtain_map)
    if (pokemon.obtain_text rescue false) && pokemon.obtain_text!=""
      mapname=pokemon.obtain_text
    end
    if !mapname || mapname==""
      mapname=_INTL("Faraway place")
    end
    textpos=[
        [pokename,460,14,2,base,shadow]
    ]
    smalltextpos=[]
    if !pokemon.egg?
      textpos.push([_INTL("Lv. {1}", pokemon.level.to_s),158,104,0,base,shadow])
      smalltextpos.push([_INTL("{1} - {2}",timeReceived,mapname),432,538,2,base,shadow])
    else
      eggstate=_INTL("It will take a long time to hatch.")
      eggstate=_INTL("It doesn't seem close to hatching.") if pokemon.steps_to_hatch<10200
      eggstate=_INTL("It moves occasionally. Getting closer.") if pokemon.steps_to_hatch<2550
      eggstate=_INTL("Sounds are coming from inside!") if pokemon.steps_to_hatch<1275
      textpos.push([eggstate,432,538,2,base,shadow])
    end
    if pokemon.hasItem?
      smalltextpos.push([GameData::Item.get(pokemon.item).name,678,230,2,base,shadow])
    else
      smalltextpos.push([_INTL("No Item"),678,230,2,Color.new(208,208,200),Color.new(120,144,184)])
    end
    smalltextpos.push([_INTL("Exp. Points"),106,150,0,base,shadow])
    smalltextpos.push([_INTL("To Next Lv."),106,202,0,base,shadow])
    smalltextpos.push([_INTL("O.T."),224,202,0,base,shadow])
    smalltextpos.push(["Met at Lv.",106,254,0,base,shadow])
    if !pokemon.egg?
      smalltextpos.push([_INTL("Happiness"),224,150,0,base,shadow])
      smalltextpos.push([sprintf("#%03d "+speciesname,GameData::Species.get(pokemon.species).id_number),460,48,2,base,shadow])
      smalltextpos.push([sprintf("%d",pokemon.exp),202,174,1,Color.new(64,64,64),Color.new(176,176,176)])
      smalltextpos.push([sprintf("%d",endexp-pokemon.exp),202,226,1,Color.new(64,64,64),Color.new(176,176,176)])
      smalltextpos.push([sprintf("%d",pokemon.obtain_level),202,278,1,Color.new(64,64,64),Color.new(176,176,176)])
      smalltextpos.push([sprintf("%3d",pokemon.happiness),320,174,1,Color.new(64,64,64),Color.new(176,176,176)])
      smalltextpos.push([GameData::Nature.get(pokemon.nature).name,678,288,2,base,shadow])
      basestats=pokemon.baseStats
      statshadows=[]
      for i in 0...5; statshadows[i]=[base,shadow]; end
      if !(pokemon.isShadow? rescue false) || pokemon.heartStage<=3
        nat = GameData::Nature.get(pokemon.nature).id_number
        natup=(nat/5).floor
        natdn=(nat%5).floor
        statshadows[natup]=[Color.new(0,150,0),Color.new(160,255,160)] if natup!=natdn
        statshadows[natdn]=[Color.new(150,0,0),Color.new(255,160,160)] if natup!=natdn
      end
      smalltextpos += [
        [_INTL("HP"),126,110+256,2,base,shadow],
        [sprintf("%3d/%3d",pokemon.hp,pokemon.totalhp),220,110+256,2,base2,shadow2],
        [_INTL("Attack"),148,138+256,2,statshadows[0][0],statshadows[0][1]],
        [sprintf("%d",pokemon.attack),242,138+256,2,base2,shadow2],
        [_INTL("Defense"),148,166+256,2,statshadows[1][0],statshadows[1][1]],
        [sprintf("%d",pokemon.defense),242,166+256,2,base2,shadow2],
        [_INTL("Sp. Atk"),148,194+256,2,statshadows[3][0],statshadows[3][1]],
        [sprintf("%d",pokemon.spatk),242,194+256,2,base2,shadow2],
        [_INTL("Sp. Def"),148,222+256,2,statshadows[4][0],statshadows[4][1]],
        [sprintf("%d",pokemon.spdef),242,222+256,2,base2,shadow2],
        [_INTL("Speed"),148,250+256,2,statshadows[2][0],statshadows[2][1]],
        [sprintf("%d",pokemon.speed),242,250+256,2,base2,shadow2],
        [sprintf("%d",basestats[:HP]),318,110+256,2,Color.new(64,64,64),Color.new(176,176,176)],
        [sprintf("%d",basestats[:ATTACK]),318,138+256,2,Color.new(64,64,64),Color.new(176,176,176)],
        [sprintf("%d",basestats[:DEFENSE]),318,166+256,2,Color.new(64,64,64),Color.new(176,176,176)],
        [sprintf("%d",basestats[:SPECIAL_ATTACK]),318,194+256,2,Color.new(64,64,64),Color.new(176,176,176)],
        [sprintf("%d",basestats[:SPECIAL_DEFENSE]),318,222+256,2,Color.new(64,64,64),Color.new(176,176,176)],
        [sprintf("%d",basestats[:SPEED]),318,250+256,2,Color.new(64,64,64),Color.new(176,176,176)],
        [sprintf("%d",pokemon.ev[:HP]),386,110+256,1,Color.new(64,64,64),Color.new(176,176,176)],
        [sprintf("%d",pokemon.ev[:ATTACK]),386,138+256,1,Color.new(64,64,64),Color.new(176,176,176)],
        [sprintf("%d",pokemon.ev[:DEFENSE]),386,166+256,1,Color.new(64,64,64),Color.new(176,176,176)],
        [sprintf("%d",pokemon.ev[:SPECIAL_ATTACK]),386,194+256,1,Color.new(64,64,64),Color.new(176,176,176)],
        [sprintf("%d",pokemon.ev[:SPECIAL_DEFENSE]),386,222+256,1,Color.new(64,64,64),Color.new(176,176,176)],
        [sprintf("%d",pokemon.ev[:SPEED]),386,250+256,1,Color.new(64,64,64),Color.new(176,176,176)]
      ]
      effort_y = 120+256
      for i in [:HP, :ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED]
        effort = [pokemon.ev[i], 252].min
        effort_width = ((effort * 30.0) / 252.0).floor * 2
        effort_rect = Rect.new(0, 0, effort_width, @effortbitmap.bitmap.height)
        overlay.blt(392,effort_y,@effortbitmap.bitmap,effort_rect)
        effort_y += 28
      end
      abilityname=GameData::Ability.get(pokemon.ability).name
      abilitydesc=GameData::Ability.get(pokemon.ability).description
      textpos.push([abilityname,634,364,2,base,shadow])
      pbSetSmallFont(overlay)
      drawSmallTextEx(overlay,512,400,250,5,abilitydesc,base,shadow)
    else
      smalltextpos.push([_INTL("Steps"),224,150,0,base,shadow])
      maxeggsteps=pokemon.species_data.hatch_steps
      goneeggsteps=maxeggsteps-pokemon.steps_to_hatch
      eggbarlen=(61.0-(pokemon.steps_to_hatch*61.0/maxeggsteps)).floor*2
      smalltextpos.push([sprintf("%d",goneeggsteps),320,174,1,Color.new(64,64,64),Color.new(176,176,176)])
      overlay.fill_rect(202,138,eggbarlen,2,Color.new(86,214,92))
      overlay.fill_rect(202,140,eggbarlen,4,Color.new(96,255,132))
    end
    idno=(pokemon.owner.name=="" || pokemon.egg?) ? "" : sprintf("%05d",publicID)
    smalltextpos.push(["ID No.",224,254,0,base,shadow])
    smalltextpos.push([idno,320,278,1,Color.new(64,64,64),Color.new(176,176,176)])
    if pokemon.egg?
      smalltextpos.push(["",172,224,1,Color.new(64,64,64),Color.new(176,176,176)])
    elsif pokemon.owner.name==""
      smalltextpos.push(["RENTAL",172,224,1,Color.new(64,64,64),Color.new(176,176,176)])
    else
      ownerbase=Color.new(64,64,64)
      ownershadow=Color.new(176,176,176)
      if pokemon.owner.gender==0 # male OT
        ownerbase=Color.new(24,112,216)
        ownershadow=Color.new(136,168,208)
      elsif pokemon.owner.gender==1 # female OT
        ownerbase=Color.new(248,56,32)
        ownershadow=Color.new(224,152,144)
      end
      smalltextpos.push([pokemon.owner.name,320,226,1,ownerbase,ownershadow])
      if pokemon.male?
        textpos.push([_INTL("♂"),138,104,0,Color.new(24,112,216),Color.new(136,168,208)])
      elsif pokemon.female?
        textpos.push([_INTL("♀"),138,104,0,Color.new(248,56,32),Color.new(224,152,144)])
      else
        textpos.push([_INTL("⚲"),138,104,0,Color.new(136,84,128),Color.new(180,160,176)])
      end
    end
    pbSetSystemFont(overlay)
    pbDrawTextPositions(overlay,textpos,false)
    pbSetSmallFont(overlay)
    pbDrawTextPositions(overlay,smalltextpos,false)
    drawMarkings(overlay,62,286,72,20,pokemon.markings)
    if !pokemon.egg?
      type1rect=Rect.new(0,GameData::Type.get(pokemon.type1).id_number*28,64,28)
      type2rect=Rect.new(0,GameData::Type.get(pokemon.type2).id_number*28,64,28)
      affinity1rect=Rect.new(0,GameData::Type.get(pokemon.affinity1).id_number*28,64,28)
      affinity2rect=Rect.new(0,GameData::Type.get(pokemon.affinity2).id_number*28,64,28)
      if pokemon.type1==pokemon.type2
        overlay.blt(678-32,114,@typebitmap.bitmap,type1rect)
      else
        overlay.blt(644-32,114,@typebitmap.bitmap,type1rect)
        overlay.blt(712-32,114,@typebitmap.bitmap,type2rect)
      end
      if pokemon.affinity1==pokemon.affinity2
        overlay.blt(678-32,172,@typebitmap.bitmap,affinity1rect)
      else
        overlay.blt(644-32,172,@typebitmap.bitmap,affinity1rect)
        overlay.blt(712-32,172,@typebitmap.bitmap,affinity2rect)
      end
      if pokemon.level<Settings::MAXIMUM_LEVEL
        overlay.fill_rect(142,138,(pokemon.exp-startexp)*64/(endexp-startexp),2,Color.new(72,120,160))
        overlay.fill_rect(142,140,(pokemon.exp-startexp)*64/(endexp-startexp),4,Color.new(24,144,248))
      end
      overlay.fill_rect(260,138,(pokemon.happiness+1)/8*2,2,Color.new(214,86,172))
      overlay.fill_rect(260,140,(pokemon.happiness+1)/8*2,4,Color.new(255,96,232))
    end
  end

  def drawPageStats(pokemon)
    @sprites["pokemon"].visible=false
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    updatePokeIcons
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_2")
    imagepos=[]
    if pbPokerus(pokemon)==1 || pokemon.hp==0 || @pokemon.status!=:None
      status=6 if pbPokerus(pokemon)==1
      status=GameData::Status.get(@pokemon.status).id_number if @pokemon.status!=:None
      status=5 if pokemon.hp==0
      #imagepos.push(["Graphics/Pictures/statuses",124,100,0,16*status,44,16])
    end
    if pokemon.shiny?
      imagepos.push([sprintf("Graphics/Pictures/shiny"),2,106,0,0,-1,-1])
    end
    if pbPokerus(pokemon)==2
      imagepos.push([sprintf("Graphics/Pictures/Summary/icon_pokerus"),176,100,0,0,-1,-1])
    end
    pbDrawImagePositions(overlay,imagepos)
    base=Color.new(64,64,64)
    shadow=Color.new(176,176,176)
    base2=Color.new(248,248,248)
    shadow2=Color.new(104,104,104)
    statshadows=[]
    for i in 0...5; statshadows[i]=[base2,shadow2]; end
    if !(pokemon.isShadow? rescue false) || pokemon.heartStage<=3
      nat = GameData::Nature.get(pokemon.nature).id_number
      natup=(nat/5).floor
      natdn=(nat%5).floor
      statshadows[natup]=[Color.new(0,150,0),Color.new(160,255,160)] if natup!=natdn
      statshadows[natdn]=[Color.new(150,0,0),Color.new(255,160,160)] if natup!=natdn
    end
    pbSetSystemFont(overlay)
    abilityname=GameData::Ability.get(pokemon.ability).name
    abilitydesc=GameData::Ability.get(pokemon.ability).description
    pokename=@pokemon.name
    speciesname = GameData::Species.get(pokemon.species).name
    basestats=pokemon.baseStats
    textpos=[
      [pokename,288,12,2,base2,shadow2],
      [_INTL("Ability"),142,312,2,base2,shadow2],
      [abilityname,142,346,2,base2,shadow2]
    ]
    smalltextpos=[
      [pokemon.level.to_s,134,82,0,base2,shadow2],
      [sprintf("#%03d "+speciesname,GameData::Species.get(pokemon.species).id_number),288,48,2,base2,shadow2],
      [_INTL("HP"),112,110,2,Color.new(248,248,248),Color.new(104,104,104)],
      [sprintf("%3d/%3d",pokemon.hp,pokemon.totalhp),206,110,2,Color.new(64,64,64),Color.new(176,176,176)],
      [_INTL("Attack"),134,138,2,statshadows[0][0],statshadows[0][1]],
      [sprintf("%d",pokemon.attack),228,138,2,base,shadow],
      [_INTL("Defense"),134,166,2,statshadows[1][0],statshadows[1][1]],
      [sprintf("%d",pokemon.defense),228,166,2,base,shadow],
      [_INTL("Sp. Atk"),134,194,2,statshadows[3][0],statshadows[3][1]],
      [sprintf("%d",pokemon.spatk),228,194,2,base,shadow],
      [_INTL("Sp. Def"),134,222,2,statshadows[4][0],statshadows[4][1]],
      [sprintf("%d",pokemon.spdef),228,222,2,base,shadow],
      [_INTL("Speed"),134,250,2,statshadows[2][0],statshadows[2][1]],
      [sprintf("%d",pokemon.speed),228,250,2,base,shadow],
      [sprintf("%d",pokemon.ev[:HP]),296,110,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",pokemon.ev[:ATTACK]),296,138,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",pokemon.ev[:DEFENSE]),296,166,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",pokemon.ev[:SPECIAL_ATTACK]),296,194,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",pokemon.ev[:SPECIAL_DEFENSE]),296,222,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",pokemon.ev[:SPEED]),296,250,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",pokemon.iv[:HP]),350,110,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",pokemon.iv[:ATTACK]),350,138,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",pokemon.iv[:DEFENSE]),350,166,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",pokemon.iv[:SPECIAL_ATTACK]),350,194,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",pokemon.iv[:SPECIAL_DEFENSE]),350,222,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",pokemon.iv[:SPEED]),350,250,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",basestats[:HP]),404,110,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",basestats[:ATTACK]),404,138,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",basestats[:DEFENSE]),404,166,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",basestats[:SPECIAL_ATTACK]),404,194,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",basestats[:SPECIAL_DEFENSE]),404,222,2,Color.new(64,64,64),Color.new(176,176,176)],
      [sprintf("%d",basestats[:SPEED]),404,250,2,Color.new(64,64,64),Color.new(176,176,176)],
      [_INTL("{1} Nature",GameData::Nature.get(pokemon.nature).name),180,280,2,base2,shadow2]
    ]
    if pokemon.hasItem?
      smalltextpos.push([GameData::Item.get(pokemon.item).name,398,280,2,base2,shadow2])
    else
      smalltextpos.push([_INTL("No Item"),398,280,2,Color.new(208,208,200),Color.new(120,144,184)])
    end
    pbSetSmallFont(overlay)
    pbDrawTextPositions(overlay,smalltextpos,false)
    pbSetSystemFont(overlay)
    pbDrawTextPositions(overlay,textpos,false)
    pbSetSmallFont(overlay)
    drawTextEx(overlay,226,316,286,2,abilitydesc,base2,shadow2,true)
    pbSetSystemFont(overlay)
    #drawMarkings(overlay,15,291,72,20,pokemon.markings)
    if pokemon.hp>0
      hpcolors=[
          Color.new(24,192,32),Color.new(0,144,0),     # Green
          Color.new(248,184,0),Color.new(184,112,0),   # Orange
          Color.new(240,80,32),Color.new(168,48,56)    # Red
      ]
      hpzone=0
      hpzone=1 if pokemon.hp<=(@pokemon.totalhp/2).floor
      hpzone=2 if pokemon.hp<=(@pokemon.totalhp/4).floor
      #overlay.fill_rect(360,110,pokemon.hp*96/pokemon.totalhp,2,hpcolors[hpzone*2+1])
      #overlay.fill_rect(360,112,pokemon.hp*96/pokemon.totalhp,4,hpcolors[hpzone*2])
    end
  end

  def drawPageMoves(pokemon,refresh_zones=nil)
    refresh_zones = [true,true,true,true] if !refresh_zones
    for i in 0...5
      if @sprites[_INTL("stats_keybinds_{1}", i)]
        @sprites[_INTL("stats_keybinds_{1}", i)].visible = false
      end
      if @sprites[_INTL("moves_keybinds_{1}", i)]
        @sprites[_INTL("moves_keybinds_{1}", i)].visible = true
      end
      if @sprites[_INTL("editmoves_keybinds_{1}", i)]
        @sprites[_INTL("editmoves_keybinds_{1}", i)].visible = false
      end
    end
    overlay=@sprites["overlay"].bitmap
    refresh_all = (refresh_zones[0] && refresh_zones[1] && refresh_zones[2] && refresh_zones[3])
    if refresh_all
      overlay.clear
    else
      overlay.clear_rect(94,134,232,354) if refresh_zones[0]
      overlay.clear_rect(528,104,240,468) if refresh_zones[1]
      if refresh_zones[2]
        overlay.clear_rect(450,142,78,62)
        overlay.clear_rect(326,230,202,22)
        overlay.clear_rect(326,278,202,22)
        overlay.clear_rect(326,302,202,180)
      end
      overlay.clear_rect(96,490,432,80) if refresh_zones[3]
    end
    updatePokeIcons
    @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_3")
    @sprites["pokemon"].visible=false
    @sprites["pokeicon"].visible=false
    speciesname=GameData::Species.get(pokemon.species).name
    base=Color.new(248,248,248)
    shadow=Color.new(104,104,104)
    base2 = Color.new(64,64,64)
    shadow2 = Color.new(176,176,176)
    pbSetSystemFont(overlay)
    textpos=[]
    smalltextpos=[]
    if refresh_all
      textpos.push([pokemon.name,460,14,2,base,shadow])
      textpos.push([_INTL("TYPE"),334,142,0,base,shadow])
      textpos.push([_INTL("CATEGORY"),334,174,0,base,shadow])

      smalltextpos.push([sprintf("#%03d "+speciesname,GameData::Species.get(pokemon.species).id_number),460,48,2,base,shadow])
      smalltextpos.push([_INTL("POWER"),374,204,2,base,shadow])
      smalltextpos.push([_INTL("ACCURACY"),478,204,2,base,shadow])
      smalltextpos.push([_INTL("EFFECT"),374,252,2,base,shadow])
      smalltextpos.push([_INTL("PRIORITY"),478,252,2,base,shadow])
    end
    if refresh_zones[3]
      chips = $PokemonBag.pbQuantity(:DATACHIP)
      if chips >= 100
        smalltextpos.push([_INTL("{1}", chips),508,536,2,base2,shadow2])
      else
        smalltextpos.push([_INTL("{1}x", chips),508,536,2,base2,shadow2])
      end
      statshadows=[]
      for i in 0...5; statshadows[i]=[base,shadow]; end
      if !(pokemon.isShadow? rescue false) || pokemon.heartStage<=3
        nat = GameData::Nature.get(pokemon.nature).id_number
        natup=(nat/5).floor
        natdn=(nat%5).floor
        statshadows[natup]=[Color.new(0,150,0),Color.new(160,255,160)] if natup!=natdn
        statshadows[natdn]=[Color.new(150,0,0),Color.new(255,160,160)] if natup!=natdn
      end
      smalltextpos += [
        [_INTL("HP"),124,194+294,2,base,shadow],
        [sprintf("%3d/%3d",pokemon.hp,pokemon.totalhp),218,194+294,2,base2,shadow2],
        [_INTL("Attack"),146,222+294,2,statshadows[0][0],statshadows[0][1]],
        [sprintf("%d",pokemon.attack),240,222+294,2,base2,shadow2],
        [_INTL("Defense"),146,250+294,2,statshadows[1][0],statshadows[1][1]],
        [sprintf("%d",pokemon.defense),240,250+294,2,base2,shadow2],
        [_INTL("Speed"),146+190,194+294,2,statshadows[2][0],statshadows[2][1]],
        [sprintf("%d",pokemon.speed),240+190,194+294,2,base2,shadow2],
        [_INTL("Sp. Atk"),146+190,222+294,2,statshadows[3][0],statshadows[3][1]],
        [sprintf("%d",pokemon.spatk),240+190,222+294,2,base2,shadow2],
        [_INTL("Sp. Def"),146+190,250+294,2,statshadows[4][0],statshadows[4][1]],
        [sprintf("%d",pokemon.spdef),240+190,250+294,2,base2,shadow2]
      ]
    end
    smallesttextpos=[]
    imagepos=[]
    if refresh_zones[0]
      xPos=102
      yPos=140
      for i in 0...4
        moveobject=pokemon.moves[i]
        if moveobject
          movedata=GameData::Move.get(moveobject.id)
          if moveobject.id!=0
            imagepos.push(["Graphics/Pictures/Summary/move_slot",xPos,yPos,0,
                GameData::Type.get(moveobject.type).id_number*80,216,80])
            textpos.push([movedata.name,xPos+106,yPos+4,2,
                Color.new(64,64,64),Color.new(176,176,176)])
            if moveobject.totalpp>0
              textpos.push([_ISPRINTF("PP"),xPos+30,yPos+32,0,
                  Color.new(64,64,64),Color.new(176,176,176)])
              textpos.push([sprintf("%d/%d",moveobject.pp,moveobject.totalpp),
                  xPos+186,yPos+32,1,Color.new(64,64,64),Color.new(176,176,176)])
              accuracy = movedata.accuracy
              if movedata.base_damage > 0
                smallesttextpos.push([sprintf("%d PWR   %s ACC",
                    movedata.base_damage,accuracy==0 ? "-" : sprintf("%d",accuracy)),
                    xPos+106,yPos+56,2,Color.new(252,252,252),Color.new(33,33,33)])
              else
                smallesttextpos.push([sprintf("%s ACCURACY",accuracy==0 ? "---" : sprintf("%d",accuracy)),
                    xPos+106,yPos+56,2,Color.new(252,252,252),Color.new(33,33,33)])
              end
            end
          else
            textpos.push(["-",316,yPos,0,Color.new(64,64,64),Color.new(176,176,176)])
            textpos.push(["--",442,yPos+32,1,Color.new(64,64,64),Color.new(176,176,176)])
          end
        end
        yPos+=86
      end
    end
    if refresh_zones[1]
      xPos=536
      yPos=140
      page = @sprites["movesel"].page
      scroll = @sprites["movesel"].scroll
      for i in scroll...(scroll+5)
        movearr=@listMoves[page][i]
        if movearr
          moveid=movearr[0]
          movedata=GameData::Move.get(moveid)
          if moveid!=0
            available = true
            available = false if page == 0 && pokemon.level < movearr[1]
            available = false if page == 2 && !movearr[2]
            available = false if page == 2 && !pbHasDataChipMove(moveid)
            imagepos.push(["Graphics/Pictures/Summary/move_slot",xPos,yPos,
                available ? 0 : 216,
                GameData::Type.get(movedata.type).id_number*80,216,80])
            textcolor = available ? base2 : base
            textshadow = available ? shadow2 : shadow
            reqcolor = available ? base2 : Color.new(252,100,100)
            reqshadow = available ? shadow2 : Color.new(120,40,40)
            textpos.push([movedata.name,xPos+106,yPos+4,2,
                textcolor, textshadow])
            if movedata.total_pp>0
              textpos.push([sprintf("%d PP", movedata.total_pp),xPos+30,yPos+32,0,
                  textcolor, textshadow])
              case page
              when 0
                textpos.push([sprintf("Lv. %d",@listMoves[page][i][1]),
                    xPos+186,yPos+32,1,reqcolor,reqshadow])
              when 1
                textpos.push([sprintf("%s",@listMoves[page][i][1]),
                    xPos+186,yPos+32,1,textcolor,textshadow])
              when 2
                if pbHasDataChipMove(moveid)

                else
                  imagepos.push(["Graphics/Pictures/Summary/datachip",xPos+190,yPos+42,0,0,-1,-1])
                  if $PokemonBag.pbQuantity(:DATACHIP)>=movearr[1]
                    textpos.push([_INTL("{1}x",movearr[1]),xPos+186,yPos+32,1,
                          Color.new(0,252,0),Color.new(0,100,0)])
                  else
                    textpos.push([_INTL("{1}x",movearr[1]),xPos+186,yPos+32,1,
                          reqcolor,reqshadow])
                  end
                end
              end
              if page == 2 && !pokemon.compatible_with_move?(moveid)
                smallesttextpos.push(["INCOMPATIBLE",
                  xPos+106,yPos+56,2,reqcolor,reqshadow])
              else
                accuracy = movedata.accuracy
                if movedata.base_damage > 0
                  smallesttextpos.push([sprintf("%s PWR   %s ACC",
                      (movedata.base_damage == 1) ? "???" : sprintf("%d", movedata.base_damage),
                      accuracy==0 ? "-" : sprintf("%d",accuracy)),
                      xPos+106,yPos+56,2,Color.new(252,252,252),Color.new(33,33,33)])
                else
                  smallesttextpos.push([sprintf("%s ACCURACY",accuracy==0 ? "---" : sprintf("%d",accuracy)),
                      xPos+106,yPos+56,2,Color.new(252,252,252),Color.new(33,33,33)])
                end
              end
            end
          else
            textpos.push(["-",316,yPos,0,Color.new(64,64,64),Color.new(176,176,176)])
            textpos.push(["--",442,yPos+32,1,Color.new(64,64,64),Color.new(176,176,176)])
          end
        end
        yPos+=86
      end
      imagepos.push(["Graphics/Pictures/Summary/learnset_title",520,104,0,page*32,248,32])
      scroll_height = 64
      scroll_y = 138
      if @listMoves[page].length > 5
        scroll_y += [((428 - scroll_height) * scroll / (@listMoves[page].length - 5)), 0].max
      end
      imagepos.push(["Graphics/Pictures/Summary/scrollbar",760,scroll_y,0,0,8,scroll_height])
    end
    pbDrawImagePositions(overlay,imagepos)
    pbSetSmallestFont(overlay)
    pbDrawTextPositions(overlay,smallesttextpos,false)
    pbSetSmallFont(overlay)
    pbDrawTextPositions(overlay,smalltextpos,false)
    pbSetSystemFont(overlay)
    pbDrawTextPositions(overlay,textpos,false)
  end

  def drawSelectedMove(pokemon,moveToLearn,moveid,refresh_zones=nil)
    refresh_zones = [true,true,true,true] if !refresh_zones
    return if !refresh_zones[2]
    overlay=@sprites["overlay"].bitmap
    @sprites["pokemon"].visible=false if @sprites["pokemon"]
    @sprites["pokeicon"].setBitmap(GameData::Species.icon_filename_from_pokemon(pokemon))
    @sprites["pokeicon"].src_rect=Rect.new(0,0,64,64)
    @sprites["pokeicon"].visible=(moveToLearn!=0)
    movedata=GameData::Move.get(moveid)
    basedamage=movedata.base_damage
    type=GameData::Type.get(movedata.type).id_number
    category=movedata.category
    accuracy=movedata.accuracy
    effectch=movedata.effect_chance
    priority=movedata.priority
    if pokemon.ability==:PRANKSTER && category==2
      priority+=1
    end
    drawMoveSelection(pokemon,moveToLearn,refresh_zones)
    pbSetSystemFont(overlay)
    move=movedata.id_number
    textcolor=[
      basedamage==movedata.base_damage ? Color.new(64,64,64) : Color.new(0,150,0),
      accuracy==movedata.accuracy ? Color.new(64,64,64) : Color.new(0,150,0),
      effectch==movedata.effect_chance ? Color.new(64,64,64) : Color.new(0,150,0),
      priority==movedata.priority ? Color.new(64,64,64) : Color.new(0,150,0)
    ]
    textshadow=[
      basedamage==movedata.base_damage ? Color.new(198,176,176) : Color.new(176,198,176),
      accuracy==movedata.accuracy ? Color.new(198,176,176) : Color.new(176,198,176),
      effectch==movedata.effect_chance ? Color.new(198,176,176) : Color.new(176,198,176),
      priority==movedata.priority ? Color.new(198,176,176) : Color.new(176,198,176)
    ]
    text_x = moveToLearn!=0 ? 60 : 374
    text_y = moveToLearn!=0 ? 142 : 228
    xdif = moveToLearn!=0 ? 120 : 104
    textpos=[
        [basedamage<=1 ? basedamage==1 ? "???" : "---" : sprintf("%d",basedamage),
          text_x,text_y,2,textcolor[0],textshadow[0]],
        [accuracy==0 ? "---" : sprintf("%d",accuracy)+"%",
          text_x+xdif,text_y,2,textcolor[1],textshadow[1]],
        [effectch==0 ? "---" : sprintf("%d",effectch)+"%",
          text_x,text_y+48,2,textcolor[2],textshadow[2]],
        [priority==0 ? "---" : sprintf("%s%d",priority>0 ? "+" : "-",priority),
          text_x+xdif,text_y+48,2,textcolor[3],textshadow[3]]
    ]
    pbSetSmallFont(overlay)
    pbDrawTextPositions(overlay,textpos,false)
    pbSetSystemFont(overlay)
    text_x = moveToLearn!=0 ? 166 : 456
    text_y = moveToLearn!=0 ? 56 : 144
    imagepos=[["Graphics/Pictures/category",text_x,text_y+32,0,category*28,64,28],
              ["Graphics/Pictures/types",text_x,text_y,0,type*28,64,28]]
    pbDrawImagePositions(overlay,imagepos)
    drawSmallTextEx(overlay,332,306,194,8,
        movedata.description,
        Color.new(248,248,248),Color.new(104,104,104))
  end

  def drawMoveSelection(pokemon,moveToLearn,refresh_zones=nil)
    refresh_zones = [true,true,true,true] if !refresh_zones
    overlay=@sprites["overlay"].bitmap
    drawPageMoves(pokemon,refresh_zones)
    for i in 0...5
      if @sprites[_INTL("stats_keybinds_{1}", i)]
        @sprites[_INTL("stats_keybinds_{1}", i)].visible = false
      end
      if @sprites[_INTL("moves_keybinds_{1}", i)]
        @sprites[_INTL("moves_keybinds_{1}", i)].visible = false
      end
      if @sprites[_INTL("editmoves_keybinds_{1}", i)]
        @sprites[_INTL("editmoves_keybinds_{1}", i)].visible = true
      end
    end
  end

  def pbChooseMoveToForget(moveToLearn)
    selmove=0
    ret=0
    maxmove=(moveToLearn>0) ? 4 : 3
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        ret=4
        break
      end
      if Input.trigger?(Input::USE)
        break
      end
      if Input.trigger?(Input::DOWN)
        selmove+=1
        if selmove<4 && selmove>=@pokemon.numMoves
          selmove=(moveToLearn>0) ? maxmove : 0
        end
        selmove=0 if selmove>maxmove
        @sprites["movesel"].index=selmove
        newmove=(selmove==4) ? moveToLearn : @pokemon.moves[selmove].id
        drawSelectedMove(@pokemon,moveToLearn,newmove)
        ret=selmove
      end
      if Input.trigger?(Input::UP)
        selmove-=1
        selmove=maxmove if selmove<0
        if selmove<4 && selmove>=@pokemon.numMoves
          selmove=@pokemon.numMoves-1
        end
        @sprites["movesel"].index=selmove
        newmove=(selmove==4) ? moveToLearn : @pokemon.moves[selmove].id
        drawSelectedMove(@pokemon,moveToLearn,newmove)
        ret=selmove
      end
    end
    return (ret==4) ? -1 : ret
  end

  def pbMoveSelection
    @sprites["movesel"].visible=true
    selmove=0
    oldselmove=0
    if !@machinemove
      @sprites["movesel"].index=0
      @sprites["movesel"].side=0
      @sprites["editmoves_keybinds_1"].name = "Remove Move"
    else
      @sprites["editmoves_keybinds_1"].name = "Switch to Data Chips"
      selmove = @sprites["movesel"].index
    end
    switching=false
    forceleft=false
    up_frames = 0
    down_frames = 1
    if @machinemove
      move = @listMoves[@sprites["movesel"].page][selmove][0]
      drawSelectedMove(@pokemon,0,move,[false,false,true,false])
      @machinemove = nil
    else
      drawSelectedMove(@pokemon,0,@pokemon.moves[selmove].id,[false,false,true,false])
    end
    offset=0
    loop do
      Graphics.update
      Input.update
      pbUpdate
      newmove = false
      #                left   right   mid  bottom
      refresh_zones = [false, false, false, false]
      if @sprites["movepresel"].index==@sprites["movesel"].index
        @sprites["movepresel"].z=@sprites["movesel"].z+1
      else
        @sprites["movepresel"].z=@sprites["movesel"].z
      end
      if Input.trigger?(Input::BACK)
        break if !switching
        @sprites["movepresel"].visible=false
        switching = false
        forceleft = false
      end
      if Input.trigger?(Input::USE)
        if @inbattle
          pbMessage("You cannot edit movesets while in battle.")
          next
        end
        if @sprites["movesel"].side == 1
          case @sprites["movesel"].page
          when 0
            if @pokemon.level < @listMoves[0][selmove][1]
              pbPlayBuzzerSE()
              next
            end
          when 1
            # No failure condition for TMs
          when 2
            move = @listMoves[2][selmove]
            movename = GameData::Move.get(move[0]).name
            if !pbHasDataChipMove(move[0])
              if $PokemonBag.pbQuantity(:DATACHIP) < move[1]
                pbMessage(_INTL("Not enough Data Chips to unlock {1}.", movename))
              else
                if $game_variables[DATA_CHIP_MOVES].length <= 0
                  pbMessage(_INTL("To unlock moves, you will use Data Chips.\nUnlocked moves will then be permanently available for all compatible Pokémon."))
                end
                command = pbMessage(_INTL("Do you want to extract {1}\nfrom {2} Data Chips?",movename,move[1]),["Yes","No"],-1)
                if command == 0
                  $PokemonBag.pbDeleteItem(:DATACHIP,move[1])
                  pbAddDataChipMove(move[0])
                  @listMoves[2] = pbGetDataChipMoves(@pokemon)
                  for i in 0...@listMoves[2].length
                    if @listMoves[2][i][0] == move[0]
                      selmove = i
                      scroll = @sprites["movesel"].scroll
                      if selmove - scroll > 4
                        scroll = [selmove - 3, @listMoves[2][i].length - 5].min
                      elsif selmove - scroll < 0
                        scroll = [selmove - 1, 0].max
                      end
                      @sprites["movesel"].scroll = scroll
                      @sprites["movesel"].index = selmove
                      break
                    end
                  end
                  drawSelectedMove(@pokemon,0,move[0],[false,true,true,true])
                end
              end
              next
            elsif !move[2]
              pbMessage(_INTL("{1} cannot learn {2}", @pokemon.name, movename))
              next
            end
          end
        end
        if selmove==4 && @sprites["movesel"].side == 0
          break if !switching
          @sprites["movepresel"].visible=false
          switching = false
          forceleft = false
        else
          if !(@pokemon.isShadow? rescue false)
            if !switching
              if @sprites["movesel"].side == 1
                moveid = @listMoves[@sprites["movesel"].page][@sprites["movesel"].index][0]
                if @pokemon.hasMove?(moveid)
                  pbMessage("You cannot add a duplicate move.")
                  next
                end
                if @pokemon.moves.length < 4
                  pbPlayCursorSE()
                  move = Pokemon::Move.new(moveid)
                  @pokemon.moves.push(move)
                  drawSelectedMove(@pokemon,0,moveid,[true,false,true,false])
                  next
                end
              end
              @sprites["movepresel"].copy(@sprites["movesel"])
              oldselmove=selmove
              @sprites["movepresel"].visible=true
              switching = true
              if @sprites["movepresel"].side == 1
                forceleft = true
              end
            else
              if @sprites["movesel"].side == 0 && @sprites["movepresel"].side == 0
                tmpmove=@pokemon.moves[oldselmove]
                @pokemon.moves[oldselmove]=@pokemon.moves[selmove]
                @pokemon.moves[selmove]=tmpmove
              else
                indices = [@sprites["movesel"].index, @sprites["movepresel"].index]
                moveslot = (@sprites["movesel"].side == 0) ? indices[0] : indices[1]
                listslot = (@sprites["movesel"].side == 0) ? indices[1] : indices[0]
                oldmove = @pokemon.moves[moveslot]
                move = Pokemon::Move.new(@listMoves[@sprites["movesel"].page][listslot][0])
                if oldmove.id != move.id && @pokemon.hasMove?(move.id)
                  pbMessage("You cannot add a duplicate move.")
                  next
                end
                @pokemon.moves[moveslot] = move
              end
              @sprites["movepresel"].visible=false
              switching = false
              forceleft = false
              refresh_zones = [true, true, true, true]
              newmove = true
            end
          end
        end
      end
      if Input.press?(Input::DOWN)
        down_frames += 1
      else
        down_frames = 0
      end
      if Input.press?(Input::UP)
        up_frames += 1
      else
        up_frames = 0
      end
      if down_frames == 1 || (down_frames > 16 && down_frames % 8 == 0)
        if @sprites["movesel"].side == 0
          selmove = (selmove + 1) % @pokemon.numMoves
        else
          page = @sprites["movesel"].page
          numMoves = @listMoves[page].length
          selmove = (selmove + 1) % numMoves
          scroll = @sprites["movesel"].scroll
          if selmove == 0
            scroll = 0
          elsif selmove - scroll == 4 && selmove < numMoves - 1
            scroll += 1
          end
          refresh_zones[1] = true if @sprites["movesel"].scroll != scroll
          @sprites["movesel"].scroll = scroll
        end
        @sprites["movesel"].index=selmove
        newmove = true
      end
      if up_frames == 1 || (up_frames > 16 && up_frames % 8 == 0)
        if @sprites["movesel"].side == 0
          selmove = (selmove - 1) % @pokemon.numMoves
        else
          page = @sprites["movesel"].page
          numMoves = @listMoves[page].length
          selmove = (selmove - 1) % @listMoves[page].length
          scroll = @sprites["movesel"].scroll
          if selmove == 0
            scroll = 0
          elsif selmove == numMoves - 1
            scroll = [numMoves - 5, 0].max
          elsif selmove - scroll <= 0 && selmove > 0
            scroll -= 1
          end
          refresh_zones[1] = true if @sprites["movesel"].scroll != scroll
          @sprites["movesel"].scroll = scroll
        end
        @sprites["movesel"].index=selmove
        newmove = true
      end
      if Input.trigger?(Input::RIGHT) || Input.trigger?(Input::LEFT) ||
          (@sprites["movesel"].side == 1 && forceleft)
        if !(@sprites["movesel"].side == 0 && forceleft)
          next if @listMoves[@sprites["movesel"].page].length == 0
          side = @sprites["movesel"].side
          side = (side + 1) % 2
          if side == 0
            @sprites["editmoves_keybinds_1"].name = "Remove Move"
            selmove = @sprites["movesel"].index - @sprites["movesel"].scroll
            selmove = @pokemon.numMoves - 1 if selmove >= @pokemon.numMoves
            @sprites["movesel"].side = side
          else
            @sprites["editmoves_keybinds_1"].name = [
              "Switch to TMs",
              "Switch to Data Chips",
              "Switch to Level Up"
            ][@sprites["movesel"].page]
            @sprites["movesel"].side = side
            selmove = selmove + @sprites["movesel"].scroll
            numMoves = @listMoves[@sprites["movesel"].page].length
            selmove = numMoves - 1 if selmove >= numMoves
          end
          @sprites["movesel"].index = selmove
          newmove = true
        end
      end
      if Input.trigger?(Input::ACTION)
        if @sprites["movesel"].side == 0
          if @inbattle
            pbMessage("You cannot edit movesets while in battle.")
            next
          end
          if @pokemon.moves.length <= 1
            pbMessage("You need at least one move in a moveset.")
          else
            moveset = []
            for i in 0...@pokemon.moves.length
              moveset.push(@pokemon.moves[i]) if i != selmove
            end
            @pokemon.moves = moveset
            selmove = [selmove, @pokemon.moves.length-1].min
            @sprites["movesel"].index = selmove
            refresh_zones[0] = true
            newmove = true
          end
        else
          page = @sprites["movesel"].page
          page = (page + 1) % 3
          while @listMoves[page].length == 0
            page = (page + 1) % 3
          end
          @sprites["movesel"].page = page
          @sprites["editmoves_keybinds_1"].name = [
            "Switch to TMs",
            "Switch to Data Chips",
            "Switch to Level Up"
          ][page]
          if @sprites["movesel"].side == 1 && @listMoves[page].length == 0
            @sprites["movesel"].side = 0
            @sprites["movesel"].index = 0
          end
          selmove = @sprites["movesel"].index
          refresh_zones[1] = true
          newmove = true
        end
      end
      if newmove
        refresh_zones[2] = true
        pbPlayCursorSE()
        if @sprites["movesel"].side == 0
          newmove=@pokemon.moves[selmove].id
          drawSelectedMove(@pokemon,0,newmove,refresh_zones)
        else
          page = @sprites["movesel"].page
          newmove=@listMoves[page][selmove][0]
          drawSelectedMove(@pokemon,0,newmove,refresh_zones)
        end
      end
    end 
    @sprites["movesel"].visible=false
  end

  def pbGoToPrevious
    if @page!=0
      newindex=@partyindex
      while newindex>0
        newindex-=1
        if @party[newindex] && !@party[newindex].egg?
          @partyindex=newindex
          break
        end
      end
    else
      newindex=@partyindex
      while newindex>0
        newindex-=1
        if @party[newindex]
          @partyindex=newindex
          break
        end
      end
    end
  end

  def pbGoToNext
    if @page!=0
      newindex=@partyindex
      while newindex<@party.length-1
        newindex+=1
        if @party[newindex] && !@party[newindex].egg?
          @partyindex=newindex
          break
        end
      end
    else
      newindex=@partyindex
      while newindex<@party.length-1
        newindex+=1
        if @party[newindex]
          @partyindex=newindex
          break
        end
      end
    end
  end

  def pbScene
    GameData::Species.play_cry(@pokemon)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        break
      end
      dorefresh=false
      if Input.trigger?(Input::USE) || @machinemove
        if @page==1
          pbMoveSelection
          dorefresh=true
        end
      end
      if Input.trigger?(Input::UP) && @partyindex>0
        oldindex=@partyindex
        pbGoToPrevious
        if @partyindex!=oldindex
          @pokemon=@party[@partyindex]
          @listMoves = [
            pbGetLevelUpMoves(@pokemon),
            pbGetTMMoves(@pokemon),
            pbGetDataChipMoves(@pokemon)
          ]
          @sprites["movesel"].reset
          @sprites["pokemon"].setPokemonBitmap(@pokemon)
          @sprites["pokemon"].color=Color.new(0,0,0,0)
          pbPositionPokemonSprite(@sprites["pokemon"],396,156)
          dorefresh=true
          GameData::Species.play_cry(@pokemon)
        end
      end
      if Input.trigger?(Input::DOWN) && @partyindex<@party.length-1
        oldindex=@partyindex
        pbGoToNext
        if @partyindex!=oldindex
          @pokemon=@party[@partyindex]
          @listMoves = [
            pbGetLevelUpMoves(@pokemon),
            pbGetTMMoves(@pokemon),
            pbGetDataChipMoves(@pokemon)
          ]
          @sprites["movesel"].reset
          @sprites["pokemon"].setPokemonBitmap(@pokemon)
          @sprites["pokemon"].color=Color.new(0,0,0,0)
          pbPositionPokemonSprite(@sprites["pokemon"],396,156)
          dorefresh=true
          GameData::Species.play_cry(@pokemon)
        end
      end
      if Input.trigger?(Input::LEFT) && !@pokemon.egg?
        oldpage=@page
        @page-=1
        @page=1 if @page<0
        @page=0 if @page>1
        dorefresh=true
        if @page!=oldpage # Move to next page
          pbPlayCursorSE()
          dorefresh=true
        end
      end
      if Input.trigger?(Input::RIGHT) && !@pokemon.egg?
        oldpage=@page
        @page+=1
        @page=1 if @page<0
        @page=0 if @page>1
        if @page!=oldpage # Move to next page
          pbPlayCursorSE()
          dorefresh=true
        end
      end
      if dorefresh
        case @page
        when 0
          drawPageInfo(@pokemon)
        when 1
          drawPageMoves(@pokemon)
        end
      end
    end
    return @partyindex
  end
end



class PokemonSummary
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen(party,partyindex,machinemove=nil)
    @scene.pbStartScene(party,partyindex,machinemove)
    ret=@scene.pbScene
    @scene.pbEndScene
    return ret
  end

  def pbStartForgetScreen(party,partyindex,moveToLearn)
    ret=-1
    @scene.pbStartForgetScene(party,partyindex,moveToLearn)
    loop do
      ret=@scene.pbChooseMoveToForget(moveToLearn)
      if ret>=0 && moveToLearn!=0 && pbIsHiddenMove?(party[partyindex].moves[ret].id) && !$DEBUG
        pbMessage(_INTL("HM moves can't be forgotten now.")){ @scene.pbUpdate }
      else
        break
      end
    end
    @scene.pbEndScene
    return ret
  end

  def pbStartChooseMoveScreen(party,partyindex,message)
    ret=-1
    @scene.pbStartForgetScene(party,partyindex,0)
    pbMessage(message){ @scene.pbUpdate }
    loop do
      ret=@scene.pbChooseMoveToForget(0)
      if ret<0
        pbMessage(_INTL("You must choose a move!")){ @scene.pbUpdate }
      else
        break
      end
    end
    @scene.pbEndScene
    return ret
  end
end