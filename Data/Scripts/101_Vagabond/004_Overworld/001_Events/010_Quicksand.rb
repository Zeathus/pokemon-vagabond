def pbQuicksand(eventid)
  event = $game_map.events[eventid]
  x_diff = $game_player.x - event.x
  y_diff = $game_player.y - event.y
  x_step = x_diff * 32.0
  y_step = y_diff * 32.0
  start_time = System.uptime
  last_time = start_time
  started_tone_change = false
  while System.uptime - start_time < 1.0
    time_now = System.uptime
    delta = time_now - last_time
    last_time = time_now
    if !started_tone_change && System.uptime - start_time > 0.5
      $game_screen.start_tone_change(Tone.new(-255, -255, -255), 30)
      started_tone_change = true
    end
    $game_player.x_offset -= x_step * delta
    $game_player.y_offset -= y_step * delta
    pbUpdateSceneMap
    Graphics.update
    Input.update
  end
end