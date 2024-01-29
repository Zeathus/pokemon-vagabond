def pbQuicksand(eventid)
  event = $game_map.events[eventid]
  x_diff = $game_player.x - event.x
  y_diff = $game_player.y - event.y
  x_step = (x_diff * 32.0 / 60.0)
  y_step = (y_diff * 32.0 / 60.0)
  60.times do |i|
    if i == 40
      $game_screen.start_tone_change(Tone.new(-255, -255, -255), 40)
    end
    $game_player.x_offset -= x_step
    $game_player.y_offset -= y_step
    pbUpdateSceneMap
    Graphics.update
    Input.update
  end
end