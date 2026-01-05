def pbUpdateAmphi
  # Do not update while on a map where Amphi could be
  if [25, 163, 206].include?($game_map.map_id)
    return
  end
  if $quests[:THEGREATAMPHI].at_step?(10)
    return
  end
  $game_switches[TORTERRA_EAST]  = false
  $game_switches[TORTERRA_WEST]  = false
  $game_switches[TORTERRA_SOUTH] = false
  return if !$game_switches[TORTERRA_ACTIVE]
  locations = [TORTERRA_EAST, TORTERRA_WEST]
  if $quests[:THEGREATAMPHI].complete?
    locations.push(TORTERRA_SOUTH)
  end
  $game_switches[locations.shuffle[0]] = true
end