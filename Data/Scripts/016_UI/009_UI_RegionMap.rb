#===============================================================================
#
#===============================================================================
class MapBottomSprite < Sprite
  attr_reader :mapname, :maplocation

  TEXT_MAIN_COLOR   = Color.new(248, 248, 248)
  TEXT_SHADOW_COLOR = Color.new(0, 0, 0)

  def initialize(viewport = nil)
    super(viewport)
    @mapname     = ""
    @maplocation = ""
    @mapdetails  = ""
    self.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def mapname=(value)
    return if @mapname == value
    @mapname = value
    refresh
  end

  def maplocation=(value)
    return if @maplocation == value
    @maplocation = value
    refresh
  end

  # From Wichu
  def mapdetails=(value)
    return if @mapdetails == value
    @mapdetails = value
    refresh
  end

  def refresh
    bitmap.clear
    c = @maplocation == "" ? nil : pbGetCompletion(@maplocation, @mapdetails)
    textpos = [
      [@mapname,                     160,  34, :left,  TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
      [@maplocation,                 160, 394, :left,  TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
      [@mapdetails, Graphics.width - 160, 394, :right, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR]
    ]
    if c
      textpos += [
        [_INTL("Items"),        178, 394 + 48,      :left, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [_INTL("Trainers"),     418, 394 + 48,      :left, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [_INTL("Quests"),       178, 394 + 48 + 40, :left, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [_INTL("Field Bosses"), 418, 394 + 48 + 40, :left, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [_INTL("Pokedex"),      178, 394 + 48 + 80, :left, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [_INTL("Secrets"),      418, 394 + 48 + 80, :left, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [sprintf("%2s", zero_dash(c.items_max)),    Graphics.width - 400, 394 + 48,      :right, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [sprintf("%2s", zero_dash(c.trainers_max)), Graphics.width - 160, 394 + 48,      :right, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [sprintf("%2s", zero_dash(c.quests_max)),   Graphics.width - 400, 394 + 48 + 40, :right, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [sprintf("%2s", zero_dash(c.bosses_max)),   Graphics.width - 160, 394 + 48 + 40, :right, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [sprintf("%2s", zero_dash(c.caught_max)),   Graphics.width - 400, 394 + 48 + 80, :right, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [sprintf("%2s", zero_dash(c.secrets_max)),  Graphics.width - 160, 394 + 48 + 80, :right, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [sprintf("%2s /", zero_dash(c.items, c.items_max)),       Graphics.width - 400 - 26, 394 + 48,      :right, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [sprintf("%2s /", zero_dash(c.trainers, c.trainers_max)), Graphics.width - 160 - 26, 394 + 48,      :right, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [sprintf("%2s /", zero_dash(c.quests, c.quests_max)),     Graphics.width - 400 - 26, 394 + 48 + 40, :right, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [sprintf("%2s /", zero_dash(c.bosses, c.bosses_max)),     Graphics.width - 160 - 26, 394 + 48 + 40, :right, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [sprintf("%2s /", zero_dash(c.caught, c.caught_max)),     Graphics.width - 400 - 26, 394 + 48 + 80, :right, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR],
        [sprintf("%2s /", zero_dash(c.secrets, c.secrets_max)),   Graphics.width - 160 - 26, 394 + 48 + 80, :right, TEXT_MAIN_COLOR, TEXT_SHADOW_COLOR]
      ]
    end
    pbDrawTextPositions(bitmap, textpos)
  end

  def zero_dash(val, val2 = 0)
    return (val == 0 && val2 == 0) ? "-" : val.to_s
  end
end

#===============================================================================
#
#===============================================================================
class PokemonRegionMap_Scene
  LEFT          = 0
  TOP           = 0
  RIGHT         = 29
  BOTTOM        = 19
  SQUARE_WIDTH  = 16
  SQUARE_HEIGHT = 16

  def initialize(region = - 1, wallmap = true)
    @region  = region
    @wallmap = wallmap
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(as_editor = false, fly_map = false)
    @editor   = as_editor
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    @sprites = {}
    @fly_map = false
    @mode    = fly_map ? 1 : 0
    map_metadata = $game_map.metadata
    playerpos = (map_metadata) ? map_metadata.town_map_position : nil
    if !playerpos
      mapindex = 0
      @map     = GameData::TownMap.get(0)
      @map_x   = LEFT
      @map_y   = TOP
    elsif @region >= 0 && @region != playerpos[0] && GameData::TownMap.exists?(@region)
      mapindex = @region
      @map     = GameData::TownMap.get(@region)
      @map_x   = LEFT
      @map_y   = TOP
    else
      mapindex = playerpos[0]
      @map     = GameData::TownMap.get(playerpos[0])
      @map_x   = playerpos[1]
      @map_y   = playerpos[2]
      mapsize  = map_metadata.town_map_size
      if mapsize && mapsize[0] && mapsize[0] > 0
        sqwidth  = mapsize[0]
        sqheight = (mapsize[1].length.to_f / mapsize[0]).ceil
        @map_x += ($game_player.x * sqwidth / $game_map.width).floor if sqwidth > 1
        @map_y += ($game_player.y * sqheight / $game_map.height).floor if sqheight > 1
      end
    end
    if !@map
      pbMessage(_INTL("The map data cannot be found."))
      return false
    end
    addBackgroundOrColoredPlane(@sprites, "background", "Town Map/bg", Color.black, @viewport)
    @sprites["map"] = IconSprite.new(0, 0, @viewport)
    @sprites["map"].setBitmap("Graphics/UI/Town Map/#{@map.filename}")
    @sprites["map"].x += (Graphics.width - @sprites["map"].bitmap.width) / 2
    @sprites["map"].y += (Graphics.height - @sprites["map"].bitmap.height) / 4
    Settings::REGION_MAP_EXTRAS.each do |graphic|
      next if graphic[0] != mapindex || !location_shown?(graphic)
      if !@sprites["map2"]
        @sprites["map2"] = BitmapSprite.new(480, 320, @viewport)
        @sprites["map2"].x = @sprites["map"].x
        @sprites["map2"].y = @sprites["map"].y
      end
      pbDrawImagePositions(
        @sprites["map2"].bitmap,
        [["Graphics/UI/Town Map/#{graphic[4]}", graphic[2] * SQUARE_WIDTH, graphic[3] * SQUARE_HEIGHT]]
      )
    end
    @sprites["mapbottom"] = MapBottomSprite.new(@viewport)
    @sprites["mapbottom"].mapname     = @map.name
    @sprites["mapbottom"].maplocation = pbGetMapLocation(@map_x, @map_y)
    @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@map_x, @map_y)
    if playerpos && mapindex == playerpos[0]
      @sprites["player"] = IconSprite.new(0, 0, @viewport)
      @sprites["player"].setBitmap(GameData::TrainerType.player_map_icon_filename($player.trainer_type))
      @sprites["player"].x = point_x_to_screen_x(@map_x)
      @sprites["player"].y = point_y_to_screen_y(@map_y)
    end
    k = 0
    (LEFT..RIGHT).each do |i|
      (TOP..BOTTOM).each do |j|
        healspot = pbGetHealingSpot(i, j)
        next if !healspot || !$PokemonGlobal.visitedMaps[healspot[0]]
        @sprites["point#{k}"] = AnimatedSprite.create("Graphics/UI/Town Map/icon_teleport", 2, 16)
        @sprites["point#{k}"].viewport = @viewport
        @sprites["point#{k}"].x        = point_x_to_screen_x(i)
        @sprites["point#{k}"].y        = point_y_to_screen_y(j)
        @sprites["point#{k}"].visible  = @mode == 1
        @sprites["point#{k}"].play
        k += 1
      end
    end
    @sprites["cursor"] = AnimatedSprite.create("Graphics/UI/Town Map/cursor", 2, 5)
    @sprites["cursor"].viewport = @viewport
    @sprites["cursor"].x        = point_x_to_screen_x(@map_x)
    @sprites["cursor"].y        = point_y_to_screen_y(@map_y)
    @sprites["cursor"].play
    @sprites["help"] = BitmapSprite.new(Graphics.width, 32, @viewport)
    pbSetSystemFont(@sprites["help"].bitmap)
    refresh_fly_screen
    @changed = false
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def point_x_to_screen_x(x)
    return (-SQUARE_WIDTH / 2) + (x * SQUARE_WIDTH) + ((Graphics.width - @sprites["map"].bitmap.width) / 2)
  end

  def point_y_to_screen_y(y)
    return (-SQUARE_HEIGHT / 2) + (y * SQUARE_HEIGHT) + ((Graphics.height - @sprites["map"].bitmap.height) / 4)
  end

  def location_shown?(point)
    return point[5] if @wallmap
    return point[1] > 0 && $game_switches[point[1]]
  end

  def pbSaveMapData
    GameData::TownMap.save
    Compiler.write_town_map
  end

  def pbGetMapLocation(x, y)
    return "" if !@map.point
    @map.point.each do |point|
      next if point[0] != x || point[1] != y
      return "" if point[7] && (@wallmap || point[7] <= 0 || !$game_switches[point[7]])
      name = pbGetMessageFromHash(MessageTypes::REGION_LOCATION_NAMES, point[2])
      return (@editor) ? point[2] : name
    end
    return ""
  end

  def pbChangeMapLocation(x, y)
    return "" if !@editor || !@map.point
    point = @map.point.select { |loc| loc[0] == x && loc[1] == y }[0]
    currentobj  = point
    currentname = (point) ? point[2] : ""
    currentname = pbMessageFreeText(_INTL("Set the name for this point."), currentname, false, 250) { pbUpdate }
    if currentname
      if currentobj
        currentobj[2] = currentname
      else
        newobj = [x, y, currentname, ""]
        @map.point.push(newobj)
      end
      @changed = true
    end
  end

  def pbGetMapDetails(x, y)
    return "" if !@map.point
    @map.point.each do |point|
      next if point[0] != x || point[1] != y
      return "" if point[7] && (@wallmap || point[7] <= 0 || !$game_switches[point[7]])
      return "" if !point[3]
      mapdesc = pbGetMessageFromHash(MessageTypes::REGION_LOCATION_DESCRIPTIONS, point[3])
      return (@editor) ? point[3] : mapdesc
    end
    return ""
  end

  def pbGetHealingSpot(x, y)
    return nil if !@map.point
    @map.point.each do |point|
      next if point[0] != x || point[1] != y
      return nil if point[7] && (@wallmap || point[7] <= 0 || !$game_switches[point[7]])
      return (point[4] && point[5] && point[6]) ? [point[4], point[5], point[6]] : nil
    end
    return nil
  end

  def refresh_fly_screen
    return if @fly_map || !Settings::CAN_FLY_FROM_TOWN_MAP || !pbCanFly?
    @sprites["help"].bitmap.clear
    #text = (@mode == 0) ? _INTL("ACTION: Fly") : _INTL("ACTION: Cancel Fly")
    #pbDrawTextPositions(
    #  @sprites["help"].bitmap,
    #  [[text, Graphics.width - 16, 4, :right, Color.new(248, 248, 248), Color.new(0, 0, 0)]]
    #)
    @sprites.each do |key, sprite|
      next if !key.include?("point")
      sprite.visible = (@mode == 1)
      sprite.frame   = 0
    end
  end

  def pbMapScene
    x_offset = 0
    y_offset = 0
    new_x    = 0
    new_y    = 0
    timer_start = System.uptime
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if x_offset != 0 || y_offset != 0
        if x_offset != 0
          @sprites["cursor"].x = lerp(new_x - x_offset, new_x, 0.1, timer_start, System.uptime)
          x_offset = 0 if @sprites["cursor"].x == new_x
        end
        if y_offset != 0
          @sprites["cursor"].y = lerp(new_y - y_offset, new_y, 0.1, timer_start, System.uptime)
          y_offset = 0 if @sprites["cursor"].y == new_y
        end
        next if x_offset != 0 || y_offset != 0
      end
      ox = 0
      oy = 0
      case Input.dir8
      when 1, 2, 3
        oy = 1 if @map_y < BOTTOM
      when 7, 8, 9
        oy = -1 if @map_y > TOP
      end
      case Input.dir8
      when 1, 4, 7
        ox = -1 if @map_x > LEFT
      when 3, 6, 9
        ox = 1 if @map_x < RIGHT
      end
      if ox != 0 || oy != 0
        @map_x += ox
        @map_y += oy
        x_offset = ox * SQUARE_WIDTH
        y_offset = oy * SQUARE_HEIGHT
        new_x = @sprites["cursor"].x + x_offset
        new_y = @sprites["cursor"].y + y_offset
        timer_start = System.uptime
      end
      @sprites["mapbottom"].maplocation = pbGetMapLocation(@map_x, @map_y)
      @sprites["mapbottom"].mapdetails  = pbGetMapDetails(@map_x, @map_y)
      if Input.trigger?(Input::BACK)
        if @editor && @changed
          pbSaveMapData if pbConfirmMessage(_INTL("Save changes?")) { pbUpdate }
          break if pbConfirmMessage(_INTL("Exit from the map?")) { pbUpdate }
        else
          break
        end
      elsif Input.trigger?(Input::USE) && @mode == 1   # Choosing an area to fly to
        healspot = pbGetHealingSpot(@map_x, @map_y)
        if healspot && ($PokemonGlobal.visitedMaps[healspot[0]] ||
           ($DEBUG && Input.press?(Input::CTRL)))
          if $game_switches[NO_TELEPORT]
            pbDialog("NO_TELEPORT")
          else
            return healspot if @fly_map
            name = pbGetMapNameFromId(healspot[0])
            return healspot if pbConfirmMessage(_INTL("Would you like to teleport to {1}?", name)) { pbUpdate }
          end
        end
      elsif Input.trigger?(Input::USE) && @editor   # Intentionally after other USE input check
        pbChangeMapLocation(@map_x, @map_y)
      #elsif Input.trigger?(Input::ACTION) && Settings::CAN_FLY_FROM_TOWN_MAP &&
      #      !@wallmap && !@fly_map && pbCanFly?
      #  pbPlayDecisionSE
      #  @mode = (@mode == 1) ? 0 : 1
      #  refresh_fly_screen
      end
    end
    pbPlayCloseMenuSE
    return nil
  end
end

#===============================================================================
#
#===============================================================================
class PokemonRegionMapScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartFlyScreen
    @scene.pbStartScene(false, true)
    ret = @scene.pbMapScene
    @scene.pbEndScene
    return ret
  end

  def pbStartScreen
    @scene.pbStartScene($DEBUG, $game_switches[HAS_TELEPORT])
    ret = @scene.pbMapScene
    @scene.pbEndScene
    return ret
  end
end

#===============================================================================
#
#===============================================================================
def pbShowMap(region = -1, wallmap = true)
  pbFadeOutIn do
    scene = PokemonRegionMap_Scene.new(region, wallmap)
    screen = PokemonRegionMapScreen.new(scene)
    ret = screen.pbStartScreen
    $game_temp.fly_destination = ret if ret && !wallmap
  end
end
