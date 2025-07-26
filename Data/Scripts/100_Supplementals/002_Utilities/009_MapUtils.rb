# Set home to the bed in Plum's house
def pbSetPokemonCenterHome
  $PokemonGlobal.pokecenterMapId = 7
  $PokemonGlobal.pokecenterX = 35
  $PokemonGlobal.pokecenterY = 28
  $PokemonGlobal.pokecenterDirection = 8
end

# Set home to the bed in Plum's house
def pbSetPokemonCenterCyrus
  $PokemonGlobal.pokecenterMapId = 241
  $PokemonGlobal.pokecenterX = 12
  $PokemonGlobal.pokecenterY = 13
  $PokemonGlobal.pokecenterDirection = 8
end

# Check if player is within a given region
def pbPlayerInArea(x1, y1, x2, y2)
  if $game_player.x >= x1 && $game_player.y >= y1
    if $game_player.x <= x2 && $game_player.y <= y2
      return true
    end
  end
  return false
end

def pbPlayerNearEvent(eventid, x_min, y_min, x_max, y_max)
  event = $game_map.events[eventid]
  return false if !event
  if $game_player.x >= event.x + x_min && $game_player.y >= event.y + y_min
    if $game_player.x <= event.x + x_max && $game_player.y <= event.y + y_max
      return true
    end
  end
  return false
end

# Returns the hypotenus distance from event to player
def pbDistanceFromPlayer(eventid)
  event = nil
  for e in $game_map.events.values
    if e.id == eventid
      event = e
      break
    end
  end
  return 0 if !event
  xdif = ($game_player.x - event.x).abs * 1.0
  ydif = ($game_player.y - event.y).abs * 1.0
  distance = Math.sqrt((xdif**2)+(ydif**2))
  return distance
end

# Checks if the player is within a certain range
# in front of an event's facing direction
def pbCheckForPlayer(eventid, range, left = 1, right = 1)
  for event in $game_map.events.values
    if event.id == eventid
      direction = event.direction
      if direction == 2 # Down
        if pbPlayerInArea(event.x - right, event.y + 1,
            event.x + left, event.y + range)
          $game_self_switches[[@map_id,event.id,"A"]]=true
          $game_map.need_refresh = true
        end
      elsif direction == 4 # Left
        if pbPlayerInArea(event.x - range, event.y - right,
            event.x - 1, event.y + left)
          $game_self_switches[[@map_id,event.id,"A"]]=true
          $game_map.need_refresh = true
        end
      elsif direction == 6 # Right
        if pbPlayerInArea(event.x + 1, event.y - left,
            event.x + range, event.y + right)
          $game_self_switches[[@map_id,event.id,"A"]]=true
          $game_map.need_refresh = true
        end
      elsif direction == 8 # Up
        if pbPlayerInArea(event.x - left, event.y - range,
            event.x + right, event.y - 1)
          $game_self_switches[[@map_id,event.id,"A"]]=true
          $game_map.need_refresh = true
        end
      end
    end
  end
end

# Checks if an event can move in a certain direction
def pbCheckPassableId(eventid, direction)
  x = 0
  y = 0
  for event in $game_map.events.values
    if event.id == eventid
      x = event.x
      y = event.y
    end
  end

  if direction == 0
    return false
  elsif direction == "left" # Left
    if $game_map.passable?(x - 1, y, 0)
      return true
    else
      return false
    end
  elsif direction == "right" # Right
    if $game_map.passable?(x + 1, y, 0)
      return true
    else
      return false
    end
  elsif direction == "up" # Up
    if $game_map.passable?(x, y - 1, 0)
      return true
    else
      return false
    end
  elsif direction == "down" # Down
    if $game_map.passable?(x, y + 1, 0)
      return true
    else
      return false
    end
  end
end

def pbMapFile(map_id, compressed=false)
  if compressed
    return sprintf("Data/CompressedMaps/Map%03d.rxdata", map_id)
  end
  return sprintf("Data/Map%03d.rxdata", map_id)
end

def pbMapCentered?
  screen_offset_x = (Graphics.width - Game_Map::TILE_WIDTH) * Game_Map::X_SUBPIXELS / 2
  screen_offset_y = (Graphics.height - Game_Map::TILE_HEIGHT) * Game_Map::Y_SUBPIXELS / 2
  current_tile_x = ($game_map.display_x + screen_offset_x) / Game_Map::REAL_RES_X
  current_tile_y = ($game_map.display_y + screen_offset_y) / Game_Map::REAL_RES_Y
  return (current_tile_x == $game_player.x && current_tile_y == $game_player.y)
end