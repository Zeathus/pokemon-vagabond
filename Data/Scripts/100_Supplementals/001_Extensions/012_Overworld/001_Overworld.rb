# Show dust trail animation
EventHandlers.add(:on_step_taken, :dust_trail,
  proc { |event|
    next if !$scene.is_a?(Scene_Map)
    event.each_occupied_tile do |x, y|
      next if !$map_factory.getTerrainTagFromCoords(event.map.map_id, x, y, true).shows_dust_particle
      spriteset = $scene.spriteset(event.map_id)
      spriteset&.addUserAnimation(Settings::DUST_ANIMATION_ID, x, y, true, 1)
    end
  }
)

# Show surf ripple animation
EventHandlers.add(:on_step_taken, :surf_ripple,
  proc { |event|
    next if !$scene.is_a?(Scene_Map)
    next if !$PokemonGlobal.surfing
    event.each_occupied_tile do |x, y|
      next if !$map_factory.getTerrainTagFromCoords(event.map.map_id, x, y, true).can_surf
      spriteset = $scene.spriteset(event.map_id)
      spriteset&.addUserAnimation(Settings::SURF_RIPPLE_ANIMATION_ID, x, y, true, 0)
    end
  }
)

# Show sprinting dust trail
EventHandlers.add(:on_step_taken, :sprinting_dust,
  proc { |event|
    next if !$game_player || $game_player.sprinting == 0
    next if !$scene.is_a?(Scene_Map)
    event.each_occupied_tile do |x, y|
      spriteset = $scene.spriteset(event.map_id)
      spriteset&.addUserAnimation(Settings::DUST_ANIMATION_ID, x, y, true, 1)
    end
  }
)

# Force cycling/walking.
EventHandlers.add(:on_enter_map, :map_update,
  proc { |_old_map_id|
    $game_switches[Supplementals::MAP_UPDATE] = true
  }
)

# Check for overhangs above player
EventHandlers.add(:on_step_taken, :overhang_check,
  proc { |event|
    next if !$scene.is_a?(Scene_Map)
    event.each_occupied_tile do |x, y|
      old_value = $game_player.under_overhang
      $game_player.under_overhang = ($map_factory.getTerrainTagFromCoords(event.map.map_id, x, y, true).id == :Overhang)
    end
  }
)