# Show dust trail animation
EventHandlers.add(:on_step_taken, :dust_trail,
  proc { |event|
    next if !$scene.is_a?(Scene_Map)
    event.each_occupied_tile do |x, y|
      next if !$map_factory.getTerrainTagFromCoords(event.map.map_id, x, y, true).shows_dust_particle
      spriteset = $scene.spriteset(event.map_id)
      spriteset&.addUserAnimation(Settings::GRASS_ANIMATION_ID, x, y, true, 1)
    end
  }
)

# Force cycling/walking.
EventHandlers.add(:on_enter_map, :force_cycling,
  proc { |_old_map_id|
    $game_switches[Supplementals::MAP_UPDATE] = true
  }
)