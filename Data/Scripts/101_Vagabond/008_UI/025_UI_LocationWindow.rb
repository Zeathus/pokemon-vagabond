#===============================================================================
# Location signpost (Overrides the vanilla Essentials one)
#===============================================================================
class LocationWindow
  APPEAR_TIME = 0.4   # In seconds; is also the disappear time
  LINGER_TIME = 1.6   # In seconds; time during which self is fully visible

  def initialize(name)
    @viewport = Viewport.new(0, 0, 384, 64)
    @viewport.z = 99999
    @window = Sprite.new(@viewport)
    @window.bitmap = Bitmap.new(384, 64)
    @window.x        = 0
    @window.y        = 0
    pbSetBoldFont(@window.bitmap)
    text_width = @window.bitmap.text_size(name).width
    @window.bitmap.fill_rect(8, 12, text_width + 20, 6, Color.new(0, 0, 0))
    @window.bitmap.fill_rect(10, 14, text_width + 16, 2, Color.new(252, 252, 252))
    @window.bitmap.fill_rect(8, 50, text_width + 20, 6, Color.new(0, 0, 0))
    @window.bitmap.fill_rect(10, 52, text_width + 16, 2, Color.new(252, 252, 252))
    pbDrawTextPositions(@window.bitmap, [
        [name, 18, 22, :left, Color.new(252, 252, 252), Color.new(0, 0, 0), true]
    ])
    @window.opacity = 0
    @currentmap = $game_map.map_id
    @timer_start = System.uptime
    @delayed = !$game_temp.fly_destination.nil?
  end

  def disposed?
    return @window.disposed?
  end

  def dispose
    @window.dispose
  end

  def update
    return if @window.disposed? || $game_temp.fly_destination
    if @delayed
      @timer_start = System.uptime
      @delayed = false
    end
    @window.update
    if $game_temp.message_window_showing || @currentmap != $game_map.map_id
      @window.dispose
      return
    end
    if System.uptime - @timer_start >= APPEAR_TIME + LINGER_TIME
      @window.opacity = lerp(255, 0, APPEAR_TIME, @timer_start + APPEAR_TIME + LINGER_TIME, System.uptime)
      @window.dispose if @window.opacity <= 0
    else
      @window.opacity = lerp(0, 255, APPEAR_TIME, @timer_start, System.uptime)
    end
  end
end