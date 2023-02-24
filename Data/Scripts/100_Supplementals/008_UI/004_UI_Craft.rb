#===============================================================================
# Abstraction layer for Pokemon Essentials
#===============================================================================
class CraftAdapter
  def getInventory()
    return $bag
  end

  def getItemIcon(item)
    return nil if !item
    return GameData::Item.icon_filename(item)
  end

  def getItemIconRect(item)
    return Rect.new(0,0,48,48)
  end

  def getDisplayName(item)
    itemname=GameData::Item.get(item).name
    if GameData::Item.get(item).is_machine?
      machine=GameData::Item.get(item).move
      itemname=_INTL("{1} {2}",itemname,GameData::Move.get(machine).name)
    end
    return itemname
  end

  def getName(item)
    return nil if item == 0
    return GameData::Item.get(item).name
  end

  def getDescription(item)
    return GameData::Item.get(item).description
  end

  def addItem(item)
    return $bag.pbStoreItem(item)
  end

  def getQuantity(item)
    return $bag.quantity(item)
  end

  def canSell?(item)
    return getPrice(item,true)>0 && !pbIsImportantItem?(item)
  end

  def showQuantity?(item)
    return !pbIsImportantItem?(item)
  end

  def removeItem(item)
    return $bag.remove(item)
  end
end



#===============================================================================
# Abstraction layer for RPG Maker XP/VX
# Won't be used if $bag exists
#===============================================================================
class RpgxpCraftAdapter
  def getMoney
    return $game_party.gold
  end

  def setMoney(value)
    $game_party.gain_gold(-$game_party.gold)
    $game_party.gain_gold(value)
  end

  def getPrice(item,selling=false)
    return item.price
  end

  def getItemIcon(item)
    return nil if !item
    if item==0
      return sprintf("Graphics/Icons/itemBack")
    elsif item.respond_to?("icon_index")
      return "Graphics/System/IconSet"
    else
      return sprintf("Graphics/Icons/%s",item.icon_name)
    end
  end

  def getItemIconRect(item)
    if item && item.respond_to?("icon_index")
      ix=item.icon_index % 16 * 24
      iy=item.icon_index / 16 * 24
      return Rect.new(ix,iy,24,24)
    else
      return Rect.new(0,0,32,32)
    end
  end

  def getInventory()
    data = []
    for i in 1...$data_items.size
      if getQuantity($data_items[i]) > 0
        data.push($data_items[i])
      end
    end
    for i in 1...$data_weapons.size
      if getQuantity($data_weapons[i]) > 0
        data.push($data_weapons[i])
     end
    end
    for i in 1...$data_armors.size
      if getQuantity($data_armors[i]) > 0
        data.push($data_armors[i])
      end
    end
    return data
  end

  def canSell?(item)
    return item ? item.price>0 : false
  end

  def getName(item)
    return item ? item.name : ""
  end

  def getDisplayName(item)
    return item ? item.name : ""
  end

  def getDisplayPrice(item,selling=false)
    price=item.price
    return _ISPRINTF("{1:d}",price)
  end

  def getDescription(item)
    return item ? item.description : ""
  end

  def addItem(item)
    ret=(getQuantity(item)<99)
    if $game_party.respond_to?("gain_weapon")
      case item
      when RPG::Item
        $game_party.gain_item(item.id, 1) if ret
      when RPG::Weapon
        $game_party.gain_weapon(item.id, 1) if ret
      when RPG::Armor
        $game_party.gain_armor(item.id, 1) if ret
      end
    else
      $game_party.gain_item(item,1) if ret
    end
    return ret
  end

  def getQuantity(item)
    ret=0
    if $game_party.respond_to?("weapon_number")
      case item
      when RPG::Item
        ret=$game_party.item_number(item.id)
      when RPG::Weapon
        ret=($game_party.weapon_number(item.id))
      when RPG::Armor
        ret=($game_party.armor_number(item.id))
      end
    else
      return $game_party.item_number(item)
    end
    return ret
  end

  def showQuantity?(item)
    return true
  end

  def removeItem(item)
    ret=(getQuantity(item)>0)
    if $game_party.respond_to?("lose_weapon")
      case item
      when RPG::Item
        $game_party.lose_item(item.id, 1) if ret
      when RPG::Weapon
        $game_party.lose_weapon(item.id, 1) if ret
      when RPG::Armor
        $game_party.lose_armor(item.id, 1) if ret
      end
    else
      $game_party.lose_item(item,1) if ret
    end
    return ret
  end
end


#===============================================================================
# Buy and Sell adapters
#===============================================================================
class ItemCraftAdapter # :nodoc:
  def initialize(adapter)
    @adapter=adapter
  end

  def getDisplayName(item)
    @adapter.getDisplayName(item)
  end

  def getDisplayPrice(item)
    @adapter.getDisplayPrice(item,false)
  end

  def isSelling?
    return false
  end
end



#===============================================================================
# Pokémon Mart
#===============================================================================
class Window_Craft < Window_DrawableCommand
  def initialize(stock,adapter,x,y,width,height,viewport=nil)
    @stock=stock
    @adapter=adapter
    super(x,y,width,height,viewport)
    @selarrow=AnimatedBitmap.new("Graphics/Pictures/Craft/cursor")
    @baseColor=Color.new(88,88,80)
    @shadowColor=Color.new(168,184,184)
    self.windowskin=nil
  end

  def itemCount
    return @stock.length+1
  end

  def item
    return self.index>=@stock.length ? 0 : @stock[self.index]
  end

  def drawItem(index,count,rect)
    textpos=[]
    rect=drawCursor(index,rect)
    ypos=rect.y
    if index==count-1
      textpos.push([_INTL("CANCEL"),rect.x,ypos,false,
         self.baseColor,self.shadowColor])
    else
      #item=@stock[index]
      itemname=@stock[index][0]
      #qty=@adapter.getDisplayPrice(item)
      #sizeQty=self.contents.text_size(qty).width
      #xQty=rect.x+rect.width-sizeQty-2-16
      textpos.push([itemname,rect.x,ypos,false,self.baseColor,self.shadowColor])
      #textpos.push([qty,xQty,ypos+2,false,self.baseColor,self.shadowColor])
    end
    pbDrawTextPositions(self.contents,textpos)
  end
end



class CraftScene
  def update
    pbUpdateSpriteHash(@sprites)
    @subscene.update if @subscene
  end

  def pbRefresh
    if !@subscene
      @sprites["itemhints"].bitmap.clear
      itemwindow=@sprites["itemwindow"]
      textpos=[]
      @sprites["itemtextwindow"].text=(itemwindow.item==0) ? _INTL("Exit menu.") :
        (itemwindow.item[3] ? itemwindow.item[3] : @adapter.getDescription(itemwindow.item[2][0]))
      valid_base = Color.new(80, 80, 88)
      valid_shadow = Color.new(160, 160, 168)
      invalid_base = Color.new(150, 0, 0)
      invalid_shadow = Color.new(255, 160, 160)
      for i in 0..2
        itemid = itemwindow.item[1][i * 2]
        itemid = nil if itemid == 0
        quantity = itemwindow.item[1][i * 2 + 1]
        if itemid
          @sprites[_INTL("icon{1}",i+1)].visible = true
          @sprites[_INTL("icon{1}",i+1)].item = itemid
          if itemid == :PAY
            @sprites[_INTL("item{1}text",i+1)].text = 
              _INTL("${1}", pbFormatNumber(quantity))
            if $player.money >= quantity
              @sprites[_INTL("item{1}text",i+1)].baseColor = valid_base
              @sprites[_INTL("item{1}text",i+1)].shadowColor = valid_shadow
            else
              @sprites[_INTL("item{1}text",i+1)].baseColor = invalid_base
              @sprites[_INTL("item{1}text",i+1)].shadowColor = invalid_shadow
            end
          else
            @sprites[_INTL("item{1}text",i+1)].text = 
              _INTL("{1} ({2}/{3})", @adapter.getName(itemid), $bag.quantity(itemid), quantity)
            if $bag.quantity(itemid) >= quantity
              @sprites[_INTL("item{1}text",i+1)].baseColor = valid_base
              @sprites[_INTL("item{1}text",i+1)].shadowColor = valid_shadow
            else
              @sprites[_INTL("item{1}text",i+1)].baseColor = invalid_base
              @sprites[_INTL("item{1}text",i+1)].shadowColor = invalid_shadow
            end
          end
          itemhint = pbItemHint(itemid)
          if itemhint
            textpos.push([
              itemhint,@item_x-24,@item_1_y+28+i*90,0,Color.new(80, 80, 88),Color.new(160, 160, 168),false
            ])
          end
        else
          @sprites[_INTL("icon{1}",i+1)].visible = false
          @sprites[_INTL("icon{1}",i+1)].item = nil
          @sprites[_INTL("item{1}text",i+1)].text = ""
        end
        if (itemwindow.item==0)
          @sprites[_INTL("icon{1}",i+1)].visible = false
          @sprites[_INTL("icon{1}",i+1)].item = nil
          @sprites[_INTL("item{1}text",i+1)].text = ""
        end
      end
      for i in 0..1
        @sprites[_INTL("item{1}text",i+4)].baseColor = valid_base
        @sprites[_INTL("item{1}text",i+4)].shadowColor = valid_shadow
        itemid = itemwindow.item[2][i * 2]
        itemid = nil if itemid == 0
        quantity = itemwindow.item[2][i * 2 + 1]
        if itemid
          @sprites[_INTL("icon{1}",i+4)].visible = true
          @sprites[_INTL("icon{1}",i+4)].item = itemid
          if itemid == :GET
            @sprites[_INTL("item{1}text",i+4)].text = 
              _INTL("${1}", pbFormatNumber(quantity))
          else
            @sprites[_INTL("item{1}text",i+4)].text = 
              _INTL("{1} ({2}/{3})", @adapter.getName(itemid), $bag.quantity(itemid), quantity)
          end
        else
          @sprites[_INTL("icon{1}",i+4)].visible = false
          @sprites[_INTL("icon{1}",i+4)].item = nil
          @sprites[_INTL("item{1}text",i+4)].text = ""
        end
        if (itemwindow.item==0)
          @sprites[_INTL("icon{1}",i+4)].visible = false
          @sprites[_INTL("icon{1}",i+4)].item = nil
          @sprites[_INTL("item{1}text",i+4)].text = ""
        end
      end
      pbDrawTextPositions(@sprites["itemhints"].bitmap, textpos)
    end
    #@sprites["moneywindow"].text=_INTL("Money:\n<r>${1}",@adapter.getMoney())
  end

  def pbStartCraftScene(stock,adapter)
    # Scroll right before showing screen
    #pbScrollMap(6,5,5)
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @stock=stock
    @adapter=adapter
    @sprites={}
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Craft/bg")
    @item_x = 312
    @item_text_x = @item_x + 24
    @item_1_y = 52
    @item_2_y = 348
    @sprites["icon1"]=ItemIconSprite.new(@item_x,@item_1_y,nil,@viewport)
    @sprites["icon2"]=ItemIconSprite.new(@item_x,@item_1_y+90,nil,@viewport)
    @sprites["icon3"]=ItemIconSprite.new(@item_x,@item_1_y+180,nil,@viewport)
    @sprites["icon4"]=ItemIconSprite.new(@item_x,@item_2_y,nil,@viewport)
    @sprites["icon5"]=ItemIconSprite.new(@item_x,@item_2_y+60,nil,@viewport)
    @sprites["item1text"]=Window_UnformattedTextPokemon.new("")
    @sprites["item2text"]=Window_UnformattedTextPokemon.new("")
    @sprites["item3text"]=Window_UnformattedTextPokemon.new("")
    @sprites["item4text"]=Window_UnformattedTextPokemon.new("")
    @sprites["item5text"]=Window_UnformattedTextPokemon.new("")
    @sprites["itemhints"]=Sprite.new(@viewport)
    @sprites["itemhints"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
    pbSetSmallFont(@sprites["itemhints"].bitmap)
    pbPrepareWindow(@sprites["item1text"])
    pbPrepareWindow(@sprites["item2text"])
    pbPrepareWindow(@sprites["item3text"])
    pbPrepareWindow(@sprites["item4text"])
    pbPrepareWindow(@sprites["item5text"])
    @sprites["item1text"].x=@item_text_x
    @sprites["item1text"].y=@item_1_y - 32
    @sprites["item2text"].x=@item_text_x
    @sprites["item2text"].y=@item_1_y - 32 + 90
    @sprites["item3text"].x=@item_text_x
    @sprites["item3text"].y=@item_1_y - 32 + 180
    @sprites["item4text"].x=@item_text_x
    @sprites["item4text"].y=@item_2_y - 32
    @sprites["item5text"].x=@item_text_x
    @sprites["item5text"].y=@item_2_y - 32 + 60
    for i in 1..5
      @sprites[_INTL("item{1}text",i)].width = 300
      @sprites[_INTL("item{1}text",i)].height = 128
      @sprites[_INTL("item{1}text",i)].visible = true
      @sprites[_INTL("item{1}text",i)].viewport = @viewport
      @sprites[_INTL("item{1}text",i)].windowskin = nil
    end
    BuyAdapter.new(adapter)
    winAdapter=ItemCraftAdapter.new(adapter)
    @sprites["itemwindow"]=Window_Craft.new(stock,winAdapter,
       -12,12,264,Graphics.height-126)#Graphics.width-316-16,12,330+16,Graphics.height-126)
    @sprites["itemwindow"].viewport=@viewport
    @sprites["itemwindow"].index=0
    @sprites["itemwindow"].refresh
    @sprites["itemtextwindow"]=Window_UnformattedTextPokemon.new("")
    pbPrepareWindow(@sprites["itemtextwindow"])
    @sprites["itemtextwindow"].x=40
    @sprites["itemtextwindow"].y=Graphics.height-96-16
    @sprites["itemtextwindow"].width=Graphics.width-64
    @sprites["itemtextwindow"].height=128
    @sprites["itemtextwindow"].baseColor=Color.new(248,248,248)
    @sprites["itemtextwindow"].shadowColor=Color.new(0,0,0)
    @sprites["itemtextwindow"].visible=true
    @sprites["itemtextwindow"].viewport=@viewport
    @sprites["itemtextwindow"].windowskin=nil
    @sprites["helpwindow"]=Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible=false
    @sprites["helpwindow"].viewport=@viewport
    pbBottomLeftLines(@sprites["helpwindow"],1)
    pbDeactivateWindows(@sprites)
    @buying=true
    pbRefresh
    Graphics.frame_reset
    pbFadeInAndShow(@sprites) { update }
  end

  def pbEndBuyScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    # Scroll left after showing screen
    #pbScrollMap(4,5,5)
  end

  def pbPrepareWindow(window)
    window.visible=true
    window.letterbyletter=false
  end

  def pbDisplay(msg,brief=false)
    cw=@sprites["helpwindow"]
    cw.letterbyletter=true
    cw.text=msg
    pbBottomLeftLines(cw,2)
    cw.visible=true
    i=0
    pbPlayDecisionSE()
    loop do
      Graphics.update
      Input.update
      self.update
      if brief && !cw.busy?
        return
      end
      if i==0 && !cw.busy?
        pbRefresh
      end
      if Input.trigger?(Input::C) && cw.busy?
        cw.resume
      end
      if i==60
        return
      end
      i+=1 if !cw.busy?
    end
  end

  def pbDisplayPaused(msg)
    cw=@sprites["helpwindow"]
    cw.letterbyletter=true
    cw.text=msg
    pbBottomLeftLines(cw,2)
    cw.visible=true
    i=0
    pbPlayDecisionSE()
    loop do
      Graphics.update
      Input.update
      wasbusy=cw.busy?
      self.update
      if !cw.busy? && wasbusy
        pbRefresh
      end
      if Input.trigger?(Input::C) && cw.resume && !cw.busy?
        @sprites["helpwindow"].visible=false
        return
      end
    end
  end

  def pbConfirm(msg)
    dw=@sprites["helpwindow"]
    dw.letterbyletter=true
    dw.text=msg
    dw.visible=true
    pbBottomLeftLines(dw,2)
    commands=[_INTL("Yes"),_INTL("No")]
    cw = Window_CommandPokemon.new(commands)
    cw.viewport=@viewport
    pbBottomRight(cw)
    cw.y-=dw.height
    cw.index=0
    pbPlayDecisionSE()
    loop do
      cw.visible=!dw.busy?
      Graphics.update
      Input.update
      cw.update
      self.update
      if Input.trigger?(Input::B) && dw.resume && !dw.busy?
        cw.dispose
        @sprites["helpwindow"].visible=false
        return false
      end
      if Input.trigger?(Input::C) && dw.resume && !dw.busy?
        cw.dispose
        @sprites["helpwindow"].visible=false
        return (cw.index==0)?true:false
      end
    end
  end

  def pbFormatNumber(num)
    ret = ""
    mod = 1
    count = 0
    while num >= mod
      count += 1
      ret = ((num / mod).floor % 10).to_s + ret
      ret = "," + ret if count  % 3 == 0
      mod *= 10
    end
    return ret
  end

  def pbChooseBuyItem
    itemwindow=@sprites["itemwindow"]
    @sprites["helpwindow"].visible=false
    pbActivateWindow(@sprites,"itemwindow"){
       pbRefresh
       loop do
         Graphics.update
         Input.update
         olditem=-1
         self.update
         if itemwindow.item!=olditem
           #@sprites["icon"].item=itemwindow.item
           pbRefresh
         end
         if Input.trigger?(Input::B)
           return 0
         end
         if Input.trigger?(Input::C)
           if itemwindow.index<@stock.length
             pbRefresh
             return @stock[itemwindow.index]
           else
             return 0
           end
         end
       end
    }
  end
end


#######################################################


class CraftScreen
  def initialize(scene,stock)
    @scene=scene
    @stock=stock
    @adapter=CraftAdapter.new
  end

  def pbConfirm(msg)
    return @scene.pbConfirm(msg)
  end

  def pbDisplay(msg)
    return @scene.pbDisplay(msg)
  end

  def pbDisplayPaused(msg)
    return @scene.pbDisplayPaused(msg)
  end

  def pbCraftScreen
    @scene.pbStartCraftScene(@stock,@adapter)
    item=0
    loop do
      item=@scene.pbChooseBuyItem
      break if item==0
      itemname=item[0]
      hasitems = true
      for i in 0..2
        it = item[1][i*2]
        qt = item[1][i*2+1]
        if it
          if it == :PAY
            if $player.money < qt
              hasitems = false
            end
          elsif it == :EXP
            if $game_variables[BONUS_EXP] < qt
              hasitems = false
            end
          elsif $bag.quantity(it)<qt
            hasitems = false
          end
        end
      end
      if !hasitems
        pbDisplayPaused("You do not have the required items.")
        next
      else
        if !pbConfirm(_INTL("Do you want the {1}?", item[0]))
          next
        end
        for i in 0..2
          it = item[1][i*2]
          qt = item[1][i*2+1]
          if it
            if it == :PAY
              $player.money -= qt
            else
               $bag.remove(it,qt)
            end
          end
        end
        for i in 0..1
          it = item[2][i*2]
          qt = item[2][i*2+1]
          if it
            if it == :GET
              $player.money += qt
              Kernel.pbMessage(_INTL("\\se[ItemGet]Obtained \\c[1]${1}\\c[0]!\\wtnp[30]",qt))
            else
               Kernel.pbReceiveItem(it,qt)
            end
          end
        end
      end
    end
    @scene.pbEndBuyScene
  end
end



def pbItemCraft(stock, speech=nil)
  scene=CraftScene.new
  screen=CraftScreen.new(scene,stock)
  screen.pbCraftScreen
end 

def pbExampleCrafts
  trades = [
    ["Berry Juice",[:ORANBERRY,3],[:BERRYJUICE,2]],
    ["Mystic Water",[:SHOALSHELL,1,:BLUESHARD,1],[:MYSTICWATER,1]]
  ]
  return trades
end