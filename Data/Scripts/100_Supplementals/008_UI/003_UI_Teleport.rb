class PokemonTeleportMapScene
  LEFT   = 0
  TOP    = 0
  RIGHT  = 29
  BOTTOM = 19
  SQUAREWIDTH  = 16
  SQUAREHEIGHT = 16

  def initialize(region=-1,destlist=[])
    @region=region
    @wallmap=false
    @destlist=destlist
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(aseditor=false,mode=0)
    @editor=aseditor
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    pbRgssOpen("Data/townmap.dat","rb"){|f|
       @mapdata=Marshal.load(f)
    }
    playerpos=!$game_map ? nil : pbGetMetadata($game_map.map_id,MetadataMapPosition)
    if !playerpos
      mapindex=0
      @map=@mapdata[0]
      @mapX=LEFT
      @mapY=TOP
    elsif @region>=0 && @region!=playerpos[0] && @mapdata[@region]
      mapindex=@region
      @map=@mapdata[@region]
      @mapX=LEFT
      @mapY=TOP
    else
      mapindex=playerpos[0]
      @map=@mapdata[playerpos[0]]
      @mapX=playerpos[1]
      @mapY=playerpos[2]
      mapsize=!$game_map ? nil : pbGetMetadata($game_map.map_id,MetadataMapSize)
      if mapsize && mapsize[0] && mapsize[0]>0
        sqwidth=mapsize[0]
        sqheight=(mapsize[1].length*1.0/mapsize[0]).ceil
        if sqwidth>1
          @mapX+=($game_player.x*sqwidth/$game_map.width).floor
        end
        if sqheight>1
          @mapY+=($game_player.y*sqheight/$game_map.height).floor
        end
      end
    end
    if !@map
      Kernel.pbMessage(_INTL("The map data cannot be found."))
      return false
    end
    addBackgroundOrColoredPlane(@sprites,"background","mapbg",Color.new(0,0,0),@viewport)
    @sprites["map"]=IconSprite.new(0,0,@viewport)
    @sprites["map"].setBitmap("Graphics/UI/#{@map[1]}")
    @sprites["map"].x+=(Graphics.width-@sprites["map"].bitmap.width)/2
    @sprites["map"].y+=(Graphics.height-@sprites["map"].bitmap.height)/2
    for hidden in REGIONMAPEXTRAS
      if hidden[0]==mapindex && ((@wallmap && hidden[5]) ||
         (!@wallmap && hidden[1]>0 && $game_switches[hidden[1]]))
        if !@sprites["map2"]
          @sprites["map2"]=BitmapSprite.new(480,320,@viewport)
          @sprites["map2"].x=@sprites["map"].x; @sprites["map2"].y=@sprites["map"].y
        end
        pbDrawImagePositions(@sprites["map2"].bitmap,[
           ["Graphics/UI/#{hidden[4]}",hidden[2]*SQUAREWIDTH,hidden[3]*SQUAREHEIGHT,0,0,-1,-1]
        ])
      end
    end
    @sprites["mapbottom"]=MapBottomSprite.new(@viewport)
    @sprites["mapbottom"].mapname=pbGetMessage(@map.name,mapindex)
    @sprites["mapbottom"].maplocation=pbGetMapLocation(@mapX,@mapY)
    @sprites["mapbottom"].mapdetails=pbGetMapDetails(@mapX,@mapY)
    if @destlist
      teleport_icon="Graphics/UI/mapTeleport"
      for dest in @destlist
        dest_id = _INTL("teleport{1}",dest[0])
        @sprites[dest_id]=IconSprite.new(0,0,@viewport)
        @sprites[dest_id].setBitmap(teleport_icon)
        @sprites[dest_id].x=-SQUAREWIDTH/2+(dest[3]*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
        @sprites[dest_id].y=-SQUAREHEIGHT/2+(dest[4]*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
      end
    end
    if playerpos && mapindex==playerpos[0]
      @sprites["player"]=IconSprite.new(0,0,@viewport)
      @sprites["player"].setBitmap(pbPlayerHeadFile($player.trainertype))
      @sprites["player"].x=-SQUAREWIDTH/2+(@mapX*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
      @sprites["player"].y=-SQUAREHEIGHT/2+(@mapY*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
    end
    if mode>0
      k=0
      for i in LEFT..RIGHT
        for j in TOP..BOTTOM
          healspot=pbGetHealingSpot(i,j)
          if healspot && $PokemonGlobal.visitedMaps[healspot[0]]
            @sprites["point#{k}"]=AnimatedSprite.create("Graphics/UI/mapFly",2,30)
            @sprites["point#{k}"].viewport=@viewport
            @sprites["point#{k}"].x=-SQUAREWIDTH/2+(i*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
            @sprites["point#{k}"].y=-SQUAREHEIGHT/2+(j*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
            @sprites["point#{k}"].play
            k+=1
          end
        end
      end
    end
    @sprites["cursor"]=AnimatedSprite.create("Graphics/UI/mapCursor",2,15)
    @sprites["cursor"].viewport=@viewport
    @sprites["cursor"].play
    @sprites["cursor"].x=-SQUAREWIDTH/2+(@mapX*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
    @sprites["cursor"].y=-SQUAREHEIGHT/2+(@mapY*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
    @changed=false
    pbFadeInAndShow(@sprites){ pbUpdate }
    return true
  end

  def pbSaveMapData
    File.open("PBS/townmap.txt","wb"){|f|
       for i in 0...@mapdata.length
         map=@mapdata[i]
         return if !map
         f.write(sprintf("[%d]\r\n",i))
         f.write(sprintf("Name=%s\r\nFilename=%s\r\n",csvquote(map[0]),csvquote(map[1])))
         for loc in map[2]
           f.write("Point=")
           pbWriteCsvRecord(loc,f,[nil,"uussUUUU"])
           f.write("\r\n")
         end
       end
    }
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbGetMapLocation(x,y)
    return "" if !@map[2]
    for loc in @map[2]
      if loc[0]==x && loc[1]==y
        if !loc[7] || (!@wallmap && $game_switches[loc[7]])
          maploc=pbGetMessageFromHash(MessageTypes::PlaceNames,loc[2])
          return @editor ? loc[2] : maploc
        else
          return ""
        end
      end
    end
    return ""
  end

  def pbChangeMapLocation(x,y)
    return if !@editor
    return "" if !@map[2]
    currentname=""
    currentobj=nil
    for loc in @map[2]
      if loc[0]==x && loc[1]==y
        currentobj=loc
        currentname=loc[2]
        break
      end
    end
    currentname=Kernel.pbMessageFreeText(_INTL("Set the name for this point."),
       currentname,false,256) { pbUpdate }
    if currentname
      if currentobj
        currentobj[2]=currentname
      else
        newobj=[x,y,currentname,""]
        @map[2].push(newobj)
      end
      @changed=true
    end
  end

  def pbGetMapDetails(x,y) # From Wichu, with my help
    return "" if !@map[2]
    for loc in @map[2]
      if loc[0]==x && loc[1]==y
        if !loc[7] || (!@wallmap && $game_switches[loc[7]])
          mapdesc=pbGetMessageFromHash(MessageTypes::PlaceDescriptions,loc[3])
          return @editor ? loc[3] : mapdesc
        else
          return ""
        end
      end
    end
    return ""
  end

  def pbGetHealingSpot(x,y)
    return nil if !@map[2]
    for loc in @map[2]
      if loc[0]==x && loc[1]==y
        if !loc[4] || !loc[5] || !loc[6]
          return nil
        else
          return [loc[4],loc[5],loc[6]]
        end
      end
    end
    return nil
  end

  def pbMapScene(mode=0)
    xOffset=0
    yOffset=0
    newX=0
    newY=0
    @sprites["cursor"].x=-SQUAREWIDTH/2+(@mapX*SQUAREWIDTH)+(Graphics.width-@sprites["map"].bitmap.width)/2
    @sprites["cursor"].y=-SQUAREHEIGHT/2+(@mapY*SQUAREHEIGHT)+(Graphics.height-@sprites["map"].bitmap.height)/2
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if xOffset!=0 || yOffset!=0
        xOffset+=xOffset>0 ? -4 : (xOffset<0 ? 4 : 0)
        yOffset+=yOffset>0 ? -4 : (yOffset<0 ? 4 : 0)
        @sprites["cursor"].x=newX-xOffset
        @sprites["cursor"].y=newY-yOffset
        next
      end
      @sprites["mapbottom"].maplocation=pbGetMapLocation(@mapX,@mapY)
      @sprites["mapbottom"].mapdetails=pbGetMapDetails(@mapX,@mapY)
      ox=0
      oy=0
      case Input.dir8
      when 1 # lower left
        oy=1 if @mapY<BOTTOM
        ox=-1 if @mapX>LEFT
      when 2 # down
        oy=1 if @mapY<BOTTOM
      when 3 # lower right
        oy=1 if @mapY<BOTTOM
        ox=1 if @mapX<RIGHT
      when 4 # left
        ox=-1 if @mapX>LEFT
      when 6 # right
        ox=1 if @mapX<RIGHT
      when 7 # upper left
        oy=-1 if @mapY>TOP
        ox=-1 if @mapX>LEFT
      when 8 # up
        oy=-1 if @mapY>TOP
      when 9 # upper right
        oy=-1 if @mapY>TOP
        ox=1 if @mapX<RIGHT
      end
      if ox!=0 || oy!=0
        @mapX+=ox
        @mapY+=oy
        xOffset=ox*SQUAREWIDTH
        yOffset=oy*SQUAREHEIGHT
        newX=@sprites["cursor"].x+xOffset
        newY=@sprites["cursor"].y+yOffset
      end
      if Input.trigger?(Input::B)
        if Kernel.pbConfirmMessage(_INTL("Do you want to stop teleporting?")) { pbUpdate }
          break
        end
      elsif Input.trigger?(Input::C)
        dest_id=-1
        for i in 0...@destlist.length
          dest=@destlist[i]
          if dest[3]==@mapX && dest[4]==@mapY
            dest_id=i
          end
        end
        if dest_id>=0
          if Kernel.pbConfirmMessage(_INTL("Do you want to teleport to {1}?",pbGetMapNameFromId(@destlist[dest_id][0]))) { pbUpdate }
            $game_variables[1]=dest_id
            break
          end
        end
      end
    end
    return nil
  end
end



class PokemonTeleportMap
  def initialize(scene)
    @scene=scene
  end

  def pbStartFlyScreen
    @scene.pbStartScene(false,1)
    ret=@scene.pbMapScene(1)
    @scene.pbEndScene
    return ret
  end

  def pbStartScreen
    @scene.pbStartScene(false)
    @scene.pbMapScene
    @scene.pbEndScene
  end
end



def pbTeleportMap(region=-1,destlist=[])
  pbFadeOutIn(99999) {         
     scene=PokemonTeleportMapScene.new(region,destlist)
     screen=PokemonTeleportMap.new(scene)
     screen.pbStartScreen
  }
end


def pbRegisterDestination(mapid, x, y, mapx, mapy)
  if $game_variables[TELEPORT_LIST]==0
    $game_variables[TELEPORT_LIST]=[]
  end
  exists=false
  for dest in $game_variables[TELEPORT_LIST]
    exists=true if dest[0]==mapid
  end
  if !exists
    $game_variables[TELEPORT_LIST].push([mapid, x, y, mapx, mapy])
    return true
  end
  return false
end

def pbRemoveDestination(mapid)
  destinations = []
  for dest in $game_variables[TELEPORT_LIST]
    if dest[0]!=mapid
      destinations.push(dest)
    end
  end
  $game_variables[TELEPORT_LIST]=destinations
end

def pbTeleportDialog(name="Teleporter", nodialog=false)
  destinations=$game_variables[TELEPORT_LIST]

  if destinations.length <= 1
    pbSpeech(name, "neutral", "I'm sorry, but you don't have any other destination to teleport to.")
    return false
  end

  Kernel.pbMessage("Would you like to teleport?\\ch[1,2,Yes,No]")
  if $game_variables[1]==0
    if map
      pbSpeech(name, "neutral", "Please choose a destination.") if !nodialog
      destlist = []
      for dest in destinations
        if $game_map.map_id!=dest[0]
          destlist.push(dest)
        end
      end
      $game_variables[1]=-1
      pbTeleportMap(0,destlist)
      if $game_variables[1]>=0
        pbTeleport($game_variables[1],destlist)
      else
        pbSpeech(name, "neutral", "We hope to see you again!") if !nodialog
      end
    else
      destlist = []
      choices = ""
      for dest in destinations
        if $game_map.map_id!=dest[0]
          destlist.push(dest)
          choices += ","
          choices += pbGetMapNameFromId(dest[0])
        end
      end
      choices += ",Cancel]"
      len = destinations.length + 1
      Kernel.pbMessage("Please choose a destination." +
      "\\ch[1," + len.to_s + choices)
      if $game_variables[1]==len-1
        pbSpeech(name, "neutral", "We hope to see you again!") if !nodialog
      else
        pbTeleport($game_variables[1], destlist)
      end
    end
  else
    pbSpeech(name, "neutral", "We hope to see you again!") if !nodialog
  end
end

def pbTeleport(id, list=$game_variables[TELEPORT_LIST])
  destination = list[id]
  i = 0
  while i <= 3 || $game_screen.tone_changing?
    pbToneChangeAll(Tone.new(255,255,255),20) if i==2
    for j in 0..3
      $game_player.turn_up if j==0
      $game_player.turn_right if j==1
      $game_player.turn_down if j==2
      $game_player.turn_left if j==3
      pbWait(4)
    end
  end
  for j in 0..3
    $game_player.turn_up if j==0
    $game_player.turn_right if j==1
    $game_player.turn_down if j==2
    $game_player.turn_left if j==3
    pbWait(4)
  end
  Kernel.pbCancelVehicles
  $game_temp.player_new_map_id=destination[0]
  $game_temp.player_new_x=destination[1]
  $game_temp.player_new_y=destination[2]
  $game_temp.player_new_direction=2
  pbBGSStop(0)
  $scene.transfer_player
  $game_map.autoplay
  $game_map.refresh
  pbToneChangeAll(Tone.new(0,0,0),12)
  pbWait(14)
end