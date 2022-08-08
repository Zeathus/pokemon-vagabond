class Sprite_Reflection

  alias sup_update update

  def update
    sup_update
    @sprite.visible = false if $game_switches[Supplementals::HIDE_REFLECTIONS]
  end

end