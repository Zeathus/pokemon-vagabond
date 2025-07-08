class DropShadowSprite
  attr_accessor :visible
  attr_accessor :character

  def initialize(sprite, event, viewport=nil, partner=false)
    @rsprite  = sprite
    @sprite   = nil
    @event    = event
    @disposed = false
    @viewport = viewport
    @partner  = partner
  end

  def dispose
    if !@disposed
      @sprite.dispose if @sprite
      @sprite=nil
      @disposed=true
    end
  end

  def disposed?
    @disposed
  end

  def visible=(value)
    @sprite.visible = value if @sprite
  end

  def angle=(value)
    @sprite.angle = value if @sprite
  end

  def update(tilemap=nil)
    return if disposed?
    if @event
      if @partner ||
          ((@event.character_name[/(trainer|NPC|pkmn|member)/] ||
          (@event != $game_player && @event.name[/_shadow/])) &&
          !(@event.character_name[/surf/]) &&
          !(@event != $game_player && @event.name[/noshadow/]))
        # Just-in-time creation of sprite
        if !@sprite
          @sprite=Sprite.new(@viewport)
          @sprite.bitmap=Bitmap.new(32,16)
          @sprite.bitmap.fill_rect(4,2,24,10,Color.new(0,0,0))
          @sprite.bitmap.fill_rect(2,4,28,8,Color.new(0,0,0))
          @sprite.bitmap.fill_rect(0,6,32,4,Color.new(0,0,0))
          @sprite.bitmap.fill_rect(6,12,20,2,Color.new(0,0,0))
          @sprite.ox = 16
          @sprite.oy = 10
        end
        if @sprite
          @sprite.visible = @rsprite.visible
          if @sprite.visible
            @sprite.x = @rsprite.x
            @sprite.y = @rsprite.y - 4
            if @partner ? (@rsprite.bush_depth && @rsprite.bush_depth > 0) : @event.bush_depth > 0
              @sprite.y -= (@partner ? @rsprite : @event).bush_depth - 8
            end
            if @partner
              @sprite.y -= @rsprite.partner_jump_y
            else
              if @event.jumping?
                jump_progress = (@event.jump_fraction - 0.5).abs
                @sprite.y -= @event.jump_peak * ((4 * (jump_progress**2)) - 1) - 1
              end
              @sprite.y -= @event.y_offset
              @sprite.y += @event.y_shadow_offset
            end
            @sprite.z = @rsprite.z - 1 # below the character
            @sprite.opacity=(@rsprite.opacity*100.0)/255.0
          end
        end
      else
        if @sprite
          @sprite.dispose
          @sprite=nil
        end
      end
    end
  end
end