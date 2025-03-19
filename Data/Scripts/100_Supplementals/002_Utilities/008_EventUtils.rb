def pbStartEvent(id)
  $game_map.events[id].start
end

def pbFadeEvent(id, start, finish, duration)
  time = 0.0
  if id.is_a?(Numeric) || id.is_a?(Game_Character)
    event = (id.is_a?(Game_Character)) ? id : $game_map.events[id]
    while time < duration
      event.setOpacity(start - ((start - finish) * (time / duration)))
      time+=0.05
      pbWait(0.05)
    end
    event.setOpacity(finish)
  else
    while time < duration
      for i in id
        $game_map.events[i].setOpacity(start - ((start - finish) * (time / duration)))
      end
      time+=0.05
      pbWait(0.05)
    end
    for i in id
      $game_map.events[i].setOpacity(finish)
    end
  end
end

def pbUpdateAllEvents
  for event in $game_map.events.values
    event.update
    event.update_move
  end
end

def pbUpdateEvent(eventid)
  for event in $game_map.events.values
    if event.id==eventid
      event.update
      event.update_move
    end
  end
end