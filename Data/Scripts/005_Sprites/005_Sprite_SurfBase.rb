class Sprite_SurfBase
  attr_reader :visible

  def initialize(parent_sprite, viewport = nil)
    @parent_sprite = parent_sprite
    @sprite = nil
    @viewport = viewport
    @disposed = false
    @surfbitmap = AnimatedBitmap.new("Graphics/Characters/base_surf")
    @divebitmap = AnimatedBitmap.new("Graphics/Characters/base_dive")
    RPG::Cache.retain("Graphics/Characters/base_surf")
    RPG::Cache.retain("Graphics/Characters/base_dive")
    @cws = @surfbitmap.width / 4
    @chs = @surfbitmap.height / 4
    @cwd = @divebitmap.width / 4
    @chd = @divebitmap.height / 4
    @spawn_time = 0
    @despawn_time = 0
    update
  end

  def dispose
    return if @disposed
    @sprite&.dispose
    @sprite = nil
    @parent_sprite = nil
    @surfbitmap.dispose
    @divebitmap.dispose
    @disposed = true
  end

  def disposed?
    return @disposed
  end

  def event
    return @parent_sprite.character
  end

  def visible=(value)
    @visible = value
    @sprite.visible = value if @sprite && !@sprite.disposed?
  end

  def update
    return if disposed?
    if !$PokemonGlobal.surfing && !$PokemonGlobal.diving
      # Just-in-time disposal of sprite
      @despawn_time = 0
      @spawn_time = 0
      if @sprite
        @sprite.dispose
        @sprite = nil
      end
      return
    end
    # Just-in-time creation of sprite
    if !@sprite
      @sprite = Sprite.new(@viewport)
      @spawn_time = System.uptime
    end
    return if !@sprite
    if $PokemonGlobal.surfing
      @sprite.bitmap = @surfbitmap.bitmap
      cw = @cws
      ch = @chs
    elsif $PokemonGlobal.diving
      @sprite.bitmap = @divebitmap.bitmap
      cw = @cwd
      ch = @chd
    end
    sx = event.pattern_surf * cw
    sy = ((event.direction - 2) / 2) * ch
    @sprite.src_rect.set(sx, sy, cw, ch)
    if $game_temp.surf_base_coords
      spr_x = ((($game_temp.surf_base_coords[0] * Game_Map::REAL_RES_X) - event.map.display_x).to_f / Game_Map::X_SUBPIXELS).round
      spr_x += (Game_Map::TILE_WIDTH / 2)
      spr_x = ((spr_x - (Graphics.width / 2)) * TilemapRenderer::ZOOM_X) + (Graphics.width / 2) if TilemapRenderer::ZOOM_X != 1
      @sprite.x = spr_x
      spr_y = ((($game_temp.surf_base_coords[1] * Game_Map::REAL_RES_Y) - event.map.display_y).to_f / Game_Map::Y_SUBPIXELS).round
      spr_y += (Game_Map::TILE_HEIGHT / 2) + 16
      spr_y = ((spr_y - (Graphics.height / 2)) * TilemapRenderer::ZOOM_Y) + (Graphics.height / 2) if TilemapRenderer::ZOOM_Y != 1
      @sprite.y = spr_y
      if $game_temp.surf_base_coords[2] && @despawn_time == 0
        @despawn_time = System.uptime
      end
    else
      @sprite.x = @parent_sprite.x
      @sprite.y = @parent_sprite.y
    end
    @sprite.ox      = cw / 2
    @sprite.oy      = ch - 16   # Assume base needs offsetting
    @sprite.oy      -= event.bob_height
    @sprite.z       = event.screen_z(ch) - 1
    @sprite.zoom_x  = @parent_sprite.zoom_x
    @sprite.zoom_y  = @parent_sprite.zoom_y
    @sprite.tone    = @parent_sprite.tone
    @sprite.color   = @parent_sprite.color
    @sprite.opacity = @parent_sprite.opacity
    if @spawn_time + 0.2 > System.uptime
      progress = (((System.uptime - @spawn_time) / 0.2) * 255).floor
      @sprite.color   = Color.new(255, 255, 255, 300 - progress)
      @sprite.opacity = progress * 2
      @sprite.zoom_x  = [progress * 2.0 / 255, 1].min
      @sprite.zoom_y  = [progress * 2.0 / 255, 1].min
    elsif @despawn_time != 0 && @despawn_time + 0.1 <= System.uptime
      progress = 255 - [(((System.uptime - 0.1 - @despawn_time) / 0.2) * 255).floor, 255].min
      @sprite.color   = Color.new(255, 255, 255, 300 - progress)
      @sprite.opacity = progress * 2
      @sprite.zoom_x  = [progress * 2.0 / 255, 1].min
      @sprite.zoom_y  = [progress * 2.0 / 255, 1].min
    end
    self.visible = @parent_sprite.visible
  end
end
