class Sprite_Character < RPG::Sprite

  alias sup_initialize initialize
  alias sup_dispose dispose
  alias sup_update update

  def initialize(viewport, character = nil)
    @marker_id   = -1
    @marker      = nil
    @marker_text = nil
    @text_bubble = nil
    @proximity_textboxes = {}
    if Supplementals::CHARACTER_DROP_SHADOWS
      @dropshadow = DropShadowSprite.new(self, character, viewport)
    end
    sup_initialize(viewport, character)
    @dropshadow&.update
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

  def dispose
    @dropshadow&.dispose
    @marker&.dispose
    @text_bubble&.on_event_dispose
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
  end

end