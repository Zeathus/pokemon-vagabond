# [map_id][eventid,marker,[requirements]]
# Marker: 0=question mark, 1=exclamation mark, 2=speech, 3=text

def pbLoadQuestMarkers
  return if !$Markers || !$Markers[$game_map.map_id]
  for marker in $Markers[$game_map.map_id]
    next if !marker || marker.length < 3
    event = $game_map.events[marker[0]]
    next if !event
    page = marker[1]
    next if event.page_number != page
    type = marker[2]
    next if !event
    active=true
    if marker.length > 3 && marker[3]
      reqs = marker[3]
      for i in reqs
        if !eval(i)
          active = false
          break
        end
      end
    end
    next if !active
    if type != 3 && marker.length > 4 && marker[4]
      quest_id = marker[4].to_sym
      if type == 0
        active = false if $quests[quest_id].status > 0
      else
        active = false if $quests[quest_id].status != 1
      end
      type += $quests[quest_id].type * 4
    end
    if active
      if type == 3
        if marker[4] == "RuinBoss"
          marker[4] = _INTL("Lv. {1}", pbRuinBossLevel)
        end
        pbQuestBubble(event,type,marker[4])
      else
        pbQuestBubble(event,type)
      end
    end
  end
end

def pbUnloadQuestMarkers
  for e in $game_map.events.values
    e.marker_id = -1
  end
end

def pbLoadItemSparkles
  for event in $game_map.events.values
    if event.name.include?("HiddenItem") &&
      !$game_self_switches[[$game_map.map_id,event.id,"A"]]
      pbQuestBubble(get_character(event.id),11)
    end
  end
end

def pbUpdateMarkers
  pbUnloadQuestMarkers
  pbLoadQuestMarkers if !($game_switches && $game_switches[Supplementals::HIDE_MARKERS])
end

def pbHideMarkers
  $game_switches[Supplementals::HIDE_MARKERS] = true
  pbUpdateMarkers
end

def pbShowMarkers
  $game_switches[Supplementals::HIDE_MARKERS] = false
  pbUpdateMarkers
end

def pbQuestBubble(event, id = 0, text = nil)
  event.marker_id = id
  event.marker_text = text
end 