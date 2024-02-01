class Sprite_Character

  alias sup_initialize initialize
  alias sup_dispose dispose
  alias sup_update update

  def initialize(viewport, character = nil)
    @isPartner   = character.is_a?(String)
    @partner     = nil
    @marker_id   = -1
    @marker      = nil
    @marker_text = nil
    @text_bubble = nil
    if Supplementals::CHARACTER_DROP_SHADOWS && !@isPartner
      @dropshadow = DropShadowSprite.new(self, character, viewport)
    end
    sup_initialize(viewport, character)
    @dropshadow&.update
    if @isPartner
      @real_x = 0
      @real_y = 0
      @direction = 0
      @visibility = true
    end
  end

  def set_text_bubble(value)
    @text_bubble = value
  end

  def initPartner
    if @partner
      @partner.dispose
    end
    @partner = Sprite_Character.new(
      self.viewport, _INTL("member{1}", getPartyActiveSprite(1)))
    @partner.setRealXY(@character.real_x, @character.real_y)
  end

  def partner
    return @partner
  end

  def visibility=(value)
    @visibility = value
  end

  def setRealXY(val_x,val_y)
    @real_x = val_x
    @real_y = val_y
  end

  def dispose
    @dropshadow&.dispose
    @marker&.dispose
    @text_bubble&.on_event_dispose
    @partner&.dispose
    sup_dispose
  end

  def update
    sup_update
    if @text_bubble
      @text_bubble.update
      if @text_bubble.disposed?
        @text_bubble = nil
      end
    end
    @dropshadow&.update
    if @partner
      sx = @character.pattern * @cw
      sy = ((@character.direction - 2) / 2) * @ch
      @partner.updatePartner(self, sx, sy, @character_name[/run/])
    end
    if @marker_id != @character.marker_id
      @marker_id = @character.marker_id
      @marker_text = @character.marker_text
      if @marker_id == -1
        @marker&.dispose
      else
        if @marker_text
          if @marker
            @marker.dispose
          end
          @marker = Sprite.new(self.viewport)
          bm = Bitmap.new(64, 48)
          pbSetSmallFont(bm)
          text_width = bm.text_size(@marker_text).width
          if bm.width <= text_width
            bm = Bitmap.new(text_width + 8, 48)
            pbSetSmallFont(bm)
          end
          src_bm = RPG::Cache.load_bitmap("","Graphics/Pictures/Quests/markers")
          bm.blt(bm.width / 2 - 16, 0, src_bm, Rect.new(32 * (@marker_id % 4), 48 * (@marker_id / 4).floor, 32, 48))
          src_bm.dispose
          pbDrawTextPositions(bm, [[_INTL(@marker_text), bm.width / 2, 6, 2, Color.new(252,252,252), Color.new(0,0,0), true]])
          @marker.bitmap = bm
        else
          if !@marker
            @marker = IconSprite.new(0, 0, self.viewport)
            @marker.setBitmap("Graphics/Pictures/Quests/markers")
          end
        end
        @marker.src_rect = Rect.new(32 * (@marker_id % 4), 48 * (@marker_id / 4).floor, 32, 48) if !@marker_text
        @marker.ox = @marker_text ? (@marker.bitmap.width / 2) : 16
      end
    end
    if @marker && !@marker.disposed?
      @marker.x = self.x
      @marker.y = self.y
      @marker.z = self.z
      if @ch
        @marker.oy = @ch + 40
      else
        @marker.oy = 40
      end
      @marker&.update
    end
  end

  def updatePartner(owner, sx, sy, run)
    if @text_bubble
      @text_bubble.update
      if @text_bubble.disposed?
        @text_bubble = nil
      end
    end
    RPG::Sprite.instance_method(:update).bind(self).call
    fullcharactername = _INTL("{1}_{2}", @character, (run ? "run" : "walk"))
    if @charactername != fullcharactername
      @charactername = fullcharactername
      @charbitmap.dispose if @charbitmap
      @charbitmap = AnimatedBitmap.new("Graphics/Characters/"+fullcharactername,
                                  owner.character.character_hue)
      @charbitmapAnimated=true
      @bushbitmap.dispose if @bushbitmap
      @bushbitmap=nil
      @cw = @charbitmap.width / 4
      @ch = @charbitmap.height / 4
      self.ox = @cw / 2
      self.oy = @ch
    end
    @charbitmap.update if @charbitmapAnimated
    self.bitmap = @charbitmap.bitmap
    self.visible = owner.visible
    self.visible = false if !@visibility || $PokemonGlobal.surfing
    self.z = owner.z

    time_now = System.uptime
    @p_last_update_time = time_now if !@p_last_update_time || @p_last_update_time > time_now
    @p_delta_t = time_now - @p_last_update_time
    @p_last_update_time = time_now

    owner_direction = [0, 2, 4, 6][sy / @ch]

    dif_x = @real_x - owner.character.real_x
    dif_y = @real_y - owner.character.real_y

    distance = Game_Map::TILE_WIDTH * 4
    speed = owner.character.move_speed * distance * 2 * @p_delta_t

    if (dif_x.abs > 256 || dif_y.abs > 256)
      @real_x = owner.character.real_x
      @real_y = owner.character.real_y
    elsif (dif_x != 0 && dif_y != 0) ||
        dif_x.abs > distance || dif_y.abs > distance
      goal_x = owner.character.real_x
      goal_y = owner.character.real_y
      if owner_direction == 2
        goal_x += distance
      elsif owner_direction == 4
        goal_x -= distance
      end
      if owner_direction == 0
        goal_y -= distance
      elsif owner_direction == 6
        goal_y += distance
      end

      dif_x = @real_x - goal_x
      dif_y = @real_y - goal_y

      if dif_x.abs > 0
        if dif_x > 0
          @real_x -= speed
          @real_x = goal_x if @real_x < goal_x
        else
          @real_x += speed
          @real_x = goal_x if @real_x > goal_x
        end
      end
      if dif_y.abs > 0
        if dif_y > 0
          @real_y -= speed
          @real_y = goal_y if @real_y < goal_y
        else
          @real_y += speed
          @real_y = goal_y if @real_y > goal_y
        end
      end

      if dif_y.abs > dif_x.abs
        @direction = (dif_y > 0) ? 6 : 0
      elsif dif_x.abs > dif_y.abs
        @direction = (dif_x > 0) ? 2 : 4
      end
    else
      sx = 0
      if dif_y.abs > dif_x.abs
        @direction = (dif_y > 0) ? 6 : 0
      elsif dif_x.abs > dif_y.abs
        @direction = (dif_x > 0) ? 2 : 4
      end
    end

    self.x = screen_x(@real_x)
    self.y = screen_y(@real_y)
    self.src_rect.set(sx, @direction * @ch / 2, @cw, @ch)

    if (@real_y - owner.character.real_y) < 4
      self.z = owner.z - 1
    end

    pbDayNightTint(self)

    self.zoom_x = owner.zoom_x
    self.zoom_y = owner.zoom_y
    self.opacity = owner.opacity
    self.blend_type = owner.blend_type
    self.angle = owner.angle
  end

  def screen_x(real_x)
    return (real_x - $game_map.display_x + 3) / 4 + (Game_Map::TILE_WIDTH/2)
  end

  def screen_y(real_y)
    y = (real_y - $game_map.display_y + 3) / 4 + (Game_Map::TILE_HEIGHT)
    return y
  end

  def snapPartner
    @partner&.snapToLeader(self)
  end

  def snapToLeader(owner)
    @real_x = owner.character.real_x
    @real_y = owner.character.real_y
    distance = Game_Map::TILE_WIDTH * 4
    case $game_player.direction
    when 2
      @real_y -= distance
    when 4
      @real_x += distance
    when 6
      @real_x -= distance
    when 8
      @real_y += distance
    end
    self.x = screen_x(@real_x)
    self.y = screen_y(@real_y)
  end

end