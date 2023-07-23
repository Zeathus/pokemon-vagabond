#===============================================================================
#
#===============================================================================
class Window_PokemonBag < Window_DrawableCommand
  attr_reader :pocket
  attr_accessor :sorting

  def initialize(bag, filterlist, pocket, x, y, width, height)
    @bag        = bag
    @filterlist = filterlist
    @pocket     = pocket
    @in_pocket  = false
    @sorting = false
    @adapter = PokemonMartAdapter.new
    super(x, y, width, height)
    @selarrow  = AnimatedBitmap.new("Graphics/Pictures/Bag/cursor")
    @swaparrow = AnimatedBitmap.new("Graphics/Pictures/Bag/cursor_swap")
    self.windowskin = nil
  end

  def dispose
    @swaparrow.dispose
    super
  end

  def in_pocket
    return @in_pocket
  end

  def in_pocket=(value)
    return @in_pocket = value
  end

  def pocket=(value)
    @pocket = value
    @item_max = (@filterlist) ? @filterlist[@pocket].length + 1 : @bag.pockets[@pocket].length + 1
    self.index = @bag.last_viewed_index(@pocket)
  end

  def page_row_max; return PokemonBag_Scene::ITEMSVISIBLE; end
  def page_item_max; return PokemonBag_Scene::ITEMSVISIBLE; end

  def item
    return nil if @filterlist && !@filterlist[@pocket][self.index]
    thispocket = @bag.pockets[@pocket]
    item = (@filterlist) ? thispocket[@filterlist[@pocket][self.index]] : thispocket[self.index]
    return (item) ? item[0] : nil
  end

  def itemCount
    return (@filterlist) ? @filterlist[@pocket].length + 1 : @bag.pockets[@pocket].length + 1
  end

  def itemRect(item)
    if item < 0 || item >= @item_max || item < self.top_item - 1 ||
       item > self.top_item + self.page_item_max
      return Rect.new(0, 0, 0, 0)
    else
      cursor_width = (self.width - self.borderX - ((@column_max - 1) * @column_spacing)) / @column_max
      x = item % @column_max * (cursor_width + @column_spacing)
      y = (item / @column_max * @row_height) - @virtualOy - 6
      return Rect.new(x, y, cursor_width, @row_height)
    end
  end

  def pocketRect(pocket)
    x = 142 + ((pocket - 1) % 3) * 50
    y = 86 + ((pocket - 1) / 3).floor * 50
    return Rect.new(x, y, 60, 60)
  end

  def drawCursor(index, rect)
    if self.index == index
      bmp = (@in_pocket) ? ((@sorting) ? @swaparrow.bitmap : @selarrow.bitmap) : @pocketarrow.bitmap
      pbCopyBitmap(self.contents, bmp, rect.x, rect.y + 2)
    end
  end

  def drawItem(index, _count, rect)
    textpos = []
    rect = Rect.new(rect.x + 16, rect.y + 16, rect.width - 16, rect.height)
    thispocket = @bag.pockets[@pocket]
    if index == self.itemCount - 1
      textpos.push([_INTL("CLOSE BAG"), rect.x, rect.y + 2, false, self.baseColor, self.shadowColor])
    else
      item = (@filterlist) ? thispocket[@filterlist[@pocket][index]][0] : thispocket[index][0]
      baseColor   = self.baseColor
      shadowColor = self.shadowColor
      if @sorting && index == self.index
        baseColor   = Color.new(224, 0, 0)
        shadowColor = Color.new(248, 144, 144)
      end
      textpos.push(
        [@adapter.getDisplayName(item), rect.x, rect.y + 2, false, baseColor, shadowColor]
      )
      if GameData::Item.get(item).is_important?
        if @bag.registered?(item)
          pbDrawImagePositions(
            self.contents,
            [["Graphics/Pictures/Bag/icon_register", rect.x + rect.width - 72, rect.y + 8, 0, 0, -1, 24]]
          )
        elsif pbCanRegisterItem?(item)
          pbDrawImagePositions(
            self.contents,
            [["Graphics/Pictures/Bag/icon_register", rect.x + rect.width - 72, rect.y + 8, 0, 24, -1, 24]]
          )
        end
      else
        qty = (@filterlist) ? thispocket[@filterlist[@pocket][index]][1] : thispocket[index][1]
        qtytext = _ISPRINTF("x{1: 3d}", qty)
        xQty    = rect.x + rect.width - self.contents.text_size(qtytext).width - 16
        textpos.push([qtytext, xQty, rect.y + 2, false, baseColor, shadowColor])
      end
    end
    pbDrawTextPositions(self.contents, textpos)
  end

  def refresh
    @item_max = itemCount
    self.update_cursor_rect
    dwidth  = self.width - self.borderX
    dheight = self.height - self.borderY - 6
    self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
    self.contents.clear
    @item_max.times do |i|
      next if i < self.top_item - 1 || i > self.top_item + self.page_item_max
      drawItem(i, @item_max, itemRect(i))
    end
    drawCursor(self.index, itemRect(self.index)) if @in_pocket
  end

  def update
    return if !@in_pocket
    super
    @uparrow.visible   = false
    @downarrow.visible = false
  end
end

#===============================================================================
# Bag visuals
#===============================================================================
class PokemonBag_Scene
  ITEMLISTBASECOLOR     = Color.new(88, 88, 80)
  ITEMLISTSHADOWCOLOR   = Color.new(168, 184, 184)
  ITEMTEXTBASECOLOR     = Color.new(248, 248, 248)
  ITEMTEXTSHADOWCOLOR   = Color.new(0, 0, 0)
  POCKETNAMEBASECOLOR   = Color.new(88, 88, 80)
  POCKETNAMESHADOWCOLOR = Color.new(168, 184, 184)
  ITEMSVISIBLE          = 11

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(bag, choosing = false, filterproc = nil, resetpocket = true)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @bag        = bag
    @choosing   = choosing
    @filterproc = filterproc
    pbRefreshFilter
    lastpocket = @bag.last_viewed_pocket
    numfilledpockets = @bag.pockets.length - 1
    if @choosing
      numfilledpockets = 0
      if @filterlist.nil?
        (1...@bag.pockets.length).each do |i|
          numfilledpockets += 1 if @bag.pockets[i].length > 0
        end
      else
        (1...@bag.pockets.length).each do |i|
          numfilledpockets += 1 if @filterlist[i].length > 0
        end
      end
      lastpocket = (resetpocket) ? 1 : @bag.last_viewed_pocket
      if (@filterlist && @filterlist[lastpocket].length == 0) ||
         (!@filterlist && @bag.pockets[lastpocket].length == 0)
        (1...@bag.pockets.length).each do |i|
          if @filterlist && @filterlist[i].length > 0
            lastpocket = i
            break
          elsif !@filterlist && @bag.pockets[i].length > 0
            lastpocket = i
            break
          end
        end
      end
    end
    @bag.last_viewed_pocket = lastpocket
    @sliderbitmap = AnimatedBitmap.new("Graphics/Pictures/Bag/icon_slider")
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["itemlist"] = Window_PokemonBag.new(@bag, @filterlist, lastpocket, 296, 8, 314, 40 + 24 + (ITEMSVISIBLE * 32))
    @sprites["itemlist"].viewport    = @viewport
    @sprites["itemlist"].pocket      = lastpocket
    @sprites["itemlist"].index       = @bag.last_viewed_index(lastpocket)
    @sprites["itemlist"].baseColor   = ITEMLISTBASECOLOR
    @sprites["itemlist"].shadowColor = ITEMLISTSHADOWCOLOR
    @sprites["itemicon"] = ItemIconSprite.new(112, Graphics.height - 48, nil, @viewport)
    @sprites["itemtext"] = Window_UnformattedTextPokemon.newWithSize(
      "", 140, 464, Graphics.width - 220, 128, @viewport
    )
    @sprites["itemtext"].baseColor   = ITEMTEXTBASECOLOR
    @sprites["itemtext"].shadowColor = ITEMTEXTSHADOWCOLOR
    @sprites["itemtext"].visible     = true
    @sprites["itemtext"].windowskin  = nil
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.new("")
    @sprites["helpwindow"].visible  = false
    @sprites["helpwindow"].viewport = @viewport
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible  = false
    @sprites["msgwindow"].viewport = @viewport
    @sprites["pocketarrow"] = IconSprite.new(14, 50, @viewport)
    @sprites["pocketarrow"].setBitmap("Graphics/Pictures/Bag/cursor_pocket")
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    pbDeactivateWindows(@sprites)
    pbRefresh
    pbFadeInAndShow(@sprites)
  end

  def pbFadeOutScene
    @oldsprites = pbFadeOutAndHide(@sprites)
  end

  def pbFadeInScene
    pbFadeInAndShow(@sprites, @oldsprites)
    @oldsprites = nil
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) if !@oldsprites
    @oldsprites = nil
    dispose
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @sliderbitmap.dispose
    @viewport.dispose
  end

  def pbDisplay(msg, brief = false)
    UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { pbUpdate }
  end

  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"], msg) { pbUpdate }
  end

  def pbChooseNumber(helptext, maximum, initnum = 1)
    return UIHelper.pbChooseNumber(@sprites["helpwindow"], helptext, maximum, initnum) { pbUpdate }
  end

  def pbShowCommands(helptext, commands, index = 0)
    return UIHelper.pbShowCommands(@sprites["helpwindow"], helptext, commands, index) { pbUpdate }
  end

  def pbRefresh
    # Set the background image
    @sprites["background"].setBitmap(sprintf("Graphics/Pictures/Bag/bg_#{@bag.last_viewed_pocket}"))
    # Refresh the item window
    @sprites["itemlist"].refresh
    # Refresh more things
    pbRefreshIndexChanged
  end

  def pbRefreshIndexChanged
    itemlist = @sprites["itemlist"]
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    # Draw the pocket name
    pbDrawTextPositions(
      overlay,
      [[PokemonBag.pocket_names[@bag.last_viewed_pocket - 1], 222, 266, 2, POCKETNAMEBASECOLOR, POCKETNAMESHADOWCOLOR]]
    )
    # Draw slider arrows
    showslider = false
    if itemlist.top_row > 0
      overlay.blt(598, 28, @sliderbitmap.bitmap, Rect.new(0, 0, 36, 36))
      showslider = true
    end
    if itemlist.top_item + itemlist.page_item_max < itemlist.itemCount
      overlay.blt(598, 408, @sliderbitmap.bitmap, Rect.new(0, 38, 36, 38))
      showslider = true
    end
    pocketRect = itemlist.pocketRect(itemlist.pocket)
    @sprites["pocketarrow"].x = pocketRect.x
    @sprites["pocketarrow"].y = pocketRect.y
    @sprites["pocketarrow"].visible = !itemlist.in_pocket
    # Draw slider box
    if showslider
      sliderheight = 322
      boxheight = (sliderheight * itemlist.page_row_max / itemlist.row_max).floor
      boxheight += [(sliderheight - boxheight) / 2, sliderheight / 6].min
      boxheight = [boxheight.floor, 38].max
      y = 76
      y += ((sliderheight - boxheight) * itemlist.top_row / (itemlist.row_max - itemlist.page_row_max)).floor
      overlay.blt(598, y, @sliderbitmap.bitmap, Rect.new(36, 0, 36, 4))
      i = 0
      while i * 16 < boxheight - 4 - 18
        height = [boxheight - 4 - 18 - (i * 16), 16].min
        overlay.blt(598, y + 4 + (i * 16), @sliderbitmap.bitmap, Rect.new(36, 4, 36, height))
        i += 1
      end
      overlay.blt(598, y + boxheight - 18, @sliderbitmap.bitmap, Rect.new(36, 20, 36, 18))
    end
    # Set the selected item's icon
    @sprites["itemicon"].item = itemlist.item
    # Set the selected item's description
    @sprites["itemtext"].text =
      (itemlist.item) ? GameData::Item.get(itemlist.item).description : _INTL("Close bag.")
  end

  def pbRefreshFilter
    @filterlist = nil
    return if !@choosing
    return if @filterproc.nil?
    @filterlist = []
    (1...@bag.pockets.length).each do |i|
      @filterlist[i] = []
      @bag.pockets[i].length.times do |j|
        @filterlist[i].push(j) if @filterproc.call(@bag.pockets[i][j][0])
      end
    end
  end

  # Called when the item screen wants an item to be chosen from the screen
  def pbChooseItem
    @sprites["helpwindow"].visible = false
    itemwindow = @sprites["itemlist"]
    thispocket = @bag.pockets[itemwindow.pocket]
    swapinitialpos = -1
    pbActivateWindow(@sprites, "itemlist") {
      loop do
        oldindex = itemwindow.index
        Graphics.update
        Input.update
        pbUpdate
        if itemwindow.sorting && itemwindow.index >= thispocket.length
          itemwindow.index = (oldindex == thispocket.length - 1) ? 0 : thispocket.length - 1
        end
        if itemwindow.index != oldindex
          # Move the item being switched
          if itemwindow.sorting
            thispocket.insert(itemwindow.index, thispocket.delete_at(oldindex))
          end
          # Update selected item for current pocket
          @bag.set_last_viewed_index(itemwindow.pocket, itemwindow.index)
          pbRefresh
        end
        if itemwindow.sorting
          if Input.trigger?(Input::ACTION) ||
             Input.trigger?(Input::USE)
            itemwindow.sorting = false
            pbPlayDecisionSE
            pbRefresh
          elsif Input.trigger?(Input::BACK)
            thispocket.insert(swapinitialpos, thispocket.delete_at(itemwindow.index))
            itemwindow.index = swapinitialpos
            itemwindow.sorting = false
            pbPlayCancelSE
            pbRefresh
          end
        else   # Change pockets
          if itemwindow.in_pocket
            if Input.trigger?(Input::BACK)   # Cancel the item screen
              pbPlayCloseMenuSE
              itemwindow.in_pocket = false
              pbRefresh
            elsif Input.trigger?(Input::ACTION)   # Start switching the selected item
              if !@choosing && thispocket.length > 1 && itemwindow.index < thispocket.length &&
                !Supplementals::BAG_POCKET_AUTO_SORT[itemwindow.pocket - 1]
                itemwindow.sorting = true
                swapinitialpos = itemwindow.index
                pbPlayDecisionSE
                pbRefresh
              end
            elsif Input.trigger?(Input::USE)   # Choose selected item
              (itemwindow.item) ? pbPlayDecisionSE : pbPlayCloseMenuSE
              return itemwindow.item
            end
          else
            if Input.trigger?(Input::LEFT)
              newpocket = itemwindow.pocket
              loop do
                newpocket = (newpocket % 3 == 1) ? newpocket + 2 : newpocket - 1
                break if !@choosing || newpocket == itemwindow.pocket
                if @filterlist
                  break if @filterlist[newpocket].length > 0
                elsif @bag.pockets[newpocket].length > 0
                  break
                end
              end
              if itemwindow.pocket != newpocket
                itemwindow.pocket = newpocket
                @bag.last_viewed_pocket = itemwindow.pocket
                thispocket = @bag.pockets[itemwindow.pocket]
                pbPlayCursorSE
                pbRefresh
              end
            elsif Input.trigger?(Input::RIGHT)
              newpocket = itemwindow.pocket
              loop do
                newpocket = (newpocket % 3 == 0) ? newpocket - 2 : newpocket + 1
                break if !@choosing || newpocket == itemwindow.pocket
                if @filterlist
                  break if @filterlist[newpocket].length > 0
                elsif @bag.pockets[newpocket].length > 0
                  break
                end
              end
              if itemwindow.pocket != newpocket
                itemwindow.pocket = newpocket
                @bag.last_viewed_pocket = itemwindow.pocket
                thispocket = @bag.pockets[itemwindow.pocket]
                pbPlayCursorSE
                pbRefresh
              end
            elsif Input.trigger?(Input::UP)
              newpocket = itemwindow.pocket
              loop do
                newpocket = (newpocket <= 3) ? newpocket + 6 : newpocket - 3
                break if !@choosing || newpocket == itemwindow.pocket
                if @filterlist
                  break if @filterlist[newpocket].length > 0
                elsif @bag.pockets[newpocket].length > 0
                  break
                end
              end
              if itemwindow.pocket != newpocket
                itemwindow.pocket = newpocket
                @bag.last_viewed_pocket = itemwindow.pocket
                thispocket = @bag.pockets[itemwindow.pocket]
                pbPlayCursorSE
                pbRefresh
              end
            elsif Input.trigger?(Input::DOWN)
              newpocket = itemwindow.pocket
              loop do
                newpocket = (newpocket >= 7) ? newpocket - 6 : newpocket + 3
                break if !@choosing || newpocket == itemwindow.pocket
                if @filterlist
                  break if @filterlist[newpocket].length > 0
                elsif @bag.pockets[newpocket].length > 0
                  break
                end
              end
              if itemwindow.pocket != newpocket
                itemwindow.pocket = newpocket
                @bag.last_viewed_pocket = itemwindow.pocket
                thispocket = @bag.pockets[itemwindow.pocket]
                pbPlayCursorSE
                pbRefresh
              end
  #          elsif Input.trigger?(Input::SPECIAL)   # Register/unregister selected item
  #            if !@choosing && itemwindow.index<thispocket.length
  #              if @bag.registered?(itemwindow.item)
  #                @bag.unregister(itemwindow.item)
  #              elsif pbCanRegisterItem?(itemwindow.item)
  #                @bag.register(itemwindow.item)
  #              end
  #              pbPlayDecisionSE
  #              pbRefresh
  #            end
            elsif Input.trigger?(Input::BACK)   # Cancel the item screen
              pbPlayCloseMenuSE
              return nil
            elsif Input.trigger?(Input::USE)   # Choose selected item
              pbPlayDecisionSE
              itemwindow.in_pocket = true
              pbRefresh
            end
          end
        end
      end
    }
  end
end

#===============================================================================
# Bag mechanics
#===============================================================================
class PokemonBagScreen
  def initialize(scene, bag)
    @bag   = bag
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene(@bag)
    item = nil
    loop do
      item = @scene.pbChooseItem
      break if !item
      itm = GameData::Item.get(item)
      cmdRead     = -1
      cmdUse      = -1
      cmdRegister = -1
      cmdGive     = -1
      cmdToss     = -1
      cmdDebug    = -1
      commands = []
      # Generate command list
      commands[cmdRead = commands.length] = _INTL("Read") if itm.is_mail?
      if ItemHandlers.hasOutHandler(item) || (itm.is_machine? && $player.party.length > 0)
        if ItemHandlers.hasUseText(item)
          commands[cmdUse = commands.length]    = ItemHandlers.getUseText(item)
        else
          commands[cmdUse = commands.length]    = _INTL("Use")
        end
      end
      commands[cmdGive = commands.length]       = _INTL("Give") if $player.pokemon_party.length > 0 && itm.can_hold?
      commands[cmdToss = commands.length]       = _INTL("Toss") if !itm.is_important? || $DEBUG
      if @bag.registered?(item)
        commands[cmdRegister = commands.length] = _INTL("Deselect")
      elsif pbCanRegisterItem?(item)
        commands[cmdRegister = commands.length] = _INTL("Register")
      end
      commands[cmdDebug = commands.length]      = _INTL("Debug") if $DEBUG
      commands[commands.length]                 = _INTL("Cancel")
      # Show commands generated above
      itemname = itm.name
      command = @scene.pbShowCommands(_INTL("{1} is selected.", itemname), commands)
      if cmdRead >= 0 && command == cmdRead   # Read mail
        pbFadeOutIn {
          pbDisplayMail(Mail.new(item, "", ""))
        }
      elsif cmdUse >= 0 && command == cmdUse   # Use item
        ret = pbUseItem(@bag, item, @scene)
        # ret: 0=Item wasn't used; 1=Item used; 2=Close Bag to use in field
        break if ret == 2   # End screen
        @scene.pbRefresh
        next
      elsif cmdGive >= 0 && command == cmdGive   # Give item to Pokémon
        if $player.pokemon_count == 0
          @scene.pbDisplay(_INTL("There is no Pokémon."))
        elsif itm.is_important?
          @scene.pbDisplay(_INTL("The {1} can't be held.", itemname))
        else
          pbChoosePokemonScreen(0, 99999) { |member_id, party_idx|
            pbGiveItemToPokemon(item, getPartyPokemon(member_id)[party_idx], @scene)
          }
          @scene.pbRefresh
        end
      elsif cmdToss >= 0 && command == cmdToss   # Toss item
        qty = @bag.quantity(item)
        if qty > 1
          helptext = _INTL("Toss out how many {1}?", itm.name_plural)
          qty = @scene.pbChooseNumber(helptext, qty)
        end
        if qty > 0
          itemname = itm.name_plural if qty > 1
          if pbConfirm(_INTL("Is it OK to throw away {1} {2}?", qty, itemname))
            pbDisplay(_INTL("Threw away {1} {2}.", qty, itemname))
            qty.times { @bag.remove(item) }
            @scene.pbRefresh
          end
        end
      elsif cmdRegister >= 0 && command == cmdRegister   # Register item
        if @bag.registered?(item)
          @bag.unregister(item)
        else
          @bag.register(item)
        end
        @scene.pbRefresh
      elsif cmdDebug >= 0 && command == cmdDebug   # Debug
        command = 0
        loop do
          command = @scene.pbShowCommands(_INTL("Do what with {1}?", itemname),
                                          [_INTL("Change quantity"),
                                           _INTL("Make Mystery Gift"),
                                           _INTL("Cancel")], command)
          case command
          ### Cancel ###
          when -1, 2
            break
          ### Change quantity ###
          when 0
            qty = @bag.quantity(item)
            itemplural = itm.name_plural
            params = ChooseNumberParams.new
            params.setRange(0, Settings::BAG_MAX_PER_SLOT)
            params.setDefaultValue(qty)
            newqty = pbMessageChooseNumber(
              _INTL("Choose new quantity of {1} (max. #{Settings::BAG_MAX_PER_SLOT}).", itemplural), params
            ) { @scene.pbUpdate }
            if newqty > qty
              @bag.add(item, newqty - qty)
            elsif newqty < qty
              @bag.remove(item, qty - newqty)
            end
            @scene.pbRefresh
            break if newqty == 0
          ### Make Mystery Gift ###
          when 1
            pbCreateMysteryGift(1, item)
          end
        end
      end
    end
    ($game_temp.fly_destination) ? @scene.dispose : @scene.pbEndScene
    return item
  end

  def pbDisplay(text)
    @scene.pbDisplay(text)
  end

  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end

  # UI logic for the item screen for choosing an item.
  def pbChooseItemScreen(proc = nil)
    oldlastpocket = @bag.last_viewed_pocket
    oldchoices = @bag.last_pocket_selections.clone
    @bag.reset_last_selections if proc
    @scene.pbStartScene(@bag, true, proc)
    item = @scene.pbChooseItem
    @scene.pbEndScene
    @bag.last_viewed_pocket = oldlastpocket
    @bag.last_pocket_selections = oldchoices
    return item
  end

  # UI logic for withdrawing an item in the item storage screen.
  def pbWithdrawItemScreen
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage = PCItemStorage.new
    end
    storage = $PokemonGlobal.pcItemStorage
    @scene.pbStartScene(storage)
    loop do
      item = @scene.pbChooseItem
      break if !item
      itm = GameData::Item.get(item)
      qty = storage.quantity(item)
      if qty > 1 && !itm.is_important?
        qty = @scene.pbChooseNumber(_INTL("How many do you want to withdraw?"), qty)
      end
      next if qty <= 0
      if @bag.can_add?(item, qty)
        if !storage.remove(item, qty)
          raise "Can't delete items from storage"
        end
        if !@bag.add(item, qty)
          raise "Can't withdraw items from storage"
        end
        @scene.pbRefresh
        dispqty = (itm.is_important?) ? 1 : qty
        itemname = (dispqty > 1) ? itm.name_plural : itm.name
        pbDisplay(_INTL("Withdrew {1} {2}.", dispqty, itemname))
      else
        pbDisplay(_INTL("There's no more room in the Bag."))
      end
    end
    @scene.pbEndScene
  end

  # UI logic for depositing an item in the item storage screen.
  def pbDepositItemScreen
    @scene.pbStartScene(@bag)
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage = PCItemStorage.new
    end
    storage = $PokemonGlobal.pcItemStorage
    loop do
      item = @scene.pbChooseItem
      break if !item
      itm = GameData::Item.get(item)
      qty = @bag.quantity(item)
      if qty > 1 && !itm.is_important?
        qty = @scene.pbChooseNumber(_INTL("How many do you want to deposit?"), qty)
      end
      if qty > 0
        if storage.can_add?(item, qty)
          if !@bag.remove(item, qty)
            raise "Can't delete items from Bag"
          end
          if !storage.add(item, qty)
            raise "Can't deposit items to storage"
          end
          @scene.pbRefresh
          dispqty  = (itm.is_important?) ? 1 : qty
          itemname = (dispqty > 1) ? itm.name_plural : itm.name
          pbDisplay(_INTL("Deposited {1} {2}.", dispqty, itemname))
        else
          pbDisplay(_INTL("There's no room to store items."))
        end
      end
    end
    @scene.pbEndScene
  end

  # UI logic for tossing an item in the item storage screen.
  def pbTossItemScreen
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage = PCItemStorage.new
    end
    storage = $PokemonGlobal.pcItemStorage
    @scene.pbStartScene(storage)
    loop do
      item = @scene.pbChooseItem
      break if !item
      itm = GameData::Item.get(item)
      if itm.is_important?
        @scene.pbDisplay(_INTL("That's too important to toss out!"))
        next
      end
      qty = storage.quantity(item)
      itemname       = itm.name
      itemnameplural = itm.name_plural
      if qty > 1
        qty = @scene.pbChooseNumber(_INTL("Toss out how many {1}?", itemnameplural), qty)
      end
      next if qty <= 0
      itemname = itemnameplural if qty > 1
      next if !pbConfirm(_INTL("Is it OK to throw away {1} {2}?", qty, itemname))
      if !storage.remove(item, qty)
        raise "Can't delete items from storage"
      end
      @scene.pbRefresh
      pbDisplay(_INTL("Threw away {1} {2}.", qty, itemname))
    end
    @scene.pbEndScene
  end
end
