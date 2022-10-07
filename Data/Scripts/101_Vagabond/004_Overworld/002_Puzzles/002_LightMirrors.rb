def pbRedirectLight(direction, eventname)
  for event in $game_map.events.values
      if event.name == "Beam"
        $game_self_switches[[@map_id,event.id,"A"]]=false
        $game_self_switches[[@map_id,event.id,"B"]]=false
        $game_self_switches[[@map_id,event.id,"C"]]=false
      elsif event.name == "Flower"
        $game_self_switches[[@map_id,event.id,"A"]]=false
      elsif event.name == "Leaf"
        $game_self_switches[[@map_id,event.id,"A"]]=false
        $game_self_switches[[@map_id,event.id,"B"]]=false
      elsif event.name == eventname
        mirror = event
      end
    end
  if direction == "auto"
    switchA = $game_self_switches[[@map_id,mirror.id,"A"]]
    switchB = $game_self_switches[[@map_id,mirror.id,"B"]]
    switchC = $game_self_switches[[@map_id,mirror.id,"C"]]
    switchD = $game_self_switches[[@map_id,mirror.id,"D"]]
    if switchA
      direction = "up"
    elsif switchB
      direction = "left"
    elsif switchC
      direction = "right"
    elsif switchD
      direction = "down"
    end
  end
  if direction == "up"
    for event in $game_map.events.values
      if mirror.y > event.y && mirror.x == event.x && event.name == "Beam"
        $game_self_switches[[@map_id,event.id,"B"]]=true
      elsif mirror.y > event.y && mirror.x == event.x && event.name == "Leaf"
        $game_self_switches[[@map_id,event.id,"B"]]=true
      elsif mirror.y > event.y && mirror.x == event.x && event.name == "Flower"
        $game_self_switches[[@map_id,event.id,"A"]]=true
        for event2 in $game_map.events.values
          if event2.x - 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x + 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y - 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y + 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          end
        end
      end
      if mirror.y > event.y && mirror.x == event.x && event.name.include?('Mirror')
        switchA = $game_self_switches[[@map_id,event.id,"A"]]
        switchB = $game_self_switches[[@map_id,event.id,"B"]]
        switchC = $game_self_switches[[@map_id,event.id,"C"]]
        switchD = $game_self_switches[[@map_id,event.id,"D"]]
        if switchA
          pbMirrorLight("up", event.name)
        elsif switchB
          pbMirrorLight("left", event.name)
        elsif switchC
          pbMirrorLight("right", event.name)
        elsif switchD
          pbMirrorLight("down", event.name)
        end
      end
    end
  elsif direction == "left"
    for event in $game_map.events.values
      if mirror.y == event.y && mirror.x > event.x && event.name == "Beam"
        $game_self_switches[[@map_id,event.id,"A"]]=true
      elsif mirror.y == event.y && mirror.x > event.x && event.name == "Leaf"
        $game_self_switches[[@map_id,event.id,"B"]]=true
      elsif mirror.y == event.y && mirror.x > event.x && event.name == "Flower"
        $game_self_switches[[@map_id,event.id,"A"]]=true
        for event2 in $game_map.events.values
          if event2.x - 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x + 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y - 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y + 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          end
        end
      end
      if mirror.y == event.y && mirror.x > event.x && event.name.include?('Mirror')
        switchA = $game_self_switches[[@map_id,event.id,"A"]]
        switchB = $game_self_switches[[@map_id,event.id,"B"]]
        switchC = $game_self_switches[[@map_id,event.id,"C"]]
        switchD = $game_self_switches[[@map_id,event.id,"D"]]
        if switchA
          pbMirrorLight("up", event.name)
        elsif switchB
          pbMirrorLight("left", event.name)
        elsif switchC
          pbMirrorLight("right", event.name)
        elsif switchD
          pbMirrorLight("down", event.name)
        end
      end
    end
  elsif direction == "right"
    for event in $game_map.events.values
      if mirror.y == event.y && mirror.x < event.x && event.name == "Beam"
        $game_self_switches[[@map_id,event.id,"A"]]=true
      elsif mirror.y == event.y && mirror.x < event.x && event.name == "Leaf"
        $game_self_switches[[@map_id,event.id,"B"]]=true
      elsif mirror.y == event.y && mirror.x < event.x && event.name == "Flower"
        $game_self_switches[[@map_id,event.id,"A"]]=true
        for event2 in $game_map.events.values
          if event2.x - 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x + 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y - 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y + 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          end
        end
      end
      if mirror.y == event.y && mirror.x < event.x && event.name.include?('Mirror')
        switchA = $game_self_switches[[@map_id,event.id,"A"]]
        switchB = $game_self_switches[[@map_id,event.id,"B"]]
        switchC = $game_self_switches[[@map_id,event.id,"C"]]
        switchD = $game_self_switches[[@map_id,event.id,"D"]]
        if switchA
          pbMirrorLight("up", event.name)
        elsif switchB
          pbMirrorLight("left", event.name)
        elsif switchC
          pbMirrorLight("right", event.name)
        elsif switchD
          pbMirrorLight("down", event.name)
        end
      end
    end
  elsif direction == "down"
    for event in $game_map.events.values
      if mirror.y < event.y && mirror.x == event.x && event.name == "Beam"
        $game_self_switches[[@map_id,event.id,"B"]]=true
      elsif mirror.y < event.y && mirror.x == event.x && event.name == "Leaf"
        $game_self_switches[[@map_id,event.id,"B"]]=true
      elsif mirror.y < event.y && mirror.x == event.x && event.name == "Flower"
        $game_self_switches[[@map_id,event.id,"A"]]=true
        for event2 in $game_map.events.values
          if event2.x - 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x + 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y - 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y + 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          end
        end
      end
      if mirror.y < event.y && mirror.x == event.x && event.name.include?('Mirror')
        switchA = $game_self_switches[[@map_id,event.id,"A"]]
        switchB = $game_self_switches[[@map_id,event.id,"B"]]
        switchC = $game_self_switches[[@map_id,event.id,"C"]]
        switchD = $game_self_switches[[@map_id,event.id,"D"]]
        if switchA
          pbMirrorLight("up", event.name)
        elsif switchB
          pbMirrorLight("left", event.name)
        elsif switchC
          pbMirrorLight("right", event.name)
        elsif switchD
          pbMirrorLight("down", event.name)
        end
      end
    end
  end
  $game_map.need_refresh = true
end

def pbMirrorLight(direction, eventname)
  for event in $game_map.events.values
    if event.name == eventname
      mirror = event
    end
  end
  if direction == "auto"
    switchA = $game_self_switches[[@map_id,mirror.id,"A"]]
    switchB = $game_self_switches[[@map_id,mirror.id,"B"]]
    switchC = $game_self_switches[[@map_id,mirror.id,"C"]]
    switchD = $game_self_switches[[@map_id,mirror.id,"D"]]
    if switchA
      direction = "up"
    elsif switchB
      direction = "left"
    elsif switchC
      direction = "right"
    elsif switchD
      direction = "down"
    end
  end
  if direction == "up"
    for event in $game_map.events.values
      if mirror.y > event.y && mirror.x == event.x && event.name == "Beam"
        if eventname == "Mirror 9"
          $game_self_switches[[@map_id,event.id,"C"]]=true
        else
          $game_self_switches[[@map_id,event.id,"B"]]=true
        end
      elsif mirror.y > event.y && mirror.x == event.x && event.name == "Leaf"
        $game_self_switches[[@map_id,event.id,"B"]]=true
      elsif mirror.y > event.y && mirror.x == event.x && event.name == "Flower"
        $game_self_switches[[@map_id,event.id,"A"]]=true
        for event2 in $game_map.events.values
          if event2.x - 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x + 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y - 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y + 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          end
        end
      end
      if mirror.y > event.y && mirror.x == event.x && event.name.include?('Mirror')
        switchA = $game_self_switches[[@map_id,event.id,"A"]]
        switchB = $game_self_switches[[@map_id,event.id,"B"]]
        switchC = $game_self_switches[[@map_id,event.id,"C"]]
        switchD = $game_self_switches[[@map_id,event.id,"D"]]
        if switchA
          #pbMirrorLight("up", event.name)
        elsif switchB
          pbMirrorLight("left", event.name)
        elsif switchC
          pbMirrorLight("right", event.name)
        elsif switchD
          #pbMirrorLight("down", event.name)
        end
      end
    end
  elsif direction == "left"
    for event in $game_map.events.values
      if mirror.y == event.y && mirror.x > event.x && event.name == "Beam"
        $game_self_switches[[@map_id,event.id,"A"]]=true
      elsif mirror.y == event.y && mirror.x > event.x && event.name == "Leaf"
        $game_self_switches[[@map_id,event.id,"B"]]=true
      elsif mirror.y == event.y && mirror.x > event.x && event.name == "Flower"
        $game_self_switches[[@map_id,event.id,"A"]]=true
        for event2 in $game_map.events.values
          if event2.x - 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x + 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y - 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y + 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          end
        end
      end
      if mirror.y == event.y && mirror.x > event.x && event.name.include?('Mirror')
        switchA = $game_self_switches[[@map_id,event.id,"A"]]
        switchB = $game_self_switches[[@map_id,event.id,"B"]]
        switchC = $game_self_switches[[@map_id,event.id,"C"]]
        switchD = $game_self_switches[[@map_id,event.id,"D"]]
        if switchA
          pbMirrorLight("up", event.name)
        elsif switchB
          #pbMirrorLight("left", event.name)
        elsif switchC
          #pbMirrorLight("right", event.name)
        elsif switchD
          pbMirrorLight("down", event.name)
        end
      end
    end
  elsif direction == "right"
    for event in $game_map.events.values
      if mirror.y == event.y && mirror.x < event.x && event.name == "Beam"
        $game_self_switches[[@map_id,event.id,"A"]]=true
      elsif mirror.y == event.y && mirror.x < event.x && event.name == "Leaf"
        $game_self_switches[[@map_id,event.id,"B"]]=true
      elsif mirror.y == event.y && mirror.x < event.x && event.name == "Flower"
        $game_self_switches[[@map_id,event.id,"A"]]=true
        for event2 in $game_map.events.values
          if event2.x - 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x + 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y - 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y + 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          end
        end
      elsif mirror.y == event.y && mirror.x < event.x && event.name.include?('Mirror')
        switchA = $game_self_switches[[@map_id,event.id,"A"]]
        switchB = $game_self_switches[[@map_id,event.id,"B"]]
        switchC = $game_self_switches[[@map_id,event.id,"C"]]
        switchD = $game_self_switches[[@map_id,event.id,"D"]]
        if switchA
          pbMirrorLight("up", event.name)
        elsif switchB
          #pbMirrorLight("left", event.name)
        elsif switchC
          #pbMirrorLight("right", event.name)
        elsif switchD
          pbMirrorLight("down", event.name)
        end
      end
    end
  elsif direction == "down"
    for event in $game_map.events.values
      if mirror.y < event.y && mirror.x == event.x && event.name == "Beam"
        if eventname == "Mirror 9"
          $game_self_switches[[@map_id,event.id,"C"]]=true
        else
          $game_self_switches[[@map_id,event.id,"B"]]=true
        end
      elsif mirror.y < event.y && mirror.x == event.x && event.name == "Leaf"
        $game_self_switches[[@map_id,event.id,"B"]]=true
      elsif mirror.y < event.y && mirror.x == event.x && event.name == "Flower"
        $game_self_switches[[@map_id,event.id,"A"]]=true
        for event2 in $game_map.events.values
          if event2.x - 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x + 1 == event.x && event2.y == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y - 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          elsif event2.x == event.x && event2.y + 1 == event.y
            $game_self_switches[[@map_id,event2.id,"A"]]=true
          end
        end
      end
      if mirror.y < event.y && mirror.x == event.x && event.name.include?('Mirror')
        switchA = $game_self_switches[[@map_id,event.id,"A"]]
        switchB = $game_self_switches[[@map_id,event.id,"B"]]
        switchC = $game_self_switches[[@map_id,event.id,"C"]]
        switchD = $game_self_switches[[@map_id,event.id,"D"]]
        if switchA
          #pbMirrorLight("up", event.name)
        elsif switchB
          if eventname == "Mirror 9"
            if event.name == "Mirror 3"
              pbMirrorLight("left", event.name)
            end
          else
            pbMirrorLight("left", event.name)
          end
        elsif switchC
          if eventname == "Mirror 9"
            if event.name == "Mirror 3"
              pbMirrorLight("right", event.name)
            end
          else
            pbMirrorLight("right", event.name)
          end
        elsif switchD
          #pbMirrorLight("down", event.name)
        end
      end
    end
  end
  $game_map.need_refresh = true
end