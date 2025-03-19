class CounselingGame

  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["comfort_bar"] = IconSprite.new(0, 0, @viewport)
    @sprites["comfort_bar"].setBitmap("Graphics/UI/Counseling/comfort_bar")
    @sprites["comfort_bar"].z = 1
    @sprites["comfort_notches"] = IconSprite.new(0, 0, @viewport)
    @sprites["comfort_notches"].setBitmap("Graphics/UI/Counseling/comfort_notches")
    @sprites["comfort_notches"].z = 3
    @sprites["comfort_gauge"] = IconSprite.new(0, 0, @viewport)
    @sprites["comfort_gauge"].setBitmap("Graphics/UI/Counseling/comfort_gauge")
    @sprites["comfort_gauge"].z = 2
    @sprites["comfort_gauge"].src_rect = Rect.new(0, 0, 0, 32)
    @sprites["stress_bar"] = IconSprite.new(0, 0, @viewport)
    @sprites["stress_bar"].setBitmap("Graphics/UI/Counseling/stress_bar")
    @sprites["stress_bar"].z = 1
    @sprites["stress_notches"] = IconSprite.new(0, 0, @viewport)
    @sprites["stress_notches"].setBitmap("Graphics/UI/Counseling/stress_notches")
    @sprites["stress_notches"].z = 3
    @sprites["stress_gauge"] = IconSprite.new(0, 0, @viewport)
    @sprites["stress_gauge"].setBitmap("Graphics/UI/Counseling/stress_gauge")
    @sprites["stress_gauge"].z = 2
    @sprites["stress_gauge"].src_rect = Rect.new(0, 0, 0, 32)
    setComfortPos(-192, 96)
    setStressPos(Graphics.width, 96)
    self.comfort = 0.3
    self.stress = 0.6
  end

  def setComfortPos(x, y)
    @sprites["comfort_bar"].x = x
    @sprites["comfort_bar"].y = y
    @sprites["comfort_notches"].x = x
    @sprites["comfort_notches"].y = y
    @sprites["comfort_gauge"].x = x + 32
    @sprites["comfort_gauge"].y = y + 32
  end

  def setStressPos(x, y)
    @sprites["stress_bar"].x = x
    @sprites["stress_bar"].y = y
    @sprites["stress_notches"].x = x
    @sprites["stress_notches"].y = y
    @sprites["stress_gauge"].x = x
    @sprites["stress_gauge"].y = y + 32
  end

  def comfort
    return @comfort
  end

  def stress
    return @stress
  end

  def comfort=(value)
    @comfort = value
    @sprites["comfort_gauge"].src_rect.width = (160 * value).floor
  end

  def stress=(value)
    @stress = value
    @sprites["stress_gauge"].src_rect.width = (160 * value).floor
    @sprites["stress_gauge"].src_rect.x = 160 - (160 * value).floor
    @sprites["stress_gauge"].ox = (160 * value).floor - 160
  end

  def values=(vals)
    new_comfort = vals[0]
    new_stress = vals[1]
    change = 0
    if new_comfort > @comfort || new_stress < @stress
      change = 1
      pbSEPlay("Voltorb Flip level up")
    elsif new_comfort < @comfort || new_stress > @stress
      change = -1
      pbSEPlay("Voltorb Flip level down")
    end
    
    old_comfort = @comfort
    old_stress = @stress

    start_time = System.uptime
    last_time = start_time
    time_now = start_time
    while time_now - start_time < 1.0
      progress = (time_now - start_time)
      self.comfort = old_comfort * (1 - progress) + new_comfort * progress
      self.stress = old_stress * (1 - progress) + new_stress * progress
      Graphics.update
      Input.update
      @viewport.update
      pbUpdateSpriteHash(@sprites)
      last_time = time_now
      time_now = System.uptime
    end
    self.comfort = new_comfort
    self.stress = new_stress
  end

  def changeValues(c, s)
    new_stress = @stress + s
    new_stress = 0 if new_stress < 0
    new_stress = 0.9 if new_stress > 0.9
    self.values = [@comfort + c, new_stress]
  end

  def start
    text_counseling = IconSprite.new(0, 0, @viewport)
    text_counseling.setBitmap("Graphics/UI/Counseling/counseling")
    text_counseling.ox = text_counseling.bitmap.width / 2
    text_counseling.oy = text_counseling.bitmap.height / 2
    text_counseling.x = Graphics.width / 2
    text_counseling.y = Graphics.height / 2 - 32
    text_counseling.zoom_x = 3.0
    text_counseling.zoom_y = 3.0

    text_start = IconSprite.new(0, 0, @viewport)
    text_start.setBitmap("Graphics/UI/Counseling/start")
    text_start.ox = text_start.bitmap.width / 2
    text_start.oy = text_start.bitmap.height / 2
    text_start.x = Graphics.width / 2
    text_start.y = Graphics.height / 2 + 32
    text_start.zoom_x = 3.0
    text_start.zoom_y = 3.0

    text_counseling.opacity = 0
    text_start.opacity = 0

    start_time = System.uptime
    time_now = start_time
    while time_now - start_time < 0.5
      text_counseling.opacity = 255 * (time_now - start_time) * 2
      text_counseling.zoom_x = 3.0 - 2.0 * (time_now - start_time) * 2
      text_counseling.zoom_y = 3.0 - 2.0 * (time_now - start_time) * 2
      Graphics.update
      Input.update
      @viewport.update
      text_counseling.update
      time_now = System.uptime
    end
    text_counseling.opacity = 255
    text_counseling.zoom_x = 1
    text_counseling.zoom_y = 1
    pbSEPlay("Blow4", 100, 100)

    
    start_time = System.uptime
    time_now = start_time
    while time_now - start_time < 0.3
      Graphics.update
      Input.update
      time_now = System.uptime
    end

    start_time = System.uptime
    time_now = start_time
    while time_now - start_time < 0.5
      text_start.opacity = 255 * (time_now - start_time) * 2
      text_start.zoom_x = 3.0 - 2.0 * (time_now - start_time) * 2
      text_start.zoom_y = 3.0 - 2.0 * (time_now - start_time) * 2
      Graphics.update
      Input.update
      @viewport.update
      text_start.update
      time_now = System.uptime
    end
    text_start.opacity = 255
    text_start.zoom_x = 1
    text_start.zoom_y = 1
    pbSEPlay("Blow4", 100, 110)

    
    start_time = System.uptime
    time_now = start_time
    while time_now - start_time < 0.5
      Graphics.update
      Input.update
      time_now = System.uptime
    end

    pbSEPlay("Wind1", 100, 100)
    start_time = System.uptime
    time_now = start_time
    while time_now - start_time < 1.0
      text_counseling.x = Graphics.width / 2 + Graphics.width * (time_now - start_time)
      text_start.x = Graphics.width / 2 - Graphics.width * (time_now - start_time)
      Graphics.update
      Input.update
      @viewport.update
      text_counseling.update
      text_start.update
      time_now = System.uptime
    end

    text_counseling.dispose
    text_start.dispose

    return if @sprites["comfort_bar"].x > 0

    pbSEPlay("Wind1", 100, 80)
    start_time = System.uptime
    time_now = start_time
    while time_now - start_time < 0.5
      progress = Math.sqrt((time_now - start_time) * 2)
      setComfortPos(-192 + 320 * progress, 96)
      setStressPos(Graphics.width - 320 * progress, 96)
      Graphics.update
      Input.update
      @viewport.update
      pbUpdateSpriteHash(@sprites)
      time_now = System.uptime
    end
    setComfortPos(-192 + 320, 96)
    setStressPos(Graphics.width - 320, 96)
  end

  def stop
    pbSEPlay("Wind1", 100, 100)
    start_time = System.uptime
    time_now = start_time
    while time_now - start_time < 0.5
      progress = Math.sqrt((time_now - start_time) * 2)
      setComfortPos(-192 + 320 - 320 * progress, 96)
      setStressPos(Graphics.width - 320 + 320 * progress, 96)
      Graphics.update
      Input.update
      @viewport.update
      pbUpdateSpriteHash(@sprites)
      time_now = System.uptime
    end
    setComfortPos(-192, 96)
    setStressPos(Graphics.width, 96)
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
  end

end

def pbStartCounseling
  game = CounselingGame.new
  $game_variables[5] = game
  game.start
end

def pbEndCounseling
  $game_variables[5].stop
  $game_variables[5].dispose
  $game_variables[5] = 0
end

def pbCounseling
  return $game_variables[5]
end