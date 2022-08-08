class Game_Screen

  attr_reader :vfx_type

  alias sup_initialize initialize

  def initialize
    sup_initialize
    @vfx_type = PBVFX::None
  end

  def vfx(type)
    @vfx_type = type
  end

end