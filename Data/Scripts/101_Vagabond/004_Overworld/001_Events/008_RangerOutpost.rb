def pbRangerClerk(area)
  if !$game_switches[MET_RANGERS]
    pbDialog("RANGER_CLERK", 0)
    $game_switches[MET_RANGERS] = true
  end
  is_ranger = (pbJob("Ranger").level > 0)
  ret = pbDialog("RANGER_CLERK", is_ranger ? 2 : 1)

  case ret
  when 0
    ret = pbDialog("RANGER_CLERK_REST")
    if ret != -1
      $game_screen.start_tone_change(Tone.new(-255, -255, -255), 20 * Graphics.frame_rate / 20)
      pbWait(3.0)
      pbMEPlay("Pkmn healing", 100, 100)
      pbWait(3.0)
      $player.heal_party
      pbGetTimeNow.forwardToTime([6, 12, 18, 0][ret])
      PBDayNight.updateTone
      $game_screen.start_tone_change(Tone.new(0, 0, 0), 20 * Graphics.frame_rate / 20)
      pbWait(3.0)
      pbDialog("RANGER_CLERK_REST", is_ranger ? 2 : 1)
    else
      pbDialog("RANGER_CLERK_REST", is_ranger ? 4 : 3)
    end
    return
  when 1
    if is_ranger
      pbDialog("RANGER_CLERK_REPORT")
    else
      if $quests[:WILDLIFEPROTECTORS].active?
        pbDialog("RANGER_CLERK_RECRUIT_ME", 2)
        if pbTotalBossesDefeated() > 0
          pbDialog("RANGER_CLERK_RECRUIT_ME", 5)
          $quests[:WILDLIFEPROTECTORS].finish
          pbJob("Ranger").level = 1
        end
      elsif $game_switches[GPO_MEMBER]
        pbDialog("RANGER_CLERK_RECRUIT_ME", 1)
        $quests[:WILDLIFEPROTECTORS].start
        if pbTotalBossesDefeated() > 0
          pbDialog("RANGER_CLERK_RECRUIT_ME", 4)
          $quests[:WILDLIFEPROTECTORS].finish
          pbJob("Ranger").level = 1
        end
      else
        pbDialog("RANGER_CLERK_RECRUIT_ME", 0)
      end
    end
  when 2
    pbDialog("RANGER_CLERK_CANCEL")
  end
end

def pbRangerNoticeBoard(area)
  finished = []
  notices = []

  addNotice = lambda { |boss, title, dialog, index = 0, condition = nil|
    list = (condition.nil? ? pbBossDefeated?(boss) : condition) ? finished : notices
    list.push([title, dialog, index])
  }

  case area
  when "breccia"
    addNotice.call("Tropius", "Tropius Sighting", "NOTICE_TROPIUS") if $game_switches[GYM_FAUNUS]
    addNotice.call("Vespiquen", "Queen Bee", "NOTICE_VESPIQUEN", 0, $game_self_switches[[62,34,"C"]])
    addNotice.call("Vespiquen", "Queen Bee 2", "NOTICE_VESPIQUEN", 1) if $game_self_switches[[62,34,"C"]]
    addNotice.call("Deino", "Panicked Deino", "NOTICE_DEINO") if $PokemonGlobal.visitedMaps[PBMaps::EvergoneRuins]
  when "pegma"
    addNotice.call("Turtonator", "Turtonator Territory", "NOTICE_TURTONATOR")
    addNotice.call("Swampert", "Feldspar Lake Floor", "NOTICE_SWAMPERT")
  when "lapis lazuli"
    addNotice.call("Lapras", "Lazuli Lake Monster", "NOTICE_LAPRAS")
    addNotice.call("RotomEasy", "Rotom Trio 1", "NOTICE_ROTOM_EASY") if $game_switches[6] # Defeated Leroy
    addNotice.call("RotomHard", "Rotom Trio 2", "NOTICE_ROTOM_HARD") if $game_switches[6] # Defeated Leroy
  end
  if notices.length == 0 && finished.length == 0
    pbDialog("NOTICE_BOARD_EMPTY")
  else
    options = notices.map { |i| i[0] }
    options.push("Read old notices") if finished.length > 0
    options.push("Leave")
    loop do
      choice = pbMessage("What notice do you want to read?", options, -1)
      if choice >= 0 && choice < notices.length
        notice = notices[choice]
        pbDialog(_INTL(notice[1]), notice[2])
      elsif choice == notices.length && finished.length > 0 # Read old notices
        options = finished.map { |i| i[0] }
        options.push("Leave")
        loop do
          choice = pbMessage("What notice do you want to read?", options, -1)
          if choice >= 0 && choice < finished.length
            notice = finished[choice]
            pbDialog(_INTL(notice[1]), notice[2])
          else
            break
          end
        end
        break
      else
        break
      end
    end
  end
end