# Only a super-class. Not meant to be used.
class WindowToast
  attr_accessor :active

  def initialize(text)
    @window = Window_AdvancedTextPokemon.new(text, 1)
    @window.resizeToFit(text, Graphics.width / 3)
    @window.x        = 0
    @window.y        = -@window.height
    @window.viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @window.viewport.z = 99999
    @frames   = 180
    @state    = 0
    @targetX  = -1
    @targetY  = -1
    @startX   = @window.x
    @startY   = @window.y
    @speed    = 8
    @active   = false
  end

  def disposed?
    @window.disposed?
  end

  def dispose
    @window.dispose
  end

  def update
    return if @window.disposed?
    @window.update
    case @state
    when 0
      done = true
      if @targetX != -1
        if @window.x < @targetX
          @window.x += @speed
          @window.x = @targetX if @window.x > @targetX
          done = false
        elsif @window.x > @targetX
          @window.x -= @speed
          @window.x = @targetX if @window.x < @targetX
          done = false
        end
      end
      if @targetY != -1
        if @window.y < @targetY
          @window.y += @speed
          @window.y = @targetY if @window.y > @targetY
          done = false
        elsif @window.y > @targetY
          @window.y -= @speed
          @window.y = @targetY if @window.y < @targetY
          done = false
        end
      end
      @state = 1 if done
    when 1
      @frames -= 1
      @state = 2 if @frames <= 0
    when 2
      done = true
      if @startX != -1
        if @window.x < @startX
          @window.x += @speed
          @window.x = @startX if @window.x > @startX
          done = false
        elsif @window.x > @startX
          @window.x -= @speed
          @window.x = @startX if @window.x < @startX
          done = false
        end
      end
      if @startY != -1
        if @window.y < @startY
          @window.y += @speed
          @window.y = @startY if @window.y > @startY
          done = false
        elsif @window.y > @startY
          @window.y -= @speed
          @window.y = @startY if @window.y < @startY
          done = false
        end
      end
      self.dispose if done
    end
  end
end

class LeftWindowToast < WindowToast
  def initialize(text)
    super(text)
    @window.x = -@window.width
    @window.y = Graphics.height / 2 - @window.height / 2
    @startX = @window.x
    @startY = @window.y
    @targetX = 0
  end
end

class RightWindowToast < WindowToast
  def initialize(text)
    super(text)
    @window.x = Graphics.width
    @window.y = Graphics.height / 2 - @window.height / 2
    @startX = @window.x
    @startY = @window.y
    @targetX = Graphics.width - @window.width
  end
end

class TopLeftWindowToast < WindowToast
  def initialize(text)
    super(text)
    @window.x = 0
    @window.y = -@window.height
    @startX = @window.x
    @startY = @window.y
    @targetY = 0
  end
end

class TopRightWindowToast < WindowToast
  def initialize(text)
    super(text)
    @window.x = Graphics.width - @window.width
    @window.y = -@window.height
    @startX = @window.x
    @startY = @window.y
    @targetY = 0
  end
end

class TopWindowToast < WindowToast
  def initialize(text)
    super(_INTL("<ac>{1}</ac>", text))
    @window.resizeToFit(text, Graphics.width * 3 / 4)
    @window.x = Graphics.width / 2 - @window.width / 2
    @window.y = -@window.height
    @startX = @window.x
    @startY = @window.y
    @targetY = 0
  end
end

class HoverTextToast
  attr_accessor :active
  attr_accessor :time

  def initialize(text)
    @viewport        = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z      = 99999
    @sprite          = Sprite.new(@viewport)
    @sprite.bitmap   = Bitmap.new(Graphics.width / 2, 48)
    textpos = [[text, 0, 4, 0, Color.new(252, 252, 252), Color.new(0, 0, 0), true]]
    pbSetSmallFont(@sprite.bitmap)
    pbDrawTextPositions(@sprite.bitmap, textpos)
    @sprite.x        = Graphics.width / 2 + 20
    @sprite.y        = Graphics.height / 2
    @sprite.opacity  = 0
    @time     = 120
    @state    = 0
    @active   = false
  end

  def disposed?
    @sprite.disposed?
  end

  def dispose
    @viewport.dispose
    @sprite.dispose
  end

  def update
    return if @sprite.disposed?
    @sprite.update
    case @state
    when 0
      @sprite.opacity += 32
      @sprite.y -= 2
      @state = 1 if @sprite.opacity >= 255
    when 1
      @time -= 1
      @state = 2 if @time <= 0
    when 2
      @sprite.opacity -= 32
      @sprite.y -= 2
      self.dispose if @sprite.opacity <= 0
    end
  end
end

def pbToast(toast)
  $game_temp.queue_toast(toast)
end

def pbTitleDisplay(title, subtitle = nil, time = 80, speed = 2)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  sprites = {}
  sprites["shadowl"] = Sprite.new(viewport)
  sprites["shadowl"].bitmap=RPG::Cache.load_bitmap("","Graphics/UI/Toasts/ui_shadow_left")
  sprites["shadowl"].y=Graphics.height/2-sprites["shadowl"].bitmap.height/2
  sprites["shadowl"].x=-Graphics.width
  sprites["shadowr"] = Sprite.new(viewport)
  sprites["shadowr"].bitmap=RPG::Cache.load_bitmap("","Graphics/UI/Toasts/ui_shadow_right")
  sprites["shadowr"].y=Graphics.height/2-sprites["shadowl"].bitmap.height/2
  sprites["shadowr"].x=Graphics.width
  sprites["display"] = Sprite.new(viewport)
  sprites["display"].z = 1
  sprites["display"].bitmap = BitmapWrapper.new(Graphics.width,Graphics.height)
  pbSetSystemFont(sprites["display"].bitmap)
  20.times do
    sprites["shadowl"].x += Graphics.width / 20
    sprites["shadowr"].x -= Graphics.width / 20
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    viewport.update
    pbUpdateSceneMap if $scene.is_a?(Scene_Map)
  end
  textx = Graphics.width / 2 - sprites["display"].bitmap.text_size(title).width / 2
  textx2 = Graphics.width / 2 - sprites["display"].bitmap.text_size(subtitle).width / 2 if subtitle
  texty = Graphics.height / 2 - 28
  texty2 = texty + 36
  index_title = -5
  index_subtitle = -5
  frame = 0
  while index_title < title.length || (subtitle && index_subtitle < subtitle.length)
    frame += 1
    if frame % speed == 0
      if index_title < title.length
        index_title += 1
      else
        index_subtitle += 1
      end
      sprites["display"].bitmap.clear
      for i in [3, 2, 1, 0]
        opacity = [255, 192, 128, 64][i]
        show_title = title[0...[[title.length, index_title + i].min, 0].max]
        textpos = if subtitle
          show_subtitle = subtitle[0...[[subtitle.length, index_subtitle + i].min, 0].max]
          [
            [show_title, textx, texty, 0, Color.new(255, 255, 255, opacity), Color.new(168, 184, 184, opacity)],
            [show_subtitle, textx2, texty2, 0, Color.new(255, 255, 255, opacity), Color.new(168, 184, 184, opacity)]
          ]
        else
          [[show_title, textx, (texty + texty2) / 2, 0, Color.new(255, 255, 255, opacity), Color.new(168, 184, 184, opacity)]]
        end
        pbDrawTextPositions(sprites["display"].bitmap, textpos)
      end
    end
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    viewport.update
    pbUpdateSceneMap if $scene.is_a?(Scene_Map)
  end
  time.times do
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    viewport.update
    pbUpdateSceneMap if $scene.is_a?(Scene_Map)
  end
  32.times do
    sprites["display"].opacity -= 16
    sprites["shadowl"].opacity -= 8
    sprites["shadowr"].opacity -= 8
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    viewport.update
    pbUpdateSceneMap if $scene.is_a?(Scene_Map)
  end
  pbDisposeSpriteHash(sprites)
  viewport.dispose
  return true
end

def pbUpdateToasts
  queue = $game_temp.toast_queue
  if queue.length > 0
    if queue[0].disposed?
      queue.shift
    elsif queue[0].active
      queue[0].update
    else
      queue[0].active = true
    end
  end
end