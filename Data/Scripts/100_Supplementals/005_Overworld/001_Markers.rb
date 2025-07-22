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
    real_type = type
    if type < 3 && marker.length > 4 && marker[4]
      quest_id = marker[4].to_sym
      quest = $quests[quest_id]
      if type == 0
        active = false if quest.status != 0 && (quest.type != PBQuestType::Main || quest.status > 0)
      else
        active = false if quest.status != 1
      end
      type += quest.type * 4
    end
    if active
      text = nil
      icon = nil
      if real_type == 5
        icon = "Graphics/Icons/field_boss"
        type = 3
      end
      if type == 3
        if marker[4] == "RuinBoss"
          text = _INTL("Lv. {1}", pbRuinBossLevel)
        elsif marker[4] == "RuinBossRematch"
          text = _INTL("Lv. {1}", pbRuinBossLevel(-1))
        else
          text = marker[4]
        end
      end
      pbQuestBubble(event, type, text, icon)
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

def pbQuestBubble(event, id = 0, text = nil, icon = nil)
  event.marker_id = id
  event.marker_text = text
  event.marker_icon = icon
end 