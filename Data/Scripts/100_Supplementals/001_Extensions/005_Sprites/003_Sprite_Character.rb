class Sprite_Character < RPG::Sprite

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
    @proximity_textboxes = {}
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

  def color=(value)
    super(value)
    @marker&.color = value
    @proximity_textboxes.each do |direction, textbox|
      textbox.color = value
    end
  end

  def tone=(value)
    super(value)
    @marker&.tone = value
    @proximity_textboxes.each do |direction, textbox|
      textbox.tone = value
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
    @proximity_textboxes.each do |direction, textbox|
      textbox.dispose
    end
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
    if $game_variables && $game_player == @character
      target_angle = $game_variables[PLAYER_ROTATION] || 0
      if self.angle < target_angle
        self.angle = [self.angle + 2, target_angle].min
      elsif self.angle > target_angle
        self.angle = [self.angle - 2, target_angle].max
      end
    end
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
          src_bm = RPG::Cache.load_bitmap("","Graphics/UI/Quests/markers")
          bm.blt(bm.width / 2 - 16, 0, src_bm, Rect.new(32 * (@marker_id % 4), 48 * (@marker_id / 4).floor, 32, 48))
          src_bm.dispose
          pbDrawTextPositions(bm, [[_INTL(@marker_text), bm.width / 2, 6, 2, Color.new(252,252,252), Color.new(0,0,0), true]])
          @marker.bitmap = bm
        else
          if !@marker
            @marker = IconSprite.new(0, 0, self.viewport)
            @marker.setBitmap("Graphics/UI/Quests/markers")
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
    if $game_player && ($game_player.x - @character.x).abs < 4 && ($game_player.y - (@character.y + 1)).abs < 5
      #echoln @character.proximity_texts.length.to_s if @character.id == 38
      @character.proximity_texts.each do |direction, text|
        textbox = @proximity_textboxes[direction]
        if textbox
          if textbox.opacity < 255
            textbox.opacity += 8
            textbox.contents_opacity += 8
          end
        else
          textbox = Window_AdvancedTextPokemon.new("", 1)
          textbox.viewport = self.viewport
          textbox.setSkin("Graphics/Windowskins/floating_text", false)
          textbox.text = ""
          textbox.resizeToFit(text, Graphics.width * 2 / 5)
          textbox.letterbyletter = false
          textbox.text = text
          textbox.contents.font.name = "Small"
          textbox.opacity = 0
          textbox.contents_opacity = 0
          textbox.z = 99999
          @proximity_textboxes[direction] = textbox
        end
      end
    else
      cleared = false
      @proximity_textboxes.each do |direction, textbox|
        textbox.opacity -= 8
        textbox.contents_opacity -= 8
        if textbox.opacity <= 0
          textbox.dispose
          cleared = true
        end
      end
      @proximity_textboxes = {} if cleared
    end
    @proximity_textboxes.each do |direction, textbox|
      case direction
      when :left
        textbox.x = self.x - textbox.width - self.src_rect.width / 4 - 8
        textbox.y = self.y - textbox.height / 2 - self.src_rect.height / 2
      when :right
        textbox.x = self.x + self.src_rect.width / 4 + 8
        textbox.y = self.y - textbox.height / 2 - self.src_rect.height / 2
      when :top
        textbox.x = self.x - textbox.width / 2
        textbox.y = self.y - textbox.height - self.src_rect.height + 4
      when :bottom
        textbox.x = self.x - textbox.width / 2
        textbox.y = self.y - 4
      end
    end
    if $game_switches[DRAWING_PENTAGRAM] && @character_name[/pentagram/]
      self.bitmap = pbDrawPentagram(self.bitmap, @charbitmap.bitmap)
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

    if !@next_target_x
      @next_target_x = owner.character.x
      @next_target_y = owner.character.y
    end
    if !@target_x
      @target_x = owner.character.x
      @target_y = owner.character.y
      @last_target_x = @target_x
      @last_target_y = @target_y
    end
    @post_move = 0 if !@post_move
    if owner.character.x != @next_target_x || owner.character.y != @next_target_y
      @last_target_x = @target_x
      @last_target_y = @target_y
      @target_x = @next_target_x
      @target_y = @next_target_y
      @next_target_x = owner.character.x
      @next_target_y = owner.character.y
      @post_move = 0
      @jumping = (@target_x - @last_target_x).abs > 1 || (@target_y - @last_target_y).abs > 1
    elsif ((@target_x - owner.character.x).abs > 2 || (@target_y - owner.character.y).abs > 2) &&
      owner.character.jump_timer && owner.character.move_time < owner.character.jump_timer
      @last_target_x = @target_x
      @last_target_y = @target_y
      @target_x = @next_target_x
      @target_x -= 1 if @last_target_x < owner.character.x
      @target_x += 1 if @last_target_x > owner.character.x
      @target_y = @next_target_y
      @target_y -= 1 if @last_target_y < owner.character.y
      @target_y += 1 if @last_target_y > owner.character.y
      @post_move = owner.character.jump_timer
      @jumping = true
    end
    
    if owner.character.x == @target_x && owner.character.y == @target_y
      self.visible = false
    end
    
    target_real_x = @target_x * Game_Map::REAL_RES_X
    target_real_y = @target_y * Game_Map::REAL_RES_Y
    dif_x = @real_x - target_real_x
    dif_y = @real_y - target_real_y

    distance = Game_Map::TILE_WIDTH * 4
    speed = owner.character.move_speed * distance * 2 * @p_delta_t
    
    if (@last_target_x != @target_x || @last_target_y != @target_y)
      move_time = owner.character.move_time
      move_timer = owner.character.move_timer || owner.character.jump_timer || move_time

      dif_x = @real_x - target_real_x
      dif_y = @real_y - target_real_y

      dist_x = (@last_target_x - @target_x).abs
      dist_y = (@last_target_y - @target_y).abs
      dist = dist_x + dist_y
      if !@jumping
        if @last_target_x != @target_x
          @real_x = lerp(@last_target_x, @target_x, move_time, move_timer) * Game_Map::REAL_RES_X
        end
        if @last_target_y != @target_y
          @real_y = lerp(@last_target_y, @target_y, move_time, move_timer) * Game_Map::REAL_RES_Y
        end
        @jump_fraction = nil
        @jump_peak = 0
      else
        if @post_move == 0
          dist = 1
        else
          dist = [(@last_target_x - owner.character.x).abs - 1, (@last_target_y - owner.character.y).abs - 1].max
          dist = 1 if dist <= 0
          move_time = owner.character.jump_time
          move_timer = owner.character.jump_timer ? (owner.character.jump_timer - @post_move) : (move_time * dist)
        end
        if @last_target_x != @target_x
          @real_x = lerp(@last_target_x, @target_x, move_time * dist, move_timer) * Game_Map::REAL_RES_X
        end
        if @last_target_y != @target_y
          @real_y = lerp(@last_target_y, @target_y, move_time * dist, move_timer) * Game_Map::REAL_RES_Y
        end
        # Player moved multiple blocks, should be jumping
        @jump_fraction = (move_timer) / (move_time * dist)
        @jump_peak = @post_move == 0 ? (dist * Game_Map::TILE_HEIGHT * 3 / 8) : owner.character.jump_peak
      end
      @real_x = @target_x * Game_Map::REAL_RES_X if (@real_x - (@target_x * Game_Map::REAL_RES_X)).abs < Game_Map::X_SUBPIXELS / 2
      @real_y = @target_y * Game_Map::REAL_RES_Y if (@real_y - (@target_y * Game_Map::REAL_RES_Y)).abs < Game_Map::Y_SUBPIXELS / 2

      if move_timer >= move_time * dist
        @last_target_x = @target_x
        @last_target_y = @target_y
        @real_x =  @target_x * Game_Map::REAL_RES_X
        @real_y =  @target_y * Game_Map::REAL_RES_Y
        @jump_fraction = nil
        @jump_peak = 0
      end

      if dif_y.abs > dif_x.abs
        @direction = (dif_y > 0) ? 6 : 0
      elsif dif_x.abs >= dif_y.abs && dif_x.abs != 0
        @direction = (dif_x > 0) ? 2 : 4
      end
    else
      sx = 0
      if dif_y.abs > dif_x.abs
        @direction = (dif_y > 0) ? 6 : 0
      elsif dif_x.abs >= dif_y.abs && dif_x.abs != 0
        @direction = (dif_x > 0) ? 2 : 4
      end
    end

    self.x = screen_x(owner, @real_x)
    self.y = screen_y(owner, @real_y)
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

  def screen_x(owner, real_x)
    ret = ((@real_x.to_f - owner.character.map.display_x) / Game_Map::X_SUBPIXELS).round
    ret += Game_Map::TILE_WIDTH / 2
    return ret
  end

  def screen_y(owner, real_y)
    ret = ret = ((@real_y.to_f - owner.character.map.display_y) / Game_Map::Y_SUBPIXELS).round
    ret += Game_Map::TILE_HEIGHT
    if @jump_fraction
      jump_progress = (@jump_fraction - 0.5).abs   # 0.5 to 0 to 0.5
      ret += @jump_peak * ((4 * (jump_progress**2)) - 1)
    end
    return ret
  end

  def snapPartner(behind = true)
    if behind
      @partner&.snapToLeader(self)
    else
      @partner&.snapOnLeader(self)
    end
  end

  def snapToLeader(owner)
    @real_x = owner.character.real_x
    @real_y = owner.character.real_y
    @next_target_x = owner.character.x
    @next_target_y = owner.character.y
    distance = Game_Map::TILE_WIDTH * 4
    case owner.character.direction
    when 2
      @last_target_x = @target_x = @next_target_x
      @last_target_y = @target_y = @next_target_y - 1
      @real_y -= distance
    when 4
      @last_target_x = @target_x = @next_target_x + 1
      @last_target_y = @target_y = @next_target_y
      @real_x += distance
    when 6
      @last_target_x = @target_x = @next_target_x - 1
      @last_target_y = @target_y = @next_target_y
      @real_x -= distance
    when 8
      @last_target_x = @target_x = @next_target_x
      @last_target_y = @target_y = @next_target_y + 1
      @real_y += distance
    end
    @direction = owner.character.direction - 2
    self.x = screen_x(owner, @real_x)
    self.y = screen_y(owner, @real_y)
  end

  def snapOnLeader(owner)
    @real_x = owner.character.real_x
    @real_y = owner.character.real_y
    @last_target_x = @target_x = @next_target_x = owner.character.x
    @last_target_y = @target_y = @next_target_y = owner.character.y
    @direction = owner.character.direction - 2
    self.x = screen_x(owner, @real_x)
    self.y = screen_y(owner, @real_y)
  end

end