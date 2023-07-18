def pbSpecialFieldSkill(pokemon)
  case pokemon
  when :AZELF
    pbGuardianMindRead(:AZELF)
  when :UXIE
    pbGuardianMindRead(:UXIE)
  when :MESPRIT
    pbGuardianMindRead(:MESPRIT)
  end
end

def pbGuardianMindReadNPC(pokemon)
  return nil if !($MindRead[$game_map.map_id])
  event = $game_player.pbFacingEvent
  return nil if event.nil?
  return nil if !($MindRead[$game_map.map_id][event.id])
  page = event.page_number
  $MindRead[$game_map.map_id][event.id].each do |thought|
    if thought[1] == page && thought[2] == pokemon
      return thought
    end
  end
  return nil
end

def pbGuardianMindRead(pokemon)
  thought = pbGuardianMindReadNPC(pokemon)
  return false if thought.nil?
  pbDialog(thought[3], thought[4])
  return true
end

module Compiler
  module_function

  def pbLoadMindReadComments(silent=false)
    mapdata=MapData.new
    t = Time.now.to_i
    Graphics.update
    $MindRead=[]
    for id in mapdata.mapinfos.keys.sort
      $MindRead[id]=[]
      map=mapdata.getMap(id)
      next if !map || !mapdata.mapinfos[id]
      pbSetWindowText(_INTL("Processing minds on map {1} ({2})",id,mapdata.mapinfos[id].name)) if !silent
      for key in map.events.keys
        if Time.now.to_i - t >= 5
          Graphics.update
          t = Time.now.to_i
        end
        pbLoadMindReadFromEvent(map.events[key],$MindRead[id])
      end
    end
    if Time.now.to_i-t>=5
      Graphics.update
      t=Time.now.to_i
    end
  end


  def pbLoadMindReadFromEvent(event,mind)
    return if !event || event.pages.length==0
    guardians = {
      "Willpower" => :AZELF,
      "Knowledge" => :UXIE,
      "Emotion" => :MESPRIT
    }
    for page in 0...event.pages.length
      commands=[]
      list=event.pages[page].list
      isFirstCommand=false
      i=0; while i<list.length
        if list[i].code==108
          command=list[i].parameters[0]
          j=i+1; while j<list.length
            break if list[j].code!=408
            command+="\r\n"+list[j].parameters[0]
            j+=1
          end
          if command[/^(Mind\:|Willpower\:|Knowledge\:|Emotion\:)/i]
            commands.push(command)
            isFirstCommand=true if i==0
          end
        end
        i+=1
      end
      next if commands.length==0
      for command in commands
        cmd = command[0...(command.index(":"))]
        arg = command[(command.index(":")+1)..command.length]
        arg.strip!
        args = arg.split(" ")
        args.push("0") if args.length == 1
        if cmd == "Mind"
          mind[event.id] = [] if !(mind[event.id])
          ["Willpower", "Knowledge", "Emotion"].each do |tag|
            mind[event.id].push([event.id, page, guardians[tag],
              _INTL("{2}_{1}", tag.upcase, args[0]), args[1].to_i])
          end
        elsif ["Willpower", "Knowledge", "Emotion"].include?(cmd)
          mind[event.id] = [] if !(mind[event.id])
          mind[event.id].push([event.id, page, guardians[cmd], args[0], args[1].to_i])
        end
      end
    end
  end
end 