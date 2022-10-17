module Dialog
  None    = 0
  Talk    = 1
  Shout   = 2
  Whisper = 3
  Silent  = 4
  Prompt  = 5
  Choice  = 6
  Command = 7
  Unown   = 8
  If      = 9
  Else    = 10
  Elsif   = 11
  Loop    = 12
  End     = 13
  Break   = 14
  Return  = 15
  Exit    = 16
end

def pbLoadDialog
  $GameDialog = load_data("Data/dialog.dat")
end

def compile_dialog_error(file, line_no, message)
  raise _INTL("Dialog file error ({1}.dlg, line: {2}):\r\n {3}\r\n", file, line_no, message)
end

def compile_dialog

  sections = {}

  echo "Compiling dialog files...\n" if DIALOG_FILES.length > 0

  for file in DIALOG_FILES
    section = []
    path = "PBS/Dialog/" + file + ".dlg"

    compile_pbs_file_message_start(path)

    chain = nil
    labels = {}
    events = {}
    events["Player"] = -1
    buffer = [] # Buffer for storing unfinished actions (like choices)
    choices = []

    idx = 0
    pbCompilerEachCommentedLine(path) { |line, line_no|
      echo "." if idx % 200 == 0
      idx += 1
      Graphics.update if idx % 1000 == 0
      if line.include?('#')
        line = line[0...line.index('#')]
      end
      line = line.strip()

      if !chain && line[0] != '['
        compile_dialog_error(file, line_no, "File must start with a [CHAIN_DEFINITION].")
      end

      feed = section
      feed_type = 0

      # Pipe new actions into subactions, like choices
      if buffer.length > 0
        element = buffer[buffer.length - 1]
        feed_type = element[0]
        feed = element[1]
      end

      if feed_type == Dialog::Prompt && (line[0...7] != "/choice" || line[0...13] == "/cancelchoice")
        compile_dialog_error(file, line_no, "?> must be immediately followed by a /choice")
      end

      case line[0]
      when '['
        # New dialog chain
        if buffer.length > 0
          compile_dialog_error(file, line_no, "Dialog chain ended with an unclosed branch.")
        end
        if section.length > 0
          sections[chain] = section
        end
        chain = line[1...line.index(']')].upcase
        if chain.include?(',')
          chain = chain.gsub(",", "_")
        else
          chain = chain + "_0"
        end
        if sections[chain]
          compile_dialog_error(file, line_no, _INTL("A dialog chain by the name [{1}] was defined multiple times.", chain))
        end
        labels = {}
        section = []
      when '>'
        # Regular speech
        talk = line[1...line.length].strip()
        feed.push([Dialog::Talk, talk])
      when '!'
        # Shouting
        if line[1] != '>'
          compile_dialog_error(file, line_no, "Missing > after ! for shouting.")
        end
        shout = line[2...line.length].strip()
        feed.push([Dialog::Shout, shout])
      when '.'
        # Whispering
        if line[1] == '.'
          if line[2] != '>'
            compile_dialog_error(file, line_no, "Missing > after .. for silent whispering.")
          end
          whisper = line[3...line.length].strip()
          feed.push([Dialog::Silent, whisper])
        else
          if line[1] != '>'
            compile_dialog_error(file, line_no, "Missing > after . for whispering.")
          end
          whisper = line[2...line.length].strip()
          feed.push([Dialog::Whisper, whisper])
        end
      when 'U'
        # Unown text
        if line[1] != '>'
          compile_dialog_error(file, line_no, "Missing > after U for unown text.")
        end
        unown = line[2...line.length].strip()
        feed.push([Dialog::Unown, unown])
      when '?'
        # Choice prompt
        if line[1..2] == "/>"
          # Close choice prompt
          if feed_type == Dialog::Prompt
            compile_dialog_error(file, line_no, "Need at least one /choice between ?> and ?/>")
          elsif feed_type != Dialog::Choice
            compile_dialog_error(file, line_no, "?/> can only be used following a ?> with /choice between")
          end
          buffer.pop
          buffer.pop
        else
          variable = 1
          if line[1] != '>'
            # Specify variable num
            variable = line[1...line.index('>')].to_i
            if variable <= 0
              compile_dialog_error(file, line_no, "Variable number in ?> must be at least 1")
            end
          end
          question = line[(line.index('>')+1)...line.length].strip()
          question = nil if question.length < 2
          prompt = [Dialog::Prompt, question, variable, []]
          feed.push(prompt)
          buffer.push([Dialog::Prompt, prompt[3]])
        end
      when '/'
        # Special command
        command = line[1...line.length]
        if line.include?(' ')
          command = command[0...line.index(' ')].strip()
        end

        all_args = ""
        arguments = []
        if line.include?(' ')
          all_args = line[line.index(' ')...line.length].strip()
          arguments = all_args.split(' ')
        end

        case command
        when "choice", "cancelchoice"
          # Adding choices to a ?> action
          if feed_type != Dialog::Prompt && feed_type != Dialog::Choice
            compile_dialog_error(file, line_no, "Cannot use /choice outside of ?>")
          end
          if feed_type == Dialog::Choice
            a = buffer.pop
            feed = buffer[buffer.length - 1][1]
            feed_type == Dialog::Prompt
          end
          answer = line[line.index(' ')...line.length].strip()
          choice = [Dialog::Choice, answer, []]
          choice.push(true) if command == "cancelchoice"
          feed.push(choice)
          buffer.push([Dialog::Choice, choice[2]])
        when "focus"
          arg = arguments[0]
          if !("012345678".include?(arg))
            compile_dialog_error(file, line_no, "/focus only accepts the numbers 0-8.")
          end
          feed.push([Dialog::Command, "focus", arg.to_i])
        when "hold"
          feed.push([Dialog::Command, "hold"])
        when "start"
          feed.push([Dialog::Command, "start"])
        when "reset"
          feed.push([Dialog::Command, "reset"])
        when "speaker"
          name = arguments[0].gsub("_", " ")
          name = nil if ["0", "none", "nil"].include?(name.downcase)
          speaker = [Dialog::Command, "speaker", name]
          speaker.push(arguments[1]) if arguments[1]
          feed.push(speaker)
        when "expression", "expressionright", "expression_right"
          arg = arguments[0]
          feed.push([Dialog::Command, "expression", arg])
        when "expressionleft", "expression_left"
          arg = arguments[0]
          feed.push([Dialog::Command, "expression_left", arg])
        when "portrait", "portraitright", "portrait_right"
          arg = arguments[0]
          arg = nil if arg == "0"
          feed.push([Dialog::Command, "portrait", arg])
        when "portraitleft", "portrait_left"
          arg = arguments[0]
          arg = nil if arg == "0"
          feed.push([Dialog::Command, "portrait_left", arg])
        when "name"
          arg = arguments[0].gsub("_", " ")
          arg = nil if arg == "0"
          feed.push([Dialog::Command, "name", arg])
        when "namepos"
          arg = arguments[0].downcase
          if !["left", "center", "middle", "right"].include?(arg)
            compile_dialog_error(file, line_no, "/namepos only accepts left, right or middle/center as arguments")
          end
          arg = "center" if arg == "middle"
          feed.push([Dialog::Command, "namepos", arg])
        when "hidename"
          arg = arguments[0]
          if !["0", "1", "2"].include?(arg)
            compile_dialog_error(file, line_no, "/hidename only accepts 0, 1 or 2 as arguments")
          end
          feed.push([Dialog::Command, "hidename", arg.to_i])
        when "hidenamebox"
          arg = arguments[0]
          if !["0", "1"].include?(arg)
            compile_dialog_error(file, line_no, "/hidenamebox only accepts 0, 1 as arguments")
          end
          feed.push([Dialog::Command, "hidenamebox", arg.to_i])
        when "window"
          arg = arguments[0]
          arg = nil if arg == "0"
          feed.push([Dialog::Command, "window", arg])
        when "windowpos"
          arg = arguments[0].downcase
          if !["bottom", "center", "middle", "top"].include?(arg)
            compile_dialog_error(file, line_no, "/windowpos only accepts bottom, top, middle/center as arguments")
          end
          arg = "center" if arg == "middle"
          feed.push([Dialog::Command, "windowpos", arg])
        when "newwindow"
          if arguments.length == 1
            case arguments[0]
            when "bottom"
              feed.push([Dialog::Command, "newwindow", 2])
            when "center", "middle"
              feed.push([Dialog::Command, "newwindow", 1])
            when "top"
              feed.push([Dialog::Command, "newwindow", 0])
            when "bottomleft"
              feed.push([Dialog::Command, "newwindow", 3])
            when "bottomright"
              feed.push([Dialog::Command, "newwindow", 4])
            else
              compile_dialog_error(file, line_no, "/newwindow only accepts <bottom/top/center/bottomleft/bottomright> or <x, y, width, lines>.")
            end
          elsif arguments.length == 4
            feed.push([Dialog::Command, "newwindow", arguments[0].to_i, arguments[1].to_i, arguments[2].to_i, arguments[3].to_i])
          else
            compile_dialog_error(file, line_no, "/newwindow only accepts <bottom/top/center/bottomleft/bottomright> or <x, y, width, lines>.")
          end
        when "hidewindow"
          arg = arguments[0]
          if !["0", "1"].include?(arg)
            compile_dialog_error(file, line_no, "/hidename only accepts 0 or 1 as arguments")
          end
          feed.push([Dialog::Command, "hidewindow", arg.to_i])
        when "textpos"
          arg = arguments[0].downcase
          if !["left", "center", "middle", "right"].include?(arg)
            compile_dialog_error(file, line_no, "/textpos only accepts left, right or middle/center as arguments")
          end
          arg = "center" if arg == "middle"
          feed.push([Dialog::Command, "textpos", arg])
        when "lines"
          arg = arguments[0].to_i
          feed.push([Dialog::Command, "lines", arg])
        when "addpauses"
          arg = arguments[0].to_i
          if !["true", "false"].include?(arg)
            compile_dialog_error(file, line_no, "/hidename only accepts true or false as arguments")
          end
          feed.push([Dialog::Command, "addpauses", (arg == "true") ? true : false])
        when "wait"
          arg = arguments[0]
          if arg[arg.length - 1] == "s"
            arg = (arg[0...(arg.length-1)].to_f * Graphics.frame_rate).round.to_i
          else
            arg = arg.to_i
          end
          feed.push([Dialog::Command, "wait", arg])
        when "rest"
          arg = arguments[0]
          if arg[arg.length - 1] == "s"
            arg = (arg[0...(arg.length-1)].to_f * Graphics.frame_rate).round.to_i
          else
            arg = arg.to_i
          end
          feed.push([Dialog::Command, "rest", arg])
        when "fade"
          tone_color = arguments[0]
          if !["white", "black", "normal", "sepia", "gray", "grey"].include?(tone_color)
            compile_dialog_error(file, line_no, "Invalid color for /fade [white, black, normal, sepia, gray].")
          end
          tone_color = "gray" if tone_color == "grey"
          frames = arguments[1] || "20"
          feed.push([Dialog::Command, "fade", frames.to_i, tone_color])
        when "exit"
          feed.push([Dialog::Exit])
        when "return"
          arg = arguments[0]
          feed.push([Dialog::Return, arg])
        when "eval"
          feed.push([Dialog::Command, "eval", all_args])
        when "if"
          condition = all_args
          if_cond = [Dialog::If, condition, []]
          feed.push(if_cond)
          buffer.push([Dialog::If, if_cond[2]])
        when "else"
          if feed_type != Dialog::If && feed_type != Dialog::Elsif
            compile_dialog_error(file, line_no, "Can only use /else after /if or /elsif")
          end
          else_cond = [Dialog::Else, []]
          feed.push(else_cond)
          buffer.push([Dialog::Else, else_cond[1]])
        when "elsif"
          if feed_type != Dialog::If && feed_type != Dialog::Elsif
            compile_dialog_error(file, line_no, "Can only use /elsif after /if or /elsif")
          end
          condition = all_args
          elsif_cond = [Dialog::Elsif, condition, []]
          feed.push(elsif_cond)
          buffer.push([Dialog::Elsif, elsif_cond[2]])
        when "loop"
          loop_cond = [Dialog::Loop, []]
          feed.push(loop_cond)
          buffer.push([Dialog::Loop, loop_cond[1]])
        when "end"
          if ![Dialog::If, Dialog::Elsif, Dialog::Else, Dialog::Loop].include?(feed_type)
            compile_dialog_error(file, line_no, "Can only use /end after a /loop or /if")
          end
          while ![Dialog::If, Dialog::Loop].include?(feed_type)
            buffer.pop
            feed_type = buffer[buffer.length - 1][0]
          end
          buffer.pop
        when "break"
          feed.push([Dialog::Break])
        when "se", "me", "bgm"
          fname = [arguments[0]]
          for i in 1...arguments.length
            if arguments[i].to_i != 0
              break
            end
            fname.push(arguments[i])
          end
          last = fname.length
          fname = fname.join(' ')
          vol = arguments[last] || nil
          pitch = arguments[last+1] || nil
          vol = vol.to_i if vol
          pitch = pitch.to_i if pitch
          feed.push([Dialog::Command, command, fname, vol, pitch])
        when "cry"
          arg1 = arguments[0]
          arg2 = arguments[1]
          arg3 = arguments[2]
          arg2 = arg2.to_i if arg2
          arg3 = arg3.to_i if arg3
          feed.push([Dialog::Command, "cry", arg1, arg2, arg3])
        when "pokemon"
          arg = arguments[0]
          text = ""
          if arguments.length > 1
            text = arguments[1..arguments.length].join(' ')
          end
          feed.push([Dialog::Command, "pokemon", arg, text])
        when "event"
          arg = arguments[0]
          if arg == "set"
            events[arguments[1]] = arguments[2].to_i
          else
            if !events[arg]
              compile_dialog_error(file, line_no, _INTL("Event name '{1}' has not been set", arg))
            end
            event_id = events[arg]
            if ["turn", "move"].include?(arguments[1])
              if !["down", "left", "right", "up"].include?(arguments[2])
                compile_dialog_error(file, line_no, _INTL("/event move and turn command can only be used with left, right, up, down."))
              end
              feed.push([Dialog::Command, "event", arguments[1], arguments[2], event_id])
            elsif arguments[1] == "sprite"
              sprite_name = arguments[2]
              if arguments.length == 3
                feed.push([Dialog::Command, "event", arguments[1], arguments[2], event_id])
              elsif arguments.length == 4
                feed.push([Dialog::Command, "event", arguments[1], arguments[2], arguments[3], event_id])
              elsif arguments.length == 5
                feed.push([Dialog::Command, "event", arguments[1], arguments[2], arguments[3], arguments[4].to_i, event_id])
              end
            elsif arguments[1] == "switch"
              if !["A", "B", "C", "D"].include?(arguments[2])
                compile_dialog_error(file, line_no, _INTL("Invalid self switch ID: {1}", arguments[2]))
              end
              if !["true", "false"].include?(arguments[3])
                compile_dialog_error(file, line_no, _INTL("Invalid self switch state: {1}", arguments[3]))
              end
              feed.push([Dialog::Command, "event", arguments[1], arguments[2], (arguments[3]=="true"), event_id])
            elsif arguments[1] == "exclaim"
              feed.push([Dialog::Command, "event", arguments[1], event_id])
            elsif arguments[1] == "emote"
              emote_id = PBEmote.fromName(arguments[2])
              if emote_id == -1
                compile_dialog_error(file, line_no, _INTL("Invalid emote name: {1}", arguments[2]))
              end
              feed.push([Dialog::Command, "event", arguments[1], event_id, emote_id])
            else
              compile_dialog_error(file, line_no, _INTL("Unknown /event command: {1}", arguments[1]))
            end
          end
        when "dialog"
          arg = arguments[0]
          if arguments[1]
            feed.push([Dialog::Command, "dialog", arg.upcase, arguments[1].to_i])
          else
            feed.push([Dialog::Command, "dialog", arg.upcase])
          end
        else
          compile_dialog_error(file, line_no, _INTL("Unknown command /{1}", command))
        end

      end

    }

    if buffer.length > 0
      compile_dialog_error(file, 0, "Dialog chain ended with an unclosed branch.")
    end
    if section.length > 0 && chain
      sections[chain] = section
    end
    
    process_pbs_file_message_end

  end

  save_data(sections, "Data/dialog.dat")

end 