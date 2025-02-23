def pbShowBitmap(bitmap, seconds, invert = false)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99998

  background = Sprite.new(viewport)
  background.bitmap = bitmap
  background.z = 0
  background.ox = Settings::SCREEN_WIDTH / 2
  background.oy = Settings::SCREEN_HEIGHT / 2
  background.x = Settings::SCREEN_WIDTH / 2
  background.y = Settings::SCREEN_HEIGHT / 2
  background.invert = invert

  start_time = System.uptime

  while System.uptime < start_time + seconds
    viewport.update
    background.update
    Graphics.update
    Input.update
  end

  bitmap.dispose
  background.dispose
  viewport.dispose
end

def pbPulseBitmapOut(bitmap, seconds, interval=0.2, invert = false)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99998

  sprites = []
  start_times = []

  start_time = System.uptime
  last_pulse = 0

  z = 999
  while System.uptime < start_time + seconds || sprites.length > 0
    if last_pulse + interval < System.uptime && System.uptime < start_time + seconds
      last_pulse = System.uptime
      pulse = Sprite.new(viewport)
      pulse.bitmap = bitmap
      pulse.z = 0
      pulse.ox = Settings::SCREEN_WIDTH / 2
      pulse.oy = Settings::SCREEN_HEIGHT / 2
      pulse.x = Settings::SCREEN_WIDTH / 2
      pulse.y = Settings::SCREEN_HEIGHT / 2
      pulse.invert = invert
      pulse.z = z
      z -= 1
      sprites.push(pulse)
      start_times.push(System.uptime)
    end
    (0...sprites.length).each do |i|
      s = sprites[i]
      stime = start_times[i]
      s.zoom_x = 1.0 + (System.uptime - stime)
      s.zoom_y = 1.0 + (System.uptime - stime)
      s.opacity = 255 - 255 * (System.uptime - stime)
      s.update
      if s.opacity <= 0
        s.dispose
        sprites[i] = nil
        start_times[i] = nil
      end
    end
    sprites.compact!
    start_times.compact!
    viewport.update
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end

  bitmap.dispose
  viewport.dispose
end

def pbPulseBitmapIn(bitmap, seconds, interval=0.2, invert = false)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99998

  sprites = []
  start_times = []

  start_time = System.uptime
  last_pulse = 0

  z = 0
  while System.uptime < start_time + seconds || sprites.length > 0
    if last_pulse + interval < System.uptime && System.uptime < start_time + seconds
      last_pulse = System.uptime
      pulse = Sprite.new(viewport)
      pulse.bitmap = bitmap
      pulse.z = 0
      pulse.ox = Settings::SCREEN_WIDTH / 2
      pulse.oy = Settings::SCREEN_HEIGHT / 2
      pulse.x = Settings::SCREEN_WIDTH / 2
      pulse.y = Settings::SCREEN_HEIGHT / 2
      pulse.invert = invert
      pulse.zoom_x = 2.0
      pulse.zoom_y = 2.0
      pulse.opacity = 0
      pulse.z = z
      z += 1
      sprites.push(pulse)
      start_times.push(System.uptime)
    end
    (0...sprites.length).each do |i|
      s = sprites[i]
      stime = start_times[i]
      zoom = [2.0 - (System.uptime - stime), 1.0].max
      s.zoom_x = zoom
      s.zoom_y = zoom
      s.opacity = 255 * (System.uptime - stime)
      s.update
      if s.opacity >= 255
        s.dispose
        sprites[i] = nil
        start_times[i] = nil
      end
    end
    sprites.compact!
    start_times.compact!
    viewport.update
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end

  bitmap.dispose
  viewport.dispose
end

EventHandlers.add(:on_leave_tile, :footsteps,
  proc { |event, old_map, x, y|
    if event == $game_player && old_map == $game_map.map_id && [132,135].include?($game_map.map_id)
      for i in 0...3
        # Regular Sand
        if [8369,8396,8407,8406].include?($game_map.data[x, y, i])
          tile = [8407,8406,8406,8407][$game_player.direction / 2 - 1]
          $game_map.set_tile(x, y, i, tile)
        # Dark Sand
        elsif [8452,8463,8462].include?($game_map.data[x, y, i])
          tile = [8463,8462,8462,8463][$game_player.direction / 2 - 1]
          $game_map.set_tile(x, y, i, tile)
        # Cliff Edge Sand
        elsif [8361,8409,8438,8439].include?($game_map.data[x, y, i])
          tile = [8439,8438,8438,8439][$game_player.direction / 2 - 1]
          $game_map.set_tile(x, y, i, tile)
        # Cliff Edge Left Corner Sand
        elsif [8408,8412,8413].include?($game_map.data[x, y, i])
          tile = [8413,8412,8412,8413][$game_player.direction / 2 - 1]
          $game_map.set_tile(x, y, i, tile)
        # Cliff Edge Right Corner Sand
        elsif [8410,8414,8415].include?($game_map.data[x, y, i])
          tile = [8415,8414,8414,8415][$game_player.direction / 2 - 1]
          $game_map.set_tile(x, y, i, tile)
        end
      end
    end
  }
)