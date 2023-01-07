class Game_Character
  attr_accessor :marker_id
  attr_accessor :marker_text

  alias sup_initialize initialize

  def initialize(map = nil)
    sup_initialize(map)
    @marker_id   = -1
    @marker_text = nil
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
  
end