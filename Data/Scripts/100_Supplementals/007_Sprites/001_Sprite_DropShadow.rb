class DropShadowSprite
  attr_accessor :visible
  attr_accessor :character

  def initialize(sprite, event, viewport=nil)
    @rsprite  = sprite
    @sprite   = nil
    @event    = event
    @disposed = false
    @viewport = viewport
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

  def update(tilemap=nil)
    return if disposed?
    if @event && @event!=$game_player
      if (@event.character_name[/trainer/] || @event.character_name[/NPC/] ||
          @event.character_name[/pkmn/]) && !@event.character_name[/member/]
        # Just-in-time creation of sprite
        if !@sprite
          @sprite=Sprite.new(@viewport)
          @sprite.bitmap=Bitmap.new(32,16)
          @sprite.bitmap.fill_rect(4,2,24,10,Color.new(0,0,0))
          @sprite.bitmap.fill_rect(2,4,28,8,Color.new(0,0,0))
          @sprite.bitmap.fill_rect(0,6,32,4,Color.new(0,0,0))
          @sprite.bitmap.fill_rect(6,12,20,2,Color.new(0,0,0))
        end
        if @sprite
          @sprite.visible
          @rsprite.visible
          @sprite.visible = @rsprite.visible
          if @sprite.visible
            @sprite.x = @rsprite.x - 16
            @sprite.y = @rsprite.y - 14
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