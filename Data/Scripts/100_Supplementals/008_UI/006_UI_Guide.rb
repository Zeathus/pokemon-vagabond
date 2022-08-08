GUIDES = [
  ["The Guide",
    "This is the Guide. It can show you all kinds of useful tips and explanations to help you on your adventure through the game.\nThe total number of pages can be seen on the bottom right.",
    "The guide is especially useful when learning the mechanics that are new to this game. More guides will be unlocked as you play through the game and you will be notified whenever you obtain a new guide."],
  ["Moves",
    ""],
  ["Types",
    "Each type has resistances, weaknesses and immunities. A full type chart can be seen on the next page.",
    "[type_chart]"],
  ["Stats",
    ""],
  ["Weather",
    ""],
  ["Quests",
    ""]
]

class KeybindSprite < SpriteWrapper

  attr_accessor :baseColor
  attr_accessor :shadowColor

  def initialize(input, name, x, y, viewport)
    super(viewport)
    @input = input
    @name  = name
    @baseColor = Color.new(252,252,252)
    @shadowColor = Color.new(0,0,0)
    self.bitmap = Bitmap.new(224, 28)
    self.x = x
    self.y = y
    @keybind_icons = AnimatedBitmap.new("Graphics/Pictures/keybinds")
    self.refresh
  end

  def name=(value)
    if @name != value
      @name = value
      self.refresh
    end
  end

  def refresh
    self.bitmap.clear
    if @input.is_a?(Array)
      x = 0
      for i in @input
        self.bitmap.blt(x, 0, @keybind_icons.bitmap, $Keybinds.rect(i))
        x += 28
      end
      textpos = [[@name,x+6,4,0,@baseColor,@shadowColor,true]]
      pbSetSmallFont(self.bitmap)
      pbDrawTextPositions(self.bitmap, textpos)
    else
      self.bitmap.blt(0, 0, @keybind_icons.bitmap, $Keybinds.rect(@input))
      textpos = [[@name,34,4,0,@baseColor,@shadowColor,true]]
      pbSetSmallFont(self.bitmap)
      pbDrawTextPositions(self.bitmap, textpos)
    end
  end

  def dispose
    @keybind_icons.dispose
    super
  end

end

class Window_Guide < Window_DrawableCommand
  def initialize(items,x,y,width,height,viewport=nil)
    @items = items
    super(x, y, width, height, viewport)
    @selarrow=AnimatedBitmap.new("Graphics/Pictures/Guide/cursor")
    @baseColor=Color.new(88,88,80)
    @shadowColor=Color.new(168,184,184)
    self.windowskin=nil
  end

  def itemCount
    return @items.length+1
  end

  def item
    return self.index >= @items.length ? 0 : @items[self.index]
  end

  def drawItem(index, count, rect)
    textpos=[]
    rect=drawCursor(index,rect)
    ypos=rect.y
    if index == count - 1
      textpos.push([_INTL("CANCEL"),rect.x,ypos,false,
         self.baseColor,self.shadowColor])
    else
      itemname=@items[index][0]
      textpos.push([itemname,rect.x,ypos,false,self.baseColor,self.shadowColor])
    end
    pbDrawTextPositions(self.contents,textpos)
  end
end

class GuideScreen

  def pbStartGuideScreen(start_guide=nil)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @guides = []
    for g in GUIDES
      # Add check for game variable
      @guides.push(g) if pbHasGuide(g[0]) || ($DEBUG && Input.press?(Input::CTRL))
    end
    @index = 0
    if start_guide
      pbAddGuide(start_guide)
      for i in 0...@guides.length
        if @guides[i][0] == start_guide
          @index = i
          break
        end
      end
    else
      for i in 0...@guides.length
        if @guides[i][0] == $game_variables[Supplementals::LAST_GUIDE]
          @index = i
          break
        end
      end
    end
    @page  = 0
    @width = Graphics.width * 2 / 5
    @height = Graphics.height * 3 / 4
    @text_x = 210
    @text_y = 12
    @text_width = Graphics.width - 214
    @text_height = Graphics.height - 48
    @image_max_width = @text_width * 1.0
    @image_max_height = Graphics.height * 3.0 / 4.0
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Guide/bg")
    @sprites["itemlist"]=Window_Guide.new(@guides, -12, 12, 264, Graphics.height - 56)
    @sprites["itemlist"].viewport = @viewport
    @sprites["itemlist"].index = @index
    @sprites["itemlist"].baseColor = Color.new(252, 252, 252)
    @sprites["itemlist"].shadowColor = Color.new(0, 0, 0)
    @sprites["itemlist"].refresh
    @sprites["textwindow"] = Window_UnformattedTextPokemon.new("")
    @sprites["textwindow"].viewport=@viewport
    @sprites["textwindow"].visible = true
    @sprites["textwindow"].letterbyletter = false
    @sprites["textwindow"].x = @text_x
    @sprites["textwindow"].y = @text_y
    @sprites["textwindow"].width = @text_width
    @sprites["textwindow"].height = @text_height
    @sprites["textwindow"].baseColor = Color.new(252, 252, 252)
    @sprites["textwindow"].shadowColor = Color.new(0, 0, 0)
    @sprites["textwindow"].windowskin=nil
    @sprites["overlay"] = Sprite.new(@viewport)
    @sprites["overlay"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSmallFont(@sprites["overlay"].bitmap)
    @sprites["image"] = IconSprite.new(0, 0, @viewport)
    @sprites["image"].x = @sprites["textwindow"].x + @sprites["textwindow"].width / 2
    @sprites["image"].y = @sprites["textwindow"].y + 6
    @sprites["control_exit"] = KeybindSprite.new(Input::BACK, "Exit", 46, Graphics.height - 36, @viewport)
    @sprites["control_hint"] = KeybindSprite.new([Input::UP, Input::DOWN], "Select Hint", 130, Graphics.height - 36, @viewport)
    @sprites["control_page"] = KeybindSprite.new([Input::LEFT, Input::RIGHT], "Change Page", 302, Graphics.height - 36, @viewport)
    self.refresh
    pbFadeInAndShow(@sprites)
  end

  def refresh
    item = @sprites["itemlist"].item
    $game_variables[Supplementals::LAST_GUIDE] = item[0]
    @sprites["overlay"].bitmap.clear
    page_text = _INTL("Page {1}/{2}", @page+1, (item == 0) ? 1 : item.length-1)
    textpos = [
      [page_text, Graphics.width-98, Graphics.height-74, 0, Color.new(252,252,252), Color.new(0,0,0), true]
    ]
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    if item == 0
      @sprites["image"].visible = false
      @sprites["textwindow"].y = @text_y
      @sprites["textwindow"].height = @text_height
      @sprites["textwindow"].text = "Select this option to close the Guide menu."
    else
      item = item[1 + @page]
      if item[0...1] == "["
        @sprites["image"].visible = true
        image = item[1...item.index("]")]
        item = item[item.index("]")+1...item.length]
        @sprites["image"].setBitmap(_INTL("Graphics/Pictures/Guide/{1}", image))
        @sprites["image"].ox = @sprites["image"].bitmap.width / 2
        zoom = [1.0, @image_max_width/@sprites["image"].bitmap.width, @image_max_height/@sprites["image"].bitmap.height].min
        @sprites["image"].zoom_x = zoom
        @sprites["image"].zoom_y = zoom
        @sprites["textwindow"].y = @text_y + @sprites["image"].bitmap.height * zoom
        @sprites["textwindow"].height = @text_height - @sprites["image"].bitmap.height * zoom
        @sprites["textwindow"].text = item
      else
        @sprites["image"].visible = false
        @sprites["image"].setBitmap(nil)
        @sprites["textwindow"].y = @text_y
        @sprites["textwindow"].height = @text_height
        @sprites["textwindow"].text = item
      end
    end
  end

  def update
    pbUpdateSpriteHash(@sprites)
    @viewport.update
    if @index != @sprites["itemlist"].index
      @index = @sprites["itemlist"].index
      @page = 0
      self.refresh
    end
  end

  def pbChooseOption
    loop do
      Graphics.update
      Input.update
      self.update
      new_page = @page
      if Input.trigger?(Input::LEFT)
        new_page -= 1
        if new_page < 0
          page_count = @sprites["itemlist"].item.length - 1
          new_page = page_count - 1
        end
      elsif Input.trigger?(Input::RIGHT)
        new_page += 1
        page_count = @sprites["itemlist"].item.length - 1
        if new_page == page_count
          new_page = 0
        end
      elsif Input.trigger?(Input::BACK)
        return -1
      elsif Input.trigger?(Input::USE)
        if @index == @sprites["itemlist"].itemCount - 1
          return -1
        end
      end
      if new_page != @page
        @page = new_page
        self.refresh
      end
    end
  end

  def pbEndGuideScreen
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

end

def pbInitGuides
  guides = {}
  guides["The Guide"] = true
  guides["Moves"] = true
  guides["Types"] = true
  guides["Stats"] = true
  $game_variables[Supplementals::GUIDE_LIST] = guides
end

def pbHasGuide(guide)
  pbInitGuides if $game_variables[Supplementals::GUIDE_LIST].is_a?(Numeric)
  return $game_variables[Supplementals::GUIDE_LIST][guide]
end

def pbAddGuide(guide)
  pbInitGuides if $game_variables[Supplementals::GUIDE_LIST].is_a?(Numeric)
  if !$game_variables[Supplementals::GUIDE_LIST][guide]
    $game_variables[Supplementals::GUIDE_LIST][guide] = true
    $game_variables[Supplementals::NEW_GUIDE] = guide
  end
end

def pbGuide(guide)
  pbAddGuide(guide)
  pbFadeOutIn {
    pbStartGuideScreen(guide)
  }
end

def pbStartGuideScreen(guide=nil)
  guide_screen = GuideScreen.new
  guide_screen.pbStartGuideScreen(guide)
  loop do
    option = guide_screen.pbChooseOption
    break if option == -1
  end
  guide_screen.pbEndGuideScreen
end

MenuHandlers.add(:pause_menu, :guide, {
  "name"      => _INTL("Guide"),
  "order"     => 65,
  "condition" => proc { next $game_variables },
  "effect"    => proc { |menu|
    menu.pbHideMenu
    pbStartGuideScreen
    menu.pbRefresh
    menu.pbShowMenu
    next false
  }
})