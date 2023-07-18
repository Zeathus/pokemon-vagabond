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

def pbTotalBossesDefeated
  if $game_variables[BOSSES_DEFEATED].is_a?(Numeric)
    $game_variables[BOSSES_DEFEATED] = {}
  end
  count = 0
  $game_variables[BOSSES_DEFEATED].each do |key, value|
    count += 1 if value
  end
  return count
end