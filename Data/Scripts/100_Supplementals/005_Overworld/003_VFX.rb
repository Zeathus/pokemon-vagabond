begin
  module PBVFX
    None         = 0
    Leaves       = 1
    LeavesAutumn = 2
    Fireflies    = 3

    def self.count
      return 4
    end

    def self.getName(id)
      id = getID(PBVFX, id) if id.is_a?(Symbol)
      return [
        "None",
        "Leaves",
        "Leaves Autumn",
        "Fireflies"
      ][id]
    end
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end

class VFXSprite < Sprite
  attr_accessor :lifetime
  attr_accessor :orig_x
  attr_accessor :orig_y
  attr_accessor :sub_x
  attr_accessor :sub_y
  attr_accessor :rng

  def initialize(viewport)
    super(viewport)
    @lifetime = 0
    @orig_x = 0
    @orig_y = 0
    @sub_x = 0.0
    @sub_y = 0.0
    self.randomize
  end

  def sub_x=(value)
    @sub_x += value
    if @sub_x >= 1
      self.x += @sub_x.floor
      @sub_x -= @sub_x.floor
    elsif @sub_x <= -1
      self.x += @sub_x.ceil
      @sub_x -= @sub_x.ceil
    end
  end

  def sub_y=(value)
    @sub_y += value
    if @sub_y >= 1
      self.y += @sub_y.floor
      @sub_y -= @sub_y.floor
    elsif @sub_y <= -1
      self.y += @sub_y.ceil
      @sub_y -= @sub_y.ceil
    end
  end

  def randomize
    @rng = rand(256)
  end
end

module RPG
  class VFX
    attr_reader :type
    attr_reader :max
    attr_reader :ox
    attr_reader :oy


    def initialize(viewport = nil)
      @type = 0
      @max = 0
      @ox = 0
      @oy = 0
      @map_display_x = $game_map ? ($game_map.display_x / 4.0).floor : 0
      @map_display_y = $game_map ? ($game_map.display_y / 4.0).floor : 0
      @frame = 0
      @origviewport = viewport
      color = Color.new(0, 0, 0, 255)
      @leavesBitmap=AnimatedBitmap.new("Graphics/Pictures/VFX/leaves").bitmap
      @leavesA1Bitmap=AnimatedBitmap.new("Graphics/Pictures/VFX/leaves_autumn1").bitmap
      @leavesA2Bitmap=AnimatedBitmap.new("Graphics/Pictures/VFX/leaves_autumn2").bitmap
      @leavesA3Bitmap=AnimatedBitmap.new("Graphics/Pictures/VFX/leaves_autumn3").bitmap
      @fireflyBitmap=AnimatedBitmap.new("Graphics/Pictures/VFX/firefly").bitmap
      @vfxTypes=[]
      @vfxTypes[PBVFX::None]         = nil
      @vfxTypes[PBVFX::Leaves]       = [[@leavesBitmap],0,0]
      @vfxTypes[PBVFX::LeavesAutumn] = [[@leavesA1Bitmap,@leavesA2Bitmap,@leavesA3Bitmap],0,0]
      @vfxTypes[PBVFX::Fireflies]    = [[@fireflyBitmap],0,0]
      @sprites = []
    end

    def ensureSprites
      return if @sprites.length>=40
      for i in 1..40
        sprite = VFXSprite.new(@origviewport)
        sprite.z = 1000
        sprite.opacity = 0
        sprite.ox = @ox
        sprite.oy = @oy
        sprite.visible = (i <= @max)
        @sprites.push(sprite)
      end
    end

    def dispose
      for sprite in @sprites
        sprite.dispose
      end
      for vfx in @vfxTypes
        next if !vfx
        for bm in vfx[0]
          bm.dispose
        end
      end
    end

    def set_type(new_type,force=false)
      return if !force && @type == new_type
      @type = new_type
      @type = 0 if !@type
      case @type
      when PBVFX::Leaves
        @max = 24
        bitmap = @leavesBitmap
      when PBVFX::LeavesAutumn
        @max = 30
        bitmap = @leavesA1Bitmap
      when PBVFX::Fireflies
        @max = 30
        bitmap = @fireflyBitmap
      else
        @max = 0
        bitmap = nil
      end
      if @type==PBVFX::None
        for sprite in @sprites
          sprite.dispose
        end
        @sprites.clear
        return
      end
      vfxbitmaps=@type==PBVFX::None ? nil : @vfxTypes[@type][0]
      ensureSprites
      positions = []
      for i in 1..40
        x = 0
        y = 0
        5.times do
          x = rand(Graphics.width + 256) - 128
          y = rand(Graphics.height + 256) - 128
          passed = true
          positions.each do |p|
            if (x - p[0]).abs < 64 && (y - p[1]).abs < 64
              passed = false
              break
            end
          end
          break if passed
        end
        positions.push([x, y])
      end
      for i in 1..40
        sprite = @sprites[i]
        if sprite != nil
          sprite.mirror=false
          sprite.visible = true
          sprite.x = positions[i - 1][0]
          sprite.y = positions[i - 1][1]
          sprite.orig_x = sprite.x
          sprite.orig_y = sprite.y
          sprite.bitmap = @type==PBVFX::None ? nil : vfxbitmaps[i%vfxbitmaps.length]
          if @type==PBVFX::Leaves || @type==PBVFX::LeavesAutumn
            sprite.src_rect=Rect.new(0,22*rand(4),24,22)
            sprite.zoom_x = 0.7 + ((sprite.rng % 16).to_f / 15) * 0.8
            sprite.zoom_y = sprite.zoom_x
          elsif @type==PBVFX::Fireflies
            sprite.src_rect=Rect.new(0,0,20,20)
            sprite.lifetime = rand(256) * Math::PI * 4 / 256
          end
        end
      end
    end

    def type=(new_type)
      self.set_type(new_type,false)
    end

    def ox=(ox)
      return if @ox == ox;
      @ox = ox
      for sprite in @sprites
        sprite.ox = @ox
      end
    end

    def oy=(oy)
      return if @oy == oy;
      @oy = oy
      for sprite in @sprites
        sprite.oy = @oy
      end
    end

    def max=(max)
      return if @max == max;
      @max = [[max, 0].max, 40].min
      if @max==0
        for sprite in @sprites
          sprite.dispose
        end
        @sprites.clear
      else
        for i in 1..40
          sprite = @sprites[i]
          if sprite != nil
            sprite.visible = (i <= @max)
          end
        end
      end
    end

    def update(force=false)
      # @max is (power+1)*4, where power is between 1 and 9
      @frame+=1
      return if !force && @type==PBVFX::None
      ensureSprites
      new_map_display_x = $game_map ? ($game_map.display_x / 4.0).floor : 0
      new_map_display_y = $game_map ? ($game_map.display_y / 4.0).floor : 0
      warped = 0
      time_now = pbGetTimeNow
      for i in 1..@max
        sprite = @sprites[i]
        break if sprite == nil
        sprite.x += @vfxTypes[@type][1]
        sprite.y += @vfxTypes[@type][2]
        if new_map_display_x != @map_display_x
          sprite.x += @map_display_x - new_map_display_x
        end
        if new_map_display_y != @map_display_y
          sprite.y += @map_display_y - new_map_display_y
        end
        sprite.opacity = 255
        x = sprite.x - @ox
        y = sprite.y - @oy
        nomwidth=Graphics.width
        nomheight=Graphics.height
        if @type==PBVFX::Leaves || @type==PBVFX::LeavesAutumn
          sprite.lifetime += 1.0 / Graphics.frame_rate
          if @frame % 8 == 0
            sprite.src_rect.y += 22
            sprite.src_rect.y = 0 if sprite.src_rect.y >= 88
          end
          move_x = (0.2 + 1.0 * (sprite.rng.to_f / 255))
          move_y = (1.0 + 1.0 * (1 - (sprite.rng.to_f / 255)))
          move_x += (Math.sin(sprite.lifetime + sprite.rng) + 1) / 2
          move_y += (2 - (Math.sin(sprite.lifetime + sprite.rng) + 1)) / 2
          if $game_screen.weather_type==:Winds
            move_x += 5
            move_y -= 2
          end
          move_x *= sprite.zoom_x * 0.5
          move_y *= sprite.zoom_y * 0.5
          sprite.sub_x += move_x
          sprite.sub_y += move_y
          sprite.opacity = 255 - 30 * sprite.zoom_x
        elsif @type==PBVFX::Fireflies
          sprite.lifetime += 1.0 / Graphics.frame_rate
          if sprite.lifetime >= Math::PI * 4
            sprite.lifetime = 0
          end
          progress = (Math.cos(Math::PI + sprite.lifetime / 2) + 1) / 2
          daylight_mod = 180
          if time_now.hour < 3 || time_now.hour >= 21
            daylight_mod = 0
          elsif time_now.hour < 6
            daylight_mod = (time_now.hour * 60 + time_now.min) - 180
          elsif time_now.hour >= 18
            daylight_mod = (1440 - (time_now.hour * 60 + time_now.min)) - 180
          end
          daylight_mod = 1 - Math.sin(daylight_mod * Math::PI / 2 / 180)
          sprite.opacity = progress * 240 * daylight_mod
          sprite.color.set(
            105 + progress * 150,
            155 + progress * 100,
            15 + progress * 150
          )
          if progress > 0.75
            sprite.src_rect.x = 20
          else
            sprite.src_rect.x = 0
          end
          sprite.ox = (Math.sin(sprite.rng + sprite.lifetime / 2) * 64).floor
          sprite.oy = (Math.cos((sprite.rng + 60) % 256 + sprite.lifetime / 2) * 32).floor
        end
        if x > nomwidth+128 || y < -128 || y > nomheight+128 || x < -128
          if @type==PBVFX::Leaves || @type==PBVFX::LeavesAutumn
            sprite.src_rect=Rect.new(0,22*rand(4),24,22)
            if x > nomwidth+128
              sprite.x -= nomwidth + 256
            elsif x < -128
              sprite.x += nomwidth + 256
            elsif y > nomheight+128
              sprite.y -= nomheight + 256
            elsif y < -128
              sprite.y += nomheight + 256
            else
              if @frame % 8 == 0 && warped < 2
                sprite.x = nomwidth + 120 + rand(20) + @ox
                sprite.y = rand(nomheight+420) - 420 + @oy
                warped+=1
              end
            end
            sprite.randomize()
            sprite.zoom_x = 0.5 + ((sprite.rng % 16).to_f / 15)
            sprite.zoom_y = sprite.zoom_x
            sprite.lifetime = 0
          else
            x = 0
            y = 0
            5.times do
              x = rand(Graphics.width + 256) - 128
              y = rand(Graphics.height + 256) - 128
              passed = true
              @sprites.each do |s|
                if (x - s.x).abs < 64 && (y - s.y).abs < 64
                  passed = false
                  break
                end
              end
              break if passed
            end
            sprite.x = x + @ox
            sprite.y = y + @oy
            sprite.orig_x = sprite.x
            sprite.orig_y = sprite.y
          end
        end
        pbDayNightTint(sprite)
      end
      @map_display_x = new_map_display_x
      @map_display_y = new_map_display_y
    end
  end
end 