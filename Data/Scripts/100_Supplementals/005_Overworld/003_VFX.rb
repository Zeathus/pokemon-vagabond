begin
  module PBVFX
    None         = 0
    Leaves       = 1
    LeavesAutumn = 2
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end


def pbUpdateVFX
  leaves = [] # Map IDs
  leaves_autumn = [] # Map IDs
  if leaves.include?($game_map.map_id)
    $game_screen.vfx(PBVFX::Leaves) if $game_screen.vfx_type != PBVFX::Leaves
  elsif leaves_autumn.include?($game_map.map_id)
    $game_screen.vfx(PBVFX::LeavesAutumn) if $game_screen.vfx_type != PBVFX::LeavesAutumn
  else
    $game_screen.vfx(PBVFX::None) if $game_screen.vfx_type != PBVFX::None
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
      @playerx = $game_player ? 0 : $game_player.real_x
      @playery = $game_player ? 0 : $game_player.real_y
      @frame = 0
      @origviewport = viewport
      color = Color.new(0, 0, 0, 255)
      @leavesBitmap=AnimatedBitmap.new("Graphics/Pictures/VFX/leaves").bitmap
      @leavesA1Bitmap=AnimatedBitmap.new("Graphics/Pictures/VFX/leaves_autumn1").bitmap
      @leavesA2Bitmap=AnimatedBitmap.new("Graphics/Pictures/VFX/leaves_autumn2").bitmap
      @leavesA3Bitmap=AnimatedBitmap.new("Graphics/Pictures/VFX/leaves_autumn3").bitmap
      @vfxTypes=[]
      @vfxTypes[PBVFX::None]         = nil
      @vfxTypes[PBVFX::Leaves]       = [[@leavesBitmap],-4,2,-8]
      @vfxTypes[PBVFX::LeavesAutumn] = [[@leavesA1Bitmap,@leavesA2Bitmap,@leavesA3Bitmap],-4,2,-8]
      @sprites = []
    end

    def ensureSprites
      return if @sprites.length>=40
      for i in 1..40
        sprite = Sprite.new(@origviewport)
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

    def type(type,force=false)
      return if !force && @type == type
      @type = type
      @type = 0 if !@type
      case @type
      when PBVFX::Leaves
        @max = 15
        bitmap = @leavesBitmap
      when PBVFX::LeavesAutumn
        @max = 30
        bitmap = @leavesA1Bitmap
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
      for i in 1..40
        sprite = @sprites[i]
        if sprite != nil
          sprite.mirror=false
          sprite.visible = true
          nomwidth=Graphics.width
          nomheight=Graphics.height
          sprite.x = rand(nomwidth+256)-128
          sprite.y = rand(nomheight+256)-128
          sprite.bitmap = @type==PBVFX::None ? nil : vfxbitmaps[i%vfxbitmaps.length]
          if @type==PBVFX::Leaves || @type==PBVFX::LeavesAutumn
            sprite.src_rect=Rect.new(0,22*rand(4),24,22)
          end
        end
      end
    end

    def type=(type)
      self.type(type,false)
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
      newplayerx = ($game_player.real_x / 4.0).floor
      newplayery = ($game_player.real_y / 4.0).floor
      warped = 0
      for i in 1..@max
        sprite = @sprites[i]
        break if sprite == nil
        sprite.x += @vfxTypes[@type][1]
        sprite.y += @vfxTypes[@type][2]
        if newplayerx != @playerx
          sprite.x += @playerx - newplayerx
        end
        if newplayery != @playery
          sprite.y += @playery - newplayery
        end
        sprite.opacity = 200
        x = sprite.x - @ox
        y = sprite.y - @oy
        nomwidth=Graphics.width
        nomheight=Graphics.height
        if (@type==PBVFX::Leaves || @type==PBVFX::LeavesAutumn)
          if @frame % 6 == 0
            sprite.src_rect.y += 22
            sprite.src_rect.y = 0 if sprite.src_rect.y >= 88
          end
          if $game_screen.weather_type==:Winds
            sprite.x += 12
            sprite.y -= 3
          end
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
          else
            sprite.x = rand(nomwidth+150) - 50 + @ox
            sprite.y = rand(nomheight+150) - 200 + @oy
          end
        end
        pbDayNightTint(sprite)
      end
      @playerx = newplayerx
      @playery = newplayery
    end
  end
end 