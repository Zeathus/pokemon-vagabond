def pbLargeBoulder(event_id)
  if $game_variables[RIDE_CURRENT]!=PBRides::Strength
    return
  end
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
            $scene.spriteset.addUserAnimation(DUST_ANIMATION_ID,e.x,e.y,true,e)
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
            $scene.spriteset.addUserAnimation(DUST_ANIMATION_ID,e.x,e.y,true,e)
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
            $scene.spriteset.addUserAnimation(DUST_ANIMATION_ID,e.x,e.y,true,e)
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
            $scene.spriteset.addUserAnimation(DUST_ANIMATION_ID,e.x,e.y,true,e)
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