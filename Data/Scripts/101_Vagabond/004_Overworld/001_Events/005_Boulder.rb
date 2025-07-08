def pbIsFillable(terrain_tag, has_boulder)
  return terrain_tag.boulder_fillable && ((has_boulder && terrain_tag.ledge) || !terrain_tag.ledge)
end

def pbFallInHole(type = "Boulder")
  boulder = get_self
  hole = nil
  hole_name = type + " Hole"
  for e in $game_map.events.values
    if e.name.include?(hole_name) && !$game_self_switches[[$game_map.map_id, e.id, "A"]]
      if e.x == boulder.x and e.y == boulder.y
        hole = e
        break
      end
    end
  end
  if hole
    pbSEPlay("Earth3")
    $game_self_switches[[$game_map.map_id, boulder.id, "A"]] = true
    $game_self_switches[[$game_map.map_id, e.id, "A"]] = true
    $game_map.need_refresh = true
    return true
  end
  # Tile holes (like lava)
  coords = [
    [0, -1],
    [1, -1],
    [0, 0],
    [1, 0],
    [0, 1],
    [1, 1]
  ]
  has_boulder = coords.map { |c| $game_map.data[boulder.x + c[0], boulder.y + c[1], 2] != 0 }
  tags = coords.map { |c| $game_map.terrain_tag(boulder.x + c[0], boulder.y + c[1]) }
  ledges = tags.map {|tag| tag.boulder_fillable && tag.ledge }
  fillable = (0...6).map {|i| pbIsFillable(tags[i], has_boulder[i]) }
  fill_location = nil
  direction = 0
  if fillable[2] && fillable[3] && (fillable[4] || ledges[4]) && (fillable[5] || ledges[5]) && !(has_boulder[2] && has_boulder[4]) && !(has_boulder[3] && has_boulder[5])
    # From above
    fill_location = [boulder.x, boulder.y + 1]
    direction = 2
  elsif (ledges[2] || ledges[3]) && (fillable[2] || ledges[2]) && (fillable[3] || ledges[3]) && fillable[0] && fillable[1] && !(has_boulder[0] && has_boulder[2]) && !(has_boulder[1] && has_boulder[3])
    # From below
    fill_location = [boulder.x, boulder.y]
    direction = 8
  elsif ledges[0] && ledges[2] && fillable[3] && (fillable[5] || ledges[5]) && !(has_boulder[3] && has_boulder[5])
    # From left
    neighbor_tags = [
      $game_map.terrain_tag(boulder.x + 2, boulder.y),
      $game_map.terrain_tag(boulder.x + 2, boulder.y + 1)
    ]
    neighbor_boulders = [
      $game_map.data[boulder.x + 2, boulder.y, 2] != 0,
      $game_map.data[boulder.x + 2, boulder.y + 1, 2] != 0
    ]
    if pbIsFillable(neighbor_tags[0], neighbor_boulders[0]) && pbIsFillable(neighbor_tags[1], neighbor_boulders[1]) && !(neighbor_boulders[0] && neighbor_boulders[1])
      fill_location = [boulder.x + 1, boulder.y + 1]
      direction = 4
    end
  elsif ledges[1] && ledges[3] && fillable[2] && (fillable[4] || ledges[4]) && !(has_boulder[2] && has_boulder[4])
    # From right
    neighbor_tags = [
      $game_map.terrain_tag(boulder.x - 1, boulder.y),
      $game_map.terrain_tag(boulder.x - 1, boulder.y + 1)
    ]
    neighbor_boulders = [
      $game_map.data[boulder.x - 1, boulder.y, 2] != 0,
      $game_map.data[boulder.x - 1, boulder.y + 1, 2] != 0
    ]
    if pbIsFillable(neighbor_tags[0], neighbor_boulders[0]) && pbIsFillable(neighbor_tags[1], neighbor_boulders[1]) && !(neighbor_boulders[0] && neighbor_boulders[1])
      fill_location = [boulder.x - 1, boulder.y + 1]
      direction = 6
    end
  end
  if direction != 0
    boulder.move_speed = 3
    boulder.through = true
    start_time = System.uptime
    time_now = System.uptime
    move_time = 0.4
    case direction
    when 2
      boulder.move_down
    when 4
      boulder.move_lower_right
    when 6
      boulder.move_lower_left
    end
    while time_now - start_time < move_time
      boulder.move_down if !boulder.moving? && (direction != 8 || time_now - start_time > 0.2)
      Input.update
      Graphics.update
      pbUpdateSceneMap
      boulder.force_bush_depth((44 * (time_now - start_time) / move_time).floor)
      time_now = System.uptime
    end
    boulder.force_bush_depth(44)
    boulder.through = false
  end
  if fill_location
    tiles = [
      [fill_location[0], fill_location[1] - 1],
      [fill_location[0] + 1, fill_location[1] - 1],
      [fill_location[0], fill_location[1]],
      [fill_location[0] + 1, fill_location[1]]
    ]
    for i in 0...4
      tile = tiles[i]
      hole_id = $game_map.data[tile[0], tile[1], 1]
      fill_id = $game_map.data[tile[0], tile[1], 2]
      boulder_id = [6, 7, 22, 23][i]
      if fill_id != 0
        if boulder_id % 2 != fill_id % 2
          if boulder_id == 6 || boulder_id == 23
            boulder_id = 5
          else
            boulder_id = 13
          end
        else
          boulder_id = boulder_id % 8 + 8
        end
      end
      $game_map.set_tile(tile[0], tile[1], 2, hole_id - hole_id % 24 + boulder_id)
    end
    pbSEPlay("Earth3")
    boulder.setTempSwitchOn("A")
    $game_map.need_refresh = true
    return true
  end
  return false
end

def pbTestDepth(event)
  event.through = true
  event.move_down
  start_time = System.uptime
  time_now = System.uptime
  move_time = 0.5
  while time_now - start_time < move_time
    Input.update
    Graphics.update
    pbUpdateSceneMap
    event.force_bush_depth((32 * (time_now - start_time) / move_time).floor)
    echoln (32 * (time_now - start_time) / move_time).floor.to_s
    time_now = System.uptime
  end
  event.force_bush_depth(32)
  event.through = false
end

def pbLargeBoulder(event_id)
  event = false
  holes = []
  boulders = []
  for e in $game_map.events.values
    if e.id==event_id
      event = e
    elsif e.character_name=="boulder_hole" ||
          e.character_name=="boulder_hole2"
      holes.push(e)
    elsif e.character_name=="boulder"
      boulders.push(e)
    end
  end
  if event
    x = event.x
    y = event.y
    dir = event.direction
    events = [event]
    for e in $game_map.events.values
      case event.direction
      when 2 # top left
        if ((e.direction==4 && x+1==e.x && y==e.y) ||
           (e.direction==6 && x==e.x && y+1==e.y) ||
           (e.direction==8 && x+1==e.x && y+1==e.y)) &&
           e.character_name == "boulder"# && e.through==false
          events.push(e)
        end
      when 4 # top right
        if ((e.direction==2 && x-1==e.x && y==e.y) ||
           (e.direction==6 && x-1==e.x && y+1==e.y) ||
           (e.direction==8 && x==e.x && y+1==e.y)) &&
           e.character_name == "boulder"
          events.push(e)
        end
      when 6 # bottom left
        if ((e.direction==2 && x==e.x && y-1==e.y) ||
           (e.direction==4 && x+1==e.x && y-1==e.y) ||
           (e.direction==8 && x+1==e.x && y==e.y)) &&
           e.character_name == "boulder"
          events.push(e)
        end
      when 8 # bottom right
        if ((e.direction==2 && x-1==e.x && y-1==e.y) ||
           (e.direction==4 && x==e.x && y-1==e.y) ||
           (e.direction==6 && x-1==e.x && y==e.y)) &&
           e.character_name == "boulder"
          events.push(e)
        end
      end
      if events.length == 4
        break
      end
    end
    if events.length == 4
      new_x = x
      new_y = y
      case $game_player.direction
      when 2 # down
        new_y += 2
        new_x2 = event.direction==2 ? (new_x + 1) : (new_x -1)
        return if !$game_map.passable?(new_x,new_y,$game_player.direction)
        return if !$game_map.passable?(new_x2,new_y,$game_player.direction)
        for b in boulders
          return if new_y==b.y && (new_x==b.x || new_x2==b.x)
        end
        for e in events
          if e.direction==6 || e.direction==8
            $scene.spriteset.addUserAnimation(Settings::DUST_ANIMATION_ID,e.x,e.y,true,e)
          end
          e.through=true
          e.move_down
          e.through=false
        end
        pbSEPlay("Blow6")
        pbWait(10)
      when 4 # left
        new_x -= 2
        new_y2 = event.direction==4 ? (new_y + 1) : (new_y -1)
        return if !$game_map.passable?(new_x,new_y,$game_player.direction)
        return if !$game_map.passable?(new_x,new_y2,$game_player.direction)
        for b in boulders
          return if new_x==b.x && (new_y==b.y || new_y2==b.y)
        end
        for e in events
          if e.direction==8
            $scene.spriteset.addUserAnimation(Settings::DUST_ANIMATION_ID,e.x,e.y,true,e)
          end
          e.through=true
          e.move_left
          e.through=false
        end
        pbSEPlay("Blow6")
        pbWait(10)
      when 6 # right
        new_x += 2
        new_y2 = event.direction==2 ? (new_y + 1) : (new_y -1)
        return if !$game_map.passable?(new_x,new_y,$game_player.direction)
        return if !$game_map.passable?(new_x,new_y2,$game_player.direction)
        for b in boulders
          return if new_x==b.x && (new_y==b.y || new_y2==b.y)
        end
        for e in events
          if e.direction==6
            $scene.spriteset.addUserAnimation(Settings::DUST_ANIMATION_ID,e.x,e.y,true,e)
          end
          e.through=true
          e.move_right
          e.through=false
        end
        pbSEPlay("Blow6")
        pbWait(10)
      when 8 # up
        new_y -= 2
        new_x2 = event.direction==6 ? (new_x + 1) : (new_x -1)
        return if !$game_map.passable?(new_x,new_y,$game_player.direction)
        return if !$game_map.passable?(new_x2,new_y,$game_player.direction)
        for b in boulders
          return if new_y==b.y && (new_x==b.x || new_x2==b.x)
        end
        for e in events
          if e.direction==6 || e.direction==8
            $scene.spriteset.addUserAnimation(Settings::DUST_ANIMATION_ID,e.x,e.y,true,e)
          end
          e.through=true
          e.move_up
          e.through=false
        end
        pbSEPlay("Blow6")
        pbWait(10)
      end
      fill_holes = []
      for e in events
        for h in holes
          if e.x==h.x && e.y==h.y
            fill_holes.push(h)
            break
          end
        end
      end
      if fill_holes.length == 4
        pbWait(4)
        pbSEPlay("Earth3")
        for h in fill_holes
          $game_self_switches[[$game_map.map_id,h.id,"A"]]=true
        end
        for e in events
          $game_self_switches[[$game_map.map_id,e.id,"A"]]=true
          e.erase
        end
        $game_map.need_refresh = true
      end
      return
    end
  end
  Kernel.pbMessage("Failed to find all 4 boulder event parts")
end

def pbBoulderGap
  event=get_character(0)
  oldx=event.x
  oldy=event.y
  gapx=event.x
  gapy=event.y
  case $game_player.direction
  when 2 # down
    gapy+=1
  when 4 # left
    gapx-=1
  when 6 # right
    gapx+=1
  when 8 # up
    gapy-=1
  end
  ret = false
  otherevent=nil
  for gap in $game_map.events.values
    if gap.name=="Gap"
      if gap.x == gapx && gap.y == gapy
        ret = true
        otherevent=gap
      end
    end
  end
  if ret==true
    event.through=true
    case $game_player.direction
    when 2 # down
      event.move_down
    when 4 # left
      event.move_left
    when 6 # right
      event.move_right
    when 8 # up
      event.move_up
    end
    $PokemonMap.addMovedEvent(@event_id) if $PokemonMap
    if oldx!=event.x || oldy!=event.y
      $game_player.lock
      begin
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end until !event.moving?
      $game_player.unlock
    end
    pbSetSelfSwitch(otherevent.id, "A", true)
    pbSetSelfSwitch(event.id,"A",true)
  end
  return ret
end