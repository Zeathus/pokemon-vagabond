def pbStartEvent(id)
  $game_map.events[id].start
end

def pbFadeEvent(id, start, finish, duration)
  time = 0.0
  if id.is_a?(Numeric)
    event = $game_map.events[id]
    while time < duration
      event.setOpacity(start - ((start - finish) * (time / duration)))
      time+=1.0
      pbWait(1)
    end
    event.setOpacity(finish)
  else
    while time < duration
      for i in id
        $game_map.events[i].setOpacity(start - ((start - finish) * (time / duration)))
      end
      time+=1.0
      pbWait(1)
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