class Game_System

  attr_accessor :bgm_override

  alias sup_initialize initialize

  def initialize
    sup_initialize
    @bgm_override = nil
  end

end