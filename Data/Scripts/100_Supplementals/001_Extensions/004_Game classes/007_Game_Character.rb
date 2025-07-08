class Game_Character
  attr_accessor :marker_id
  attr_accessor :marker_text
  attr_accessor :marker_icon
  attr_accessor :proximity_texts
  attr_accessor :sprite_grid_size

  alias sup_initialize initialize

  def initialize(map = nil)
    @sprite_grid_size = [4, 4]
    sup_initialize(map)
    @marker_id   = -1
    @marker_text = nil
    @marker_icon = nil
    @proximity_texts = {}
  end
  
  def direction_fix=(value)
    @direction_fix = value
  end

  def direction_fix
    return @direction_fix
  end

  def step_anime=(value)
    @step_anime = value
  end

  def step_anime
    if $PokemonGlobal.diving || $PokemonGlobal.surfing
      return true
    end
    return @step_anime
  end

  def setOpacity(op)
    @opacity = op
  end

  def proximity_texts
    @proximity_texts = {} if !@proximity_texts
    return @proximity_texts
  end

  def sprite
    if $scene.is_a?(Scene_Map) && $scene.spriteset
      return $scene.spriteset($game_map.map_id).pbFindCharacterSprite(self)
    end
    return nil
  end
  
end