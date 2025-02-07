################################################################################
# List of Habitats to display on the list, and the maps they contain
################################################################################
def pbGetHabitatList
  return [
    ["Crosswoods Area", :Crosswoods, :HalcyonForest, :HalcyonClearing],
    ["Breccia Area", :BrecciaUndergrowth, :BrecciaTrail],
    ["Evergone Mangrove", :EvergoneMangrove, :EvergoneCrater, :EvergoneHill, :EvergoneStairway],
    ["Lapis Lazuli Area", :LazuliRiver, :LapisDistrict, :LapisLazuliPark],
    ["Mt. Pegma Area", :FeldsparDistrict, :QuartzPassing, :MtPegmaHillside, :PegmaFalls],
    ["Mt. Pegma Interior", :MtPegma1F, :MtPegma2F, :MtPegma3F, :MtPegmaB1F],
    ["Pegma Quarry", :MicaQuarryB1F, :MicaQuarryB2F, :MicaQuarryB3F, :MicaQuarryB4F, :MicaQuarryB5F],
    ["Scoria Area", :ScoriaCity, :ScoriaCanyon, :ScoriaDesert, :ScoriaDesertUnder, :ScoriaDesertPass],
    ["East Sea Area", :CentralEastSea]
  ]
end
  
def pbGetHabitatListReward(area)
  
  rewards = [
    ["Andes Isles", :AQUATAIL],
    ["Breccia Area", :GIGADRAIN],
    ["Canjon Valley", :DOUBLEEDGE],
    ["Crosswoods", :ELECTROWEB],
    ["Evergone Mangrove", :AMNESIA],
    ["Lazuli Area", :WATERPULSE],
    ["Mica Quarry", :ENDURE],
    ["Mica Quarry Deep", :CURSE],
    ["Mt. Pegma Area", :IRONDEFENSE],
    ["Mt. Pegma Interior", :IRONTAIL],
    ["Quartz Area", :BOUNCE],
    ["Shale Area", :DESTINYBOND],
    ["Smokey Forest", :DEFOG],
    ["Tuff Area", :COUNTER]
  ]
    
  for i in rewards
    if i[0] == area
      return [1]
    end
  end
  
  return false
  
end

def pbGetHabitatAreaCompletion
  habitats = pbGetHabitatList
  complete = {}
  habitats.each do |habitat|
    completed = true
    for i in 1...habitat.length
      map = habitat[i]
      map = getID(PBMaps,map) if map.is_a?(Symbol)

      encounter_data = GameData::Encounter.get(map, $PokemonGlobal.encounter_version)
      encounters = Marshal.load(Marshal.dump(encounter_data.types))

      encounters.each_value do |encounter_type|
        encounter_type.each do |pokemon|
          species = pokemon[1]
          if !$player.owned?(species)
            completed = false
            break
          end
        end
        break if !completed
      end
      break if !completed
    end
    if completed
      complete[habitat[0]] = true
    end
  end
  return complete
end

def pbGetHabitatMapCompletion
  habitats = pbGetHabitatList
  complete = {}
  habitats.each do |habitat|
    for i in 1...habitat.length
      map = habitat[i]
      map = getID(PBMaps,map) if map.is_a?(Symbol)

      encounter_data = GameData::Encounter.get(map, $PokemonGlobal.encounter_version)
      encounters = Marshal.load(Marshal.dump(encounter_data.types))

      completed = true
      encounters.each_value do |encounter_type|
        encounter_type.each do |pokemon|
          species = pokemon[1]
          if !$player.owned?(species)
            completed = false
            break
          end
        end
        break if !completed
      end
      if completed
        complete[map] = true
      end
    end
  end
  return complete
end

def pbGetHabitatAreaHookedCompletion
  habitats = pbGetHabitatList
  complete = {}
  habitats.each do |habitat|
    completed = nil
    for i in 1...habitat.length
      map = habitat[i]
      map = getID(PBMaps,map) if map.is_a?(Symbol)

      encounter_data = GameData::Encounter.get(map, $PokemonGlobal.encounter_version)
      encounters = Marshal.load(Marshal.dump(encounter_data.types))

      next if !encounters.key?(:FishingRod)

      completed = true if completed.nil?
      encounters[:FishingRod].each do |pokemon|
        species = pokemon[1]
        if !pbJob("Fisher").hooked?(species)
          completed = false
          break
        end
      end
      break if !completed
    end
    complete[habitat[0]] = completed if !completed.nil?
  end
  return complete
end

def pbGetHabitatMapHookedCompletion
  habitats = pbGetHabitatList
  complete = {}
  habitats.each do |habitat|
    for i in 1...habitat.length
      map = habitat[i]
      map = getID(PBMaps,map) if map.is_a?(Symbol)

      encounter_data = GameData::Encounter.get(map, $PokemonGlobal.encounter_version)
      encounters = Marshal.load(Marshal.dump(encounter_data.types))

      next if !encounters.key?(:FishingRod)

      completed = true
      encounters[:FishingRod].each do |pokemon|
        species = pokemon[1]
        if !pbJob("Fisher").hooked?(species)
          completed = false
          break
        end
      end
      complete[map] = completed
    end
  end
  return complete
end

def pbCheckHabitatRewards
  $game_variables[HABITAT_REWARDS] = {} if !$game_variables[HABITAT_REWARDS].is_a?(Hash)
  obtained = $game_variables[HABITAT_REWARDS]

  newly_obtained = []
  pbGetHabitatAreaCompletion.each do |area|
    if area[1] && !obtained[area[0]]
      newly_obtained.push(area[0])
      obtained[area[0]] = true
    end
  end

  if newly_obtained.length > 0
    pbDialog("GPO_HABITAT_DEX",7)
    newly_obtained.each do |area|
      $game_variables[1] = _INTL(area)
      pbDialog("GPO_HABITAT_DEX",8)
    end
    pbDialog("GPO_HABITAT_DEX",9)
    pbReceiveItem(:DATACHIP, newly_obtained.length * 2)
  else
    pbDialog("GPO_HABITAT_DEX",6)
  end

  $game_variables[HABITAT_REWARDS] = obtained
end
  
################################################################################
# Shows the "Nest" page of the Pokédex entry screen.
################################################################################
class PokemonHabitatMapScene
  LEFT          = 0
  TOP           = 0
  RIGHT         = 29
  BOTTOM        = 19
  SQUARE_WIDTH  = 16
  SQUARE_HEIGHT = 16

  ALL_ENCOUNTER_TYPES_ORDER = [
      :Land, :Land2, :Land3, :Land4,
      :LandMorning, :LandDay, :LandAfternoon, :LandEvening, :LandNight,
      :Flowers, :Swamp,
      :Cave, :CaveMorning, :CaveDay, :CaveAfternoon, :CaveEvening, :CaveNight,
      :Water, :WaterMorning, :WaterDay, :WaterAfternoon, :WaterEvening, :WaterNight,
      :FishingRod
  ]

  ENCOUNTER_TYPE_DEFAULT_NAME = {
      :Land => "Grass",
      :Land2 => "Grass Alt. 1",
      :Land3 => "Grass Alt. 2",
      :Land4 => "Grass Alt. 3",
      :LandMorning => "Morning",
      :LandDay => "Daytime",
      :LandAfternoon => "Afternoon",
      :LandEvening => "Evening",
      :LandNight => "Night",
      :Flowers => "Flowers",
      :Swamp => "Swamp",
      :Cave => "Cave",
      :CaveMorning => "Morning",
      :CaveDay => "Daytime",
      :CaveAfternoon => "Afternoon",
      :CaveEvening => "Evening",
      :CaveNight => "Nighttime",
      :Water => "Surfing",
      :WaterMorning => "Morning",
      :WaterDay => "Daytime",
      :WaterAfternoon => "Afternoon",
      :WaterEvening => "Evening",
      :WaterNight => "Nighttime",
      :FishingRod => "Fishing"
  }

  ENCOUNTER_TYPE_ALTERNATE_NAMES = {
      [:Crosswoods, :Land] => "North Grass",
      [:Crosswoods, :Land2] => "West Grass",
      [:Crosswoods, :Land3] => "East Grass",
      [:Crosswoods, :Land4] => "South Grass",
      [:HalcyonForest, :Land2] => "Special",
      [:LazuliRiver, :Land] => "East Grass",
      [:LazuliRiver, :Land2] => "West Grass",
      [:LazuliRiver, :Land3] => "Near Ruins",
      [:ScoriaCanyon, :Land2] => "Rocky Turf",
      [:ScoriaDesert, :Land2] => "Dark Sand",
  }

  def pbStartScene(species, region = -1)
    @region = region
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    map_metadata = $game_map.metadata
    playerpos = (map_metadata) ? map_metadata.town_map_position : nil
    if !playerpos
      mapindex = 0
      @map     = GameData::TownMap.get(0)
      @map_x   = LEFT
      @map_y   = TOP
      @region = 0 if @region < 0
    elsif @region >= 0 && @region != playerpos[0] && GameData::TownMap.exists?(@region)
      mapindex = @region
      @region  = playerpos[0]
      @map     = GameData::TownMap.get(@region)
    else
      mapindex = playerpos[0]
      @map     = GameData::TownMap.get(playerpos[0])
      @map_x    = playerpos[1]
      @map_y    = playerpos[2]
      mapsize = map_metadata.town_map_size
      if mapsize && mapsize[0] && mapsize[0] > 0
        sqwidth  = mapsize[0]
        sqheight = (mapsize[1].length.to_f / mapsize[0]).ceil
        @map_x += ($game_player.x * sqwidth / $game_map.width).floor if sqwidth > 1
        @map_y += ($game_player.y * sqheight / $game_map.height).floor if sqheight > 1
      end
    end
    @areas_all_caught = pbGetHabitatAreaCompletion
    @areas_all_hooked = pbGetHabitatAreaHookedCompletion
    @maps_all_caught = pbGetHabitatMapCompletion
    @maps_all_hooked = pbGetHabitatMapHookedCompletion
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(_INTL("Graphics/UI/Pokedex/habitat"))
    @sprites["overlay"]=IconSprite.new(0,0,@viewport)
    @sprites["overlay"].setBitmap(_INTL("Graphics/UI/Pokedex/habitat_overlay"))
    @sprites["overlay"].z=99
    @sprites["frame"]=IconSprite.new(0,0,@viewport)
    @sprites["frame"].setBitmap(_INTL("Graphics/UI/Pokedex/habitat_frame"))
    @sprites["frame"].z=103
    @sprites["pokemonlist"]=IconSprite.new(0,0,@viewport)
    @sprites["pokemonlist"].setBitmap(_INTL("Graphics/UI/Pokedex/habitat_list"))
    @sprites["pokemonlist"].z=99
    @sprites["pokemonlist"].visible=false
    @sprites["pokemonlist2"]=Sprite.new(@viewport)
    @sprites["pokemonlist2"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @sprites["pokemonlist2"].z=101
    @sprites["pokemonlist2"].visible=false
    @sprites["map"]=IconSprite.new(0,0,@viewport)
    @sprites["map"].setBitmap("Graphics/UI/Town Map/#{@map.filename}")
    @sprites["map"].x = 276
    @sprites["map"].y = (Graphics.height - @sprites["map"].bitmap.height) / 2
    @sprites["map_highlight"] = Sprite.new(@viewport)
    @sprites["map_highlight"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
    @sprites["map_highlight"].z = 102
    @sprites["list_player"] = IconSprite.new(0, 0, @viewport)
    @sprites["list_player"].setBitmap(GameData::TrainerType.map_icon_filename(:PROTAGONIST))
    @sprites["list_player"].visible = false
    @sprites["list_player"].z = 107
    @map_highlight_timer = 16
    Settings::REGION_MAP_EXTRAS.each do |graphic|
      next if graphic[0] != mapindex || !location_shown?(graphic)
      if !@sprites["map2"]
        @sprites["map2"] = BitmapSprite.new(480, 320, @viewport)
        @sprites["map2"].x = @sprites["map"].x
        @sprites["map2"].y = @sprites["map"].y
      end
      pbDrawImagePositions(
        @sprites["map2"].bitmap,
        [["Graphics/UI/#{graphic[4]}", graphic[2] * SQUARE_WIDTH, graphic[3] * SQUARE_HEIGHT]]
      )
    end
    @index = 0
    @scroll = 0
    @player_habitat_area = -1
    @player_habitat_subarea = -1
    habitats = pbGetHabitatList
    @habitatlist=[]
    for i in 0...habitats.length
      habitat = habitats[i]
      added = false
      for j in 1...habitat.length
        mapid = habitat[j]
        mapid = getID(PBMaps,mapid) if mapid.is_a?(Symbol)
        if !added && $PokemonGlobal.visitedMaps[mapid]
          @habitatlist.push(habitat)
          added = true
        end
        if $game_map.map_id == mapid
          @index = @habitatlist.length - 1
          @player_habitat_area = i
          @player_habitat_subarea = j
          @sprites["list_player"].visible = true
        end
      end
    end
    @sprites["maplist"]=Sprite.new(@viewport)
    @sprites["maplist"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
    @sprites["maplist"].z=100
    @sprites["rightarrow"]=AnimatedSprite.new("Graphics/UI/right_arrow",8,40,28,2,@viewport)
    @sprites["rightarrow"].z=200
    @sprites["rightarrow"].play
    @sprites["rightarrowenc"]=AnimatedSprite.new("Graphics/UI/right_arrow",8,40,28,2,@viewport)
    @sprites["rightarrowenc"].z=201
    @sprites["rightarrowenc"].visible=false
    @sprites["rightarrowenc"].play
    @sprites["leftarrowenc"]=AnimatedSprite.new("Graphics/UI/left_arrow",8,40,28,2,@viewport)
    @sprites["leftarrowenc"].z=201
    @sprites["leftarrowenc"].visible=false
    @sprites["leftarrowenc"].play
    for i in 0...7
      @sprites[_INTL("pokeicon_{1}", i)] = IconSprite.new(356 + 66 * i, 80, @viewport)
      @sprites[_INTL("pokeicon_{1}", i)].src_rect = Rect.new(0, 0, 64, 64)
      @sprites[_INTL("pokeicon_{1}", i)].z = 100
      @sprites[_INTL("pokeicon_{1}", i)].visible = false
    end
    pbDrawMapList
    pbDrawAreaLocations
    @sprites["mapbottom"]=MapBottomSprite.new(@viewport)
    @sprites["mapbottom"].maplocation=@map.name
    @sprites["mapbottom"].mapdetails=_INTL("")
    return true
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

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    @map_highlight_timer += 1
    if @map_highlight_timer < 32
      @sprites["map_highlight"].opacity = @map_highlight_timer * 4
    else
      @sprites["map_highlight"].opacity = (64 - @map_highlight_timer) * 4
      @map_highlight_timer = 0 if @map_highlight_timer > 64
    end
  end
  
  def pbDrawMapList
    @sprites["list_player"].visible = false
    textpos = []
    imagepos = []
    for i in @scroll...@scroll+16
      offset=(i-@scroll)*32
      if @habitatlist[i]
        area_name = @habitatlist[i][0]
        textpos.push([area_name,36,40+offset,:left,
          Color.new(24,24,24),Color.new(184,184,184)])
        icon_x_pos = 314
        if @areas_all_caught[area_name]
          imagepos.push([sprintf("Graphics/UI/Pokedex/icon_own"),
            icon_x_pos,34 + offset,0,0,-1,-1])
        else
          imagepos.push([sprintf("Graphics/UI/Pokedex/icon_own_blank"),
            icon_x_pos,34 + offset,0,0,-1,-1])
        end
        icon_x_pos -= 28
        if @areas_all_hooked.key?(area_name)
          if @areas_all_hooked[area_name]
            imagepos.push([sprintf("Graphics/UI/Pokedex/icon_hooked"),
              icon_x_pos,34 + offset,0,0,-1,-1])
          else
            imagepos.push([sprintf("Graphics/UI/Pokedex/icon_hooked_blank"),
              icon_x_pos,34 + offset,0,0,-1,-1])
          end
          icon_x_pos -= 28
        end
        if i == @player_habitat_area
          @sprites["list_player"].x = icon_x_pos
          @sprites["list_player"].y = 32 + offset
          @sprites["list_player"].visible = true
        end
      end
    end
    @sprites["maplist"].bitmap.clear
    pbSetSystemFont(@sprites["maplist"].bitmap)
    pbDrawTextPositions(@sprites["maplist"].bitmap,textpos)
    pbDrawImagePositions(@sprites["maplist"].bitmap,imagepos)
    @sprites["rightarrow"].x = 0
    @sprites["rightarrow"].y = 34 + 32*(@index-@scroll)
  end
  
  def pbDrawSubMapList
    @sprites["list_player"].visible = false
    textpos = []
    textpos.push([@habitatlist[@index][0],180,40,:center,
          Color.new(24,24,24),Color.new(184,184,184)])
    imagepos = []
    arealist = @habitatlist[@index]
    namebug = false
    for i in 1...@habitatlist[@index].length
      offset=(i)*32
      if @habitatlist[i]
        mapid=arealist[i]
        mapid=getID(PBMaps,mapid) if mapid.is_a?(Symbol)
        mapname=pbGetMapNameFromId(mapid)
        mapname="-----" if !$PokemonGlobal.visitedMaps[mapid]
        if mapname != "-----" && false && rand(50)==0
          mapname = "NULL"
          namebug = true
        end
        textpos.push([mapname,36,40+offset,:left,
          Color.new(24,24,24),Color.new(184,184,184)])
        icon_x_pos = 314
        if @maps_all_caught[mapid]
          imagepos.push([sprintf("Graphics/UI/Pokedex/icon_own"),
            icon_x_pos,34 + offset,0,0,-1,-1])
        else
          imagepos.push([sprintf("Graphics/UI/Pokedex/icon_own_blank"),
            icon_x_pos,34 + offset,0,0,-1,-1])
        end
        icon_x_pos -= 28
        if @maps_all_hooked.key?(mapid)
          if @maps_all_hooked[mapid]
            imagepos.push([sprintf("Graphics/UI/Pokedex/icon_hooked"),
              icon_x_pos,34 + offset,0,0,-1,-1])
          else
            imagepos.push([sprintf("Graphics/UI/Pokedex/icon_hooked_blank"),
              icon_x_pos,34 + offset,0,0,-1,-1])
          end
          icon_x_pos -= 28
        end
        if @index == @player_habitat_area && i == @player_habitat_subarea
          @sprites["list_player"].x = icon_x_pos
          @sprites["list_player"].y = 32 + offset
          @sprites["list_player"].visible = true
        end
      end
    end
    @sprites["maplist"].bitmap.clear
    if namebug
      pbSetSmallFont(@sprites["maplist"].bitmap)
      pbDrawTextPositions(@sprites["maplist"].bitmap,
        [["Failed to load String 'mapname'",Graphics.width - 8,6,:right,
        Color.new(0,255,0),Color.new(0,155,0,0)]])
    end
    pbSetSystemFont(@sprites["maplist"].bitmap)
    pbDrawTextPositions(@sprites["maplist"].bitmap,textpos)
    pbDrawImagePositions(@sprites["maplist"].bitmap,imagepos)
    @sprites["rightarrow"].x = 0
    @sprites["rightarrow"].y = 34 + 32*(@subindex+1)
  end
  
  def pbDrawPokemonList
    mapsym = @habitatlist[@index][@subindex+1]
    mapid = mapsym
    mapid = getID(PBMaps,mapid) if mapid.is_a?(Symbol)

    @sprites["pokemonlist2"].bitmap.clear
    if !$PokemonGlobal.visitedMaps[mapid]
      pbSetSystemFont(@sprites["pokemonlist2"].bitmap)
      pbDrawTextPositions(@sprites["pokemonlist2"].bitmap,[
        ["You have not been",550,120,:center,
        Color.new(24,24,24),Color.new(184,184,184)],
        ["to this area yet",550,150,:center,
        Color.new(24,24,24),Color.new(184,184,184)]])
      return
    end
    
    if @encounter_types.length > 1
      @sprites["rightarrowenc"].x=Graphics.width - 32
      @sprites["rightarrowenc"].y=38
      @sprites["leftarrowenc"].x=334
      @sprites["leftarrowenc"].y=38
      @sprites["rightarrowenc"].visible=true
      @sprites["leftarrowenc"].visible=true
    else
      @sprites["rightarrowenc"].visible=false
      @sprites["leftarrowenc"].visible=false
    end
    
    imagepos = []
    textpos = []
    smalltextpos=[]
    
    for i in 0...[@encounter_types.length, 9].min
      type = @encounter_types[(@encounter_type_index + i) % @encounter_types.length]
      imagepos.push([_INTL("Graphics/UI/Pokedex/habitat_type_{1}",type.downcase),
        490 + i * 38, 36, 0, 0, -1, -1])
    end

    y = 42
    pbSetSystemFont(@sprites["pokemonlist2"].bitmap)
    if @encounters[@encounter_type]
      encounter_type_name = ENCOUNTER_TYPE_DEFAULT_NAME[@encounter_type]
      if ENCOUNTER_TYPE_ALTERNATE_NAMES.key?([mapsym, @encounter_type])
        encounter_type_name = ENCOUNTER_TYPE_ALTERNATE_NAMES[[mapsym, @encounter_type]]
      end
      x = 356
      textpos.push([encounter_type_name,426,y,:center,
        Color.new(24,24,24),Color.new(184,184,184)])
      y += 24
      encounter_index = 0
      for encounter in @encounters[@encounter_type]
        chance = encounter[0]
        species = encounter[1]
        form = (encounter.length <= 4) ? 0 : encounter[4]
        @sprites[_INTL("pokeicon_{1}", encounter_index)].setBitmap(GameData::Species.icon_filename(species, form))
        icon_bitmap = @sprites[_INTL("pokeicon_{1}", encounter_index)].bitmap
        @sprites[_INTL("pokeicon_{1}", encounter_index)].src_rect = Rect.new(0, 0, icon_bitmap.width / 2, icon_bitmap.height)
        @sprites[_INTL("pokeicon_{1}", encounter_index)].visible = true
        if $player.seen?(species)
          @sprites[_INTL("pokeicon_{1}", encounter_index)].color = Color.new(0, 0, 0, 0)
        else
          @sprites[_INTL("pokeicon_{1}", encounter_index)].color = Color.new(0, 0, 0)
        end

        if @encounter_type == :FishingRod && pbJob("Fisher").hooked?(species) && $player.owned?(species)
          imagepos.push([sprintf("Graphics/UI/Pokedex/icon_own"),
            x+30,y+102,0,0,-1,-1])
          imagepos.push([sprintf("Graphics/UI/Pokedex/icon_hooked"),
            x+2,y+102,0,0,-1,-1])
        elsif $player.owned?(species)
          imagepos.push([sprintf("Graphics/UI/Pokedex/icon_own"),
            x+16,y+102,0,0,-1,-1])
        elsif @encounter_type == :FishingRod && pbJob("Fisher").hooked?(species)
          imagepos.push([sprintf("Graphics/UI/Pokedex/icon_hooked"),
            x+16,y+102,0,0,-1,-1])
        end
        smalltextpos.push([_INTL("{1}%",chance),x+32,y+80,:center,
          Color.new(24,24,24),Color.new(184,184,184)])
        x += 66
        encounter_index += 1
      end
    end
    
    pbDrawImagePositions(@sprites["pokemonlist2"].bitmap,imagepos)
    pbSetSystemFont(@sprites["pokemonlist2"].bitmap)
    pbDrawTextPositions(@sprites["pokemonlist2"].bitmap,textpos)
    pbSetSmallFont(@sprites["pokemonlist2"].bitmap)
    pbDrawTextPositions(@sprites["pokemonlist2"].bitmap,smalltextpos)
    
  end
  
  def pbDrawMapLocation
    @map_highlight_timer = 16
    overlay = @sprites["map_highlight"].bitmap
    overlay.clear
    @sprites["map_highlight"].x = @sprites["map"].x
    @sprites["map_highlight"].y = @sprites["map"].y

    mapid = @habitatlist[@index][@subindex + 1]
    mapid = getID(PBMaps,mapid) if mapid.is_a?(Symbol)
    mapdata = GameData::MapMetadata.get(mapid)
    mappos = mapdata&.town_map_position
    mapsize = mapdata&.town_map_size || [1, "1"]
    if mappos && mappos[0] == @region
      for j in 0...mapsize[1].length
        if mapsize[1][j] == "1"
          overlay.fill_rect(
            (mappos[1] + (j % mapsize[0])) * SQUARE_WIDTH - 4,
            (mappos[2] + (j / mapsize[0]).floor) * SQUARE_HEIGHT - 4,
            SQUARE_WIDTH + 8,
            SQUARE_HEIGHT + 8,
            Color.new(255, 0, 0))
        end
      end
    else
      echoln _INTL("No map position for map {1} ({2})", mapid, @habitatlist[@index][i].to_s)
    end
  end
  
  def pbDrawAreaLocations
    @map_highlight_timer = 16
    overlay = @sprites["map_highlight"].bitmap
    overlay.clear
    @sprites["map_highlight"].x = @sprites["map"].x
    @sprites["map_highlight"].y = @sprites["map"].y

    for i in 1...@habitatlist[@index].length
      mapid = @habitatlist[@index][i]
      mapid = getID(PBMaps,mapid) if mapid.is_a?(Symbol)
      mapdata = GameData::MapMetadata.get(mapid)
      mappos = mapdata&.town_map_position
      mapsize = mapdata&.town_map_size || [1, "1"]
      if mappos && mappos[0] == @region
        for j in 0...mapsize[1].length
          if mapsize[1][j] == "1"
            overlay.fill_rect(
              (mappos[1] + (j % mapsize[0])) * SQUARE_WIDTH - 4,
              (mappos[2] + (j / mapsize[0]).floor) * SQUARE_HEIGHT - 4,
              SQUARE_WIDTH + 8,
              SQUARE_HEIGHT + 8,
              Color.new(255, 0, 0))
          end
        end
      else
        echoln _INTL("No map position for map {1} ({2})", mapid, @habitatlist[@index][i].to_s)
      end
    end
  end

  def pbLoadEncounters
    mapid = @habitatlist[@index][@subindex+1]
    mapid = getID(PBMaps,mapid) if mapid.is_a?(Symbol)
    encounter_data = GameData::Encounter.get(mapid, $PokemonGlobal.encounter_version)
    @encounters = Marshal.load(Marshal.dump(encounter_data.types))

    @encounter_types = []
    ALL_ENCOUNTER_TYPES_ORDER.each do |e|
      @encounter_types.push(e) if @encounters.key?(e)
    end
    
    if @encounter_types.include?(@encounter_type)
      @encounter_type_index = @encounter_types.index(@encounter_type)
    else
      @encounter_type = @encounter_types[0]
      @encounter_type_index = 0
    end
  end

  def pbMapScene
    Graphics.transition
    ret=0
    refresh=true
    subview=false
    @subindex = 0
    @encounter_type = nil
    @encounter_type_index = 0
    pbLoadEncounters
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.repeat?(Input::UP)
        pbPlayCursorSE()
        if !subview
          @index-=1
          @scroll-=1 if @index - @scroll < 0
          if @index<0
            @index=@habitatlist.length-1
            @scroll=@habitatlist.length-16
            @scroll=0 if @scroll<0
          end
        else
          @subindex-=1
          if @subindex<0
            @subindex=@habitatlist[@index].length-2
          end
          pbLoadEncounters
        end
        refresh=true
      elsif Input.repeat?(Input::DOWN)
        pbPlayCursorSE()
        if !subview
          @index+=1
          @scroll+=1 if @index - @scroll > 15
          if @index>@habitatlist.length-1
            @index=0
            @scroll=0
          end
        else
          @subindex+=1
          if @subindex>@habitatlist[@index].length-2
            @subindex=0
          end
          pbLoadEncounters
        end
        refresh=true
      elsif Input.repeat?(Input::LEFT)
        if subview
          pbPlayCursorSE()
          @encounter_type_index = (@encounter_type_index - 1) % @encounter_types.length
          @encounter_type = @encounter_types[@encounter_type_index]
        end
        refresh=true
      elsif Input.repeat?(Input::RIGHT)
        if subview
          pbPlayCursorSE()
          @encounter_type_index = (@encounter_type_index + 1) % @encounter_types.length
          @encounter_type = @encounter_types[@encounter_type_index]
        end
        refresh=true
      elsif Input.trigger?(Input::B)
        if subview
          subview=false
          @sprites["pokemonlist"].visible=false
          @sprites["pokemonlist2"].visible=false
          @sprites["rightarrowenc"].visible=false
          @sprites["leftarrowenc"].visible=false
          pbPlayCancelSE()
          refresh=true
        else
          ret=1
          pbPlayCloseMenuSE()
          pbFadeOutAndHide(@sprites)
          break
        end
      elsif Input.trigger?(Input::C)
        if !subview
          pbPlayDecisionSE()
          subview=true
          if @index == @player_habitat_area
              @subindex = @player_habitat_subarea - 1
          else
              @subindex = 0
          end
          @sprites["pokemonlist"].visible=true
          @sprites["pokemonlist2"].visible=true
          pbLoadEncounters
          refresh=true
        end
      end
      if refresh
        refresh=false
        for i in 0...7
          @sprites[_INTL("pokeicon_{1}", i)].visible = false
        end
        if !subview
          @sprites["map"].y = (Graphics.height - @sprites["map"].bitmap.height) / 2
          pbDrawMapList
          pbDrawAreaLocations
        else
          @sprites["map"].y = Graphics.height - @sprites["map"].bitmap.height - 32
          pbDrawSubMapList
          pbDrawPokemonList
          pbDrawMapLocation
        end
      end
    end
    return ret
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonHabitatMap
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    species=4
    region=pbGetCurrentRegion
    @scene.pbStartScene(species,region)
    ret=@scene.pbMapScene
    @scene.pbEndScene
    return ret
  end
end