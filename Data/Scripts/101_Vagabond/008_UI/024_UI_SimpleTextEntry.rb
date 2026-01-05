#===============================================================================
#
#===============================================================================
class Window_SimpleCharacterEntry < Window_DrawableCommand
  XSIZE = 13
  YSIZE = 4

  def initialize(charset, viewport = nil)
    @viewport = viewport
    @charset = charset
    @othercharset = ""
    super(0, 96, 480, 192)
    colors = getDefaultTextColors(self.windowskin)
    self.baseColor = colors[0]
    self.shadowColor = colors[1]
    self.columns = XSIZE
    refresh
  end

  def setOtherCharset(value)
    @othercharset = value.clone
    refresh
  end

  def setCharset(value)
    @charset = value.clone
    refresh
  end

  def character
    if self.index < 0 || self.index >= @charset.length
      return ""
    else
      return @charset[self.index]
    end
  end

  def command
    return -1 if self.index == @charset.length
    return -2 if self.index == @charset.length + 1
    return -3 if self.index == @charset.length + 2
    return self.index
  end

  def itemCount
    return @charset.length + 3
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    if index == @charset.length # -1
      pbDrawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height, "[ ]",
                       self.baseColor, self.shadowColor)
    elsif index == @charset.length + 1 # -2
      pbDrawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height, @othercharset,
                       self.baseColor, self.shadowColor)
    elsif index == @charset.length + 2 # -3
      pbDrawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height, _INTL("OK"),
                       self.baseColor, self.shadowColor)
    else
      pbDrawShadowText(self.contents, rect.x, rect.y, rect.width, rect.height, @charset[index],
                       self.baseColor, self.shadowColor)
    end
  end
end

#===============================================================================
# Text entry screen - free typing.
#===============================================================================
class PokemonSimpleEntryScene
  @@Characters = [
    [("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz").scan(/./), "[*]"],
    [("0123456789 !-+:',.?").scan(/./), "[A]"]
  ]
  USEKEYBOARD = true

  def pbStartScene(x, y, helptext, minlength, maxlength, initialText, subject = 0, pokemon = nil)
    @sprites = {}
    @viewport = Viewport.new(x, y, Graphics.width, Graphics.height)
    @viewport.z = 99999
    if USEKEYBOARD
      @sprites["entry"] = Window_TextEntry_Keyboard.new(
        initialText, 0, 0, 560, 96, helptext, true
      )
      Input.text_input = true
    else
      @sprites["entry"] = Window_TextEntry.new(initialText, 0, 0, 400, 96, helptext, true)
    end
    @sprites["entry"].x = (Graphics.width / 2) - (@sprites["entry"].width / 2) + 32
    @sprites["entry"].viewport = @viewport
    @sprites["entry"].visible = true
    @minlength = minlength
    @maxlength = maxlength
    @symtype = 0
    @sprites["entry"].maxlength = maxlength
    if !USEKEYBOARD
      @sprites["entry2"] = Window_SimpleCharacterEntry.new(@@Characters[@symtype][0])
      @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
      @sprites["entry2"].viewport = @viewport
      @sprites["entry2"].visible = true
      @sprites["entry2"].x = (Graphics.width / 2) - (@sprites["entry2"].width / 2)
    end
    if minlength == 0
      @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize(
        _INTL("Enter text using the keyboard. Press\nEnter to confirm, or Esc to cancel."),
        32, Graphics.height - 96, Graphics.width - 64, 96, @viewport
      )
    else
      @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize(
        _INTL("Enter text using the keyboard.\nPress Enter to confirm."),
        32, Graphics.height - 96, Graphics.width - 64, 96, @viewport
      )
    end
    @sprites["helpwindow"].letterbyletter = false
    @sprites["helpwindow"].viewport = @viewport
    @sprites["helpwindow"].visible = USEKEYBOARD
    @sprites["helpwindow"].baseColor = Color.new(16, 24, 32)
    @sprites["helpwindow"].shadowColor = Color.new(168, 184, 184)
    @sprites["control_input"] = KeybindSprite.new(Input::F9, "Change to virtual keyboard", 132, 476, @viewport)
    @sprites["control_input"].z = 99999
    #@sprites["background"] = IconSprite.new(0, 0, @viewport)
    #@sprites["background"].setBitmap("Graphics/UI/Naming/bg_simple")
    addBackgroundPlane(@sprites, "background", "Naming/bg_simple", @viewport)
    case subject
    when 1   # Player
      meta = GameData::PlayerMetadata.get($player.character_ID)
      if meta
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap("Graphics/UI/Naming/icon_shadow")
        @sprites["shadow"].x = 66
        @sprites["shadow"].y = 64
        filename = pbGetPlayerCharset(meta.walk_charset, nil, true)
        @sprites["subject"] = TrainerWalkingCharSprite.new(filename, @viewport)
        charwidth = @sprites["subject"].bitmap.width
        charheight = @sprites["subject"].bitmap.height
        @sprites["subject"].x = 88 - (charwidth / 8)
        @sprites["subject"].y = 76 - (charheight / 4)
      end
    when 2   # Pokémon
      if pokemon
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap("Graphics/UI/Naming/icon_shadow")
        @sprites["shadow"].x = 66
        @sprites["shadow"].y = 64
        @sprites["subject"] = PokemonIconSprite.new(pokemon, @viewport)
        @sprites["subject"].setOffset(PictureOrigin::CENTER)
        @sprites["subject"].x = 88
        @sprites["subject"].y = 54
        @sprites["gender"] = BitmapSprite.new(32, 32, @viewport)
        @sprites["gender"].x = 430
        @sprites["gender"].y = 54
        @sprites["gender"].bitmap.clear
        pbSetSystemFont(@sprites["gender"].bitmap)
        textpos = []
        if pokemon.male?
          textpos.push([_INTL("♂"), 0, 6, :left, Color.new(0, 128, 248), Color.new(168, 184, 184)])
        elsif pokemon.female?
          textpos.push([_INTL("♀"), 0, 6, :left, Color.new(248, 24, 24), Color.new(168, 184, 184)])
        end
        pbDrawTextPositions(@sprites["gender"].bitmap, textpos)
      end
    when 3   # NPC
      @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
      @sprites["shadow"].setBitmap("Graphics/UI/Naming/icon_shadow")
      @sprites["shadow"].x = 66
      @sprites["shadow"].y = 64
      @sprites["subject"] = TrainerWalkingCharSprite.new(pokemon.to_s, @viewport)
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - (charwidth / 8)
      @sprites["subject"].y = 76 - (charheight / 4)
    when 4   # Storage box
      @sprites["subject"] = TrainerWalkingCharSprite.new(nil, @viewport)
      @sprites["subject"].altcharset = "Graphics/UI/Naming/icon_storage"
      @sprites["subject"].anim_duration = 0.4
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - (charwidth / 8)
      @sprites["subject"].y = 52 - (charheight / 2)
    end
    pbFadeInAndShow(@sprites)
  end

  def pbEntry1
    ret = ""
    loop do
      Graphics.update
      Input.update
      if Input.triggerex?(:ESCAPE) && @minlength == 0
        ret = ""
        break
      elsif Input.triggerex?(:RETURN) && @sprites["entry"].text.length >= @minlength
        ret = @sprites["entry"].text
        break
      elsif Input.triggerex?(:F9)
        ret = -1
        break
      end
      @sprites["helpwindow"].update
      @sprites["entry"].update
      @sprites["subject"]&.update
    end
    Input.update
    return ret
  end

  def pbEntry2
    ret = ""
    loop do
      Graphics.update
      Input.update
      @sprites["helpwindow"].update
      @sprites["entry"].update
      @sprites["entry2"].update
      @sprites["subject"]&.update
      if Input.trigger?(Input::USE)
        index = @sprites["entry2"].command
        if index == -3 # Confirm text
          ret = @sprites["entry"].text
          if ret.length < @minlength || ret.length > @maxlength
            pbPlayBuzzerSE
          else
            pbPlayDecisionSE
            break
          end
        elsif index == -1   # Insert a space
          if @sprites["entry"].insert(" ")
            pbPlayDecisionSE
          else
            pbPlayBuzzerSE
          end
        elsif index == -2   # Change character set
          pbPlayDecisionSE
          @symtype += 1
          @symtype = 0 if @symtype >= @@Characters.length
          @sprites["entry2"].setCharset(@@Characters[@symtype][0])
          @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
        else   # Insert given character
          if @sprites["entry"].insert(@sprites["entry2"].character)
            pbPlayDecisionSE
          else
            pbPlayBuzzerSE
          end
        end
        next
      end
    end
    Input.update
    return ret
  end

  def pbEntry
    return USEKEYBOARD ? pbEntry1 : pbEntry2
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    Input.text_input = false if USEKEYBOARD
  end
end

#===============================================================================
# Text entry screen - arrows to select letter.
#===============================================================================
class PokemonSimpleEntryScene2
  @@Characters = [
    [("ABCDEFGHIJ,." + "KLMNOPQRST'-" + "UVWXYZ    !?" + "0123456789:+").scan(/./), _INTL("UPPER")]
  ]
  ROWS    = 12
  COLUMNS = 4
  MODE1   = -6
  MODE2   = -5
  MODE3   = -4
  MODE4   = -3
  BACK    = -2
  OK      = -1

  class NameEntryCursor
    def initialize(viewport)
      @sprite = Sprite.new(viewport)
      @cursortype = 0
      @cursor1 = AnimatedBitmap.new("Graphics/UI/Naming/cursor_1")
      @cursor2 = AnimatedBitmap.new("Graphics/UI/Naming/cursor_2")
      @cursor3 = AnimatedBitmap.new("Graphics/UI/Naming/cursor_3")
      @cursorPos = 0
      updateInternal
    end

    def setCursorPos(value)
      @cursorPos = value
    end

    def updateCursorPos
      value = @cursorPos
      case value
      when PokemonSimpleEntryScene2::MODE1   # Upper case
        @sprite.x = 44
        @sprite.y = 74
        @cursortype = 1
      when PokemonSimpleEntryScene2::MODE2   # Lower case
        @sprite.x = 106
        @sprite.y = 74
        @cursortype = 1
      when PokemonSimpleEntryScene2::MODE3   # Accents
        @sprite.x = 168
        @sprite.y = 74
        @cursortype = 1
      when PokemonSimpleEntryScene2::MODE4   # Other symbols
        @sprite.x = 230
        @sprite.y = 74
        @cursortype = 1
      when PokemonSimpleEntryScene2::BACK   # Back
        @sprite.x = 448
        @sprite.y = 148
        @cursortype = 2
      when PokemonSimpleEntryScene2::OK   # OK
        @sprite.x = 448
        @sprite.y = 198
        @cursortype = 2
      else
        if value >= 0
          @sprite.x = 52 + (32 * (value % PokemonSimpleEntryScene2::ROWS))
          @sprite.y = 134 + (38 * (value / PokemonSimpleEntryScene2::ROWS))
          @cursortype = 0
        end
      end
    end

    def visible=(value)
      @sprite.visible = value
    end

    def visible
      @sprite.visible
    end

    def color=(value)
      @sprite.color = value
    end

    def color
      @sprite.color
    end

    def disposed?
      @sprite.disposed?
    end

    def updateInternal
      @cursor1.update
      @cursor2.update
      @cursor3.update
      updateCursorPos
      case @cursortype
      when 0 then @sprite.bitmap = @cursor1.bitmap
      when 1 then @sprite.bitmap = @cursor2.bitmap
      when 2 then @sprite.bitmap = @cursor3.bitmap
      end
    end

    def update
      updateInternal
    end

    def dispose
      @cursor1.dispose
      @cursor2.dispose
      @cursor3.dispose
      @sprite.dispose
    end
  end

  def pbStartScene(x, y, helptext, minlength, maxlength, initialText, subject = 0, pokemon = nil)
    @viewport = Viewport.new(x, y, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @helptext = helptext
    @helper = CharacterEntryHelper.new(initialText)
    # Create bitmaps
    @bitmaps = []
    @@Characters.length.times do |i|
      @bitmaps[i] = AnimatedBitmap.new("Graphics/UI/Naming/overlay_tab_simple")
      b = @bitmaps[i].bitmap.clone
      pbSetSystemFont(b)
      textPos = []
      COLUMNS.times do |y|
        ROWS.times do |x|
          pos = (y * ROWS) + x
          textPos.push([@@Characters[i][0][pos], 44 + (x * 32), 24 + (y * 38), :center,
                        Color.new(16, 24, 32), Color.new(160, 160, 160)])
        end
      end
      pbDrawTextPositions(b, textPos)
      @bitmaps[@@Characters.length + i] = b
    end
    underline_bitmap = Bitmap.new(24, 6)
    underline_bitmap.fill_rect(2, 2, 22, 4, Color.new(168, 184, 184))
    underline_bitmap.fill_rect(0, 0, 22, 4, Color.new(16, 24, 32))
    @bitmaps.push(underline_bitmap)
    # Create sprites
    @sprites = {}
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap("Graphics/UI/Naming/bg_simple")
    @sprites["control_input"] = KeybindSprite.new(Input::F9, "Change to keyboard input", 132, 476, @viewport)
    @sprites["control_input"].z = 99999
    case subject
    when 1   # Player
      meta = GameData::PlayerMetadata.get($player.character_ID)
      if meta
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap("Graphics/UI/Naming/icon_shadow")
        @sprites["shadow"].x = 66
        @sprites["shadow"].y = 64
        filename = pbGetPlayerCharset(meta.walk_charset, nil, true)
        @sprites["subject"] = TrainerWalkingCharSprite.new(filename, @viewport)
        charwidth = @sprites["subject"].bitmap.width
        charheight = @sprites["subject"].bitmap.height
        @sprites["subject"].x = 88 - (charwidth / 8)
        @sprites["subject"].y = 76 - (charheight / 4)
      end
    when 2   # Pokémon
      if pokemon
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap("Graphics/UI/Naming/icon_shadow")
        @sprites["shadow"].x = 66
        @sprites["shadow"].y = 64
        @sprites["subject"] = PokemonIconSprite.new(pokemon, @viewport)
        @sprites["subject"].setOffset(PictureOrigin::CENTER)
        @sprites["subject"].x = 88
        @sprites["subject"].y = 54
        @sprites["gender"] = BitmapSprite.new(32, 32, @viewport)
        @sprites["gender"].x = 430
        @sprites["gender"].y = 54
        @sprites["gender"].bitmap.clear
        pbSetSystemFont(@sprites["gender"].bitmap)
        textpos = []
        if pokemon.male?
          textpos.push([_INTL("♂"), 0, 6, :left, Color.new(0, 128, 248), Color.new(168, 184, 184)])
        elsif pokemon.female?
          textpos.push([_INTL("♀"), 0, 6, :left, Color.new(248, 24, 24), Color.new(168, 184, 184)])
        end
        pbDrawTextPositions(@sprites["gender"].bitmap, textpos)
      end
    when 3   # NPC
      @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
      @sprites["shadow"].setBitmap("Graphics/UI/Naming/icon_shadow")
      @sprites["shadow"].x = 66
      @sprites["shadow"].y = 64
      @sprites["subject"] = TrainerWalkingCharSprite.new(pokemon.to_s, @viewport)
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - (charwidth / 8)
      @sprites["subject"].y = 76 - (charheight / 4)
    when 4   # Storage box
      @sprites["subject"] = TrainerWalkingCharSprite.new(nil, @viewport)
      @sprites["subject"].altcharset = "Graphics/UI/Naming/icon_storage"
      @sprites["subject"].anim_duration = 0.4
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - (charwidth / 8)
      @sprites["subject"].y = 52 - (charheight / 2)
    end
    @sprites["bgoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbDoUpdateOverlay
    @blanks = []
    @mode = 0
    @minlength = minlength
    @maxlength = maxlength
    @maxlength.times do |i|
      @sprites["blank#{i}"] = Sprite.new(@viewport)
      @sprites["blank#{i}"].x = 128 + (24 * i)
      @sprites["blank#{i}"].bitmap = @bitmaps[@bitmaps.length - 1]
      @blanks[i] = 0
    end
    @sprites["bottomtab"] = Sprite.new(@viewport)   # Current tab
    @sprites["bottomtab"].x = 22
    @sprites["bottomtab"].y = 116
    @sprites["bottomtab"].bitmap = @bitmaps[@@Characters.length]
    @sprites["toptab"] = Sprite.new(@viewport)   # Next tab
    @sprites["toptab"].x = 22 - 504
    @sprites["toptab"].y = 116
    @sprites["toptab"].bitmap = @bitmaps[@@Characters.length + 1]
    @sprites["controls"] = IconSprite.new(0, 0, @viewport)
    @sprites["controls"].x = 16
    @sprites["controls"].y = 50
    @sprites["controls"].setBitmap(_INTL("Graphics/UI/Naming/overlay_controls_simple"))
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbDoUpdateOverlay2
    @sprites["cursor"] = NameEntryCursor.new(@viewport)
    @cursorpos = 0
    @refreshOverlay = true
    @sprites["cursor"].setCursorPos(@cursorpos)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbUpdateOverlay
    @refreshOverlay = true
  end

  def pbDoUpdateOverlay2
    overlay = @sprites["overlay"].bitmap
    overlay.clear
  end

  def pbDoUpdateOverlay
    return if !@refreshOverlay
    @refreshOverlay = false
    bgoverlay = @sprites["bgoverlay"].bitmap
    bgoverlay.clear
    pbSetSystemFont(bgoverlay)
    textPositions = [
      [@helptext, 128, 18, :left, Color.new(16, 24, 32), Color.new(168, 184, 184)]
    ]
    chars = @helper.textChars
    x = 140
    chars.each do |ch|
      textPositions.push([ch, x, 54, :center, Color.new(16, 24, 32), Color.new(168, 184, 184)])
      x += 24
    end
    pbDrawTextPositions(bgoverlay, textPositions)
  end

  def pbUpdate
    @@Characters.length.times do |i|
      @bitmaps[i].update
    end
    # Update which inputted text's character's underline is lowered to indicate
    # which character is selected
    cursorpos = @helper.cursor.clamp(0, @maxlength - 1)
    @maxlength.times do |i|
      @blanks[i] = (i == cursorpos) ? 1 : 0
      @sprites["blank#{i}"].y = [78, 82][@blanks[i]]
    end
    pbDoUpdateOverlay
    pbUpdateSpriteHash(@sprites)
  end

  def pbColumnEmpty?(m)
    return false if m >= ROWS - 1
    chset = @@Characters[@mode][0]
    COLUMNS.times do |i|
      return false if chset[(i * ROWS) + m] != " "
    end
    return true
  end

  def wrapmod(x, y)
    result = x % y
    result += y if result < 0
    return result
  end

  def pbMoveCursor
    oldcursor = @cursorpos
    cursordiv = @cursorpos / ROWS   # The row the cursor is in
    cursormod = @cursorpos % ROWS   # The column the cursor is in
    cursororigin = @cursorpos - cursormod
    if Input.repeat?(Input::LEFT)
      if @cursorpos < 0   # Controls
        case @cursorpos
        when BACK  then @cursorpos = ROWS * 2 - 1
        when OK    then @cursorpos = ROWS * 3 - 1
        end
      elsif @cursorpos % ROWS == 0
        case @cursorpos
        when 0, ROWS         then @cursorpos = BACK
        when ROWS*2, ROWS*3  then @cursorpos = OK
        end
      else
        loop do
          cursormod = wrapmod(cursormod - 1, ROWS)
          @cursorpos = cursororigin + cursormod
          break unless pbColumnEmpty?(cursormod)
        end
      end
    elsif Input.repeat?(Input::RIGHT)
      if @cursorpos < 0   # Controls
        case @cursorpos
        when BACK  then @cursorpos = ROWS
        when OK    then @cursorpos = ROWS * 2
        end
      elsif @cursorpos % ROWS == ROWS - 1
        case @cursorpos
        when ROWS-1, ROWS*2-1    then @cursorpos = BACK
        when ROWS*3-1, ROWS*4-1  then @cursorpos = OK
        end
      else
        loop do
          cursormod = wrapmod(cursormod + 1, ROWS)
          @cursorpos = cursororigin + cursormod
          break unless pbColumnEmpty?(cursormod)
        end
      end
    elsif Input.repeat?(Input::UP)
      if @cursorpos < 0         # Controls
        case @cursorpos
        when BACK  then @cursorpos = OK
        when OK    then @cursorpos = BACK
        end
      else
        cursordiv = wrapmod(cursordiv - 1, COLUMNS)
        @cursorpos = (cursordiv * ROWS) + cursormod
      end
    elsif Input.repeat?(Input::DOWN)
      if @cursorpos < 0                      # Controls
        case @cursorpos
        when BACK  then @cursorpos = OK
        when OK    then @cursorpos = BACK
        end
      else
        cursordiv = wrapmod(cursordiv + 1, COLUMNS)
        @cursorpos = (cursordiv * ROWS) + cursormod
      end
    end
    if @cursorpos != oldcursor   # Cursor position changed
      @sprites["cursor"].setCursorPos(@cursorpos)
      pbPlayCursorSE
      return true
    end
    return false
  end

  def pbEntry
    ret = ""
    loop do
      Graphics.update
      Input.update
      pbUpdate
      next if pbMoveCursor
      if Input.trigger?(Input::ACTION)
        @cursorpos = OK
        @sprites["cursor"].setCursorPos(@cursorpos)
      elsif Input.trigger?(Input::BACK)
        @helper.delete
        pbPlayCancelSE
        pbUpdateOverlay
      elsif Input.trigger?(Input::USE)
        case @cursorpos
        when BACK   # Backspace
          @helper.delete
          pbPlayCancelSE
          pbUpdateOverlay
        when OK     # Done
          pbSEPlay("GUI naming confirm")
          if @helper.length >= @minlength
            ret = @helper.text
            break
          end
        else
          cursormod = @cursorpos % ROWS
          cursordiv = @cursorpos / ROWS
          charpos = (cursordiv * ROWS) + cursormod
          chset = @@Characters[@mode][0]
          @helper.delete if @helper.length >= @maxlength
          @helper.insert(chset[charpos])
          pbPlayCursorSE
          if @helper.length >= @maxlength
            @cursorpos = OK
            @sprites["cursor"].setCursorPos(@cursorpos)
          end
          pbUpdateOverlay
        end
      elsif Input.trigger?(Input::F9)
        ret = -1
        break
      end
    end
    Input.update
    return ret
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    @bitmaps.each do |bitmap|
      bitmap&.dispose
    end
    @bitmaps.clear
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonSimpleEntry
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(x, y, helptext, minlength, maxlength, initialText, mode = -1, pokemon = nil)
    @scene.pbStartScene(x, y, helptext, minlength, maxlength, initialText, mode, pokemon)
    ret = @scene.pbEntry
    @scene.pbEndScene
    return ret
  end
end

#===============================================================================
#
#===============================================================================
def pbEnterTextSimple(helptext, minlength, maxlength, x = 128, y = 80, initialText = "", mode = 0, pokemon = nil)
  ret = ""
  loop do
    if ($PokemonSystem.textinput == 1 rescue false)   # Keyboard
      sscene = PokemonSimpleEntryScene.new
      sscreen = PokemonSimpleEntry.new(sscene)
      ret = sscreen.pbStartScreen(x, y, helptext, minlength, maxlength, initialText, mode, pokemon)
    else   # Cursor
      sscene = PokemonSimpleEntryScene2.new
      sscreen = PokemonSimpleEntry.new(sscene)
      ret = sscreen.pbStartScreen(x, y, helptext, minlength, maxlength, initialText, mode, pokemon)
    end
    break if ret.is_a?(String)
    if ret == -1
      $PokemonSystem.textinput = ($PokemonSystem.textinput + 1) % 2
      ret = ""
    end
  end
  return ret
end
