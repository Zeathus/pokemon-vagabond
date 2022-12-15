class Sprite_Character

  alias sup_initialize initialize
  alias sup_dispose dispose
  alias sup_update update

  def initialize(viewport, character = nil)
    @marker_id   = -1
    @marker      = nil
    @marker_text = nil
    @text_bubble = nil
    if Supplementals::CHARACTER_DROP_SHADOWS
      @dropshadow = DropShadowSprite.new(self, character, viewport)
    end
    sup_initialize(viewport, character)
    @dropshadow.update
  end

  def dispose
    @dropshadow&.dispose
    @marker&.dispose
    @text_bubble&.on_event_dispose
    sup_dispose
  end

  def update
    sup_update
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
        if @ch
          @marker.oy = @ch + 40
        else
          @marker.oy = 40
        end
      end
    end
    if @marker && !@marker.disposed?
      @marker.x = self.x
      @marker.y = self.y
      @marker.z = self.z
      @marker&.update
    end
  end

end