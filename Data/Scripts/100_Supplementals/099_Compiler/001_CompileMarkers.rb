module Compiler
  module_function

  def pbLoadMarkerComments(silent=false)
    mapdata=MapData.new
    t = Time.now.to_i
    Graphics.update
    $Markers=[]
    for id in mapdata.mapinfos.keys.sort
      $Markers[id]=[]
      map=mapdata.getMap(id)
      next if !map || !mapdata.mapinfos[id]
      pbSetWindowText(_INTL("Processing markers on map {1} ({2})",id,mapdata.mapinfos[id].name)) if !silent
      for key in map.events.keys
        if Time.now.to_i - t >= 5
          Graphics.update
          t = Time.now.to_i
        end
        pbLoadMarkersFromEvent(map.events[key],$Markers[id])
      end
    end
    if Time.now.to_i-t>=5
      Graphics.update
      t=Time.now.to_i
    end
  end


  def pbLoadMarkersFromEvent(event,markers)
    return if !event || event.pages.length==0
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
          if command[/^(MarkerType\:|MarkerQuest\:|MarkerReq\:|MarkerText\:)/i]
            commands.push(command)
            isFirstCommand=true if i==0
          end
        end
        i+=1
      end
      next if commands.length==0
      markertype=-1
      markerquest=false
      markerreqs=false
      markertext=nil
      for command in commands
        cmd = command[0...(command.index(":"))]
        arg = command[(command.index(":")+1)..command.length]
        arg.strip!
        if cmd == "MarkerType"
          if markertype >= 0
            if markertype == 3
              markers.push([event.id,page,markertype,markerreqs,markertext])
            else
              markers.push([event.id,page,markertype,markerreqs,markerquest])
            end
            markerquest=false
            markerreqs=false
            markertext=nil
          end
          arg = "0" if arg=="?"
          arg = "1" if arg=="!"
          arg = "2" if arg=="..."
          arg = "3" if arg.downcase=="text"
          markertype = arg.to_i
        elsif cmd == "MarkerQuest"
          if [0,1,2].include?(markertype)
            markerquest = arg
          elsif markertype == 3
            raise "MarkerType Text does not support MarkerQuest."
          else
            raise "MarkerType must be set before MarkerQuest."
          end
        elsif cmd == "MarkerReq"
          if markertype >= 0
            markerreqs = [] if !markerreqs
            markerreqs.push(arg)
          else
            raise "MarkerType must be set before MarkerReq."
          end
        elsif cmd == "MarkerText"
          if markertype == 3
            markertext = arg
          else
            raise "MarkerType Text must be set before MarkerText."
          end
        end
      end
      if markertype == 3
        markers.push([event.id,page,markertype,markerreqs,markertext])
      else
        markers.push([event.id,page,markertype,markerreqs,markerquest])
      end
    end
  end
end 