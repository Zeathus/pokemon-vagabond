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
      pbWait(60)
      pbMEPlay("Pkmn healing", 100, 100)
      pbWait(60)
      $player.heal_party
      pbGetTimeNow.forwardToTime([6, 12, 18, 0][ret])
      PBDayNight.updateTone
      $game_screen.start_tone_change(Tone.new(0, 0, 0), 20 * Graphics.frame_rate / 20)
      pbWait(60)
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