class PauseOptionSprite < Sprite

  def initialize(viewport, index)
    super(viewport)
    @viewport  = viewport
    @index     = index
    @selected  = false
    @timer     = 0
    self.reset_position
    @sprite_bg = IconSprite.new(@sprite_x, @sprite_y, @viewport)
    @sprite_fg = IconSprite.new(@sprite_x, @sprite_y, @viewport)
    @sprite_bg.setBitmap("Graphics/UI/Pause/options")
    @sprite_fg.setBitmap("Graphics/UI/Pause/options")
    @sprite_bg.ox = 64
    @sprite_bg.oy = 64
    @sprite_fg.ox = 64
    @sprite_fg.oy = 64
    self.x = @sprite_x
    self.y = @sprite_y
    self.z = 5
    self.update
  end

  def reset_position
    @sprite_x  = 252 + 132 * (@index % 3)
    @sprite_y  = 164 + 132 * (@index / 3).floor
    self.x = @sprite_x
    self.y = @sprite_y
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
    if @index == 1 && !($quests.enabled)
      @sprite_fg.src_rect = Rect.new(4 * 128, 256, 128, 128)
    else
      @sprite_fg.src_rect = Rect.new(@index * 128, 256, 128, 128)
    end
    @sprite_bg.update
    @sprite_fg.update
  end
  
  def x=(value)
    super(value)
    @sprite_x = value
    @sprite_bg&.x = value
    @sprite_fg&.x = value
  end

  def y=(value)
    super(value)
    @sprite_y = y
    @sprite_bg&.y = value
    @sprite_fg&.y = value
  end

  def z=(value)
    super(value)
    @sprite_bg&.z = value + 1
    @sprite_fg&.z = value + 2
  end

  def opacity=(value)
    super(value)
    @sprite_bg&.opacity = value
    @sprite_fg&.opacity = value
  end

  def color=(value)
    super(value)
    @sprite_bg&.color = value
    @sprite_fg&.color = value
  end

  def tone=(value)
    super(value)
    @sprite_bg&.tone = value
    @sprite_fg&.tone = value
  end

  def zoom_x=(value)
    super(value)
    @sprite_bg&.zoom_x = value
    @sprite_fg&.zoom_x = value
  end

  def zoom_y=(value)
    super(value)
    @sprite_bg&.zoom_y = value
    @sprite_fg&.zoom_y = value
  end

end

class PauseControlsSprite < IconSprite

  def initialize(viewport, index)
    super(viewport)
    @index = index
    self.setBitmap("Graphics/UI/Pause/controls")
    @overlay = Sprite.new(viewport)
    @overlay.bitmap = Bitmap.new(self.bitmap.width, self.bitmap.height)
    @keybind_icons = AnimatedBitmap.new("Graphics/UI/keybinds")
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
    self.reset_position
    self.update
    self.refresh
  end

  def reset_position
    self.x = Graphics.width / 2 - self.bitmap.width / 2
    self.y = Graphics.height - self.bitmap.height
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
    @overlay.bitmap.blt(302, 14, @keybind_icons.bitmap, $Keybinds.rect(Input::SPECIAL))
    textpos = [
      ["Save",46,18,0,Color.new(252,252,252),Color.new(0,0,0),true],
      [@controls[@index][1],190,18,0,Color.new(252,252,252),Color.new(0,0,0),true],
      ["Map",334,18,0,Color.new(252,252,252),Color.new(0,0,0),true]
    ]
    pbSetSmallFont(@overlay.bitmap)
    pbDrawTextPositions(@overlay.bitmap, textpos)
  end

  def update
    super
    @overlay.update
  end

  def x=(value)
    super(value)
    @overlay.x = x
  end

  def y=(value)
    super(value)
    @overlay.y = y
  end

  def z=(value)
    super(value)
    @overlay.z = z + 1
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
    self.setBitmap("Graphics/UI/Pause/info")
    self.src_rect = Rect.new(0, @index * 76, self.bitmap.width, 76)
    @overlay = Sprite.new(viewport)
    @overlay.bitmap = Bitmap.new(self.bitmap.width, self.bitmap.height)
    pbSetSmallFont(@overlay.bitmap)
    self.reset_position
    self.refresh
    self.update
  end

  def reset_position
    self.x = Graphics.width - self.bitmap.width
    self.y = Graphics.height / 2 - 100 + @index * 82
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
      map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
      outdoor_map = map_metadata ? map_metadata.outdoor_map : true
      @value = $game_screen.weather_type
      weather_names = {
        :None      => outdoor_map ? "Clear" : "None",
        :Rain      => "Raining",
        :Sun       => "Sunny",
        :Winds     => "Windy",
        :Sandstorm => "Sandstorm",
        :BloodMoon => "Blood Moon",
        :Snow      => "Snowing",
        :Hail      => "Hailing",
        :Cloudy    => "Cloudy",
        :NoxiousStorm => "Nox. Storm"
      }
      textpos = [[weather_names[@value], 82, 34, 0, Color.new(252,252,252), Color.new(0,0,0), true]]
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
    @overlay.update
    super
  end

  def dispose
    @overlay.dispose
    super
  end

  def x=(value)
    super(value)
    @overlay.x = x
  end

  def y=(value)
    super(value)
    @overlay.y = y
  end

  def z=(value)
    super(value)
    @overlay.z = z + 1
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
    self.setBitmap("Graphics/UI/Pause/pokemon_bg")
    @overlay = Sprite.new(viewport)
    @overlay.bitmap = Bitmap.new(self.bitmap.width, self.bitmap.height)
    pbSetSmallFont(@overlay.bitmap)
    @pokemon_icon = PokemonIconSprite.new(@pokemon, viewport)
    @status_icon = IconSprite.new(0, 0, viewport)
    @status_icon.setBitmap(_INTL("Graphics/UI/statuses"))
    self.reset_position
    self.refresh
    self.update
  end

  def reset_position
    self.x = 0
    self.y = Graphics.height / 2 - 50 + @index * 60
    self.y -= (getActivePokemon(0).length - 1) * 60 if @party == 0
    self.y += 72 if @party == 1
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
        id = GameData::Status.get(@pokemon.status).icon_position
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
    self.x = self.x
    self.y = self.y
    self.z = self.z
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

  def x=(value)
    super(value)
    @overlay.x = self.x
    @pokemon_icon.x = self.x - 2
    @status_icon.x = self.x + 52
  end

  def y=(value)
    super(value)
    @overlay.y = self.y
    @pokemon_icon.y = self.y - 22
    @status_icon.y = self.y + 6
  end

  def z=(value)
    super(value)
    @overlay.z = self.z + 1
    @pokemon_icon.z = self.z + 1
    @status_icon.z = self.z + 1
  end

end

class PauseScreen

  def initialize
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
    @sprites["focus_quest"] = Window_AdvancedTextPokemon.new("", 1)
    @sprites["focus_quest"].viewport = @viewport
    @sprites["focus_quest"].z = 4
    @sprites["focus_quest"].setSkin("Graphics/Windowskins/pause_menu")
    @viewport.visible = false
  end

  def refresh
    @sprites["controls"].refresh
  end

  def update
    for i in 0...9
      if i != 4
        @sprites[_INTL("option_{1}", i)].selected = (@index == i)
      end
    end
    @sprites["controls"].index = @index
    pbUpdateSceneMap
  end

  def pbStartPauseScreen
    for i in 0...9
      if i != 4
        @sprites[_INTL("option_{1}", i)].reset_position
        if i == @index
          @sprites[_INTL("option_{1}", i)].selected = true
        end
      end
    end
    @sprites["controls"].reset_position
    for i in 0...3
      @sprites[_INTL("info_{1}", i)].reset_position
    end
    for i in 0...6
      @sprites[_INTL("pokemon_{1}", i)].reset_position
    end
    focus_quest = nil
    focus_quest_priority = -999
    $quests.each { |quest|
      if quest.type == PBQuestType::Main && quest.active?
        priority = MAIN_QUEST_DISPLAY_PRIORITY.index(quest.quest_id) || -1
        if priority > focus_quest_priority
          focus_quest = quest
          focus_quest_priority = priority
        end
      end
    }
    if focus_quest
      quest_title = focus_quest.display_name(focus_quest.status)
      quest_text = focus_quest.steps[focus_quest.step]
      full_text = _INTL("<ac><c2=3aff043c><u>{1}</u></c2>\n{2}</ac>", quest_title, quest_text)
      for w in 4...10
        @sprites["focus_quest"].resizeToFit(full_text, Graphics.width * w / 10)
        break if @sprites["focus_quest"].height < 120
      end
      @sprites["focus_quest"].text = full_text
      @sprites["focus_quest"].y = -12
      @sprites["focus_quest"].x = Graphics.width / 2 - @sprites["focus_quest"].width / 2
    end
    pbOpenAnimation
  end

  def pbEndPauseScreen(remember_index=true)
    if remember_index
      $game_variables[LAST_PAUSE_INDEX] = @index
    end
    pbCloseAnimation
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def disposed?
    return @viewport.disposed?
  end

  def pbOpenAnimation
    @viewport.visible = true
    pbSEPlay("GUI menu open")
    frames = (1..12).to_a.reverse
    frames_sum = frames.sum
    option_to_move = {}
    @sprites.each do |key, sprite|
      if key[/option/]
        to_move = [sprite.x - Graphics.width / 2, sprite.y - Graphics.height / 2]
        option_to_move[key] = to_move
        sprite.x -= to_move[0]
        sprite.y -= to_move[1]
        sprite.zoom_x = 0.0
        sprite.zoom_y = 0.0
        sprite.opacity = 0
      elsif key[/pokemon/]
        sprite.x -= frames_sum * 2
      elsif key[/info/]
        sprite.x += frames_sum * 2
      elsif key == "focus_quest"
        sprite.y -= frames_sum
      elsif key == "controls"
        sprite.y += frames_sum
      end
    end
    frames.each do |f|
      @sprites.each do |key, sprite|
        if key[/option/]
          sprite.x += (f * option_to_move[key][0] / frames_sum)
          sprite.y += (f * option_to_move[key][1] / frames_sum)
          sprite.zoom_x += f * 1.0 / frames_sum
          sprite.zoom_y += f * 1.0 / frames_sum
          sprite.opacity += f * 255 / frames_sum
        elsif key[/pokemon/]
          sprite.x += f * 2
        elsif key[/info/]
          sprite.x -= f * 2
        elsif key == "focus_quest"
          sprite.y += f
        elsif key == "controls"
          sprite.y -= f
        end
      end
      self.update
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      pbUpdateToasts
    end
  end

  def pbCloseAnimation
    pbPlayCloseMenuSE
    frames = (1..12).to_a
    frames_sum = frames.sum
    option_to_move = {}
    @sprites.each do |key, sprite|
      if key[/option/]
        to_move = [sprite.x - Graphics.width / 2, sprite.y - Graphics.height / 2]
        option_to_move[key] = to_move
      end
    end
    frames.each do |f|
      @sprites.each do |key, sprite|
        if key[/option/]
          sprite.x += (f * option_to_move[key][0] / frames_sum)
          sprite.y += (f * option_to_move[key][1] / frames_sum)
          sprite.zoom_x += f * 1.0 / frames_sum / 2
          sprite.zoom_y += f * 1.0 / frames_sum / 2
          sprite.opacity -= f * 255 / frames_sum
        elsif key[/pokemon/]
          sprite.x -= f * 2
        elsif key[/info/]
          sprite.x += f * 2
        elsif key == "focus_quest"
          sprite.y -= f
        elsif key == "controls"
          sprite.y += f
        end
      end
      self.update
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      pbUpdateToasts
    end
    @viewport.visible = false
  end

  def pbChooseOption
    loop do
      self.update
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      pbUpdateToasts
      @viewport.update
      if Input.trigger?(Input::BACK)
        return -1
      elsif Input.trigger?(Input::USE)
        return @index
      elsif Input.trigger?(Input::ACTION)
        return @index + 10
      elsif Input.trigger?(Input::SPECIAL)
        return 30
      elsif Input.repeat?(Input::RIGHT)
        pbSEPlay("GUI sel cursor")
        if @index % 3 == 2
          @index -= 2
        elsif @index == 3
          @index += 2
        else
          @index += 1
        end
      elsif Input.repeat?(Input::LEFT)
        pbSEPlay("GUI sel cursor")
        if @index % 3 == 0
          @index += 2
        elsif @index == 5
          @index -= 2
        else
          @index -= 1
        end
      elsif Input.repeat?(Input::UP)
        pbSEPlay("GUI sel cursor")
        if @index <= 2
          @index += 6
        elsif @index == 7
          @index -= 6
        else
          @index -= 3
        end
      elsif Input.repeat?(Input::DOWN)
        pbSEPlay("GUI sel cursor")
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

  def pbExpandOption(option)
    #pbPlayDecisionSE
    pbSEPlay("GUI storage show party panel")
    sprite = @sprites[_INTL("option_{1}", option)]
    origin_x = sprite.x
    origin_y = sprite.y
    origin_z = sprite.z
    to_move_x = sprite.x - Graphics.width / 2
    to_move_y = sprite.y - Graphics.height / 2
    sprite.z = 10
    15.times do |i|
      factor = i / 60.0
      sprite.zoom_x += i * factor
      sprite.zoom_y += i * factor
      if i < 5
        sprite.x = origin_x + to_move_x * factor * 4
        sprite.y = origin_y + to_move_y * factor * 4
      else
        sprite.x = origin_x + to_move_x / 3.0 - to_move_x * (factor - 5.0 / 60) * 4
        sprite.y = origin_y + to_move_y / 3.0 - to_move_y * (factor - 5.0 / 60) * 4
      end
      tone = -256 * (i + 1) / 15
      sprite.tone = Tone.new(tone, tone, tone)
      self.update
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      pbUpdateToasts
      @viewport.update
    end
    val = 0
    val = yield if block_given?
    pbSEPlay("GUI storage hide party panel")
    15.times do |i|
      factor = (14 - i) / 60.0
      sprite.zoom_x -= (14 - i) * factor
      sprite.zoom_y -= (14 - i) * factor
      if i >= 5
        sprite.x = origin_x + to_move_x * factor * 4
        sprite.y = origin_y + to_move_y * factor * 4
      else
        sprite.x = origin_x + to_move_x / 3.0 - to_move_x * (factor - 5.0 / 60) * 4
        sprite.y = origin_y + to_move_y / 3.0 - to_move_y * (factor - 5.0 / 60) * 4
      end
      tone = -256 * (16 - i) / 15
      sprite.tone = Tone.new(tone, tone, tone)
      self.update
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      pbUpdateToasts
      @viewport.update
    end
    sprite.tone = Tone.new(0, 0, 0)
    sprite.x = origin_x
    sprite.y = origin_y
    sprite.z = origin_z
    sprite.zoom_x = 1.0
    sprite.zoom_y = 1.0
    return val
  end

end

def pbPauseMenu
  if !$game_switches || $game_switches[LOCK_PAUSE_MENU]
    pbDialog("NO_PAUSE_MENU")
    return
  end
  if $game_switches[CANNOT_OPEN_MENUS]
    return
  end
  if !$pause_screen || $pause_screen.disposed?
    $pause_screen = PauseScreen.new
    echoln "Init pause screen"
  end
  $pause_screen.pbStartPauseScreen
  loop do
    option = $pause_screen.pbChooseOption
    if option == 30
      pbFadeOutIn(99998) {
        scene = PokemonRegionMap_Scene.new(-1, false)
        screen = PokemonRegionMapScreen.new(scene)
        ret = screen.pbStartScreen
        if ret
          $game_temp.fly_destination = ret
        end
      }
      if $game_temp.fly_destination
        break
      end
      next
    end
    shortcut = (option >= 10)
    option -= 10 if shortcut
    break if option == -1
    if shortcut
      $pause_screen.pbEndPauseScreen
      scene = PokemonSave_Scene.new
      screen = PokemonSaveScreen.new(scene)
      screen.pbSaveScreen
      return 2
    end
    case option
    when 0 # Pokemon
      if shortcut

      else
        if pbGet(PARTY_ACTIVE).length < 2 ||
           pbGet(PARTY_ACTIVE)[0] == -1 ||
           pbGet(PARTY_ACTIVE)[1] == -1
          pbDialog("NOT_ENOUGH_PARTY_MEMBERS")
          next
        end
        sscene=PokemonScreen_Scene.new
        sscreen=PokemonScreen.new(sscene,getActivePokemon(0))
        hiddenmove=nil
        $pause_screen.pbExpandOption(option) { 
          hiddenmove=sscreen.pbPokemonScreen
          if hiddenmove
            $pause_screen.pbEndPauseScreen
          end
        }
        if hiddenmove
          $pause_screen.pbEndPauseScreen
          Kernel.pbUseHiddenMove(hiddenmove[0],hiddenmove[1])
          return 1
        end
      end
    when 1 # Quests
      if shortcut

      else
        if $quests.enabled
          $pause_screen.pbExpandOption(option) {
            pbShowQuests
          }
        else
          pbDialog("NO_QUEST_LIST")
        end
      end
    when 2 # Items
      if shortcut

      else
        if pbGet(PARTY_ACTIVE).length < 2 ||
           pbGet(PARTY_ACTIVE)[0] == -1 ||
           pbGet(PARTY_ACTIVE)[1] == -1
          pbDialog("NOT_ENOUGH_PARTY_MEMBERS")
          next
        end
        item=0
        scene=PokemonBag_Scene.new
        screen=PokemonBagScreen.new(scene,$bag)
        $pause_screen.pbExpandOption(option) { 
          item=screen.pbStartScreen 
          if item
            $pause_screen.pbEndPauseScreen
          end
        }
        if item
          $pause_screen.pbEndPauseScreen
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
            $pause_screen.pbExpandOption(option) {
              scene = PokemonPokedex_Scene.new
              screen = PokemonPokedexScreen.new(scene)
              screen.pbStartScreen
            }
          else
            $pause_screen.pbExpandOption(option) {
              scene = PokemonPokedexMenu_Scene.new
              screen = PokemonPokedexMenuScreen.new(scene)
              screen.pbStartScreen
            }
          end
        end
      end
    when 5 # Trainer
      if shortcut
        $pause_screen.pbExpandOption(option) {
          scene = PokemonJobs_Scene.new
          screen = PokemonJobsScreen.new(scene)
          screen.pbStartScreen
        }
      else
        $pause_screen.pbExpandOption(option) {
          scene = PokemonJobs_Scene.new
          screen = PokemonJobsScreen.new(scene)
          screen.pbStartScreen
        }
      end
    when 6 # Guide
      if shortcut
        $pause_screen.pbExpandOption(option) {
          pbStartGuideScreen($game_variables[NEW_GUIDE])
        }
      else
        $pause_screen.pbExpandOption(option) {
          pbStartGuideScreen
        }
      end
    when 7 # System
      if shortcut
        $pause_screen.pbEndPauseScreen(false)
        scene = PokemonSave_Scene.new
        screen = PokemonSaveScreen.new(scene)
        screen.pbSaveScreen
        return 2
      else
        $pause_screen.pbExpandOption(option) {
          scene = PokemonOption_Scene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
          $pause_screen.refresh
          pbUpdateSceneMap
        }
      end
    when 8 # Phone
      if shortcut
        $pause_screen.pbExpandOption(option) {
          scene = PokemonRegionMap_Scene.new(-1, false)
          screen = PokemonRegionMapScreen.new(scene)
          ret = screen.pbStartScreen
          if ret
            $game_temp.fly_destination = ret
          end
        }
      else
        $pause_screen.pbExpandOption(option) {
          scene = PokemonPokegear_Scene.new
          screen = PokemonPokegearScreen.new(scene)
          screen.pbStartScreen
        }
      end
      if $game_temp.fly_destination
        break
      end
    end
  end
  $pause_screen.pbEndPauseScreen
  if $game_temp.fly_destination
    pkmn = [
      :ABRA, :KADABRA,
      :NATU, :XATU,
      :ELGYEM, :BEHEEYEM,
      :RALTS, :KIRLIA
    ]
    pkmn = Pokemon.new(pkmn.shuffle[0], 10)
    pbFlyToNewLocation(pkmn)
  end
end