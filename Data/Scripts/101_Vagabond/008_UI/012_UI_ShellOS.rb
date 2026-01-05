class ShellOSScreen

  def initialize(options, version)
    @options = options
    @version = version
    @hints = {
      # Storage
      "Organize Boxes" => "Move Pokémon around in boxes or your party.",
      "Withdraw Pokémon" => "Insert Pokémon into your party.",
      "Deposit Pokémon" => "Remove Pokémon from your party.",
      "Customize Silvally" => "Change the traits of your Silvally.",
      "Log Off" => "End your user session.",
      # Factory 0
      "View File #136" => "View file_136.md in the default text viewer.",
      "View File #233" => "View file_233.md in the default text viewer.",
      "Release Outer Gate" => "Open the outer gate inside the factory.",
      "Release Inner Gate" => "Open the inner gate inside the factory.",
      # Factory 1
      "View Journal #1" => "View the first part of journal.txt.",
      "View Journal #2" => "View the second part of journal.txt."
    }
    @index = 0
  end

  def pbBootShellOS(setup=false)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    @sprites = {}

    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap("Graphics/UI/Storage/shellos")
    @sprites["border"] = IconSprite.new(0, 0, @viewport)
    @sprites["border"].setBitmap("Graphics/UI/Storage/border")
    @sprites["border"].z = 998

    @sprites["terminal"] = Window_UnformattedTextPokemon.newWithSize("",
      128, 40, 500, 400, @viewport)
    @sprites["terminal"].baseColor   = Color.new(252,252,252)
    @sprites["terminal"].shadowColor = Color.new(60,60,80)
    @sprites["terminal"].visible     = true
    @sprites["terminal"].windowskin  = nil
    @sprites["terminal"].text = ""

    @sprites["helptext"] = Window_UnformattedTextPokemon.newWithSize("",
      128, 442, 500, 128, @viewport)
    @sprites["helptext"].z = 999
    @sprites["helptext"].baseColor   = Color.new(252,252,252)
    @sprites["helptext"].shadowColor = Color.new(60,60,80)
    @sprites["helptext"].visible     = true
    @sprites["helptext"].windowskin  = nil
    if setup
      @sprites["helptext"].text = "Please wait while ShellOS is configuring..."
    end

    @sprites["logo"] = IconSprite.new(Graphics.width / 2, Graphics.height / 6, @viewport)
    @sprites["logo"].setBitmap(sprintf("Graphics/UI/Storage/shellos_logo_%02d", @version))
    @sprites["logo"].ox = @sprites["logo"].bitmap.width / 2

    @sprites["overlay"] = Sprite.new(@viewport)
    @sprites["overlay"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(@sprites["overlay"].bitmap)

    pbSEPlay("PC_open")
    if setup
      pbSetupSequence()
    else
      pbRefresh()
      pbFadeInAndShow(@sprites)
    end

  end

  def pbSetupSequence
    terminal = @sprites["terminal"]
    @sprites["logo"].visible = false
    all_text = "Please scan your Trainer Card to log in."
    terminal.text = all_text
    pbFadeInAndShow(@sprites)
    pbWait(1.0)
    pbMessage(_INTL("{1} grabs their Trainer Card and scans it.", $player.name))
    temp_text = all_text + "\nScanning Trainer Card..."
    pbLoading(terminal, temp_text, 4)
    all_text += "\nUser identified as '" + $player.name + "'."
    terminal.text = all_text
    pbWait(1.0)
    temp_text = all_text + "\nSearching in user database..."
    pbLoading(terminal, temp_text, 6)
    all_text += "\nCould not find '" + $player.name + "'."
    terminal.text = all_text
    pbWait(1.0)
    all_text += "\nCreate new user '" + $player.name + "'? (y/n): "
    terminal.text = all_text
    pbWait(1.0)
    all_text += "y"
    terminal.text = all_text
    pbWait(1.0)
    temp_text = all_text + "\nCreating new user..."
    pbLoading(terminal, temp_text, 4)
    all_text += "\nUser '" + $player.name + "' successfully created."
    terminal.text = all_text
    pbWait(1.0)
    all_text += "\nInitializing storage environment...\n"
    progress = -1
    loop do
      if rand(4) == 1 || progress == -1
        progress += 1 
        temp_text = all_text + sprintf("%03d%%   [", progress)
        for i in 0...50
          if progress / 2 > i
            temp_text += "|"
          else
            temp_text += " "
          end
        end
        temp_text += "]"
        terminal.text = temp_text
        if progress >= 100
          all_text = temp_text
          break
        end
      end
      self.pbUpdate
    end
    pbWait(0.5)
    all_text += "\nDone."
    terminal.text = all_text
    pbWait(1.0)
    all_text += "\nYou will be signed in automatically next time."
    terminal.text = all_text
    pbWait(1.0)
    all_text += "\nPress any key to continue..."
    terminal.text = all_text
    pbWait(1.0)
    loop do
      pbUpdate
      if Input.trigger?(Input::USE) ||
        Input.trigger?(Input::BACK) ||
        Input.trigger?(Input::ACTION)
        break
      end
    end
    terminal.text = ""
    @sprites["logo"].visible = true
    pbRefresh()
  end

  def pbLogOffShellOS
    pbSEPlay("PC close")
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbLoading(terminal, text, cycles)
    icons = ["|", "/", "-", "\\"]
    cycles.times do
      for i in icons
        terminal.text = text + "  " + i
        pbWait(0.2)
      end
    end
  end

  def pbWait(duration)
    timer_start = System.uptime
    until System.uptime - timer_start >= duration
      Graphics.update
      Input.update
      self.pbUpdate()
    end
  end

  def pbUpdate
    Graphics.update
    Input.update
    @viewport.update
    pbUpdateSpriteHash(@sprites)
  end

  def pbRefresh
    @sprites["overlay"].bitmap.clear
    pos_x = 286
    pos_y = 180
    textpos = []
    for i in 0...@options.length
      text = @options[i]
      text = "> " + text if @index == i
      text = "   " + text if @index != i
      textpos.push([
        text,pos_x,pos_y + i * 40,0,Color.new(252,252,252),Color.new(60, 60, 80)
      ])
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    if @hints[@options[@index]]
      @sprites["helptext"].text = @hints[@options[@index]]
    else
      @sprites["helptext"].text = ""
    end
  end

  def pbDisplay(msg, error = false)
    if error
      pbPlayBuzzerSE
    else
      pbPlayDecisionSE
    end
    @sprites["helptext"].text = msg
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        pbPlayDecisionSE
        break
      end
    end
    pbRefresh
  end

  def pbDisplayPaused(msg, error = false)
    if error
      pbPlayBuzzerSE
    else
      pbPlayDecisionSE
    end
    @sprites["helptext"].text = msg
    start_time = System.uptime
    time_now = System.uptime
    last_modulo = -1
    while time_now - start_time < 4.5
      modulo = (((time_now - start_time) * 2).floor) % 3
      if modulo != last_modulo
        @sprites["helptext"].text = msg + ".."[0...modulo]
        last_modulo = modulo
      end
      time_now = System.uptime
      Graphics.update
      Input.update
    end
    pbRefresh
  end

  def pbShowDocument(text)
    pbSEPlay("PC access")
    @sprites["terminal"].text = text
    @sprites["terminal"].visible = true
    @sprites["logo"].visible = false
    @sprites["overlay"].visible = false
    @sprites["helptext"].text = _INTL("Press enter to stop viewing.")
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        pbSEPlay("PC close")
        break
      end
    end
    @sprites["terminal"].text = ""
    @sprites["terminal"].visible = false
    @sprites["logo"].visible = true
    @sprites["overlay"].visible = true
    pbRefresh
  end

  def pbChooseOption
    new_index = @index
    loop do
      self.pbUpdate
      if Input.repeat?(Input::UP)
        new_index = (@index - 1) % @options.length
      end
      if Input.repeat?(Input::DOWN)
        new_index = (@index + 1) % @options.length
      end
      if new_index != @index
        @index = new_index
        pbPlayCursorSE()
        pbRefresh()
      end
      if Input.trigger?(Input::USE)
        return @options[@index]
      elsif Input.trigger?(Input::BACK)
        return nil
      end
    end
  end

end

def pbBootShellOS(mode = 0, submode = 0)

  options = []
  version = 20

  if mode == 0 # Storage
    options = [
      "Organize Boxes",
      "Withdraw Pokémon",
      "Deposit Pokémon"
    ]
    if pbJob("Engineer").level > 0 || $DEBUG
      options.push("Customize Silvally")
    end
  elsif mode == 1 # Factory
    case submode
    when 0
      version = 12
      options = [
        "View File #136",
        "View File #233",
        "Release Outer Gate",
        "Release Inner Gate"
      ]
    when 1
      version = 12
      options = [
        "View Journal #1",
        "View Journal #2"
      ]
    end
  end

  options.push("Log Off")

  shellos_screen = ShellOSScreen.new(options, version)
  if $game_switches && !$game_switches[INITIALIZED_SHELLOS] && mode == 0
    shellos_screen.pbBootShellOS(true)
    $game_switches[INITIALIZED_SHELLOS] = true
  else
    shellos_screen.pbBootShellOS
  end

  access_level = 0

  loop do
    option = shellos_screen.pbChooseOption
    break if !option || (option == "Log Off")
    case option
    # Storage
    when "Organize Boxes"
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene,$PokemonStorage)
      screen.pbStartScreen(0)
      pbSEPlay("PC close")
    when "Withdraw Pokémon"
      if $PokemonStorage.party_full?
        pbMessage(_INTL("Your party is full!"))
        next
      end
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene,$PokemonStorage)
      screen.pbStartScreen(1)
      pbSEPlay("PC close")
    when "Deposit Pokémon"
      count=0
      for p in $PokemonStorage.party
        count += 1 if p && !p.egg? && p.hp>0
      end
      if count<=1
        pbMessage(_INTL("Can't deposit the last Pokémon!"))
        next
      end
      scene = PokemonStorageScene.new
      screen = PokemonStorageScreen.new(scene,$PokemonStorage)
      screen.pbStartScreen(2)
      pbSEPlay("PC close")
    when "Customize Silvally"
      pbCustomPokemonScreen
    # Factory 0
    when "View File #136"
      shellos_screen.pbShowDocument(_INTL("  Viewing File #136\n\nWe finally found a test subject that was receptive to our enhancements. The ones before it must have been too physically weak.\n\nAfter the enhancements, the subject has developed an occasional twitch that agitates it for a while, but otherwise appears well."))
    when "View File #233"
      if access_level < 1
        shellos_screen.pbDisplay(_INTL("Viewing this file requires higher privileges.\nEnter the system password to continue."), true)
        pwd = pbEnterTextSimple("Enter system password", 0, 10, 128, 256).downcase
        if pwd == "klefki376"
          shellos_screen.pbDisplay(_INTL("Access granted."))
          access_level = 1
        else
          shellos_screen.pbDisplay(_INTL("Incorrect password. Access denied."), true)
        end
      end
      if access_level >= 1
        shellos_screen.pbShowDocument(_INTL("  Viewing File #233\n\nThe work has been delayed significantly as several of my colleagues decided to resign due to concerns about \"unethical treatment of Pokémon\".\n\nWith all we have already done, it would be for nothing if we do not continue. I choose to believe in the vision our leader put forth and continue the experiments."))
      end
    when "Release Outer Gate"
      if $game_self_switches[[272,2,"A"]]
        shellos_screen.pbDisplay(_INTL("The outer gate is already open."))
      else
        shellos_screen.pbDisplay(_INTL("No special privileges requires."))
        shellos_screen.pbDisplayPaused(_INTL("Releasing the outer gate."))
        shellos_screen.pbDisplay(_INTL("The outer gate has been opened."))
        $game_self_switches[[272,2,"A"]] = true
      end
    when "Release Inner Gate"
      if $game_self_switches[[272,4,"A"]]
        shellos_screen.pbDisplay(_INTL("The inner gate is already open."))
      else
        if access_level < 1
          shellos_screen.pbDisplay(_INTL("Releasing the inner gate requires higher privileges.\nEnter the system password to continue."), true)
          pwd = pbEnterTextSimple("Enter system password", 0, 10, 128, 256).downcase
          if pwd == "klefki376"
            shellos_screen.pbDisplay(_INTL("Access granted."))
            access_level = 1
          else
            shellos_screen.pbDisplay(_INTL("Incorrect password. Access denied."), true)
          end
        end
        if access_level >= 1
          shellos_screen.pbDisplayPaused(_INTL("Releasing the inner gate."))
          shellos_screen.pbDisplay(_INTL("The inner gate has been opened."))
          $game_self_switches[[272,4,"A"]] = true
        end
      end
    # Factory 1
    when "View Journal #1"
      shellos_screen.pbShowDocument(_INTL("  Viewing Journal #1\n\nI was refused access to the basement.\nNow I am even more certain there is something going on down there.\n\nI will figure out the password of one of by higher ranked colleagues so I can learn more."))
    when "View Journal #2"
      shellos_screen.pbShowDocument(_INTL("  Viewing Journal #2\n\nThe password was obvious. It was just his favorite Pokémon followed by its regional Pokédex number.\n\nThough knowing what I now know, I cannot feign ignorance and work here any longer."))
    end
  end

  shellos_screen.pbLogOffShellOS

end

def pbFactoryPC(id)
  pbBootShellOS(1, id)
end