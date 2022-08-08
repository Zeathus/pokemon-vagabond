def pbBossDefeated?(boss)
  if !$game_variables[BOSSES_DEFEATED].is_a?(Hash)
    $game_variables[BOSSES_DEFEATED] = {}
  end
  return false if !$game_variables[BOSSES_DEFEATED].key?(boss)
  return $game_variables[BOSSES_DEFEATED][boss]
end

def pbSetBossDefeated(boss)
  if !$game_variables[BOSSES_DEFEATED].is_a?(Hash)
    $game_variables[BOSSES_DEFEATED] = {}
  end
  return $game_variables[BOSSES_DEFEATED][boss] = true
end