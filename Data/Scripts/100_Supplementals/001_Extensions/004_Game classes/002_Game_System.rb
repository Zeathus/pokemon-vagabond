class Game_System

  attr_accessor :message_effect
  attr_accessor :bgm_override

  alias sup_initialize initialize

  def initialize
    sup_initialize
    @message_effect = nil
    @bgm_override = nil
  end

end