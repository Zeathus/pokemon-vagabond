def pbStairs(xOffset,yOffset)
  return false if $game_player.through
  x = $game_player.x + xOffset
  y = $game_player.y + yOffset

  facing_terrain = $game_player.pbFacingTerrainTag
  facing_stairs = (facing_terrain.stair_left || facing_terrain.stair_right || facing_terrain.stair_up)
  on_stairs = $game_map.stairs?($game_player.x,$game_player.y)
  if $game_player.direction==2 && on_stairs # Down
    return true if !$game_map.stairs?(x,y+1)
  end
  if facing_stairs
    if facing_terrain.stair_right
      if $game_player.direction==6 # Right
        $game_player.move_upper_right
        return true
      elsif $game_player.direction==4 # Left
        if !$game_map.stairs?(x,y+1)
          return true
        end
        if on_stairs
          $game_player.move_lower_left
          return true
        end
      end
    elsif facing_terrain.stair_left
      if $game_player.direction==4 # Left
        $game_player.move_upper_left
        return true
      elsif $game_player.direction==6 # Right
        if !$game_map.stairs?(x,y+1)
          return true
        end
        if on_stairs
          $game_player.move_lower_right
          return true
        end
      end
    end
  else
    if $game_map.stairsRight?($game_player.x,$game_player.y)
      if $game_player.direction==4 # Left
        $game_player.move_lower_left
        return true
      elsif $game_player.direction == 6 # Right
        if $game_map.stairsRight?($game_player.x + 1 ,$game_player.y - 1)
          $game_player.move_upper_right
          return true
        else
          return false
        end
      end
    elsif $game_map.stairsLeft?($game_player.x,$game_player.y)
      if $game_player.direction==6 # Right
        $game_player.move_lower_right
        return true
      elsif $game_player.direction==4 # Left
        if $game_map.stairsRight?($game_player.x - 1 ,$game_player.y - 1)
          $game_player.move_upper_left
          return true
        else
          return false
        end
      end
    end
  end
  return false
end 

def pbForceMoveTile
  if !$DEBUG || !Input.press?(Input::CTRL)
    force_move = $game_player.pbTerrainTag.force_move
    if force_move
      x_offset = (force_move == 4) ? -1 : (force_move == 6) ? 1 : 0
      y_offset = (force_move == 8) ? -1 : (force_move == 2) ? 1 : 0
      $game_player.direction = force_move
      if pbEndSurf(x_offset, y_offset)
        return
      elsif $game_player.can_move_in_direction?(force_move)
        $game_player.move_generic(force_move)
        return
      end
    end
  end
end