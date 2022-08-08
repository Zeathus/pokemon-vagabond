def pbDebugSelfSwitches
  $game_temp.menu_calling = false
  event_id = pbNumericUpDown("Set Self Switch of [Event ID]")
  if $game_map.events[event_id]
    switches = ["A", "B", "C", "D"]
    choices = ""
    for i in switches
      choices += _INTL("{1} [{2}],",
        i, $game_self_switches[[$game_map.map_id, event_id, i]] ? "On" : "Off")
    end
    pbMessage(_INTL("Toggle what switch of \"{1}\"?, \\ch[1,5,{2}Cancel]",
      $game_map.events[event_id].name, choices))
    if $game_variables[1] < 4
      state = $game_self_switches[[$game_map.map_id, event_id, i]]
      $game_self_switches[[$game_map.map_id, event_id, i]] = !state
      return true
    end
  else
    pbMessage("No event with that ID.")
  end
  return false
end