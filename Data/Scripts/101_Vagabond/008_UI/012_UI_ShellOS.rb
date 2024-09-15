class ShellOSScreen

  def initialize(options)
      @options = options
      @hints = {
          "Organize Boxes" => "Move Pokémon around in boxes or your party.",
          "Withdraw Pokémon" => "Insert Pokémon into your party.",
          "Deposit Pokémon" => "Remove Pokémon from your party.",
          "Customize Silvally" => "Change the traits of your Silvally.",
          "Log Off" => "End your user session."
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
      @sprites["logo"].setBitmap("Graphics/UI/Storage/shellos_logo")
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

def pbBootShellOS(mode=0)

  options = []

  if mode == 0 # Storage
      options = [
          "Organize Boxes",
          "Withdraw Pokémon",
          "Deposit Pokémon"
      ]
      if pbJob("Engineer").level > 0 || $DEBUG
        options.push("Customize Silvally")
      end
  end

  options.push("Log Off")

  shellos_screen = ShellOSScreen.new(options)
  if $game_switches && !$game_switches[INITIALIZED_SHELLOS]
      shellos_screen.pbBootShellOS(true)
      $game_switches[INITIALIZED_SHELLOS] = true
  else
      shellos_screen.pbBootShellOS
  end

  loop do
      option = shellos_screen.pbChooseOption
      break if !option || (option == "Log Off")
      case option
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
      end
  end

  shellos_screen.pbLogOffShellOS

end