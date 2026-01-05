class Sprite_Reflection

  alias sup_update update

  def update
    sup_update
    if @sprite && @sprite.visible && ($game_switches[Supplementals::HIDE_REFLECTIONS] || DISTORTION_MAP_IDS.include?($game_map.map_id))
      @sprite.visible = false
    end
  end

end