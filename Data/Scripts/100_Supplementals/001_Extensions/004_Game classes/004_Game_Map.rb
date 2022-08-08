class Game_Map

  alias sup_setup setup
  alias sup_refresh refresh

  def setup(map_id)
    sup_setup(map_id)
    @scroll_speed = Supplementals::FRAME_RATE_60 ? 3 : 4
  end

  def refresh
    sup_refresh
    #pbUpdateUI
    pbGetTimeNow.update if Supplementals::USE_INGAME_TIME
  end

  def waterEdge?(x, y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return true if terrain.water_edge
    end
    return false
  end
  
  def swamp?(x, y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return true if terrain.swamp_wild_encounters
    end
    return false
  end
    
  def stairs?(x, y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return true if terrain.stair_left || terrain.stair_right
    end
    return false
  end
  
  def stairsRight?(x, y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return true if terrain.stair_right
    end
    return false
  end
  
  def stairsLeft?(x, y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return true if terrain.stair_left
    end
    return false
  end
  
  def stairsUp?(x, y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return true if terrain.stair_up
    end
    return false
  end

end