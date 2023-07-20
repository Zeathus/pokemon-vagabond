class PokeSelectionSelectedSprite < SpriteWrapper
  attr_accessor :text

  def initialize(index,viewport=nil)
    super(viewport)
    @xvalues=([70]*6) + ([378]*6) + [0, 710]
    @yvalues=[]
    for i in 0...6
      @yvalues.push(68 + 64 * i)
    end
    @yvalues *= 2
    @yvalues.push(122, 122)
    @member=false
    @pbitmap=AnimatedBitmap.new("Graphics/Pictures/Party/bar_select")
    @mbitmap=AnimatedBitmap.new("Graphics/Pictures/Party/member_select")
    self.bitmap=@pbitmap.bitmap
    self.x=@xvalues[index]
    self.y=@yvalues[index]
    self.src_rect=Rect.new(0,0,320,64)
    @text=nil
  end

  def setIndex(value)
    @member = value >= 12
    self.other = value >= 6 && value < 12 || value == 13
    self.x=@xvalues[value]
    self.y=@yvalues[value]
  end

  def other=(value)
    if @member
      self.bitmap=@mbitmap.bitmap
      self.src_rect=Rect.new(0, 0, 58, 72)
      self.mirror = value
    else
      self.bitmap=@pbitmap.bitmap
      self.src_rect=Rect.new(0,value ? 64 : 0, 320, 64)
      self.mirror = false
    end
  end

  def update
    super
    @pbitmap.update
    @mbitmap.update
    self.bitmap=@member ? @mbitmap.bitmap : @pbitmap.bitmap
  end

  def selected
    return false
  end

  def selected=(value)
  end

  def preselected
    return false
  end

  def preselected=(value)
  end

  def switching
    return false
  end

  def switching=(value)
  end

  def refresh
  end

  def dispose
    @pbitmap.dispose
    super
  end
end


class PokeSelectionMenuItemSprite < SpriteWrapper
  attr_reader :selected

  def initialize(text,x,y,dir=0,otherid=0,viewport=nil,z=10)
    super(viewport)
    self.z=z
    @otherid=otherid
    @refreshBitmap=true
    @bgsprite=ChangelingSprite.new(0,0,viewport)
    @bgsprite.addBitmap("deselbitmap","Graphics/Pictures/Party/menu_item")
    @bgsprite.addBitmap("selbitmap","Graphics/Pictures/Party/menu_item_selected")
    if dir > 0
      @bgsprite.mirror=true
    end
    @bgsprite.changeBitmap("deselbitmap")
    @bgsprite.z=self.z
    @overlaysprite=BitmapSprite.new(@bgsprite.bitmap.width,@bgsprite.bitmap.height,viewport)
    @yoffset=8
    pbSetSmallFont(@overlaysprite.bitmap)
    textpos=[[text,68,8,2,Color.new(248,248,248),Color.new(40,40,40)]]
    pbDrawTextPositions(@overlaysprite.bitmap,textpos)
    @overlaysprite.z=self.z+1 # For compatibility with RGSS2
    self.x=x
    self.y=y
  end

  def dispose
    @overlaysprite.bitmap.dispose
    @overlaysprite.dispose
    @bgsprite.dispose
    super
  end

  def viewport=(value)
    super
    refresh
  end

  def color=(value)
    super
    refresh
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def zoom_y
    return @bgsprite.zoom_y
  end

  def zoom_y=(value)
    @bgsprite.zoom_y=value
  end

  def selected=(value)
    @selected=value
    refresh
  end

  def refresh
    @bgsprite.changeBitmap((@selected) ? "selbitmap" : "deselbitmap")
    @bgsprite.src_rect=Rect.new(0,@selected ? 0 : [32*@otherid, @bgsprite.bitmap.height - 32].min,134,32)
    if @bgsprite && !@bgsprite.disposed?
      @bgsprite.x=self.x
      @bgsprite.y=self.y
      @overlaysprite.x=self.x
      @overlaysprite.y=self.y
      @bgsprite.color=self.color
      @overlaysprite.color=self.color
    end
  end
end


class PokeSelectionConfirmCancelSprite < SpriteWrapper
  attr_reader :selected

  def initialize(text,x,y,narrowbox=false,viewport=nil)
    super(viewport)
    @refreshBitmap=true
    @bgsprite=ChangelingSprite.new(0,0,viewport)
    @bgsprite.addBitmap("deselbitmap","Graphics/Pictures/Party/button")
    @bgsprite.addBitmap("selbitmap","Graphics/Pictures/Party/button_active")
    @bgsprite.changeBitmap("deselbitmap")
    @overlaysprite=BitmapSprite.new(@bgsprite.bitmap.width,@bgsprite.bitmap.height,viewport)
    @yoffset=8
    pbSetSystemFont(@overlaysprite.bitmap)
    textpos=[[text,94,10,2,Color.new(248,248,248),Color.new(40,40,40)]]
    pbDrawTextPositions(@overlaysprite.bitmap,textpos)
    @overlaysprite.z=self.z+1 # For compatibility with RGSS2
    self.x=x
    self.y=y
  end

  def dispose
    @overlaysprite.bitmap.dispose
    @overlaysprite.dispose
    @bgsprite.dispose
    super
  end

  def viewport=(value)
    super
    refresh
  end

  def color=(value)
    super
    refresh
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def selected=(value)
    @selected=value
    refresh
  end

  def refresh
    @bgsprite.changeBitmap((@selected) ? "selbitmap" : "deselbitmap")
    if @bgsprite && !@bgsprite.disposed?
      @bgsprite.x=self.x
      @bgsprite.y=self.y
      @overlaysprite.x=self.x
      @overlaysprite.y=self.y
      @bgsprite.color=self.color
      @overlaysprite.color=self.color
    end
  end
end



class PokeSelectionSwitchSprite < SpriteWrapper
  attr_reader :selected

  def initialize(text,x,y,narrowbox=false,viewport=nil)
    super(viewport)
    @refreshBitmap=true
    @bgsprite=ChangelingSprite.new(0,0,viewport)
    @bgsprite.addBitmap("deselbitmap","Graphics/Pictures/Party/button")
    @bgsprite.addBitmap("selbitmap","Graphics/Pictures/Party/button_active")
    @bgsprite.addBitmap("switchbitmap","Graphics/Pictures/Party/button_switch")
    @bgsprite.addBitmap("switchselbitmap","Graphics/Pictures/Party/button_switch_active")
    @bgsprite.changeBitmap("deselbitmap")
    @overlaysprite=BitmapSprite.new(@bgsprite.bitmap.width,@bgsprite.bitmap.height,viewport)
    @yoffset=8
    @mode=0
    pbSetSystemFont(@overlaysprite.bitmap)
    textpos=[[text,94,10,2,Color.new(248,248,248),Color.new(40,40,40)]]
    pbDrawTextPositions(@overlaysprite.bitmap,textpos)
    @overlaysprite.z=self.z+1 # For compatibility with RGSS2
    self.x=x
    self.y=y
  end

  def mode=(value)
    @mode=value
  end

  def dispose
    @overlaysprite.bitmap.dispose
    @overlaysprite.dispose
    @bgsprite.dispose
    super
  end

  def viewport=(value)
    super
    refresh
  end

  def color=(value)
    super
    refresh
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def selected=(value)
    @selected=value
    refresh
  end

  def refresh
    if @mode==0
      @bgsprite.changeBitmap((@selected) ? "selbitmap" : "deselbitmap")
      @overlaysprite.bitmap.clear
      pbSetSystemFont(@overlaysprite.bitmap)
      textpos=[["SWITCH",94,10,2,Color.new(248,248,248),Color.new(40,40,40)]]
      pbDrawTextPositions(@overlaysprite.bitmap,textpos)
    else
      @bgsprite.changeBitmap((@selected) ? "switchselbitmap" : "switchbitmap")
      @overlaysprite.bitmap.clear
      pbSetSystemFont(@overlaysprite.bitmap)
      textpos=[["SUMMARY",94,10,2,Color.new(248,248,248),Color.new(40,40,40)]]
      pbDrawTextPositions(@overlaysprite.bitmap,textpos)
    end
    if @bgsprite && !@bgsprite.disposed?
      @bgsprite.x=self.x
      @bgsprite.y=self.y
      @overlaysprite.x=self.x
      @overlaysprite.y=self.y
      @bgsprite.color=self.color
      @overlaysprite.color=self.color
    end
  end
end


class PokeSelectionCancelSprite < PokeSelectionConfirmCancelSprite
  def initialize(viewport=nil)
    super(_INTL("CANCEL"),272,342,false,viewport)
  end
end


class PokeSelectionModeSprite < PokeSelectionSwitchSprite
  def initialize(viewport=nil)
    super(_INTL("SWITCH"),56,342,false,viewport)
  end
end



class PokeSelectionMenuSprite < PokeSelectionMenuItemSprite
  def initialize(text, x, y, dir=0, otherid=0, viewport=nil,z=10)
    super(_INTL(text),x,y,dir,otherid,viewport,z)
  end
end


class PokeSelectionMenuSmallSprite < PokeSelectionMenuItemSprite
  def initialize(text, x, y, viewport=nil)
    super(_INTL(text),x,y,true,0,viewport)
  end
end


class PokeSelectionConfirmSprite < PokeSelectionConfirmCancelSprite
  def initialize(viewport=nil)
    super(_INTL("CONFIRM"),56,342,true,viewport)
  end
end



class PokeSelectionCancelSprite2 < PokeSelectionConfirmCancelSprite
  def initialize(viewport=nil)
    if $game_switches[STADIUM_PARTY_SEL]
      super(_INTL("OPPONENT"),272,342,true,viewport)
    else
      super(_INTL("CANCEL"),272,342,true,viewport)
    end
  end
end



class ChangelingSprite < SpriteWrapper
  def initialize(x=0,y=0,viewport=nil)
    super(viewport)
    self.x=x
    self.y=y
    @bitmaps={}
    @currentBitmap=nil
  end

  def addBitmap(key,path)
    if @bitmaps[key]
      @bitmaps[key].dispose
    end
    @bitmaps[key]=AnimatedBitmap.new(path)
  end

  def changeBitmap(key)
    @currentBitmap=@bitmaps[key]
    self.bitmap=@currentBitmap ? @currentBitmap.bitmap : nil
  end

  def dispose
    return if disposed?
    for bm in @bitmaps.values; bm.dispose; end
    @bitmaps.clear
    super
  end

  def update
    return if disposed?
    for bm in @bitmaps.values; bm.update; end
    self.bitmap=@currentBitmap ? @currentBitmap.bitmap : nil
  end
end



class PartyMemberSprite < SpriteWrapper

  def initialize(type,otherid,other,viewport)
    super(viewport)
    @enabled=true
    @type=type
    @otherid=otherid
    @other=other
    @barbitmap=AnimatedBitmap.new("Graphics/Pictures/Party/member")
    @charsprite=IconSprite.new(0,0,viewport)
    @stepx=0
    @spritex=(@other ? 712 : 0)
    @spritey=124
    self.x = @spritex
    self.y = @spritey
    self.type=type
    self.mirror = @other
    @refreshBitmap=true
    refresh
  end

  def type=(value)
    @charsprite.setBitmap(sprintf("Graphics/Characters/trainer_%s",@type.to_s))
    width=@charsprite.bitmap.width
    height=@charsprite.bitmap.height
    @stepx=width/4
    @charsprite.src_rect=Rect.new(0,0,@stepx,height/4)
    @charsprite.x = self.x + (@other ? 26 : 30) - @stepx/2
    @charsprite.y = self.y
  end

  def color=(value)
    super(value)
    @charsprite.color=value
  end

  def tone=(value)
    super(value)
    @charsprite.tone=value
  end

  def opacity=(value)
    super(value)
    @charsprite.opacity=value
  end

  def x=(value)
    super
    @charsprite.x = self.x + (@other ? 26 : 30) - @stepx/2
  end

  def refresh
    if !self.bitmap || self.bitmap.disposed?
      self.bitmap=BitmapWrapper.new(56,68)
    end
    if @refreshBitmap
      @refreshBitmap=false
      self.bitmap.clear
      tmp_y = [@otherid * 68, @barbitmap.bitmap.height - 68].min
      self.bitmap.blt(0,0,@barbitmap.bitmap,Rect.new(0,tmp_y,56,68))
    end
    self.z = 15
    @charsprite.z = self.z + 1
  end

  def enabled=(value)
    @enabled=value
  end

  def animating
    if @enabled
      if @other
        return self.x > 712
      else
        return self.x < 0
      end
    else
      if @other
        return self.x < 768
      else
        return self.x > -56
      end
    end
  end

  def update
    if self.animating
      if @other
        self.x += @enabled ? -12 : 12
        #@charsprite.x += @enabled ? -12 : 12
      else
        self.x += @enabled ? 12 : -12
        #@charsprite.x += @enabled ? 12 : -12
      end
    end
    @charsprite.update
  end

  def dispose
    @barbitmap.dispose
    @charsprite.dispose
    self.bitmap.dispose
    super
  end

end

class PartyMemberChangeSprite < SpriteWrapper

  def initialize(otherid,other,viewport)
    super(viewport)
    self.z = 30
    @otherid=otherid
    @other=other
    @bgbitmap=AnimatedBitmap.new("Graphics/Pictures/Party/member_change")
    @namebitmap=AnimatedBitmap.new("Graphics/Pictures/Party/member_change_name")
    @arrow=IconSprite.new(0,0,viewport)
    @arrow.setBitmap("Graphics/Pictures/downarrow")
    @arrow.src_rect=Rect.new(0,0,28,40)
    @arrow.z = 32
    @members=[]
    @charsprites=[]
    @stepx=[]
    @selected=0
    @frame=0
    for i in 0...PBParty.len
      if hasPartyMember(i)
        @members.push(i)
        charsprite=IconSprite.new(0,0,viewport)
        type=PBParty.getTrainerType(i)
        if i==0
          charsprite.setBitmap(sprintf("Graphics/Characters/trainer_%s",type.to_s))
        else
          charsprite.setBitmap(sprintf("Graphics/Characters/trainer_%s",type.to_s))
        end
        width=charsprite.bitmap.width
        height=charsprite.bitmap.height
        step=width/4
        @stepx.push(step)
        charsprite.src_rect=Rect.new(0,0,step,height/4)
        charsprite.z = 31
        @charsprites.push(charsprite)
        if i == otherid
          @selected = @members.length - 1
        end
      end
    end
    @spacing = 64
    @spacing = 48 if @members.length >= 6
    @xstart = 256 - (@spacing * (@members.length - 1) / 2) + 128
    @spritex = 192
    @spritey = 242
    @arrow.y=@spritey - 32
    self.x = @spritex
    self.y = @spritey
    @refreshBitmap=true
    refresh
    refreshName
  end

  def cursor_visible=(value)
    @arrow.visible = value
  end

  def refresh
    if !self.bitmap || self.bitmap.disposed?
      self.bitmap=BitmapWrapper.new(384,128)
    end
    if @refreshBitmap
      @refreshBitmap=false
      self.bitmap.clear
      self.bitmap.blt(0,12,@bgbitmap.bitmap,Rect.new(0,0,384,46))
      for i in 0...@members.length
        @charsprites[i].x = @xstart + @spacing * i - @stepx[i] / 2
        @charsprites[i].y = self.y
      end
      @arrow.x = @xstart + @spacing * @selected - 14
    end
  end

  def refreshName
    self.bitmap.blt(106,64,@namebitmap.bitmap,Rect.new(0,0,172,40))
    name=PBParty.getName(@members[@selected])
    textpos=[[name,192,66,2,Color.new(248,248,248),Color.new(40,40,40)]]
    #pbSetSmallFont(self.bitmap)
    pbDrawTextPositions(self.bitmap,textpos)
  end

  def right
    @frame = 0
    @selected += 1
    @selected = 0 if @selected >= @members.length
    refreshName
  end

  def left
    @frame = 0
    @selected -= 1
    @selected = @members.length - 1 if @selected < 0
    refreshName
  end

  def selected
    return @selected
  end

  def member
    return @members[selected]
  end

  def y=(value)
    super
    for spr in @charsprites
      spr.y = self.y
    end
    @arrow.y = self.y - 32
  end

  def update
    @frame+=0.1
    @frame=0 if @frame>=4
    for i in 0...@members.length
      if i==@selected
        @charsprites[i].src_rect=Rect.new(@frame.floor*@stepx[i],0,@stepx[i],@charsprites[i].bitmap.height/4)
      else
        @charsprites[i].src_rect=Rect.new(0,0,@stepx[i],@charsprites[i].bitmap.height/4)
      end
      @charsprites[i].update
    end
    spacing = 64
    spacing = 48 if @members.length >= 6
    xstart = 256 - (spacing * (@members.length - 1) / 2)
    @arrow.x = @xstart + @spacing * @selected - 14
  end

  def dispose
    @bgbitmap.dispose
    @namebitmap.dispose
    @arrow.dispose
    for spr in @charsprites
      spr.dispose
    end
    self.bitmap.dispose
    super
  end

end



class PokeSelectionSprite < SpriteWrapper
  attr_reader :selected
  attr_reader :preselected
  attr_reader :switching
  attr_reader :pokemon
  attr_reader :active
  attr_accessor :text

  def initialize(pokemon,index,viewport=nil,other=false,otherid=0,multi=false,hasother=false)
    super(viewport)
    @pokemon=pokemon
    active=(index==0)
    @active=active
    @enabled=true
    @teampos=-1
    @multi=multi
    @index=index
    @hasother = hasother
    @other = other
    @otherid = otherid
    @barbitmap=AnimatedBitmap.new("Graphics/Pictures/Party/bar")
    @switchbitmap=AnimatedBitmap.new("Graphics/Pictures/Party/bar_switch")
    @numberbitmap=AnimatedBitmap.new("Graphics/Pictures/Party/bar_numbers")
    @spriteXOffset=@other ? 14 : 28
    @spriteYOffset=-18
    @pokenameX=@spriteXOffset + 60
    @pokenameY=16
    #@levelX=@other ? 274 : 292
    @levelY=20
    @numberX=@other ? 280 : 8
    @numberY=10
    @statusX=@numberX
    @statusY=@numberY
    @genderX=300
    @genderY=4
    @gaugeX=@other ? 74 : 90
    @gaugeY=46
    @hpbarX=@gaugeX - 50
    @hpbarY=34
    @hpX=@gaugeX + 90
    @hpY=@gaugeY - 4
    @itemXOffset=@spriteXOffset + 40
    @itemYOffset=@spriteYOffset + 46
    @annotX=96
    @annotY=58
    @xvalues=([70]*6) + ([378]*6)
    @yvalues=[]
    for i in 0...6
      @yvalues.push(68 + 64 * i)
    end
    @yvalues *= 2
    @text=nil
    @statuses=AnimatedBitmap.new(_INTL("Graphics/Pictures/Party/statuses"))
    @hpbar=AnimatedBitmap.new("Graphics/Pictures/Party/overlay_hp")
    @pkmnsprite=PokemonIconSprite.new(pokemon,viewport)
    @pkmnsprite.active=active
    @pkmnsprite.color=self.color
    @itemsprite=ChangelingSprite.new(0,0,viewport)
    @itemsprite.addBitmap("itembitmap","Graphics/Pictures/Party/icon_item")
    @itemsprite.addBitmap("mailbitmap","Graphics/Pictures/Party/icon_mail")
    @spriteX=@xvalues[@index]
    @spriteY=@yvalues[@index]
    @refreshBitmap=true
    @refreshing=false 
    @preselected=false
    @switching=false
    @pkmnsprite.z=self.z+2 # For compatibility with RGSS2
    @itemsprite.z=self.z+3 # For compatibility with RGSS2
    self.selected=false
    self.x=@spriteX
    self.y=@spriteY
    refresh
  end

  def enabled=(value)
    @enabled=value
    @active=value
  end

  def animating
    if @enabled
      if @other
        return self.x > @xvalues[@index]
      else
        return self.x < @xvalues[@index]
      end
    else
      if @other
        return self.x < @xvalues[@index] + 448
      else
        return self.x > @xvalues[@index] - 448
      end
    end
  end

  def dispose
    @barbitmap.dispose
    @statuses.dispose
    @hpbar.dispose
    @switchbitmap.dispose
    @numberbitmap.dispose
    @itemsprite.dispose
    @pkmnsprite.dispose
    self.bitmap.dispose
    super
  end

  def setTeamPos(value)
    @teampos=value
    #@switchbitmap=AnimatedBitmap.new("Graphics/Pictures/partyBar" + value.to_s + "_switch")
  end

  def selected=(value)
    @selected=value
    @refreshBitmap=true
    refresh
  end

  def text=(value)
    @text=value
    @refreshBitmap=true
    refresh
  end

  def pokemon=(value)
    @pokemon=value
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.pokemon=value
    end
    @refreshBitmap=true
    refresh
  end

  def preselected=(value)
    if value!=@preselected
      @preselected=value
      refresh
    end
  end

  def switching=(value)
    if value!=@switching
      @switching=value
      refresh
    end
  end

  def color=(value)
    super
    refresh
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def hp
    return @pokemon.hp
  end

  def refresh
    return if @refreshing
    return if disposed?
    @refreshing=true
    if !self.bitmap || self.bitmap.disposed?
      self.bitmap=BitmapWrapper.new(320,64)
    end
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.x=self.x+@spriteXOffset
      @pkmnsprite.y=self.y+@spriteYOffset
      @pkmnsprite.color=self.color
      @pkmnsprite.selected=self.selected
      @pkmnsprite.z = (self.selected ? 4 : 2)
    end
    if @itemsprite && !@itemsprite.disposed?
      @itemsprite.visible=(@pokemon.item != nil)
      if @itemsprite.visible
        @itemsprite.changeBitmap(@pokemon.mail ? "mailbitmap" : "itembitmap")
        @itemsprite.x=self.x+@itemXOffset
        @itemsprite.y=self.y+@itemYOffset
        @itemsprite.color=self.color
        @itemsprite.z = (self.selected ? 5 : 3)
      end
    end
    if @refreshBitmap
      @refreshBitmap=false
      self.bitmap.clear if self.bitmap
      tmp_x = @other ? 320 : 0
      tmp_x = 0 if @hasother && @index % 6 >= 3
      tmp_y = [64 * @otherid, @barbitmap.bitmap.height - 64].min
      if @teampos >= 0
        self.bitmap.blt(0,0,@barbitmap.bitmap,Rect.new(tmp_x,tmp_y,320,64))
        self.bitmap.blt(0,0,@switchbitmap.bitmap,Rect.new(0,@other ? 64 : 0,320,64))
        self.bitmap.blt(@numberX,@numberY,@numberbitmap.bitmap,Rect.new(32*@teampos,[32*@otherid,@numberbitmap.height-32].min,32,32))
      elsif self.preselected
        self.bitmap.blt(0,0,@barbitmap.bitmap,Rect.new(tmp_x,tmp_y,320,64))
        self.bitmap.blt(0,0,@switchbitmap.bitmap,Rect.new(0,@other ? 64 : 0,320,64))
        self.bitmap.blt(@numberX,@numberY,@numberbitmap.bitmap,Rect.new(32*(@index%6),[32*@otherid,@numberbitmap.height-32].min,32,32))
      else
        self.bitmap.blt(0,0,@barbitmap.bitmap,Rect.new(tmp_x,tmp_y,320,64))
        self.bitmap.blt(@numberX,@numberY,@numberbitmap.bitmap,Rect.new(32*(@index%6),[32*@otherid,@numberbitmap.height-32].min,32,32))
      end
      base=Color.new(248,248,248)
      shadow=Color.new(40,40,40)
      pbSetSystemFont(self.bitmap)
      pokename=@pokemon.name
      textpos=[[pokename,@pokenameX,@pokenameY,0,base,shadow]]
      if !@pokemon.egg?
        if !@text || !@text.is_a?(String) || @text.length==0
          tothp=@pokemon.totalhp
          hptextpos = [[_ISPRINTF("{1: 3d}/{2: 3d}",@pokemon.hp,tothp),
             @hpX,@hpY,2,base,shadow]]
          hpgauge=@pokemon.totalhp==0 ? 0 : ((self.hp*95/@pokemon.totalhp).floor * 2)
          hpgauge=1 if hpgauge==0 && self.hp>0
          hpzone=0
          hpzone=1 if self.hp<=(@pokemon.totalhp/2).floor
          hpzone=2 if self.hp<=(@pokemon.totalhp/4).floor
          hpcolors=[
             Color.new(14,152,22),Color.new(24,192,32),   # Green
             Color.new(202,138,0),Color.new(232,168,0),   # Orange
             Color.new(218,42,36),Color.new(248,72,56)    # Red
          ]
          # fill with HP color
          self.bitmap.fill_rect(@gaugeX,@gaugeY,hpgauge,2,hpcolors[hpzone*2])
          self.bitmap.fill_rect(@gaugeX,@gaugeY+2,hpgauge,4,hpcolors[hpzone*2+1])
          self.bitmap.fill_rect(@gaugeX,@gaugeY+6,hpgauge,2,hpcolors[hpzone*2])
          self.bitmap.blt(@hpbarX,@hpbarY,@hpbar.bitmap,
            Rect.new(0,[@otherid*32, @hpbar.bitmap.height-32].min,@hpbar.width,32))
          if @pokemon.hp==0 || @pokemon.status != :NONE
            status=(@pokemon.hp==0) ? 5 : (GameData::Status.get(@pokemon.status).icon_position)
            statusrect=Rect.new(0,32*status,32,32)
            self.bitmap.blt(@statusX,@statusY,@statuses.bitmap,statusrect)
          end
        end
        pbSetSmallestFont(self.bitmap)
        pbDrawTextPositions(self.bitmap,hptextpos)
      end
      pbSetSystemFont(self.bitmap)
      pbDrawTextPositions(self.bitmap,textpos)
      pbSetSmallFont(self.bitmap)
      if !@pokemon.egg?
        pbSetSystemFont(self.bitmap)
        levelX = @pokenameX + self.bitmap.text_size(pokename).width + 8
        leveltext=[([_INTL("Lv.{1}",@pokemon.level),levelX,@levelY,0,base,shadow])]
        pbSetSmallFont(self.bitmap)
        pbDrawTextPositions(self.bitmap,leveltext)
      end
      if @text && @text.is_a?(String) && @text.length>0
        pbSetSystemFont(self.bitmap)
        #annotation=[[@text,@annotX,@annotY,0,base,shadow]]
        self.bitmap.fill_rect(320,14,156,8,Color.new(104,85,85))
        self.bitmap.fill_rect(320,22,150,4,Color.new(104,85,85))
        annotation=[[@text,400,10,2,base,shadow]]
        pbDrawTextPositions(self.bitmap,annotation)
      end
    end
    @refreshing=false
  end

  def update
    super
    if self.animating
      if @other
        self.x += @enabled ? -32 : 32
      else
        self.x += @enabled ? 32 : -32
      end
    end
    @itemsprite.update if @itemsprite && !@itemsprite.disposed?
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.update
    end
  end
end

class PokeSelectionPlaceholderSprite < SpriteWrapper
  attr_accessor :text

  def initialize(pokemon,index,viewport=nil,other=false,otherid=0)
    super(viewport)
    @enabled=true
    @xvalues=([70]*6) + ([378]*6)
    @yvalues=[]
    for i in 0...6
      @yvalues.push(68 + 64 * i)
    end
    @yvalues *= 2
    @other = other
    @otherid = otherid
    @index = index
    @pbitmap=AnimatedBitmap.new("Graphics/Pictures/Party/bar")
    self.bitmap=@pbitmap.bitmap
    self.x=@xvalues[index]
    self.y=@yvalues[index]
    self.src_rect = Rect.new(@other ? 320 : 0,[64*@otherid, self.bitmap.height - 64].min,320,64)
    self.tone = Tone.new(-100,-100,-100)
    @text=nil
  end

  def enabled=(value)
    @enabled=value
  end

  def animating
    if @enabled
      if @other
        return self.x > @xvalues[@index]
      else
        return self.x < @xvalues[@index]
      end
    else
      if @other
        return self.x < @xvalues[@index] + 448
      else
        return self.x > @xvalues[@index] - 448
      end
    end
  end

  def update
    super
    if self.animating
      if @other
        self.x += @enabled ? -32 : 32
      else
        self.x += @enabled ? 32 : -32
      end
    end
    @pbitmap.update
    self.bitmap=@pbitmap.bitmap
  end

  def selected
    return false
  end

  def selected=(value)
  end

  def preselected
    return false
  end

  def preselected=(value)
  end

  def switching
    return false
  end

  def switching=(value)
  end

  def refresh
  end

  def dispose
    @pbitmap.dispose
    super
  end
end

class LevelUpSprite < SpriteWrapper
  attr_accessor :spriteY
  attr_accessor :new_level
  attr_reader :max_level

  def initialize(pokemon,summary,viewport=nil)
    super(viewport)
    @pokemon = pokemon
    @new_level = 0
    if $game_variables[BADGE_COUNT] > 0
      @max_level = pbNextGymLevel($game_variables[BADGE_COUNT]-1)
    else
      @max_level = 0
    end
    @summary = summary
    @pbitmap = AnimatedBitmap.new("Graphics/Pictures/Party/summary_minihud")
    self.bitmap = @pbitmap.bitmap
    @overlay=Sprite.new(viewport)
    @overlay.bitmap=Bitmap.new(@pbitmap.bitmap.width, @pbitmap.bitmap.height)
    @overlay.z = self.z + 1
    @arrowoverlay=Sprite.new(viewport)
    @arrowoverlay.bitmap=Bitmap.new(@pbitmap.bitmap.width, @pbitmap.bitmap.height + 22)
    @arrowoverlay.z = self.z + 6
    @spriteY = 0
    self.x=Graphics.width / 2 - @pbitmap.bitmap.width / 2
    self.update
  end

  def pokemon=(value)
    @pokemon = value
    @new_level = @pokemon.level
    self.refresh
  end

  def z=(value)
    @overlay.z = value + 1
    super(value)
  end

  def update
    self.y = @summary.y + @spriteY
    @overlay.x = self.x
    @overlay.y = self.y
    @arrowoverlay.x = self.x
    @arrowoverlay.y = self.y - 10
    super
  end

  def cost
    return (@new_level == @pokemon.level) ? 0 : (@new_level**3 - @pokemon.exp)
  end

  def refresh(arrow=false)
    @overlay.bitmap.clear
    @arrowoverlay.bitmap.clear
    return if !@pokemon
    base=Color.new(248,248,248)
    shadow=Color.new(104,104,104)
    textpos = [
      [sprintf("Max Lv.%3d", @max_level),16,8,0,base,shadow],
      [sprintf("Lv.%3d", @pokemon.level),160,8,0,base,shadow],
      [sprintf("Lv.%3d", @new_level),160+82,8,0,base,shadow],
      [sprintf("Cost:"),@overlay.bitmap.width - 136,8,0,base,shadow],
      [sprintf("$%d", self.cost),@overlay.bitmap.width - 16,8,1,base,shadow]
    ]
    pbSetSmallFont(@overlay.bitmap)
    pbDrawTextPositions(@overlay.bitmap, textpos)
    if arrow
      imagepos = []
      if @new_level > @pokemon.level
        imagepos.push(["Graphics/Pictures/Party/arrow",268,36,0,16,24,16])
      end
      if @new_level < @max_level
        imagepos.push(["Graphics/Pictures/Party/arrow",268,0,0,0,24,16])
      end
      pbDrawImagePositions(@arrowoverlay.bitmap, imagepos)
    end
  end

  def dispose
    @pbitmap.dispose
    @overlay.dispose
    @arrowoverlay.dispose
    super
  end
end

class QuickSummarySprite < SpriteWrapper
  def initialize(pokemon,viewport=nil)
    super(viewport)
    @enabled=true
    @pokemon=pokemon
    @pbitmap=AnimatedBitmap.new("Graphics/Pictures/Party/summary")
    self.bitmap=@pbitmap.bitmap
    @overlay=Sprite.new(viewport)
    @overlay.bitmap=Bitmap.new(@pbitmap.bitmap.width, @pbitmap.bitmap.height)
    @overlay.z = self.z + 1
    @icon = AutoMosaicPokemonSprite.new(viewport)
    @icon.z = self.z + 1
    @typebitmap=AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    self.x=Graphics.width / 2 - @pbitmap.bitmap.width / 2
    self.y=Graphics.height - @pbitmap.bitmap.height
    self.update
    if @pokemon
      @icon.setPokemonBitmap(@pokemon)
      self.refresh
    end
  end

  def pokemon=(value)
    if @pokemon != value
      if !value
        @pokemon = nil
        self.refresh
      else
        @pokemon = value
        @icon.setPokemonBitmap(@pokemon)
        #@icon.mosaic = Graphics.frame_rate/4
        self.refresh
      end
    end
  end

  def enabled=(value)
    @enabled=value
  end

  def update
    @overlay.x = self.x
    @overlay.y = self.y
    @overlay.update
    @icon.x = Graphics.width / 2 + 8
    @icon.y = self.y + 134
    @icon.update
    super
  end

  def z=(value)
    @overlay.z = value + 1
    @icon.z = value + 1
    super(value)
  end

  def refresh
    @overlay.bitmap.clear
    if @pokemon
      base=Color.new(64,64,64)
      shadow=Color.new(176,176,176)
      base2=Color.new(248,248,248)
      shadow2=Color.new(104,104,104)
      typerect=Rect.new(0,GameData::Type.get(@pokemon.types[0]).icon_position*28,64,28)
      affinityrect=Rect.new(0,GameData::Type.get(@pokemon.affinities[0]).icon_position*28,64,28)
      if @pokemon.types.length == 1
        @overlay.bitmap.blt(478,40,@typebitmap.bitmap,typerect)
      else
        type2rect=Rect.new(0,GameData::Type.get(@pokemon.types[1]).icon_position*28,64,28)
        @overlay.bitmap.blt(478-34,40,@typebitmap.bitmap,typerect)
        @overlay.bitmap.blt(478+34,40,@typebitmap.bitmap,type2rect)
      end
      if @pokemon.affinities.length == 1
        @overlay.bitmap.blt(478,40+58,@typebitmap.bitmap,affinityrect)
      else
        affinity2rect=Rect.new(0,GameData::Type.get(@pokemon.affinities[1]).icon_position*28,64,28)
        @overlay.bitmap.blt(478-34,40+58,@typebitmap.bitmap,affinityrect)
        @overlay.bitmap.blt(478+34,40+58,@typebitmap.bitmap,affinity2rect)
      end
      textpos = []
      imagepos = []
      if @pokemon.hasItem?
        textpos.push([GameData::Item.get(@pokemon.item).name,478+32,40+58*2,2,base2,shadow2])
      else
        textpos.push([_INTL("No Item"),478+32,46+58*2,2,Color.new(208,208,200),Color.new(120,144,184)])
      end
      abilityname = GameData::Ability.get(@pokemon.ability).name
      textpos.push([abilityname,478+32,46+58*3,2,base2,shadow2])

      xPos=16
      yPos=52
      for i in 0...4
        moveobject=@pokemon.moves[i]
        if moveobject
          movedata=GameData::Move.get(moveobject.id)
          if moveobject.id!=0
            imagepos.push(["Graphics/Pictures/Party/move_slot",xPos,yPos,0,
                GameData::Type.get(moveobject.type).icon_position*46,192,46])
            textpos.push([movedata.name,xPos+98,yPos+16,2,
                Color.new(64,64,64),Color.new(176,176,176)])
          end
        end
        yPos+=44
      end
      pbDrawImagePositions(@overlay.bitmap, imagepos)
      pbSetSmallFont(@overlay.bitmap)
      pbDrawTextPositions(@overlay.bitmap, textpos)
    end
  end

  def color=(value)
    @overlay.color = value
    @icon.color = value
    super(value)
  end

  def dispose
    @icon.dispose
    @overlay.dispose
    @pbitmap.dispose
    @typebitmap.dispose
    super
  end
end


##############################


class PokemonScreen_Scene
  include PokemonDebugMixin

  def pbShowCommands(helptext,commands,index=0)
    ret=-1
    helpwindow=@sprites["helpwindow"]
    #helpwindow.visible=true
    using(cmdwindow=Window_CommandPokemon.new(commands)) {
       cmdwindow.z=@viewport.z+1
       cmdwindow.index=index
       pbBottomRight(cmdwindow)
       helpwindow.text=""
       helpwindow.resizeHeightToFit(helptext,Graphics.width-cmdwindow.width)
       helpwindow.text=helptext
       pbBottomLeft(helpwindow)
       loop do
         Graphics.update
         Input.update
         cmdwindow.update
         self.update
         if Input.trigger?(Input::BACK)
           pbPlayCancelSE()
           ret=-1
           break
         end
         if Input.trigger?(Input::USE)
           pbPlayDecisionSE()
           ret=cmdwindow.index
           break
         end
       end
    }
    return ret
  end

  def pbConfirm(str)
    return pbShowCommands(str,[_INTL("Yes"),_INTL("No")])==0
  end

  def pbUpdate
    update
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbSetHelpText(helptext)
    helpwindow=@sprites["helpwindow"]
    pbBottomLeftLines(helpwindow,1)
    helpwindow.text=helptext
    helpwindow.width=398
    #helpwindow.visible=true
  end

  def tid
    return @tid
  end

  def ptid
    return @ptid
  end

  def party
    return @party
  end

  def pparty
    return @pparty
  end

  def party=(value)
    @party = value
  end

  def pparty=(value)
    @pparty = value
  end

  def pbStartScene(party,starthelptext,annotations=nil,multiselect=false)
    @sprites={}
    @mode=0
    @tid=getPartyActive(0)
    @ptid=getPartyActive(1)
    @party=getActivePokemon(0) if !@party
    @pparty=getActivePokemon(1) if !@pparty # Partner Party
    @fullparty=-1
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @multiselect=multiselect
    addBackgroundPlane(@sprites,"bg","Party/bg",@viewport)
    @sprites["messagebox"]=Window_AdvancedTextPokemon.new("")
    @sprites["helpwindow"]=Window_UnformattedTextPokemon.new(starthelptext)
    @sprites["messagebox"].viewport=@viewport
    @sprites["messagebox"].visible=false
    @sprites["messagebox"].letterbyletter=true
    @sprites["helpwindow"].viewport=@viewport
    @sprites["helpwindow"].visible=false
    @sprites["messagebox"].z = 9999
    @sprites["helpwindow"].z = 9999
    pbBottomLeftLines(@sprites["messagebox"],2)
    pbBottomLeftLines(@sprites["helpwindow"],1)
    pbSetHelpText(starthelptext)
    @sprites["summary"]=QuickSummarySprite.new(@party[0], @viewport)
    @sprites["summary"].z = 4
    @sprites["levelup"]=LevelUpSprite.new(nil, @sprites["summary"], @viewport)
    @sprites["levelup"].z = 1
    # Party Member Slots
    @sprites["member1"]=PartyMemberSprite.new(
      PBParty.getTrainerType(@tid),@tid,false,@viewport)
    @sprites["member2"]=PartyMemberSprite.new(
      PBParty.getTrainerType(@ptid),@ptid,true,@viewport)
    # Add player party Pokémon sprites
    for i in 0...6
      if @party[i]
        @sprites["pokemon#{i}"]=PokeSelectionSprite.new(
           @party[i],i,@viewport,false,@tid,multiselect,@ptid>=0)
      else
        @sprites["pokemon#{i}"]=PokeSelectionPlaceholderSprite.new(
           @party[i],i,@viewport,false,@tid)
      end
      if annotations
        @sprites["pokemon#{i}"].text=annotations[i]
      end
    end
    # Add partner party Pokémon sprites
    for i in 6...12
      if @pparty.is_a?(Array) && @pparty[i-6]
        @sprites["pokemon#{i}"]=PokeSelectionSprite.new(
           @pparty[i-6],i,@viewport,true,@ptid,multiselect,@ptid>=0)
      else
        @sprites["pokemon#{i}"]=PokeSelectionPlaceholderSprite.new(
           @pparty[i-6],i,@viewport,true,@ptid)
      end
      if annotations
        @sprites["pokemon#{i}"].text=annotations[i]
      end
    end
    # Set enabled
    if @ptid >= 0
      for i in 3...6
        @sprites["pokemon#{i}"].x -= 448
        @sprites["pokemon#{i}"].enabled = false
      end
    else
      for i in 6...9
        @sprites["pokemon#{i}"].x += 448
        @sprites["pokemon#{i}"].enabled = false
      end
    end
    for i in 9...12
      @sprites["pokemon#{i}"].x += 448
      @sprites["pokemon#{i}"].enabled = false
    end

    @sprites["selected"] = PokeSelectionSelectedSprite.new(0, @viewport)
    # Select first Pokémon
    @activecmd=0
    @prevcmd=0
    @sprites["pokemon0"].selected=true
    pbFadeInAndShow(@sprites) { update }
  end

  def mode=(value)
    @mode=value
    #@sprites["pokemon6"].mode=value
    pbRefresh
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbChooseNumber(helptext, maximum, initnum = 1)
    return UIHelper.pbChooseNumber(@sprites["helpwindow"], helptext, maximum, initnum) { update }
  end

  def pbMemberMenuStart(index)
    left = index == 12
    otherid = left ? @tid : @ptid
    other = @ptid >= 0
    if left
      @sprites["option0"]=PokeSelectionMenuSprite.new(
        "Change",-48,100,1,otherid,@viewport)
      @sprites["option1"]=PokeSelectionMenuSprite.new(
        "Party",-48,126,0,otherid,@viewport)
      12.times do
        for i in 0...2
          @sprites[_INTL("option{1}",i)].x += 6
        end
        Graphics.update
        Input.update
        self.update
      end
      for i in 0...2
        @sprites[_INTL("option{1}",i)].x += 2
      end
    else
      @sprites["option0"]=PokeSelectionMenuSprite.new(
        "Change",426,262,0,otherid,@viewport)
      @sprites["option1"]=PokeSelectionMenuSprite.new(
        "Party",426,288,1,otherid,@viewport)
      12.times do
        for i in 0...2
          @sprites[_INTL("option{1}",i)].x -= 6
        end
        Graphics.update
        Input.update
        self.update
      end
      for i in 0...2
        @sprites[_INTL("option{1}",i)].x -= 2
      end
    end
    Graphics.update
    Input.update
    self.update
    @menuindex=0
  end

  def pbMemberMenuEnd(index)
    left = index == 12
    if left
      14.times do
        for i in 0...2
          @sprites[_INTL("option{1}",i)].x -= 6
        end
        Graphics.update
        Input.update
        self.update
      end
    else
      14.times do
        for i in 0...2
          @sprites[_INTL("option{1}",i)].x += 6
        end
        Graphics.update
        Input.update
        self.update
      end
    end
    for i in 0...2
      @sprites[_INTL("option{1}",i)].dispose
    end
    Graphics.update
    Input.update
    self.update
    @menuindex=0
  end

  def pbMemberMenu(index)
    menuitems = 2
    @sprites[_INTL("option{1}",@menuindex)].selected = true
    @sprites[_INTL("option{1}",@menuindex)].refresh
    Graphics.update
    Input.update

    loop do
      update = false
      key=-1
      key=Input::DOWN if Input.repeat?(Input::DOWN)
      key=Input::UP if Input.repeat?(Input::UP)

      if key != -1
        @menuindex = (@menuindex + 1) % 2
        update = true
      end

      if Input.trigger?(Input::USE)
        return @menuindex
      end
      if Input.trigger?(Input::BACK)
        return -1
      end

      if update
        for i in 0...menuitems
          @sprites[_INTL("option{1}",i)].selected=(@menuindex==i)
          @sprites[_INTL("option{1}",i)].refresh
        end
      end

      Graphics.update
      Input.update
      self.update
    end

  end

  def pbPokemonMenuStart(index, cmds)
    otherid = index < 6 ? @tid : @ptid
    other = @ptid >= 0
    index-=9 if index >= 9
    index-=3 if index >= 6
    for j in 0...cmds.length
      i = cmds.length - j - 1
      if other && @fullparty == 1
        @sprites[_INTL("button{1}",i)]=
          PokeSelectionMenuSprite.new(
          cmds[i],290,106+index*64,(i+1)%2,otherid,@viewport,20)
      else
        @sprites[_INTL("button{1}",i)]=
          PokeSelectionMenuSprite.new(
          cmds[i],((index < 3) ? 256 : 378),106+(index%3)*64,i%2,otherid,@viewport,20)
      end
    end
    6.times do
      for i in 0...cmds.length
        @sprites[_INTL("button{1}",i)].y += i*4
      end
      Graphics.update
      Input.update
      self.update
    end
    for i in 0...cmds.length
      @sprites[_INTL("button{1}",i)].y += i*2
    end
    Graphics.update
    Input.update
    self.update
    @menuindex=0
  end

  def pbPokemonMenuEnd(index, cmds)
    return if !@sprites.key?("button0")
    index-=9 if index >= 9
    index-=3 if index >= 6
    6.times do
      for i in 0...cmds.length
        @sprites[_INTL("button{1}",i)].y -= i*4
      end
      Graphics.update
      Input.update
      self.update
    end
    for i in 0...cmds.length
      @sprites[_INTL("button{1}",i)].dispose
      @sprites.delete(_INTL("button{1}",i))
    end
    Graphics.update
    Input.update
    self.update
    @menuindex=0
  end

  def pbPokemonMenu(index, cmds)
    menuitems = cmds.length
    @sprites[_INTL("button{1}",@menuindex)].selected = true
    @sprites[_INTL("button{1}",@menuindex)].refresh
    Graphics.update
    Input.update

    loop do
      update = false
      key=-1
      key=Input::DOWN if Input.repeat?(Input::DOWN)
      key=Input::UP if Input.repeat?(Input::UP)

      if key == Input::DOWN
        @menuindex += 1
        @menuindex = 0 if @menuindex >= menuitems
        update = true
      elsif key == Input::UP
        @menuindex -= 1
        @menuindex = menuitems - 1 if @menuindex < 0
        update = true
      end

      if Input.trigger?(Input::USE)
        return @menuindex
      end
      if Input.trigger?(Input::BACK)
        return -1
      end

      if update
        for i in 0...menuitems
          @sprites[_INTL("button{1}",i)].selected=(@menuindex==i ? true : false)
          @sprites[_INTL("button{1}",i)].refresh
        end
      end

      Graphics.update
      Input.update
      self.update
    end

  end

  def pbChangeSelection(key,currentsel,prevsel)
    other=@ptid >= 0
    numsprites=6
    case key
    when Input::RIGHT
      if currentsel == 12
        if prevsel >= 0 && prevsel <= 2
          currentsel = prevsel
        else
          currentsel = 0
        end
      elsif other && @fullparty != 0 && currentsel >= 6 && currentsel <= 8
        currentsel = 13
      elsif currentsel >= 0 && currentsel <= 2
        currentsel = 6 + [currentsel, @pparty.length-1].min
      end
    when Input::LEFT
      if currentsel == 13
        if prevsel >= 6 && prevsel <= 8
          currentsel = prevsel
        else
          currentsel = 6
        end
      elsif @fullparty != 1 && currentsel >= 0 && currentsel <= 2
        currentsel = 12
      elsif currentsel >= 6 && currentsel <= 8
        currentsel = [currentsel - 6, @party.length-1].min
      end
    when Input::UP
      if currentsel < 12
        currentsel -= 1
        if other && @fullparty == 1
          currentsel = 5 + @pparty.length if currentsel < 6
        elsif other && @fullparty != 0
          currentsel = 5 + [@pparty.length,3].min if currentsel == 5
          currentsel = [@party.length-1,2].min if currentsel < 0
        else
          currentsel = @party.length - 1 if currentsel < 0
        end
      end
    when Input::DOWN
      if currentsel < 12
        currentsel += 1
        if other && @fullparty == 1
          currentsel = 6 if currentsel == 6 + @pparty.length
        elsif other && @fullparty != 0
          currentsel = 6 if currentsel == 6 + [@pparty.length,3].min
          currentsel = 0 if currentsel == [@party.length,3].min
        else
          currentsel = 0 if currentsel == @party.length
        end
      end
    end
    return currentsel
  end

  def pbRefresh
    for i in 0...12
      sprite=@sprites["pokemon#{i}"]
      if sprite 
        if sprite.is_a?(PokeSelectionSprite)
          sprite.pokemon=sprite.pokemon
        else
          sprite.refresh
        end
      end
    end
    @sprites["member1"].refresh
    @sprites["member2"].refresh
  end

  def pbRefreshSingle(i)
    sprite=@sprites["pokemon#{i}"]
    if sprite 
      if sprite.is_a?(PokeSelectionSprite)
        sprite.pokemon=sprite.pokemon
      else
        sprite.refresh
      end
    end
  end

  def pbHardRefresh(hide=-1)
    oldtext=[]
    lastselected=-1
    for i in 0...12
      oldtext.push(@sprites["pokemon#{i}"].text)
      lastselected=i if @sprites["pokemon#{i}"].selected
      @sprites["pokemon#{i}"].dispose
    end
    lastselected=@party.length-1 if lastselected>=@party.length
    lastselected=0 if lastselected<0
    @sprites["member1"].dispose
    @sprites["member2"].dispose
    @sprites["member1"]=PartyMemberSprite.new(
      PBParty.getTrainerType(@tid),@tid,false,@viewport)
    @sprites["member2"]=PartyMemberSprite.new(
      PBParty.getTrainerType(@ptid),@ptid,true,@viewport)
    # Add player party Pokémon sprites
    for i in 0...6
      if @party[i]
        @sprites["pokemon#{i}"]=PokeSelectionSprite.new(
           @party[i],i,@viewport,false,@tid,false,@ptid>=0)
      else
        @sprites["pokemon#{i}"]=PokeSelectionPlaceholderSprite.new(
           @party[i],i,@viewport,false,@tid)
      end
      @sprites["pokemon#{i}"].text=oldtext[i]
    end
    # Add partner party Pokémon sprites
    for i in 6...12
      if @pparty.is_a?(Array) && @pparty[i-6]
        @sprites["pokemon#{i}"]=PokeSelectionSprite.new(
           @pparty[i-6],i,@viewport,true,@ptid,false,@ptid>=0)
      else
        @sprites["pokemon#{i}"]=PokeSelectionPlaceholderSprite.new(
           @pparty[i-6],i,@viewport,true,@ptid)
      end
      @sprites["pokemon#{i}"].text=oldtext[i]
    end
    # Set enabled
    if @ptid >= 0
      for i in 3...6
        @sprites["pokemon#{i}"].x -= 448
        @sprites["pokemon#{i}"].enabled = false
      end
    else
      for i in 6...9
        @sprites["pokemon#{i}"].x += 448
        @sprites["pokemon#{i}"].enabled = false
      end
    end
    for i in 9...12
      @sprites["pokemon#{i}"].x += 448
      @sprites["pokemon#{i}"].enabled = false
    end
    if hide == 1 || hide == 3
      @sprites["member1"].x = -56 - 4
      @sprites["member1"].enabled = false
      for i in 0...3
        @sprites["pokemon#{i}"].x -= 448
        @sprites["pokemon#{i}"].enabled = false
      end
    end
    if hide == 2 || hide == 3
      @sprites["member2"].x = 768 + 4
      @sprites["member2"].enabled = false
      for i in 6...9
        @sprites["pokemon#{i}"].x += 448
        @sprites["pokemon#{i}"].enabled = false
      end
    end
    pbSelect(lastselected) if hide < 0
  end

  def pbPreSelect(pkmn)
    @activecmd=pkmn
  end

  def pbChoosePokemon(switching=false,initialsel=-1,inbattle=false)
    for i in 0...12
      @sprites["pokemon#{i}"].preselected=(switching && i==@activecmd)
      @sprites["pokemon#{i}"].switching=switching
    end
    @activecmd=initialsel if initialsel>=0
    @prevcmd=@activecmd
    @changecmd=-1
    pbRefresh
    loop do
      Graphics.update
      Input.update
      self.update
      oldsel=@activecmd
      if @changecmd >= 0
        @activecmd = @changecmd
        @changecmd = -1
      end
      key=-1
      key=Input::DOWN if Input.repeat?(Input::DOWN)
      key=Input::RIGHT if Input.repeat?(Input::RIGHT)
      key=Input::LEFT if Input.repeat?(Input::LEFT)
      key=Input::UP if Input.repeat?(Input::UP)
      if key!=-1
        newcmd = pbChangeSelection(key,@activecmd,@prevcmd)
        if newcmd != @activecmd
          @prevcmd = @activecmd
          @activecmd = newcmd
          if @activecmd < 6
            @sprites["summary"].pokemon=@party[@activecmd]
          elsif @activecmd < 12
            @sprites["summary"].pokemon=@pparty[@activecmd-6]
          end
        end
      end
      if @activecmd!=oldsel # Changing selection
        pbPlayCursorSE()
        numsprites=12
        for i in 0...numsprites
          @sprites["pokemon#{i}"].selected=(i==@activecmd)
        end
        @sprites["selected"].setIndex(@activecmd)
        #@sprites["selected"].y = 52 + (48 * @activecmd)
        #@sprites["selected"].y = 400 if @activecmd >= 6
      end
      if Input.trigger?(Input::BACK)
        if switching
          return -1
        elsif @fullparty >= 0
          pbHideEntireParty
          if @activecmd < 12
            if @activecmd >= 9
              @changecmd = [@party.length-1,@activecmd - 9].min
            elsif @activecmd >= 3 && @activecmd < 6
              @changecmd = [6+@pparty.length-1,@activecmd + 3].min
            end
          end
          @fullparty = -1
        else
          return -1
        end
      end
      if Input.trigger?(Input::USE)
        if @activecmd < 12
          pbPlayDecisionSE()
          return @activecmd
        else
          if inbattle
            pbDisplay("You can't do this while in battle.")
          elsif @ptid < 0
            pbDisplay("You can't do this right now.")
          elsif switching
            pbDisplay("You can't do this while switching.")
          else
            #pbMemberMenuStart(@activecmd)
            #cmd = pbMemberMenu(@activecmd)
            cmd = 0
            if cmd == 1
              pbShowEntireParty(@activecmd)
            end
            #pbMemberMenuEnd(@activecmd)
            if cmd == 1 && @ptid >= 0
              @changecmd = @activecmd == 12 ? 0 : 6
            elsif cmd == 0
              pbPartyMemberChange(@activecmd)
            end
          end
        end
      end
    end
  end

  def pbToggleLeft(enabled, memchange=false)
    @sprites["member1"].enabled = enabled
    for i in 0...3
      @sprites["pokemon#{i}"].enabled = enabled
    end
    while @sprites["pokemon0"].animating
      if memchange
        @sprites["memchange"].y += 16
        if @sprites["summary"].y > Graphics.height - @sprites["summary"].bitmap.height
          @sprites["summary"].y -= 24
        end
      end
      pbUpdateSpriteHash(@sprites)
      Graphics.update
      Input.update
    end
  end

  def pbToggleRight(enabled, memchange=false)
    @sprites["member2"].enabled = enabled
    for i in 6...9
      @sprites["pokemon#{i}"].enabled = enabled
    end
    while @sprites["pokemon6"].animating
      if memchange
        @sprites["memchange"].y += 16
        if @sprites["summary"].y > Graphics.height - @sprites["summary"].bitmap.height
          @sprites["summary"].y -= 24
        end
      end
      pbUpdateSpriteHash(@sprites)
      Graphics.update
      Input.update
    end
  end

  def pbToggleAll(enabled, memchange=false)
    @sprites["member1"].enabled = enabled
    @sprites["member2"].enabled = enabled
    for i in 0...3
      @sprites["pokemon#{i}"].enabled = enabled
    end
    for i in 6...9
      @sprites["pokemon#{i}"].enabled = enabled
    end
    while @sprites["pokemon0"].animating || @sprites["pokemon6"].animating
      if memchange
        @sprites["memchange"].y += 16
        if @sprites["summary"].y > Graphics.height - @sprites["summary"].bitmap.height
          @sprites["summary"].y -= 24
        end
      end
      pbUpdateSpriteHash(@sprites)
      Graphics.update
      Input.update
    end
  end

  def pbPartyMemberChange(activecmd)
    left = (activecmd == 12)
    otherid = left ? @tid : @ptid
    partnerid = left ? @ptid : @tid
    @sprites["memchange"]=PartyMemberChangeSprite.new(otherid,!left,@viewport)

    @sprites["selected"].visible=false
    @sprites["selected"].update

    @sprites["memchange"].cursor_visible=false
    @sprites["memchange"].y = Graphics.height
    @sprites["summary"].y = Graphics.height - @sprites["summary"].bitmap.height
    14.times do
      @sprites["memchange"].y -= 16
      @sprites["summary"].y += 24
      pbUpdateSpriteHash(@sprites)
      Graphics.update
      Input.update
    end
    @sprites["memchange"].cursor_visible=true

    choice = -1
    loop do
      if Input.repeat?(Input::RIGHT)
        @sprites["memchange"].right
      end
      if Input.repeat?(Input::LEFT)
        @sprites["memchange"].left
      end
      if Input.trigger?(Input::USE)
        choice = @sprites["memchange"].selected
        member = @sprites["memchange"].member
        if left && PBParty.secondOnly(member)
          pbDisplay(_INTL("{1} cannot be set as a leader, only as a follower.",
            PBParty.getName(member)))
          choice = -1
        elsif member == partnerid && PBParty.secondOnly(otherid)
          pbDisplay(_INTL("This would place {1} in the leader position.\n{1} cannot be set as a leader, only as a follower.",
            PBParty.getName(otherid)))
          choice = -1
        else
          break
        end
      elsif Input.trigger?(Input::BACK)
        break
      end
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
    end
    @sprites["memchange"].cursor_visible=false

    member = @sprites["memchange"].member

    if choice >= 0 && member != otherid
      setPartyActive(member,left ? 0 : 1)
      @tid=getPartyActive(0)
      @ptid=getPartyActive(1)
      @party=getPartyPokemon(@tid)
      @pparty=getPartyPokemon(@ptid)
      pbSelect(left ? 0 : 6)
      if member == partnerid
        pbToggleAll(false, true)
      elsif left
        pbToggleLeft(false, true)
      else
        pbToggleRight(false, true)
      end
      pbHardRefresh(member == partnerid ? 3 : (left ? 1 : 2))
    else
      14.times do
        @sprites["memchange"].y += 16
        @sprites["summary"].y -= 24
        pbUpdateSpriteHash(@sprites)
        Graphics.update
        Input.update
      end
    end

    pbToggleAll(true, true)
    @sprites["memchange"].dispose
    @sprites.delete("memchange")
    @sprites["selected"].visible=true
    @sprites["selected"].update
  end

  def pbShowEntireParty(activecmd)
    left = activecmd == 12
    @fullparty = left ? 0 : 1
    if left
      @sprites["member2"].enabled = false
      for i in 6...9
        @sprites["pokemon#{i}"].enabled = false
      end
      while @sprites["member2"].animating
        for i in 3...9
          @sprites["pokemon#{i}"].update
        end
        @sprites["member2"].update
        Graphics.update
        Input.update
      end
      for i in 3...6
        @sprites["pokemon#{i}"].enabled = true
      end
      while @sprites["pokemon3"].animating
        for i in 3...9
          @sprites["pokemon#{i}"].update
        end
        @sprites["member2"].update
        Graphics.update
        Input.update
      end
    else
      @sprites["member1"].enabled = false
      for i in 0...3
        @sprites["pokemon#{i}"].enabled = false
      end
      while @sprites["member1"].animating
        for i in 0...3
          @sprites["pokemon#{i}"].update
        end
        @sprites["member1"].update
        Graphics.update
        Input.update
      end
      for i in 9...12
        @sprites["pokemon#{i}"].enabled = true
      end
      while @sprites["pokemon9"].animating
        for i in 0...3
          @sprites["pokemon#{i}"].update
        end
        for i in 9...12
          @sprites["pokemon#{i}"].update
        end
        @sprites["member1"].update
        Graphics.update
        Input.update
      end
    end
  end

  def pbHideEntireParty
    left = @fullparty == 0
    if left
      for i in 3...6
        @sprites["pokemon#{i}"].enabled = false
      end
      for i in 6...9
        @sprites["pokemon#{i}"].enabled = true
      end
      while @sprites["pokemon3"].animating
        for i in 3...9
          @sprites["pokemon#{i}"].update
        end
        @sprites["member2"].update
        Graphics.update
        Input.update
      end
      @sprites["member2"].enabled = true
      while @sprites["member2"].animating
        for i in 3...9
          @sprites["pokemon#{i}"].update
        end
        @sprites["member2"].update
        Graphics.update
        Input.update
      end
    else
      for i in 9...12
        @sprites["pokemon#{i}"].enabled = false
      end
      for i in 0...3
        @sprites["pokemon#{i}"].enabled = true
      end
      while @sprites["pokemon9"].animating
        for i in 0...3
          @sprites["pokemon#{i}"].update
        end
        for i in 9...12
          @sprites["pokemon#{i}"].update
        end
        @sprites["member1"].update
        Graphics.update
        Input.update
      end
      @sprites["member1"].enabled = true
      while @sprites["member1"].animating
        for i in 0...3
          @sprites["pokemon#{i}"].update
        end
        for i in 9...12
          @sprites["pokemon#{i}"].update
        end
        @sprites["member1"].update
        Graphics.update
        Input.update
      end
    end
  end

  def pbSelect(item)
    if @activecmd != item
      if item < 6
        @sprites["summary"].pokemon = @party[item]
      elsif item < 12
        @sprites["summary"].pokemon = @pparty[item - 6]
      end
    end
    @activecmd=item
    numsprites=6
    for i in 0...numsprites
      @sprites["pokemon#{i}"].selected=(i==@activecmd)
    end
    @sprites["selected"].setIndex(@activecmd)
    #@sprites["selected"].y = 52 + (48 * @activecmd)
    #@sprites["selected"].y = 400 if @activecmd >= 6
  end

  def pbDisplay(text)
    @sprites["messagebox"].text=text
    @sprites["messagebox"].visible=true
    @sprites["helpwindow"].visible=false
    pbPlayDecisionSE()
    loop do
      Graphics.update
      Input.update
      self.update
      if @sprites["messagebox"].busy? && Input.trigger?(Input::USE)
        pbPlayDecisionSE() if @sprites["messagebox"].pausing?
        @sprites["messagebox"].resume
      end
      if !@sprites["messagebox"].busy? &&
         (Input.trigger?(Input::USE) || Input.trigger?(Input::BACK))
        break
      end
    end
    @sprites["messagebox"].visible=false
    #@sprites["helpwindow"].visible=true
  end

  def pbSwitchBegin(oldid,newid)
    oldsprite=@sprites["pokemon#{oldid}"]
    newsprite=@sprites["pokemon#{newid}"]
    selsprite=@sprites["selected"]
    ydif = oldsprite.y - newsprite.y
    extra = 0
    extra = 4 if oldid < 3 && newid >= 3
    extra = 8 if oldid >= 3 && newid < 3
    extra = 8 if oldid < 9 && newid >= 9
    extra = 4 if oldid >= 9 && newid < 9
    16.times do
      oldsprite.y -= (ydif / 16).floor
      newsprite.y += (ydif / 16).floor
      #oldsprite.x-=44
      #newsprite.x-=44
      #selsprite.x-=44
      Graphics.update
      Input.update
      self.update
    end
    oldsprite.y -= extra
    newsprite.y += extra
    Graphics.update
    Input.update
    self.update
  end

  def pbSwitchEnd(oldid,newid)
    oldsprite=@sprites["pokemon#{oldid}"]
    newsprite=@sprites["pokemon#{newid}"]
    selsprite=@sprites["selected"]
    if oldid > 5 && newid > 5
      oldsprite.pokemon=@pparty[oldid % 6]
      newsprite.pokemon=@pparty[newid % 6]
    else
      oldsprite.pokemon=@party[oldid]
      newsprite.pokemon=@party[newid]
    end
    oldy = oldsprite.y
    oldsprite.y = newsprite.y
    newsprite.y = oldy
    #12.times do
    #oldsprite.x+=44
    #  newsprite.x+=44
    #  selsprite.x+=44
    #  Graphics.update
    #  Input.update
    #  self.update
    #end
    for i in 0...12
      @sprites["pokemon#{i}"].preselected=false
      @sprites["pokemon#{i}"].switching=false
    end
    pbRefresh
  end

  def pbDisplayConfirm(text)
    ret=-1
    @sprites["messagebox"].text=text
    @sprites["messagebox"].visible=true
    @sprites["helpwindow"].visible=false
    using(cmdwindow=Window_CommandPokemon.new([_INTL("Yes"),_INTL("No")])){
       cmdwindow.z=@viewport.z+1
       cmdwindow.visible=false
       pbBottomRight(cmdwindow)
       cmdwindow.y-=@sprites["messagebox"].height
       loop do
         Graphics.update
         Input.update
         cmdwindow.visible=true if !@sprites["messagebox"].busy?
         cmdwindow.update
         self.update
         if Input.trigger?(Input::BACK) && !@sprites["messagebox"].busy?
           ret=false
           break
         end
         if Input.trigger?(Input::USE) && @sprites["messagebox"].resume && !@sprites["messagebox"].busy?
           ret=(cmdwindow.index==0)
           break
         end
       end
    }
    @sprites["messagebox"].visible=false
    #@sprites["helpwindow"].visible=true
    return ret
  end

  def pbAnnotate(annot)
    for i in 0...12
      if annot && @party[i]
        @sprites["pokemon#{i}"].setTeamPos(annot[i] - 3)
      end
    end
  end

  def pbSummary(pkmnid,both=true,inbattle=false)
    oldsprites=pbFadeOutAndHide(@sprites)
    scene=PokemonSummaryScene.new(inbattle)
    screen=PokemonSummary.new(scene)
    party = []
    both = false if @fullparty >= 0
    if both && @ptid >= 0 && @pparty.is_a?(Array)
      for i in 0...3
        party.push(@party[i]) if @party[i]
      end
      for i in 0...3
        party.push(@pparty[i]) if @pparty[i]
      end
      pkmnid = pkmnid < 6 ? pkmnid : ((pkmnid % 6) + [@party.length,3].min)
    else
      party = pkmnid < 6 ? @party : @pparty
      pkmnid = pkmnid % 6
    end
    screen.pbStartScreen(party,pkmnid)
    @sprites["summary"].pokemon = nil
    if pkmnid < 6
      @sprites["summary"].pokemon = @party[pkmnid]
    elsif pkmnid < 12
      @sprites["summary"].pokemon = @pparty[pkmnid-6]
    end
    pbFadeInAndShow(@sprites,oldsprites)
  end

  def pbChooseItem(bag)
    ret = nil
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,bag)
      ret = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).can_hold? })
      yield if block_given?
    }
    return ret
  end

  def pbUseItem(bag,pokemon)
    ret = nil
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,bag)
      ret = screen.pbChooseItemScreen(Proc.new { |item|
        itm = GameData::Item.get(item)
        next false if !pbCanUseOnPokemon?(itm)
        if itm.is_machine?
          move = itm.move
          next false if pokemon.hasMove?(move) || !pokemon.compatible_with_move?(move)
        end
        next true
      })
      yield if block_given?
    }
    return ret
  end

  def pbMessageFreeText(text,startMsg,maxlength)
    return Kernel.pbMessageFreeText(
       _INTL("Please enter a message (max. {1} characters).",maxlength),
       _INTL("{1}",startMsg),false,maxlength,Graphics.width) { update }
  end

  def pbLevelUp(pkmn)
    @sprites["levelup"].pokemon = pkmn

    5.times do
      @sprites["levelup"].spriteY -= 6
      pbUpdateSpriteHash(@sprites)
      Graphics.update
      Input.update
    end

    @sprites["levelup"].refresh(true)

    loop do
      if Input.trigger?(Input::BACK)
        break
      elsif Input.trigger?(Input::USE)
        if @sprites["levelup"].new_level > pkmn.level
          cost = @sprites["levelup"].cost
          skip_pay = ($DEBUG && Input.press?(Input::CTRL))
          if cost > $player.money && !skip_pay
            pbDisplay(sprintf("You do not have $%d (You have $%d).", cost, $player.money))
          elsif pbDisplayConfirm(sprintf("Use $%d to level up %s from Lv.%3d to Lv.%3d?\nYou have $%d.",
                cost, pkmn.name, pkmn.level, @sprites["levelup"].new_level, $player.money))
              $player.money -= cost if !skip_pay
              pbSEPlay("Pkmn exp full")
              pbChangeLevel(pkmn, @sprites["levelup"].new_level, self, false)
              @sprites["summary"].pokemon = nil
              @sprites["summary"].pokemon = pkmn
            break
          else
            break
          end
        end
      elsif Input.repeat?(Input::UP)
        if @sprites["levelup"].new_level < @sprites["levelup"].max_level
          @sprites["levelup"].new_level += 1
          @sprites["levelup"].refresh(true)
        end
      elsif Input.repeat?(Input::DOWN)
        if @sprites["levelup"].new_level > pkmn.level
          @sprites["levelup"].new_level -= 1
          @sprites["levelup"].refresh(true)
        end
      end
      pbUpdateSpriteHash(@sprites)
      Graphics.update
      Input.update
    end

    @sprites["levelup"].refresh(false)

    5.times do
      @sprites["levelup"].spriteY += 6
      pbUpdateSpriteHash(@sprites)
      Graphics.update
      Input.update
    end
  end

  def refresh_summary
    @sprites["summary"].refresh
  end
end


######################################


class PokemonScreen
  def initialize(scene,party=nil,pparty=nil)
    @party=party
    @pparty=pparty
    @scene=scene
    @scene.party=@party if @party
    @scene.pparty=@pparty if @pparty
  end

  def scene
    return @scene
  end

  def pbHardRefresh
    @scene.pbHardRefresh
  end

  def pbRefresh
    @scene.pbRefresh
  end

  def pbRefreshSingle(i)
    @scene.pbRefreshSingle(i)
  end

  def pbUpdate
    @scene.pbUpdate
  end

  def pbDisplay(text)
    @scene.pbDisplay(text)
  end

  def pbConfirm(text)
    return @scene.pbDisplayConfirm(text)
  end

  def pbSwitch(oldid,newid)
    if oldid!=newid
      if oldid > 5 && newid > 5
        @scene.pbSwitchBegin(oldid,newid)
        tmp=@pparty[oldid % 6]
        @pparty[oldid % 6]=@pparty[newid % 6]
        @pparty[newid % 6]=tmp
        @scene.pbSwitchEnd(oldid,newid)
      elsif oldid <= 5 && newid <= 5
        @scene.pbSwitchBegin(oldid,newid)
        tmp=@party[oldid]
        @party[oldid]=@party[newid]
        @party[newid]=tmp
        @scene.pbSwitchEnd(oldid,newid)
      else
        pbDisplay("You can't swap Pokemon between characters.")
        return
      end
    end
  end

  def pbMailScreen(item,pkmn,pkmnid)
    message=""
    loop do
      message=@scene.pbMessageFreeText(
         _INTL("Please enter a message (max. 256 characters)."),"",256)
      if message!=""
        # Store mail if a message was written
        poke1=poke2=poke3=nil
        if $player.party[pkmnid+2]
          p=$player.party[pkmnid+2]
          poke1=[p.species,p.gender,p.isShiny?,(p.form rescue 0),(p.shadowPokemon? rescue false)]
          poke1.push(true) if p.egg?
        end
        if $player.party[pkmnid+1]
          p=$player.party[pkmnid+1]
          poke2=[p.species,p.gender,p.isShiny?,(p.form rescue 0),(p.shadowPokemon? rescue false)]
          poke2.push(true) if p.egg?
        end
        poke3=[pkmn.species,pkmn.gender,pkmn.isShiny?,(pkmn.form rescue 0),(pkmn.shadowPokemon? rescue false)]
        poke3.push(true) if pkmn.egg?
        pbStoreMail(pkmn,item,message,poke1,poke2,poke3)
        return true
      else
        return false if pbConfirm(_INTL("Stop giving the Pokémon Mail?"))
      end
    end
  end

  def pbTakeMail(pkmn)
    if !pkmn.hasItem?
      pbDisplay(_INTL("{1} isn't holding anything.",pkmn.name))
    elsif !$bag.can_add?(pkmn.item)
      pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
    elsif pkmn.mail
      if pbConfirm(_INTL("Send the removed mail to your PC?"))
        if !pbMoveToMailbox(pkmn)
          pbDisplay(_INTL("Your PC's Mailbox is full."))
        else
          pbDisplay(_INTL("The mail was sent to your PC."))
          pkmn.item = nil
        end
      elsif pbConfirm(_INTL("If the mail is removed, the message will be lost. OK?"))
        pbDisplay(_INTL("Mail was taken from the Pokémon."))
        $bag.add(pkmn.item)
        pkmn.item = nil
        pkmn.mail=nil
      end
    else
      $bag.add(pkmn.item)
      itemname=GameData::Item.get(pkmn.item).name
      pbDisplay(_INTL("Received the {1} from {2}.",itemname,pkmn.name))
      pkmn.item = nil
      pbRKSMemoryCheck(pkmn)
    end
  end

  def pbGiveMail(item,pkmn,pkmnid=0)
    thisitemname=PBItems.getName(item)
    if pkmn.egg?
      pbDisplay(_INTL("Eggs can't hold items."))
      return false
    elsif pkmn.mail
      pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.",pkmn.name))
      return false
    end
    if pkmn.item!=0
      itemname=PBItems.getName(pkmn.item)
      pbDisplay(_INTL("{1} is already holding {2}.\1",pkmn.name,itemname))
      if pbConfirm(_INTL("Would you like to switch the two items?"))
        $bag.pbDeleteItem(item)
        if !$bag.add(pkmn.item)
          if !$bag.add(item) # Compensate
            raise _INTL("Can't re-store deleted item in bag")
          end
          pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
        else
          if GameData::Item.get(item).is_mail?
            if pbMailScreen(item,pkmn,pkmnid)
              pkmn.item = item
              pbRKSMemoryCheck(pkmn)
              pbDisplay(_INTL("The {1} was taken and replaced with the {2}.",itemname,thisitemname))
              return true
            else
              if !$bag.add(item) # Compensate
                raise _INTL("Can't re-store deleted item in bag")
              end
            end
          else
            pkmn.item = item
            pbRKSMemoryCheck(pkmn)
            pbDisplay(_INTL("Took the Pokémon's {1} and gave it the {2}.",itemname,thisitemname))
            return true
          end
        end
      end
    else
      if !GameData::Item.get(item).is_mail? || pbMailScreen(item,pkmn,pkmnid) # Open the mail screen if necessary
        $bag.pbDeleteItem(item)
        pkmn.item = item
        pbRKSMemoryCheck(pkmn)
        pbDisplay(_INTL("The Pokémon is now holding the {1}.",thisitemname))
        return true
      end
    end
    return false
  end

  def pbRKSMemoryCheck(pkmn)
    if pkmn.item != :RKSMEMORY && pkmn.species==:SILVALLY
      pkmn.form=0
    end
    if pkmn.item == :CORRUPTEDMEMORY && pkmn.species==:SILVALLY
      pkmn.form=PBTypes::QMARKS
      pbDisplay(_INTL("{1} was loaded with corrupted data!",pkmn.name))
    end
    if pkmn.item == :RKSMEMORY && pkmn.species==:SILVALLY
          pbDisplay(_INTL("Select a type of memory to load."))
          itemcommands = []
          cmdFire      = -1
          cmdWater     = -1
          cmdGrass     = -1
          cmdElectric  = -1
          cmdFairy     = -1
          cmdGhost     = -1
          cmdDark      = -1
          cmdPsychic   = -1
          cmdSteel     = -1
          cmdIce       = -1
          cmdBug       = -1
          cmdDragon    = -1
          cmdGround    = -1
          cmdRock      = -1
          cmdFlying    = -1
          cmdFighting  = -1
          cmdPoison    = -1
          # Build the commands
          itemcommands[cmdFire=itemcommands.length]  = _INTL("Fire")
          itemcommands[cmdWater=itemcommands.length] = _INTL("Water")
          itemcommands[cmdGrass=itemcommands.length] = _INTL("Grass")
          itemcommands[cmdElectric=itemcommands.length] = _INTL("Electric")
          itemcommands[cmdFairy=itemcommands.length] = _INTL("Fairy")
          itemcommands[cmdGhost=itemcommands.length] = _INTL("Ghost")
          itemcommands[cmdDark=itemcommands.length] = _INTL("Dark")
          itemcommands[cmdPsychic=itemcommands.length] = _INTL("Psychic")
          itemcommands[cmdSteel=itemcommands.length] = _INTL("Steel")
          itemcommands[cmdIce=itemcommands.length] = _INTL("Ice")
          itemcommands[cmdBug=itemcommands.length] = _INTL("Bug")
          itemcommands[cmdDragon=itemcommands.length] = _INTL("Dragon")
          itemcommands[cmdGround=itemcommands.length] = _INTL("Ground")
          itemcommands[cmdRock=itemcommands.length] = _INTL("Rock")
          itemcommands[cmdFlying=itemcommands.length] = _INTL("Flying")
          itemcommands[cmdFighting=itemcommands.length] = _INTL("Fighting")
          itemcommands[cmdPoison=itemcommands.length] = _INTL("Poison")
          command=@scene.pbShowCommands(_INTL("Do what with an item?"),itemcommands)
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::FIRE if cmdFire>=0 && command==cmdFire
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::WATER if cmdWater>=0 && command==cmdWater
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::GRASS if cmdGrass>=0 && command==cmdGrass
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::ELECTRIC if cmdElectric>=0 && command==cmdElectric
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::FAIRY if cmdFairy>=0 && command==cmdFairy
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::GHOST if cmdGhost>=0 && command==cmdGhost
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::DARK if cmdDark>=0 && command==cmdDark
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::PSYCHIC if cmdPsychic>=0 && command==cmdPsychic
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::STEEL if cmdSteel>=0 && command==cmdSteel
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::ICE if cmdIce>=0 && command==cmdIce
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::BUG if cmdBug>=0 && command==cmdBug
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::DRAGON if cmdDragon>=0 && command==cmdDragon
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::GROUND if cmdGround>=0 && command==cmdGround
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::ROCK if cmdRock>=0 && command==cmdRock
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::FLYING if cmdFlying>=0 && command==cmdFlying
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::FIGHTING if cmdFighting>=0 && command==cmdFighting
          $game_variables[RKS_MEMORY_TYPE]=PBTypes::POISON if cmdPoison>=0 && command==cmdPoison
          pkmn.form=$game_variables[RKS_MEMORY_TYPE]
          pbDisplay(_INTL("{1} loaded the data of the {2} type!",pkmn.name,PBTypes.getName($game_variables[RKS_MEMORY_TYPE])))
        end
  end

  def pbPokemonGiveScreen(item)
    @scene.pbStartScene(@party,_INTL("Give to which Pokémon?"))
    ret=false
    loop do
      pkmnid=@scene.pbChoosePokemon
      if pkmnid>=0 && @scene.party[pkmnid]
        ret=pbGiveMail(item,@scene.party[pkmnid],pkmnid)
      elsif pkmnid>=6 && @scene.pparty[pkmnid-6]
        ret=pbGiveMail(item,@scene.pparty[pkmnid-6],pkmnid)
      end
      if pkmnid>=12
        pbDisplay("You can't do that right now.")
        next
      end
      pbRefreshSingle(pkmnid)
      break
    end
    @scene.pbEndScene
    return ret
  end

  def pbPokemonGiveMailScreen(mailIndex)
    @scene.pbStartScene(@party,_INTL("Give to which Pokémon?"))
    pkmnid=@scene.pbChoosePokemon
    if pkmnid>=0
      pkmn=@party[pkmnid]
      if pkmn.item!=0 || pkmn.mail
        pbDisplay(_INTL("This Pokémon is holding an item. It can't hold mail."))
      elsif pkmn.egg?
        pbDisplay(_INTL("Eggs can't hold mail."))
      else
        pbDisplay(_INTL("Mail was transferred from the Mailbox."))
        pkmn.mail=$PokemonGlobal.mailbox[mailIndex]
        pkmn.item = pkmn.mail.item
        $PokemonGlobal.mailbox.delete_at(mailIndex)
        pbRefreshSingle(pkmnid)
      end
    end
    @scene.pbEndScene
  end

  def pbStartScene(helptext,doublebattle,annotations=nil)
    @scene.pbStartScene(@party,helptext,annotations)
  end

  def pbChoosePokemon(helptext=nil,initialselect=-1,inbattle=false)
    @scene.pbSetHelpText(helptext) if helptext
    return @scene.pbChoosePokemon(false,initialselect,inbattle)
  end

  def pbChooseMove(pokemon,helptext)
    movenames=[]
    for i in pokemon.moves
      break if i.id==0
      if i.totalpp==0
        movenames.push(_INTL("{1} (PP: ---)",i.name,i.pp,i.totalpp))
      else
        movenames.push(_INTL("{1} (PP: {2}/{3})",i.name,i.pp,i.totalpp))
      end
    end
    return @scene.pbShowCommands(helptext,movenames)
  end

  def pbEndScene
    @scene.pbEndScene
  end

  # Checks for identical species
  def pbCheckSpecies(array)
    for i in 0...array.length
      for j in i+1...array.length
        return false if array[i].species==array[j].species
      end
    end
    return true
  end

# Checks for identical held items
  def pbCheckItems(array)
    for i in 0...array.length
      next if !array[i].hasItem?
      for j in i+1...array.length
        return false if array[i].item==array[j].item
      end
    end
    return true
  end

  def pbPokemonMultipleEntryScreenEx(ruleset)
    annot=[]
    statuses=[]
    ordinals=[
       _INTL("INELIGIBLE"),
       _INTL("NOT ENTERED"),
       _INTL("BANNED"),
       _INTL("FIRST"),
       _INTL("SECOND"),
       _INTL("THIRD"),
       _INTL("FOURTH"),
       _INTL("FIFTH"),
       _INTL("SIXTH")
    ]
    if !ruleset.hasValidTeam?(@party)
      return nil
    end
    ret=nil
    addedEntry=false
    for i in 0...@party.length
      if ruleset.isPokemonValid?(@party[i])
        statuses[i]=1
      else
        statuses[i]=2
      end  
    end
    for i in 0...@party.length
      annot[i]=statuses[i]
    end
    @scene.pbStartScene(@party,_INTL("Choose Pokémon and confirm."),annot,true)
    loop do
      realorder=[]
      for i in 0...@party.length
        for j in 0...@party.length
          if statuses[j]==i+3
            realorder.push(j)
            break
          end
        end
      end
      for i in 0...realorder.length
        statuses[realorder[i]]=i+3
      end
      for i in 0...@party.length
        annot[i]=statuses[i]
      end
      @scene.pbAnnotate(annot)
      if realorder.length==ruleset.number && addedEntry
        @scene.pbSelect(6)
      end
      @scene.pbSetHelpText(_INTL("Choose Pokémon and confirm."))
      pkmnid=@scene.pbChoosePokemon
      addedEntry=false
      if pkmnid==6 # Confirm was chosen
        ret=[]
        for i in realorder
          ret.push(@party[i])
        end
        error=[]
        if !ruleset.isValid?(ret,error)
          pbDisplay(error[0])
          ret=nil
        else
          break
        end
      end
      if pkmnid<0 # Canceled
        break
      end
      cmdEntry=-1
      cmdNoEntry=-1
      cmdSummary=-1
      commands=[]
      if (statuses[pkmnid] || 0) == 1
        commands[cmdEntry=commands.length]=_INTL("Entry")
      elsif (statuses[pkmnid] || 0) > 2
        commands[cmdNoEntry=commands.length]=_INTL("No Entry")
      end
      pkmn=@party[pkmnid]
      commands[cmdSummary=commands.length]=_INTL("Summary")
      commands[commands.length]=_INTL("Cancel")
      command=@scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),commands) if pkmn
      if cmdEntry>=0 && command==cmdEntry
        if realorder.length>=ruleset.number && ruleset.number>0
          pbDisplay(_INTL("No more than {1} Pokémon may enter.",ruleset.number))
        else
          statuses[pkmnid]=realorder.length+3
          addedEntry=true
          pbRefreshSingle(pkmnid)
        end
      elsif cmdNoEntry>=0 && command==cmdNoEntry
        statuses[pkmnid]=1
        pbRefreshSingle(pkmnid)
      elsif cmdSummary>=0 && command==cmdSummary
        @scene.pbSummary(pkmnid)
      end
    end
    @scene.pbEndScene
    return ret
  end

  def pbChooseAblePokemon(ableProc,allowIneligible=false)
    annot=[]
    eligibility=[]
    for pkmn in @party
      elig=ableProc.call(pkmn)
      eligibility.push(elig)
      annot.push(elig ? _INTL("ABLE") : _INTL("NOT ABLE"))
    end
    ret=-1
    @scene.pbStartScene(@party,
       @party.length>1 ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),annot)
    loop do
      @scene.pbSetHelpText(
         @party.length>1 ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      pkmnid=@scene.pbChoosePokemon
      if pkmnid<0
        break
      elsif !eligibility[pkmnid] && !allowIneligible
        pbDisplay(_INTL("This Pokémon can't be chosen."))
      else
        ret=pkmnid
        break
      end
    end
    @scene.pbEndScene
    return ret
  end

  def pbRefreshAnnotations(ableProc)   # For after using an evolution stone
    annot=[]
    for pkmn in @party
      elig=ableProc.call(pkmn)
      annot.push(elig ? _INTL("ABLE") : _INTL("NOT ABLE"))
    end
    @scene.pbAnnotate(annot)
  end

  def pbClearAnnotations
    @scene.pbAnnotate(nil)
  end

  def pbPokemonScreen
    @party=getActivePokemon(0) if !@party
    @pparty=getActivePokemon(1) if !@pparty
    @tid=getPartyActive(0)
    @ptid=getPartyActive(1)
    @scene.pbStartScene(@party,@party.length>1 ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."),nil)
    loop do
      @scene.pbSetHelpText(@party.length>1 ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      pkmnid=@scene.pbChoosePokemon
      @party = @scene.party
      @pparty = @scene.pparty
      @tid = @scene.tid
      @ptid = @scene.ptid
      break if pkmnid<0
      if Input.press?(Input::CTRL) && $DEBUG
        if pkmnid<6
          @scene.pbPokemonDebug(@party[pkmnid], pkmnid)
        elsif pkmnid<12
          @scene.pbPokemonDebug(@pparty[pkmnid-6], pkmnid)
        end
        next
      end
      if @mode==1
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid=pkmnid
        pkmnid=@scene.pbChoosePokemon(true)
        Kernel.pbMessage(pkmnid.to_s)
        if pkmnid>=0 && pkmnid<=11 && pkmnid!=oldpkmnid
          pbSwitch(oldpkmnid,pkmnid)
        end
        next
      end
      if (pkmnid<=5 && @party[pkmnid]) || (pkmnid>5 && pkmnid<=11 && @pparty[pkmnid-6])
        pkmn = pkmnid<6 ? @party[pkmnid] : @pparty[pkmnid-6]
        movecmds = []
        for i in 0...pkmn.moves.length
          move=pkmn.moves[i]
          # Check for hidden moves and add any that were found
          if !pkmn.egg? && (move.id == :MILKDRINK || 
                            move.id == :SOFTBOILED ||
                            HiddenMoveHandlers.hasHandler(move.id))
            movecmds.push(move.id)
          end
        end
        cmds = ["Summary", "Item", "Switch"]
        cmds.push("Level Up") if $game_variables[BADGE_COUNT] > 0
        switch=false
        @scene.pbPokemonMenuStart(pkmnid, cmds)
        loop do
          cmd = @scene.pbPokemonMenu(pkmnid, cmds)
          if cmd < 0
            break
          elsif cmds[cmd]=="Summary"
            @scene.pbSummary(pkmnid)
          elsif cmds[cmd]=="Restore"

          elsif cmds[cmd]=="Switch"
            switch=true
            break
          elsif cmds[cmd]=="Item"
            if pkmn.hp >= pkmn.totalhp &&
              pkmn.status == 0
              pbMessage(_INTL("{1} is already fully healed.", pkmn.name))
            else
              quick = []
              if pkmn.hp<=0
                revive = pbGetSuggestedRevive(pkmn)
                quick[0]=revive if revive
              end
              if pkmn.hp>0 && pkmn.hp<pkmn.totalhp
                potion = pbGetSuggestedPotion(pkmn)
                quick[0]=potion if potion
              end
              if pkmn.status != 0
                medicine = pbGetSuggestedMedicine(pkmn)
                quick[1]=medicine if medicine
              end
            end
            itemcommands = []
            cmdUseItem      = -1
            cmdGiveItem     = -1
            cmdTakeItem     = -1
            cmdMoveItem     = -1
            cmdHealItem     = -1
            cmdMedicineItem = -1
            # Build the commands
            itemcommands[cmdUseItem=itemcommands.length]      = _INTL("Use")
            itemcommands[cmdGiveItem=itemcommands.length]     = _INTL("Give")
            itemcommands[cmdTakeItem=itemcommands.length]     = _INTL("Take") if pkmn.hasItem?
            itemcommands[cmdMoveItem=itemcommands.length]     = _INTL("Move") if pkmn.hasItem? && !GameData::Item.get(pkmn.item).is_mail?
            itemcommands[cmdHealItem=itemcommands.length]     = _INTL(GameData::Item.get(quick[0]).name) if quick[0]
            itemcommands[cmdMedicineItem=itemcommands.length] = _INTL(GameData::Item.get(quick[1]).name) if quick[1]
            itemcommands[itemcommands.length]                 = _INTL("Cancel")
            command=@scene.pbShowCommands(_INTL("Do what with an item?"),itemcommands)
            if cmdUseItem>=0 && command==cmdUseItem   # Use
              item = @scene.pbUseItem($bag,pkmn) {
                @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
              }
              if item
                pbUseItemOnPokemon(item,pkmn,self)
                pbRefreshSingle(pkmnid)
              end
            elsif cmdGiveItem>=0 && command==cmdGiveItem   # Give
              item = @scene.pbChooseItem($bag) {
                @scene.pbSetHelpText((@party.length>1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
              }
              if item
                if pbGiveItemToPokemon(item,pkmn,self,pkmnid)
                  pbRefreshSingle(pkmnid)
                end
              end
            elsif cmdTakeItem>=0 && command==cmdTakeItem   # Take
              pbTakeMail(pkmn)
              pbRefreshSingle(pkmnid)
            elsif cmdMoveItem>=0 && command==cmdMoveItem   # Move
              @scene.pbPokemonMenuEnd(pkmnid, cmds)
              item=pkmn.item
              itemname=GameData::Item.get(item).name
              @scene.pbSetHelpText(_INTL("Give {1} to which Pokémon?",itemname))
              oldpkmnid=pkmnid
              loop do
                @scene.pbPreSelect(oldpkmnid)
                newpkmnid=@scene.pbChoosePokemon(true,pkmnid)
                break if newpkmnid<0
                newpkmn = (newpkmnid >= 6) ? @pparty[newpkmnid - 6] : @party[newpkmnid]
                if newpkmnid==oldpkmnid
                  break
                elsif newpkmn.egg?
                  pbDisplay(_INTL("Eggs can't hold items."))
                elsif !newpkmn.hasItem?
                  newpkmn.item = item
                  pkmn.item = nil
                  pbRefresh
                  pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
                  break
                elsif GameData::Item.get(item).is_mail?
                  pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.",newpkmn.name))
                else
                  newitem=newpkmn.item
                  newitemname=GameData::Item.get(newitem).name
                  pbDisplay(_INTL("{1} is already holding one {2}.\1",newpkmn.name,newitemname))
                  if pbConfirm(_INTL("Would you like to switch the two items?"))
                    newpkmn.item = item
                    pkmn.item = newitem
                    pbRefresh
                    pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
                    pbDisplay(_INTL("{1} was given the {2} to hold.",pkmn.name,newitemname))
                    break
                  end
                end
              end
              @scene.refresh_summary
              break
            elsif cmdHealItem>=0 && command==cmdHealItem   # Quick Potion/Revive
              if $bag.quantity(quick[0])>0
                pbUseItemOnPokemon(quick[0],pkmn,self)
              end
            elsif cmdMedicineItem>=0 && command==cmdMedicineItem   # Quick Medicine
              if $bag.quantity(quick[1])>0
                pbUseItemOnPokemon(quick[1],pkmn,self)
              end
            end
            @scene.refresh_summary
          elsif cmds[cmd]=="Level Up"
            @scene.pbPokemonMenuEnd(pkmnid, cmds)
            @scene.pbLevelUp(pkmn)
            break
          end
        end
        @scene.pbPokemonMenuEnd(pkmnid, cmds)
        if switch
          @scene.pbSetHelpText(_INTL("Move to where?"))
          oldpkmnid=pkmnid
          pkmnid=@scene.pbChoosePokemon(true)
          if pkmnid>=0 && pkmnid<=11 && pkmnid!=oldpkmnid
            pbSwitch(oldpkmnid,pkmnid)
          end
        end
        next
      end
      pkmn=pkmnid >= 6 ? @pparty[pkmnid-6] : @party[pkmnid]
      commands   = []
      cmdSummary = -1
      cmdDebug   = -1
      cmdMoves   = [-1,-1,-1,-1]
      cmdSwitch  = -1
      cmdMail    = -1
      cmdItem    = -1
      # Build the commands
      commands[cmdSummary=commands.length]      = _INTL("Summary")
      commands[cmdDebug=commands.length]        = _INTL("Debug") if $DEBUG
      for i in 0...pkmn.moves.length
        move=pkmn.moves[i]
        # Check for hidden moves and add any that were found
        if !pkmn.egg? && (isConst?(move.id,PBMoves,:MILKDRINK) ||
                            isConst?(move.id,PBMoves,:SOFTBOILED) ||
                            HiddenMoveHandlers.hasHandler(move.id))
          commands[cmdMoves[i]=commands.length] = PBMoves.getName(move.id)
        end
      end
      commands[cmdSwitch=commands.length]       = _INTL("Switch") if @party.length>1
      if !pkmn.egg?
        if pkmn.mail
          commands[cmdMail=commands.length]     = _INTL("Mail")
        else
          commands[cmdItem=commands.length]     = _INTL("Item")
        end
      end
      commands[commands.length]                 = _INTL("Cancel")
      command=@scene.pbShowCommands(_INTL("Do what with {1}?",pkmn.name),commands)
      havecommand=false
      for i in 0...4
        if cmdMoves[i]>=0 && command==cmdMoves[i]
          havecommand=true
          if isConst?(pkmn.moves[i].id,PBMoves,:SOFTBOILED) ||
             isConst?(pkmn.moves[i].id,PBMoves,:MILKDRINK)
            amt=[(pkmn.totalhp/5).floor,1].max
            if pkmn.hp<=amt
              pbDisplay(_INTL("Not enough HP..."))
              break
            end
            @scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
            oldpkmnid=pkmnid
            loop do
              @scene.pbPreSelect(oldpkmnid)
              pkmnid=@scene.pbChoosePokemon(true,pkmnid)
              break if pkmnid<0
              newpkmn=@party[pkmnid]
              if pkmnid==oldpkmnid
                pbDisplay(_INTL("{1} can't use {2} on itself!",pkmn.name,PBMoves.getName(pkmn.moves[i].id)))
              elsif newpkmn.egg?
                pbDisplay(_INTL("{1} can't be used on an Egg!",PBMoves.getName(pkmn.moves[i].id)))
              elsif newpkmn.hp==0 || newpkmn.hp==newpkmn.totalhp
                pbDisplay(_INTL("{1} can't be used on that Pokémon.",PBMoves.getName(pkmn.moves[i].id)))
              else
                pkmn.hp-=amt
                hpgain=pbItemRestoreHP(newpkmn,amt)
                @scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",newpkmn.name,hpgain))
                pbRefresh
              end
              break if pkmn.hp<=amt
            end
            break
          elsif Kernel.pbCanUseHiddenMove?(pkmn,pkmn.moves[i].id)
            @scene.pbEndScene
            if isConst?(pkmn.moves[i].id,PBMoves,:FLY)
              scene=PokemonRegionMapScene.new(-1,false)
              screen=PokemonRegionMap.new(scene)
              ret=screen.pbStartFlyScreen
              if ret
                $PokemonTemp.flydata=ret
                return [pkmn,pkmn.moves[i].id]
              end
              @scene.pbStartScene(@party,
                 @party.length>1 ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
              break
            end
            return [pkmn,pkmn.moves[i].id]
          else
            break
          end
        end
      end
      next if havecommand
      if cmdSummary>=0 && command==cmdSummary
        @scene.pbSummary(pkmnid)
      elsif cmdDebug>=0 && command==cmdDebug
        pbPokemonDebug(pkmn,pkmnid)
      elsif cmdSwitch>=0 && command==cmdSwitch
        @scene.pbSetHelpText(_INTL("Move to where?"))
        oldpkmnid=pkmnid
        pkmnid=@scene.pbChoosePokemon(true)
        if pkmnid>=0 && pkmnid!=oldpkmnid
          pbSwitch(oldpkmnid,pkmnid)
        end
      elsif cmdMail>=0 && command==cmdMail
        command=@scene.pbShowCommands(_INTL("Do what with the mail?"),
           [_INTL("Read"),_INTL("Take"),_INTL("Cancel")])
        case command
        when 0 # Read
          pbFadeOutIn(99999){
             pbDisplayMail(pkmn.mail,pkmn)
          }
        when 1 # Take
          pbTakeMail(pkmn)
          pbRefreshSingle(pkmnid)
        end
      elsif cmdItem>=0 && command==cmdItem
        itemcommands = []
        cmdUseItem   = -1
        cmdGiveItem  = -1
        cmdTakeItem  = -1
        cmdMoveItem  = -1
        # Build the commands
        itemcommands[cmdUseItem=itemcommands.length]  = _INTL("Use")
        itemcommands[cmdGiveItem=itemcommands.length] = _INTL("Give")
        itemcommands[cmdTakeItem=itemcommands.length] = _INTL("Take") if pkmn.hasItem?
        itemcommands[cmdMoveItem=itemcommands.length] = _INTL("Move") if pkmn.hasItem? && !GameData::Item.get(pkmn.item).is_mail?
        itemcommands[itemcommands.length]             = _INTL("Cancel")
        command=@scene.pbShowCommands(_INTL("Do what with an item?"),itemcommands)
        if cmdUseItem>=0 && command==cmdUseItem   # Use
          item=@scene.pbUseItem($bag,pkmn)
          if item>0
            pbUseItemOnPokemon(item,pkmn,self)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdGiveItem>=0 && command==cmdGiveItem   # Give
          item=@scene.pbChooseItem($bag)
          if item>0
            pbGiveMail(item,pkmn,pkmnid)
            pbRefreshSingle(pkmnid)
          end
        elsif cmdTakeItem>=0 && command==cmdTakeItem   # Take
          pbTakeMail(pkmn)
          pbRefreshSingle(pkmnid)
        elsif cmdMoveItem>=0 && command==cmdMoveItem   # Move
          item=pkmn.item
          itemname=GameData::Item.get(item).name
          @scene.pbSetHelpText(_INTL("Give {1} to which Pokémon?",itemname))
          oldpkmnid=pkmnid
          loop do
            @scene.pbPreSelect(oldpkmnid)
            pkmnid=@scene.pbChoosePokemon(true,pkmnid)
            break if pkmnid<0
            newpkmn=@party[pkmnid]
            if pkmnid==oldpkmnid
              break
            elsif newpkmn.egg?
              pbDisplay(_INTL("Eggs can't hold items."))
            elsif !newpkmn.hasItem?
              newpkmn.item = item
              pkmn.item = nil
              pbRefresh
              pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
              break
            elsif GameData::Item.get(newpkmn.item).is_mail?
              pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.",newpkmn.name))
            else
              newitem=newpkmn.item
              newitemname=GameData::Item.get(newitem).name
              pbDisplay(_INTL("{1} is already holding one {2}.\1",newpkmn.name,newitemname))
              if pbConfirm(_INTL("Would you like to switch the two items?"))
                newpkmn.item = item
                pkmn.item = newitem
                pbRefresh
                pbDisplay(_INTL("{1} was given the {2} to hold.",newpkmn.name,itemname))
                pbDisplay(_INTL("{1} was given the {2} to hold.",pkmn.name,newitemname))
                break
              end
            end
          end
        end
        @scene.refresh_summary
      end
    end
    @scene.pbEndScene
    return nil
  end  
end