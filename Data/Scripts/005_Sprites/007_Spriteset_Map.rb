#===============================================================================
# Unused.
#===============================================================================
class ClippableSprite < Sprite_Character
  def initialize(viewport, event, tilemap)
    @tilemap = tilemap
    @_src_rect = Rect.new(0, 0, 0, 0)
    super(viewport, event)
  end

  def update
    super
    @_src_rect = self.src_rect
    tmright = (@tilemap.map_data.xsize * Game_Map::TILE_WIDTH) - @tilemap.ox
    echoln "x=#{self.x},ox=#{self.ox},tmright=#{tmright},tmox=#{@tilemap.ox}"
    if @tilemap.ox - self.ox < -self.x
      # clipped on left
      diff = -self.x - @tilemap.ox + self.ox
      self.src_rect = Rect.new(@_src_rect.x + diff, @_src_rect.y,
                               @_src_rect.width - diff, @_src_rect.height)
      echoln "clipped out left: #{diff} #{@tilemap.ox - self.ox} #{self.x}"
    elsif tmright - self.ox < self.x
      # clipped on right
      diff = self.x - tmright + self.ox
      self.src_rect = Rect.new(@_src_rect.x, @_src_rect.y,
                               @_src_rect.width - diff, @_src_rect.height)
      echoln "clipped out right: #{diff} #{tmright + self.ox} #{self.x}"
    else
      echoln "-not- clipped out left: #{diff} #{@tilemap.ox - self.ox} #{self.x}"
    end
  end
end

#===============================================================================
#
#===============================================================================
class Spriteset_Map
  attr_reader :map

  @@viewport0 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Panorama
  @@viewport0.z = -100
  @@viewport1 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Map, events, player, fog
  @@viewport1.z = 0
  @@viewport3 = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)   # Flashing
  @@viewport3.z = 500
  @@viewport_test = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
  @@viewport_test.z = 900

  # For access by Spriteset_Global.
  def self.viewport
    return @@viewport1
  end

  def initialize(map = nil)
    @map = (map) ? map : $game_map
    $scene.map_renderer.add_tileset(@map.tileset_name)
    @map.autotile_names.each { |filename| $scene.map_renderer.add_autotile(filename) }
    $scene.map_renderer.add_extra_autotiles(@map.tileset_id)
    @panorama = AnimatedPlane.new(@@viewport0)
    @fog = AnimatedPlane.new(@@viewport1)
    @fog.z = 3000
    @character_sprites = []
    @map.events.keys.sort.each do |i|
      sprite = Sprite_Character.new(@@viewport1, @map.events[i])
      @character_sprites.push(sprite)
    end
    EventHandlers.trigger(:on_new_spriteset_map, self, @@viewport1)
    #createWaterMap
    update
  end

  def dispose
    if $scene.is_a?(Scene_Map)
      $scene.map_renderer.remove_tileset(@map.tileset_name)
      @map.autotile_names.each { |filename| $scene.map_renderer.remove_autotile(filename) }
      $scene.map_renderer.remove_extra_autotiles(@map.tileset_id)
    end
    @panorama.dispose
    @fog.dispose
    @character_sprites.each { |sprite| sprite.dispose }
    @panorama = nil
    @fog = nil
    @character_sprites.clear
    @water_sprite&.dispose
  end

  def getAnimations
    return @usersprites
  end

  def restoreAnimations(anims)
    @usersprites = anims
  end

  def update
    if @panorama_name != @map.panorama_name || @panorama_hue != @map.panorama_hue
      @panorama_name = @map.panorama_name
      @panorama_hue  = @map.panorama_hue
      @panorama.set_panorama(nil) if !@panorama.bitmap.nil?
      @panorama.set_panorama(@panorama_name, @panorama_hue) if !nil_or_empty?(@panorama_name)
      Graphics.frame_reset
    end
    if @fog_name != @map.fog_name || @fog_hue != @map.fog_hue
      @fog_name = @map.fog_name
      @fog_hue = @map.fog_hue
      @fog.set_fog(nil) if !@fog.bitmap.nil?
      @fog.set_fog(@fog_name, @fog_hue) if !nil_or_empty?(@fog_name)
      Graphics.frame_reset
    end
    tmox = (@map.display_x / Game_Map::X_SUBPIXELS).round
    tmoy = (@map.display_y / Game_Map::Y_SUBPIXELS).round
    @@viewport1.rect.set(0, 0, Graphics.width, Graphics.height)
    @@viewport1.ox = 0
    @@viewport1.oy = 0
    @@viewport1.ox += $game_screen.shake
    @panorama.ox = tmox / 2
    @panorama.oy = tmoy / 2
    @fog.ox         = tmox + @map.fog_ox
    @fog.oy         = tmoy + @map.fog_oy
    @fog.zoom_x     = @map.fog_zoom / 100.0
    @fog.zoom_y     = @map.fog_zoom / 100.0
    @fog.opacity    = @map.fog_opacity
    @fog.blend_type = @map.fog_blend_type
    @fog.tone       = @map.fog_tone
    @panorama.update
    @fog.update
    @character_sprites.each do |sprite|
      sprite.update
    end
    @@viewport1.tone = $game_screen.tone
    @@viewport3.color = $game_screen.flash_color
    @@viewport1.update
    @@viewport3.update
    @water_sprite&.update
  end

  class DummyTile
    attr_accessor :filename
    attr_accessor :src_rect

    def initialize
      @filename = ""
      @src_rect = Rect.new(0, 0, 32, 32)
    end
  end

  class WaterSprite < Sprite
    def initialize(viewport, bitmap, map)
      super(viewport)
      @map = map
      self.bitmap = bitmap
      self.src_rect = Rect.new(0, 0, bitmap.width / 8, bitmap.height / 8)
      @time = System.uptime
      @frame = 0
      @sun_bitmaps = [
        Bitmap.new("Graphics/Pictures/LE.png"),
        Bitmap.new("Graphics/Pictures/LE2.png")
      ]
      @sun = Sprite.new(viewport)
      @sun.pattern = @sun_bitmaps[0]
      @sun.pattern_tile = false
      @sun.pattern_blend_type = 0
      @sun.pattern_opacity = 192
      @sun.bitmap = Bitmap.new(@sun.pattern.width, @sun.pattern.height)
      @sun.zoom_x = 2
      @sun.zoom_y = 2
      @sun.z = 1
      @sun.x = 120
      @sun.y = 120
      @sun_rect = Rect.new(0, 0, @sun.bitmap.width, @sun.bitmap.height)
      @sun_origin = [Graphics.width / 2, Graphics.height + 150]
    end

    def update
      self.x = -(@map.display_x.to_f / Game_Map::X_SUBPIXELS / 2).round * 2
      self.y = -(@map.display_y.to_f / Game_Map::Y_SUBPIXELS / 2).round * 2
      new_time = System.uptime
      if new_time - @time > 0.1
        @time = new_time
        @frame = (@frame + 1) % 64
        self.src_rect.x = (self.bitmap.width / 8) * (@frame % 8)
        self.src_rect.y = (self.bitmap.height / 8) * (@frame / 8)
        time_now = pbGetTimeNow
        hour = time_now.hour
        if hour >= 6 && hour < 20
          @sun.pattern = @sun_bitmaps[0]
          time_of_day = ((hour - 6) * 60 * 60 + time_now.min * 60 + time_now.sec).to_f / (14 * 60 * 60)
        elsif hour < 4 || hour >= 20
          @sun.pattern = @sun_bitmaps[1]
          hour = (hour < 6) ? (hour + 4) : (hour - 20)
          time_of_day = (hour * 60 * 60 + time_now.min * 60 + time_now.sec).to_f / (8 * 60 * 60)
        else
          time_of_day = 1.5
        end
        sun_angle = time_of_day * (Math::PI * 2 / 3) + Math::PI / 6
        s = Math.sin(sun_angle)
        c = Math.cos(sun_angle)
        @sun.x = -200
        @sun.y = Graphics.height + 150
        @sun.x -= @sun_origin[0]
        @sun.y -= @sun_origin[1]
        new_sun_x = @sun.x * c - @sun.y * s
        new_sun_y = @sun.x * s + @sun.y * c
        @sun.x = ((new_sun_x + @sun_origin[0] - @sun.bitmap.width / 2) / 2).round * 2
        @sun.y = ((new_sun_y + @sun_origin[1] - @sun.bitmap.height / 2) / 2).round * 2
        pbDayNightTint(self)
        pbDayNightTint(@sun)
      end
      self.bitmap.blt(
        @sun_rect.x, @sun_rect.y,
        @sun.bitmap,
        Rect.new(0, 0, @sun_rect.width, @sun_rect.height)
      )
      @sun_rect.x = self.src_rect.x - (self.x - @sun.x) / 2
      @sun_rect.y = self.src_rect.y - (self.y - @sun.y) / 2
      @sun.bitmap.clear
      @sun.bitmap.blt(0, 0, self.bitmap, @sun_rect)
      self.bitmap.clear_rect(@sun_rect)
      @sun.update
      super
    end

    def dispose
      @sun_bitmaps.each do |bm|
        bm.dispose
      end
      @sun.bitmap = nil
      @sun.dispose
      super
    end
  end

  def tileHasWater(tileset, tile)
    pixel = tileset.get_pixel(tile.src_rect.x + 8 * 2, tile.src_rect.y + 8 * 2)
    return true if pixel.alpha == 1
    pixel = tileset.get_pixel(tile.src_rect.x * 2, tile.src_rect.y * 2)
    return true if pixel.alpha == 1
    pixel = tileset.get_pixel(tile.src_rect.x + 15 * 2, tile.src_rect.y * 2)
    return true if pixel.alpha == 1
    pixel = tileset.get_pixel(tile.src_rect.x * 2, tile.src_rect.y + 15 * 2)
    return true if pixel.alpha == 1
    pixel = tileset.get_pixel(tile.src_rect.x + 15 * 2, tile.src_rect.y + 15 * 2)
    return true if pixel.alpha == 1
    return false
  end

  def tileHasRiver(tileset, tile)
    pixel = tileset.get_pixel(tile.src_rect.x + 8 * 2, tile.src_rect.y + 8 * 2)
    return true if pixel.alpha == 1 && pixel.green == 0 && pixel.blue == 255
    pixel = tileset.get_pixel(tile.src_rect.x * 2, tile.src_rect.y * 2)
    return true if pixel.alpha == 1 && pixel.green == 0 && pixel.blue == 255
    pixel = tileset.get_pixel(tile.src_rect.x + 15 * 2, tile.src_rect.y * 2)
    return true if pixel.alpha == 1 && pixel.green == 0 && pixel.blue == 255
    pixel = tileset.get_pixel(tile.src_rect.x * 2, tile.src_rect.y + 15 * 2)
    return true if pixel.alpha == 1 && pixel.green == 0 && pixel.blue == 255
    pixel = tileset.get_pixel(tile.src_rect.x + 15 * 2, tile.src_rect.y + 15 * 2)
    return true if pixel.alpha == 1 && pixel.green == 0 && pixel.blue == 255
    return false
  end

  def createWaterMap
    if false
      time_now = System.uptime
      echoln "load start"
      water_bitmap = Bitmap.new("test_file.png")
      echoln "load end"
      echoln (System.uptime - time_now).to_s
      @water_sprite = WaterSprite.new(@@viewport1, water_bitmap, @map)
      @water_sprite.z = 1
      @water_sprite.zoom_x = 2
      @water_sprite.zoom_y = 2
      return
    end
    
    echoln "watermap start"
    tileset = $scene.map_renderer.tilesets[@map.tileset_name]
    tile = DummyTile.new()
    tile.filename = @map.tileset_name
    blank = Color.new(0, 0, 0, 0)
    water_bitmaps = []
    for i in 0...64
      water_bitmaps.push(Bitmap.new(@map.width * 16, @map.height * 16))
    end

    # Map out what tiles have water
    water_map = []
    for i in 0...@map.height
      water_map.push([false] * @map.width)
    end
    for my in 0...(@map.height)
      for mx in 0...(@map.width)
        for i in 0...3
          $scene.map_renderer.tilesets.set_src_rect(tile, @map.data[mx, my, i])
          if tileHasWater(tileset, tile)
            water_map[my][mx] = true
            break
          end
        end
      end
    end

    # Map out the movement of rivers
    river_map = []
    for i in 0...@map.height
      river_map.push([[0, 0]] * @map.width)
    end
    for my in 0...(@map.height)
      for mx in 0...(@map.width)
        if water_map[my][mx]
          for i in 0...3
            $scene.map_renderer.tilesets.set_src_rect(tile, @map.data[mx, my, i])
            if tileHasRiver(tileset, tile)
              distance = [0.0, 0.0, 0.0]
              while water_map[my][mx + distance[0]]
                distance[0] += 1
                if mx + distance[0] >= @map.width
                  distance[0] = [distance[0], 10].max
                  break
                end
              end
              while water_map[my + distance[1]][mx]
                distance[1] += 1
                if my + distance[1] >= @map.height
                  distance[1] = [distance[1], 10].max
                  break
                end
              end
              while water_map[my + distance[2]][mx + distance[2]]
                distance[2] += 1
                if mx + distance[2] >= @map.width || my + distance[2] >= @map.height
                  distance[2] = [distance[2], 10].max
                  break
                end
              end
              #if mx - 1 < 0 || water_map[my][mx - 1]
              #  distance[0] += 4
              #end
              #if my - 1 < 0 || water_map[my - 1][mx]
              #  distance[1] += 4
              #end
              #if mx - 1 < 0 || my - 1 < 0 || water_map[my - 1][mx - 1]
              #  distance[2] += 4
              #end
              distance[0] **= 2
              distance[1] **= 2
              distance[2] **= 2
              total = distance[0] + distance[1] + distance[2]
              if total > 0
                river_map[my][mx] = [(distance[0] + distance[2] / 2) / total, (distance[1] + distance[2] / 2) / total]
              end
              break
            end
          end
        end
      end
    end

    # Create the entire water map
    time_now = System.uptime
    echoln "water start"
    water = pbGetAutotile("water_dynamic")
    for my in 0...(@map.height)
      echoln _INTL("water {1}/{2}", my, @map.height)
      for mx in 0...(@map.width)
        if (mx + my * @map.width) % 100 == 0
          Graphics.update
          Input.update
        end
        for i in 0...3
          $scene.map_renderer.tilesets.set_src_rect(tile, @map.data[mx, my, i])
          for ty in 0...16
            for tx in 0...16
              pixel = tileset.get_pixel(tile.src_rect.x + tx * 2, tile.src_rect.y + ty * 2)
              is_water = false
              if pixel.alpha == 1
                is_water = true
                if pixel.green == 255 && pixel.blue == 255
                  for frame in 0...64
                    layer1 = water.get_pixel((mx * 16 + tx + frame / 2) % 32, (my * 16 + ty - frame / 2) % 32)
                    layer2 = water.get_pixel((mx * 16 + tx - frame / 2) % 32, (my * 16 + ty + frame / 2) % 32 + 32)
                    water_bitmaps[frame].set_pixel(mx * 16 + tx, my * 16 + ty,
                      Color.new(
                        layer1.red + (layer2.red * layer2.alpha / 255 / 4),
                        layer1.green + (layer2.green * layer2.alpha / 255 / 4),
                        layer1.blue + (layer2.blue * layer2.alpha / 255 / 4),
                        160))
                  end
                else
                  for frame in 0...64
                    layer1 = water.get_pixel((mx * 16 + tx + frame / 2) % 32, (my * 16 + ty - frame / 2) % 32)
                    layer1.alpha = 192
                    water_bitmaps[frame].set_pixel(mx * 16 + tx, my * 16 + ty, layer1)
                  end
                end
              elsif is_water && pixel.alpha > 200
                is_water = false
                for frame in 0...32
                  water_bitmaps[frame].set_pixel(mx * 16 + tx, my * 16 + ty, blank)
                end
              end
            end
          end
        end
      end
    end
    echoln (System.uptime - time_now).to_s

    time_now = System.uptime
    echoln "ripples start"
    # Create river ripples
    for my in 0...(@map.height)
      echoln _INTL("ripples {1}/{2}", my, @map.height)
      for mx in 0...(@map.width)
        if (mx + my * @map.width) % 100 == 0
          Graphics.update
          Input.update
        end
        flow = river_map[my][mx]
        river_speed = 2.5
        if flow[0] != 0 || flow[1] != 0
          for ty in -8...24
            real_y = my * 16 + ty
            next if real_y < 0 || real_y >= @map.height * 16
            for tx in -8...24
              real_x = mx * 16 + tx
              next if real_x < 0 || real_x >= @map.width * 16
              for frame in 0...64
                pixel = water_bitmaps[(frame + i * 16) % 64].get_pixel(real_x, real_y)
                if pixel.alpha > 10
                  opacity = 0.06
                  dist = [-tx, -ty, tx - 16, tx - 16].max
                  if dist > 0
                    opacity = opacity * (8 - dist) / 8
                  end
                  water_pixel = water.get_pixel((real_x - frame * (flow[0] * river_speed).round) % 32, (real_y - frame * (flow[1] * river_speed).round) % 32 + 32)
                  water_bitmaps[frame].set_pixel(real_x, real_y,
                    Color.new(
                      pixel.red + (water_pixel.red * water_pixel.alpha / 255 * opacity).floor,
                      pixel.green + (water_pixel.green * water_pixel.alpha / 255 * opacity).floor,
                      pixel.blue + (water_pixel.blue * water_pixel.alpha / 255 * opacity).floor,
                      192))
                end
              end
            end
          end
        end
      end
    end
    echoln (System.uptime - time_now).to_s

    echoln "Saving to file"
    filename = "Map_water_test.dat"
    full_bitmap = Bitmap.new(@map.width * 16 * 8, @map.height * 16 * 8)
    for i in 0...64
      full_bitmap.blt(@map.width * 16 * (i % 8), @map.height * 16 * (i / 8), water_bitmaps[i], Rect.new(0, 0, @map.width * 16, @map.height * 16))
      water_bitmaps[i].dispose
    end
    full_bitmap.to_file("test_file.png")

    @water_sprite = WaterSprite.new(@@viewport1, full_bitmap, @map)
    @water_sprite.z = 1
    @water_sprite.zoom_x = 2
    @water_sprite.zoom_y = 2
    water.dispose

    echoln "watermap end"
  end

  def pbFindCharacterSprite(character)
    for sprite in @character_sprites
      if sprite.character == character
        return sprite
      end
    end
    return nil
  end

  def createPNG
    echoln "map start"
    tileset = $scene.map_renderer.tilesets[@map.tileset_name]
    tile = DummyTile.new()
    tile.filename = @map.tileset_name
    echoln @map.tileset_name
    blank = Color.new(0, 0, 0, 0)
    map_bitmap = Bitmap.new(@map.width * 32, @map.height * 32)

    # Map out what tiles have water
    for my in 0...(@map.height)
      for mx in 0...(@map.width)
        for i in 0...3
          next if @map.data[mx, my, i] < 384 # auto tile
          $scene.map_renderer.tilesets.set_src_rect(tile, @map.data[mx, my, i])
          map_bitmap.blt(mx * 32, my * 32, tileset, tile.src_rect)
        end
      end
    end

    map_bitmap.to_file("test_map.png")
  end

  def createHeightMap
    echoln "map start"
    tileset = $scene.map_renderer.tilesets[@map.tileset_name]
    tile = DummyTile.new()
    tile.filename = @map.tileset_name
    echoln @map.tileset_name
    blank = Color.new(0, 0, 0, 0)
    tile_height_bitmap = AnimatedBitmap.new("Graphics/Testing/HeightMaps/" + @map.tileset_name).deanimate
    tile_height_map = TilemapRenderer::TilesetWrapper.wrapTileset(tile_height_bitmap)
    map_bitmap = Bitmap.new(@map.width * 32, @map.height * 32)

    heights = []
    offsets = []
    for i in 0...3
      heights.push([])
      offsets.push([])
      for y in 0...(@map.height * 16)
        heights[i].push([0] * (@map.width * 16))
        offsets[i].push([0] * (@map.width * 16))
      end
    end

    updates = 0
    # Map out in columns
    for i in 0...3
      echoln _INTL("layer {1}/{2}", i + 1, 3)
      for x in 0...(@map.width * 16)
        height = 0
        ground_levels = []
        ground_level = 0
        for oy in 1..(@map.height * 16)
          if (x + oy * @map.width) % 10000 == 0
            Graphics.update
            Input.update
            updates += 1
          end
          y = @map.height * 16 - oy
          mx = (x / 16).floor
          my = (y / 16).floor
          if @map.data[mx, my, i] >= 384 # not auto tile
            $scene.map_renderer.tilesets.set_src_rect(tile, @map.data[mx, my, i])
            tx = x % 16
            ty = y % 16
            pixel = tile_height_map.get_pixel(tile.src_rect.x + tx * 2, tile.src_rect.y + ty * 2)
            alpha = pixel.alpha.to_i
            if alpha > 0
              is_up = (alpha & 1 == 1)
              set_ground_level = (alpha & 2 == 0)
              if set_ground_level
                ground_levels.push(height)
                ground_level = height
              end
              if is_up
                height += pixel.red
              else
                height -= pixel.red
                ground_level = [ground_level, height].min
                while ground_levels.length > 0 && ground_levels[ground_levels.length - 1] > height
                  ground_levels.pop
                end
              end
            end
            height = height.floor
          end
          # next if y + height >= @map.height * 16
          heights[i][y][x] = height
          offsets[i][y][x] = ground_level #(ground_levels.length < 1 ? 0 : ground_levels[ground_levels.length - 1])
        end
      end
    end

    for y in 0...(@map.height * 16)
      for x in 0...(@map.width * 16)
        height = heights[0][y][x] + heights[1][y][x] + heights[2][y][x]
        offset = offsets[0][y][x] + offsets[1][y][x] + offsets[2][y][x]
        map_bitmap.fill_rect(x * 2, y * 2, 2, 2, Color.new(height, 0, offset, 255))
      end
    end

    echoln _INTL("Update seconds: {1}", updates / 60)

    map_bitmap.to_file("test_height_map.png")

    tile_height_map.dispose
    
    return

    # Create the entire water map
    time_now = System.uptime
    echoln "water start"
    water = pbGetAutotile("water_dynamic")
    for my in 0...(@map.height)
      echoln _INTL("water {1}/{2}", my, @map.height)
      for mx in 0...(@map.width)
        if (mx + my * @map.width) % 100 == 0
          Graphics.update
          Input.update
        end
        for i in 0...3
          $scene.map_renderer.tilesets.set_src_rect(tile, @map.data[mx, my, i])
          for ty in 0...16
            for tx in 0...16
              pixel = tileset.get_pixel(tile.src_rect.x + tx * 2, tile.src_rect.y + ty * 2)
              is_water = false
              if pixel.alpha == 1
                is_water = true
                if pixel.green == 255 && pixel.blue == 255
                  for frame in 0...64
                    layer1 = water.get_pixel((mx * 16 + tx + frame / 2) % 32, (my * 16 + ty - frame / 2) % 32)
                    layer2 = water.get_pixel((mx * 16 + tx - frame / 2) % 32, (my * 16 + ty + frame / 2) % 32 + 32)
                    water_bitmaps[frame].set_pixel(mx * 16 + tx, my * 16 + ty,
                      Color.new(
                        layer1.red + (layer2.red * layer2.alpha / 255 / 4),
                        layer1.green + (layer2.green * layer2.alpha / 255 / 4),
                        layer1.blue + (layer2.blue * layer2.alpha / 255 / 4),
                        160))
                  end
                else
                  for frame in 0...64
                    layer1 = water.get_pixel((mx * 16 + tx + frame / 2) % 32, (my * 16 + ty - frame / 2) % 32)
                    layer1.alpha = 192
                    water_bitmaps[frame].set_pixel(mx * 16 + tx, my * 16 + ty, layer1)
                  end
                end
              elsif is_water && pixel.alpha > 200
                is_water = false
                for frame in 0...32
                  water_bitmaps[frame].set_pixel(mx * 16 + tx, my * 16 + ty, blank)
                end
              end
            end
          end
        end
      end
    end
    echoln (System.uptime - time_now).to_s

    time_now = System.uptime
    echoln "ripples start"
    # Create river ripples
    for my in 0...(@map.height)
      echoln _INTL("ripples {1}/{2}", my, @map.height)
      for mx in 0...(@map.width)
        if (mx + my * @map.width) % 100 == 0
          Graphics.update
          Input.update
        end
        flow = river_map[my][mx]
        river_speed = 2.5
        if flow[0] != 0 || flow[1] != 0
          for ty in -8...24
            real_y = my * 16 + ty
            next if real_y < 0 || real_y >= @map.height * 16
            for tx in -8...24
              real_x = mx * 16 + tx
              next if real_x < 0 || real_x >= @map.width * 16
              for frame in 0...64
                pixel = water_bitmaps[(frame + i * 16) % 64].get_pixel(real_x, real_y)
                if pixel.alpha > 10
                  opacity = 0.06
                  dist = [-tx, -ty, tx - 16, tx - 16].max
                  if dist > 0
                    opacity = opacity * (8 - dist) / 8
                  end
                  water_pixel = water.get_pixel((real_x - frame * (flow[0] * river_speed).round) % 32, (real_y - frame * (flow[1] * river_speed).round) % 32 + 32)
                  water_bitmaps[frame].set_pixel(real_x, real_y,
                    Color.new(
                      pixel.red + (water_pixel.red * water_pixel.alpha / 255 * opacity).floor,
                      pixel.green + (water_pixel.green * water_pixel.alpha / 255 * opacity).floor,
                      pixel.blue + (water_pixel.blue * water_pixel.alpha / 255 * opacity).floor,
                      192))
                end
              end
            end
          end
        end
      end
    end
    echoln (System.uptime - time_now).to_s

    echoln "Saving to file"
    filename = "Map_water_test.dat"
    full_bitmap = Bitmap.new(@map.width * 16 * 8, @map.height * 16 * 8)
    for i in 0...64
      full_bitmap.blt(@map.width * 16 * (i % 8), @map.height * 16 * (i / 8), water_bitmaps[i], Rect.new(0, 0, @map.width * 16, @map.height * 16))
      water_bitmaps[i].dispose
    end
    full_bitmap.to_file("test_file.png")

    @water_sprite = WaterSprite.new(@@viewport1, full_bitmap, @map)
    @water_sprite.z = 1
    @water_sprite.zoom_x = 2
    @water_sprite.zoom_y = 2
    water.dispose

    echoln "watermap end"
  end
end