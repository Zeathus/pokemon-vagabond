def pbRangerClerk(area)
  if !$game_switches[MET_RANGERS]
    pbDialog("RANGER_CLERK", 0)
    $game_switches[MET_RANGERS] = true
  end
  is_ranger = pbJob("Ranger").level > 0
  ret = -1
  if pbJob("Ranger").level >= 2
    ret = pbDialog("RANGER_CLERK", 3)
  elsif is_ranger
    ret = pbDialog("RANGER_CLERK", 2)
  else
    ret = pbDialog("RANGER_CLERK", 1)
  end

  case ret
  when 0
    ret = pbDialog("RANGER_CLERK_REST")
    if ret != -1
      $game_screen.start_tone_change(Tone.new(-255, -255, -255), 20)
      pbWait(1.5)
      pbMEPlay("Pkmn healing", 100, 100)
      pbWait(2)
      $player.heal_party
      pbGetTimeNow.forwardToTime([6, 12, 18, 0][ret])
      PBDayNight.updateTone
      $game_screen.start_tone_change(Tone.new(0, 0, 0), 20)
      pbWait(1.5)
      pbDialog("RANGER_CLERK_REST", is_ranger ? 2 : 1)
    else
      pbDialog("RANGER_CLERK_REST", is_ranger ? 4 : 3)
    end
    return
  when 1
    if is_ranger
      if pbJob("Ranger").level >= 5
        pbDialog("RANGER_CLERK_REPORT", 1)
      elsif pbJob("Ranger").progress >= pbJob("Ranger").requirement
        pbDialog("RANGER_CLERK_RANK_UP")
        pbDialog("RANGER_CLERK_RANK_UP", pbJob("Ranger").level)
        pbJob("Ranger").level += 1
      else
        pbDialog("RANGER_CLERK_REPORT")
      end
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
    pbRangerShop(area)
  when -1
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
    addNotice.call("Primarina", "Sea Melody", "NOTICE_PRIMARINA")
    addNotice.call("Clawitzer", "Clauncher Territory", "NOTICE_CLAUNCHER_QWILFISH", 0)
    addNotice.call("Overqwil", "Qwilfish Territory", "NOTICE_CLAUNCHER_QWILFISH", 1)
    addNotice.call("Palafin", "Palafin's Treaty", "NOTICE_CLAUNCHER_QWILFISH", 2) if $game_self_switches[[163,68,"B"]]
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

def pbRangerShop(area)
  items_and_prices = [
    [:POKEBALL, 100]
  ]
  level = pbJob("Ranger").level
  if level >= 2
    items_and_prices = [
      [:POKEBALL, 100],
      [:GREATBALL, 300],
      [:ULTRABALL, 600],
      [:MAXREPEL, 600],
      [:SUPERPOTION, 500],
      [:HYPERPOTION, 1200],
      [:MAXPOTION, 2000],
      [:FULLRESTORE, 2500]
    ]
  end
  if level >= 3
    case area
    when "breccia"
      items_and_prices.push([:HEALBALL, 200])
      items_and_prices.push([:NESTBALL, 800])
    when "pegma"
      items_and_prices.push([:REPEATBALL, 800])
      items_and_prices.push([:DUSKBALL, 1000])
    when "lapis lazuli"
      items_and_prices.push([:NETBALL, 800])
      items_and_prices.push([:DIVEBALL, 800])
    when "gabbro"
      items_and_prices.push([:TIMERBALL, 1000])
      items_and_prices.push([:QUICKBALL, 1000])
    end
  end
  if level >= 4
    case area
    when "breccia"
      items_and_prices.push([:LOVEBALL, 500])
      items_and_prices.push([:FRIENDBALL, 500])
    when "pegma"
      items_and_prices.push([:LEVELBALL, 500])
      items_and_prices.push([:HEAVYBALL, 500])
    when "lapis lazuli"
      items_and_prices.push([:FASTBALL, 500])
      items_and_prices.push([:LUREBALL, 500])
    when "gabbro"
      items_and_prices.push([:MOONBALL, 500])
      items_and_prices.push([:DREAMBALL, 500])
    end
  end
  items = []
  items_and_prices.each do |i|
    price = i[1]
    if level >= 5
      price = (price * 4 / 5).floor
    end
    setPrice(i[0], i[1])
    items.push(i[0])
  end
  pbPokemonMart(items)
end