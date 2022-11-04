class PauseOptionSprite < SpriteWrapper

  def initialize(viewport, index)
    super(viewport)
    @viewport  = viewport
    @index     = index
    @selected  = false
    @timer     = 0
    @sprite_x  = 252 + 132 * (index % 3)
    @sprite_y  = 164 + 132 * (index / 3).floor
    @sprite_bg = IconSprite.new(@sprite_x, @sprite_y, @viewport)
    @sprite_fg = IconSprite.new(@sprite_x, @sprite_y, @viewport)
    @sprite_bg.setBitmap("Graphics/Pictures/Pause/options")
    @sprite_fg.setBitmap("Graphics/Pictures/Pause/options")
    @sprite_bg.ox = 64
    @sprite_bg.oy = 64
    @sprite_bg.z  = 1
    @sprite_fg.ox = 64
    @sprite_fg.oy = 64
    @sprite_fg.z  = 2
    self.update
  end

  def selected=(value)
    @selected = value
    self.update
  end

  def dispose
    @sprite_bg.dispose
    @sprite_fg.dispose
    super()
  end

  def update
    if @selected
      @timer += 1
      @sprite_bg.angle = Math.sin(@timer / 16.0) * 6
    else
      @timer = 0
      @sprite_bg.angle = 0
    end
    @sprite_bg.src_rect = Rect.new(@index * 128, @selected ? 128 : 0, 128, 128)
    @sprite_fg.src_rect = Rect.new(@index * 128, 256, 128, 128)
    @sprite_bg.update
    @sprite_fg.update
  end

  def opacity=(value)
    super(value)
    @sprite_bg.opacity = value
    @sprite_fg.opacity = value
  end

  def color=(value)
    super(value)
    @sprite_bg.color = value
    @sprite_fg.color = value
  end

end

class PauseControlsSprite < IconSprite

  def initialize(viewport, index)
    super(viewport)
    @index = index
    self.setBitmap("Graphics/Pictures/Pause/controls")
    self.x = Graphics.width / 2 - self.bitmap.width / 2
    self.y = Graphics.height - self.bitmap.height
    @overlay = Sprite.new(viewport)
    @overlay.bitmap = Bitmap.new(self.bitmap.width, self.bitmap.height)
    @keybind_icons = AnimatedBitmap.new("Graphics/Pictures/keybinds")
    @controls = [
      ["Quick Swap", "Pokemon"], # Pokemon
      ["Recent", "Quests"], # Quests
      ["Registered", "Items"], # Items
      ["This Area", "Pokedex"], # Pokedex
      ["How are", "you here"], # None
      ["???", "Card"], # Trainer
      ["Recent", "Guide"], # Guide
      ["Save", "Options"], # System
      ["Map", "Phone"]  # Phone
    ]
    self.update
    self.refresh
  end

  def index=(value)
    if @index != value
      @index = value
      self.refresh
    end
  end

  def refresh
    @overlay.bitmap.clear
    @overlay.bitmap.blt(14, 14, @keybind_icons.bitmap, $Keybinds.rect(Input::ACTION))
    @overlay.bitmap.blt(158, 14, @keybind_icons.bitmap, $Keybinds.rect(Input::USE))
    textpos = [
      [@controls[@index][0],46,18,0,Color.new(252,252,252),Color.new(0,0,0),true],
      [@controls[@index][1],190,18,0,Color.new(252,252,252),Color.new(0,0,0),true]
    ]
    pbSetSmallFont(@overlay.bitmap)
    pbDrawTextPositions(@overlay.bitmap, textpos)
  end

  def update
    @overlay.x = self.x
    @overlay.y = self.y
    @overlay.z = self.z + 1
    @overlay.update
    super
  end

  def dispose
    @keybind_icons.dispose
    @overlay.dispose
    super
  end

  def opacity=(value)
    super(value)
    @overlay.opacity = value
  end

  def color=(value)
    super(value)
    @overlay.color = value
  end

end

class PauseInfoBox < IconSprite

  def initialize(viewport, index)
    super(viewport)
    @index = index
    self.setBitmap("Graphics/Pictures/Pause/info")
    self.x = Graphics.width - self.bitmap.width
    self.y = Graphics.height / 2 - 100 + @index * 82
    self.src_rect = Rect.new(0, @index * 76, self.bitmap.width, 76)
    @overlay = Sprite.new(viewport)
    @overlay.bitmap = Bitmap.new(self.bitmap.width, self.bitmap.height)
    pbSetSmallFont(@overlay.bitmap)
    self.refresh
    self.update
  end

  def refresh
    @overlay.bitmap.clear
    case @index
    when 0 # Money
      @value = $player.money
      text = "$" + self.number_with_delimiter(@value)
      textpos = [[text, 82, 34, 0, Color.new(252,252,252), Color.new(0,0,0), true]]
      pbDrawTextPositions(@overlay.bitmap, textpos)
    when 1 # Time
      @value = pbGetTimeNow.to_i_min
      text = (pbGetLanguage()==2) ? pbGetTimeNow.getDigitalString : pbGetTimeNow.getDigitalString(true, true)
      textpos = [[text, 82, 34, 0, Color.new(252,252,252), Color.new(0,0,0), true]]
      pbDrawTextPositions(@overlay.bitmap, textpos)
    when 2 # Weather
      @value = pbGetForecast[$game_map.map_id]
      text = "[WIP]"
      textpos = [[text, 82, 34, 0, Color.new(252,252,252), Color.new(0,0,0), true]]
      pbDrawTextPositions(@overlay.bitmap, textpos)
    end
  end

  def update
    case @index
    when 0 # Money
      self.refresh if @value != $player.money
    when 1 # Time
      self.refresh if @value != pbGetTimeNow.to_i_min
    when 2 # Weather
      self.refresh if @value != pbGetForecast[$game_map.map_id]
    end
    @overlay.x = self.x
    @overlay.y = self.y
    @overlay.z = self.z + 1
    @overlay.update
    super
  end

  def dispose
    @overlay.dispose
    super
  end

  def opacity=(value)
    super(value)
    @overlay.opacity = value
  end

  def color=(value)
    super(value)
    @overlay.color = value
  end

  def number_with_delimiter(num)
    neg = (num < 0)
    num = num.abs
    str = num.to_s
    ret = ""
    if str.include?(".")
      ret = str[str.index(".")...str.length]
      str = str[0...str.index(".")]
    end
    while str.length > 3
      sub = str[(str.length-3)...str.length]
      str = str[0...(str.length-3)]
      ret = "," + sub + ret
    end
    ret = str + ret
    ret = "-" + ret if neg
    return ret
  end

end

class PausePokemonBox < IconSprite

  def initialize(viewport, index)
    super(viewport)
    @index = index
    @party = (@index >= 3) ? 0 : 1
    @index -= 3 if @index >= 3
    @pokemon = getActivePokemon(@party)[@index]
    @species = @pokemon ? @pokemon.species : nil
    @hp = @pokemon ? @pokemon.hp : 0
    @totalhp = @pokemon ? @pokemon.totalhp : 0
    @status = @pokemon ? @pokemon.status : 0
    self.setBitmap("Graphics/Pictures/Pause/pokemon_bg")
    self.x = 0
    self.y = Graphics.height / 2 - 50 + @index * 60
    self.y -= (getActivePokemon(0).length - 1) * 60 if @party == 0
    self.y += 72 if @party == 1
    @overlay = Sprite.new(viewport)
    @overlay.bitmap = Bitmap.new(self.bitmap.width, self.bitmap.height)
    pbSetSmallFont(@overlay.bitmap)
    @pokemon_icon = PokemonIconSprite.new(@pokemon, viewport)
    @pokemon_icon.x = self.x - 2
    @pokemon_icon.y = self.y - 22
    @status_icon = IconSprite.new(0, 0, viewport)
    @status_icon.setBitmap(_INTL("Graphics/Pictures/statuses"))
    @status_icon.x = self.x + 52
    @status_icon.y = self.y + 6
    self.refresh
    self.update
  end

  def refresh
    @overlay.bitmap.clear
    if @pokemon
      self.visible = true
      if @pokemon.hp <= 0
        id = 5
        @status_icon.src_rect = Rect.new(0, 32*id, 32, 32)
      elsif @pokemon.status == :NONE
        @status_icon.visible = false
      else
        id = GameData::Status.get(@pokemon.status).icon_position - 1
        @status_icon.src_rect = Rect.new(0, 32*id, 32, 32)
      end
      hpzone=0
      hpzone=1 if @hp<=(@totalhp/2).floor
      hpzone=2 if @hp<=(@totalhp/4).floor
      hpcolors=[
         Color.new(14,152,22),Color.new(24,192,32),   # Green
         Color.new(202,138,0),Color.new(232,168,0),   # Orange
         Color.new(218,42,36),Color.new(248,72,56)    # Red
      ]
      bar_len = 46
      for i in 0...4
        color_index = [0,1,1,0][i]
        @overlay.bitmap.fill_rect(84, 18+i*2, [(@hp*1.0*bar_len/@totalhp/2).ceil*2,bar_len-i*2].min, 2, hpcolors[hpzone*2 + color_index])
      end
    else
      self.visible = false
    end
  end

  def update
    if @pokemon != getActivePokemon(@party)[@index] || (@pokemon && @pokemon.species != @species)
      @pokemon = getActivePokemon(@party)[@index]
      @species = @pokemon ? @pokemon.species : nil
      @pokemon_icon.pokemon = @pokemon
      @pokemon_icon.update
      @hp = @pokemon ? @pokemon.hp : 0
      @totalhp = @pokemon ? @pokemon.totalhp : 0
      self.refresh
    elsif @pokemon && (@hp != @pokemon.hp || @totalhp != @pokemon.totalhp || @status != @pokemon.status)
      @hp = @pokemon.hp
      @totalhp = @pokemon.totalhp
      @status = @pokemon.status
      self.refresh
    end
    @overlay.x = self.x
    @overlay.y = self.y
    @overlay.z = self.z + 1
    @overlay.update
    super
  end

  def dispose
    @overlay.dispose
    @pokemon_icon.dispose
    @status_icon.dispose
    super
  end

  def visible=(value)
    super(value)
    @overlay.visible = value
    @pokemon_icon.visible = value
    @status_icon.visible = value
  end

  def opacity=(value)
    super(value)
    @overlay.opacity = value
    @pokemon_icon.opacity = value
    @status_icon.opacity = value
  end

  def color=(value)
    super(value)
    @overlay.color = value
    @pokemon_icon.color = value
    @status_icon.color = value
  end

end

class PauseScreen

  def update
    for i in 0...9
      if i != 4
        @sprites[_INTL("option_{1}", i)].selected = (@index == i)
      end
    end
    @sprites["controls"].index = @index
  end

  def pbStartPauseScreen
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 9999
    @sprites = {}
    @index = 0
    if $game_variables && $game_variables[LAST_PAUSE_INDEX].is_a?(Numeric)
      @index = $game_variables[LAST_PAUSE_INDEX]
    end
    for i in 0...9
      if i != 4
        option_sprite = PauseOptionSprite.new(@viewport, i)
        @sprites[_INTL("option_{1}", i)] = option_sprite
        if i == @index
          option_sprite.selected = true
        end
      end
    end
    @sprites["controls"] = PauseControlsSprite.new(@viewport, @index)
    for i in 0...3
      @sprites[_INTL("info_{1}", i)] = PauseInfoBox.new(@viewport, i)
    end
    for i in 0...6
      @sprites[_INTL("pokemon_{1}", i)] = PausePokemonBox.new(@viewport, i)
    end
    pbFadeInAndShow(@sprites)
  end

  def pbEndPauseScreen(remember_index=true)
    if remember_index
      $game_variables[LAST_PAUSE_INDEX] = @index
    end
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbChooseOption
    loop do
      self.update
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      @viewport.update
      if Input.trigger?(Input::BACK)
        return -1
      elsif Input.trigger?(Input::USE)
        return @index
      elsif Input.trigger?(Input::ACTION)
        return @index + 10
      elsif Input.repeat?(Input::RIGHT)
        if @index % 3 == 2
          @index -= 2
        elsif @index == 3
          @index += 2
        else
          @index += 1
        end
      elsif Input.repeat?(Input::LEFT)
        if @index % 3 == 0
          @index += 2
        elsif @index == 5
          @index -= 2
        else
          @index -= 1
        end
      elsif Input.repeat?(Input::UP)
        if @index <= 2
          @index += 6
        elsif @index == 7
          @index -= 6
        else
          @index -= 3
        end
      elsif Input.repeat?(Input::DOWN)
        if @index >= 6
          @index -= 6
        elsif @index == 1
          @index += 6
        else
          @index += 3
        end
      end
    end
  end

end

def pbPauseMenu
  return if !$game_switches || $game_switches[LOCK_PAUSE_MENU]
  pause_screen = PauseScreen.new
  pause_screen.pbStartPauseScreen
  loop do
    option = pause_screen.pbChooseOption
    shortcut = (option >= 10)
    option -= 10 if shortcut
    break if option == -1
    case option
    when 0 # Pokemon
      if shortcut

      else
        sscene=PokemonScreen_Scene.new
        sscreen=PokemonScreen.new(sscene,getActivePokemon(0))
        hiddenmove=nil
        pbFadeOutIn(99999) { 
          hiddenmove=sscreen.pbPokemonScreen
          if hiddenmove
            pbPauseMenuClose(toDispose)
          end
        }
        if hiddenmove
          pause_screen.pbEndPauseScreen
          Kernel.pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
          return 1
        end
      end
    when 1 # Quests
      if shortcut

      else
        pbFadeOutIn {
          pbShowQuests
        }
      end
    when 2 # Items
      if shortcut

      else
        item=0
        scene=PokemonBag_Scene.new
        screen=PokemonBagScreen.new(scene,$bag)
        pbFadeOutIn(99999) { 
          item=screen.pbStartScreen 
          if item
            pbPauseMenuClose(toDispose)
          end
        }
        if item
          pause_screen.pbEndPauseScreen
          pbUseKeyItemInField(item)
          return 1
        end
      end
    when 3 # Pokedex
      if shortcut

      else
        if Settings::USE_CURRENT_REGION_DEX
          pbFadeOutIn {
            scene = PokemonPokedex_Scene.new
            screen = PokemonPokedexScreen.new(scene)
            screen.pbStartScreen
          }
        else
          if $player.pokedex.accessible_dexes.length == 1 && !$game_switches[HAS_HABITAT_DEX]
            $PokemonGlobal.pokedexDex = $player.pokedex.accessible_dexes[0]
            pbFadeOutIn {
              scene = PokemonPokedex_Scene.new
              screen = PokemonPokedexScreen.new(scene)
              screen.pbStartScreen
            }
          else
            pbFadeOutIn {
              scene = PokemonPokedexMenu_Scene.new
              screen = PokemonPokedexMenuScreen.new(scene)
              screen.pbStartScreen
            }
          end
        end
      end
    when 5 # Trainer
      if shortcut
        pbFadeOutIn {
          scene = PokemonJobs_Scene.new
          screen = PokemonJobsScreen.new(scene)
          screen.pbStartScreen
        }
      else
        pbFadeOutIn {
          scene = PokemonTrainerCard_Scene.new
          screen = PokemonTrainerCardScreen.new(scene)
          screen.pbStartScreen
        }
      end
    when 6 # Guide
      if shortcut
        pbFadeOutIn {
          pbStartGuideScreen($game_variables[NEW_GUIDE])
        }
      else
        pbFadeOutIn {
          pbStartGuideScreen
        }
      end
    when 7 # System
      if shortcut
        pause_screen.pbEndPauseScreen(false)
        scene = PokemonSave_Scene.new
        screen = PokemonSaveScreen.new(scene)
        screen.pbSaveScreen
        return 2
      else
        pbFadeOutIn {
          scene = PokemonOption_Scene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
          pbUpdateSceneMap
        }
      end
    when 8 # Phone
      if shortcut
        pbShowMap(-1,false)
      else
        pbFadeOutIn {
          scene = PokemonPokegear_Scene.new
          screen = PokemonPokegearScreen.new(scene)
          screen.pbStartScreen
        }
      end
    end
  end
  pause_screen.pbEndPauseScreen
end