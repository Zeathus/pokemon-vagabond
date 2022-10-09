DIALOG_FILES = [
  "prologue",
  "chapter1",
  "chapter2",
  "crosswoods",
  "breccia",
  "lazuli",
  "lapis",
  "quartz",
  "feldspar",
  "mica",
  "general",
  "pokemon",
  "ruins",
  "quests_minor",
  "gpo",
  "evergone",
  "job_engineer"
]

def pbDialog(name, index=0)

  name = _INTL("{1}_{2}", name.upcase, index)
  dialog = $GameDialog[name]

  if !dialog
    raise _INTL("Did not find a dialog with the name [{1}]", name)
  end

  msgwindows = TalkMessageWindows.new

  ret = pbRunDialogFeed(dialog, msgwindows)
  Graphics.update
  Input.update

  msgwindows.dispose

  $game_system.message_position = 2
  $game_system.message_frame = 0

  if ret[0] == Dialog::Return
    return ret[1]
  else
    return nil
  end

end

def pbRunDialogFeed(dialog, msgwindows = nil)
  ret = [0]

  for action in dialog

    type = action[0]

    case type
    when Dialog::Talk
      speech = _format(action[1])
      pbTalk(speech, msgwindows)
    when Dialog::Shout
      speech = _format(action[1])
      opts["shout"] = true
      pbTalk(speech, msgwindows)
      opts["shout"] = false
    when Dialog::Unown
      text = _format(action[1])
      pbShowUnownText(text)
    when Dialog::Prompt
      question = _format(action[1])
      variable = action[2]
      cancel = 0
      choices = []
      for i in 0...action[3].length
        choices.push(_format(action[3][i][1]))
        cancel = i+1 if action[3][i][3]
      end
      if question
        question += _INTL("\\ch[{1},", variable)
        question += cancel.to_s
        for choice in choices
          question += ","
          question += choice
        end
        question += "]"
        pbTalk(question, msgwindows)

        answer = $game_variables[variable]

        choice = action[3][answer]
        if choice
          ret = pbRunDialogFeed(choice[2], msgwindows)
        else
          raise "Failed to find the selected choice's contents"
        end
      else
        # Figure out how to show the commands with no textbox
      end
    when Dialog::Command
      command = action[1]
      args = []
      args = action[2...action.length] if action.length > 2

      case command
      when "hold"
        msgwindows.holding = true
      when "start"
        msgwindows.holding = false
      when "focus"
        msgwindows.focus(args[0])
      when "reset"
        msgwindows.each { |w| w.reset(true) }
      when "speaker"
        # Change all speaker properties
        speaker = args[0] ? _format(args[0]) : nil
        expression = args[1] || "neutral"
        msgwindows.focused.portrait.set(speaker, expression)
        msgwindows.focused.namebox.real_name = speaker
        skin = Dialog.getWindowSkin(speaker)
        msgwindows.focused.setSkin(skin)
      when "expression"
        msgwindows.focused.portrait.expression = args[0]
      when "expression_left"
        msgwindows.focused.portrait(1).expression = args[0]
      when "portrait"
        msgwindows.focused.portrait.character = args[0]
      when "portrait_left"
        msgwindows.focused.portrait(1).character = args[0]
      when "name"
        msgwindows.focused.namebox.name = _format(args[0])
      when "namepos"
        if args[0] == "left"
          msgwindows.focused.namebox.position = 0
        elsif args[0] == "center"
          msgwindows.focused.namebox.position = 2
        else
          msgwindows.focused.namebox.position = 1
        end
      when "hidename"
        msgwindows.focused.namebox.hide_name = args[0]
      when "hidenamebox"
        msgwindows.focused.namebox.real_name = nil
      when "window"
        msgwindows.focused.setSkin(args[0])
      when "windowpos"
        if args[0] == "top"
          msgwindows.focused.message_position = 0
        elsif args[0] == "center"
          msgwindows.focused.message_position = 1
        else
          msgwindows.focused.message_position = 2
        end
      when "newwindow"
        if args.length == 1
          msgwindows.add_window(args[0])
        elsif args.length == 4
          msgwindows.add_window_manual(args[0], args[1], args[2], args[3])
        end
      when "hidewindow"
        msgwindows.focused.message_frame = args[0]
      when "textpos"
        if args[0] == "left"
          msgwindows.focused.text_alignment = 0
        elsif args[0] == "right"
          msgwindows.focused.text_alignment = 2
        else
          msgwindows.focused.text_alignment = 1
        end
      when "lines"
        msgwindows.focused.line_count = args[0]
      when "addpauses"
        msgwindows.focused.add_pauses = args[0]
      when "wait"
        args[0].times do
          Graphics.update
          Input.update
          msgwindows.update
        end
      when "rest"
        old_vis = []
        for i in 0...msgwindows.length
          old_vis.push(msgwindows[i].visible)
          msgwindows[i].visible = false
        end
        pbWait(args[0])
        for i in 0...msgwindows.length
          msgwindows[i].visible = old_vis[i]
        end
      when "fade"
        tone = Tone.new(0, 0, 0, 0)
        case args[1]
        when "black"
          tone = Tone.new(-255, -255, -255, 0)
        when "white"
          tone = Tone.new(255, 255, 255, 0)
        when "sepia"
          tone = Tone.new(46, 0, -46, 175)
        when "gray"
          tone = Tone.new(0, 0, 0, 255)
        end
        $game_screen.start_tone_change(tone, args[0] * Graphics.frame_rate / 20)
        pbWait(args[0] * Graphics.frame_rate / 20)
      when "eval"
        eval(args[0])
      when "se"
        pbSEPlay(args[0], args[1], args[2])
      when "me"
        pbMEPlay(args[0], args[1], args[2])
      when "bgm"
        pbBGMPlay(args[0], args[1], args[2])
      when "cry"
        species = _format(args[0])
        if species[0] == ':'
          species = eval(species)
        else
          species = eval(_INTL(":{1}", species))
        end
        GameData::Species.play_cry(species, (args[1] || 100), args[2])
      when "pokemon"
        species = _format(args[0])
        if species[0] == ':'
          species = eval(species)
        else
          species = eval(_INTL(":{1}", species))
        end
        pbShowSpeciesPicture(species, args[1] || "")
      when "event"
        case args[0]
        when "turn"
          event = get_character(args[2])
          case args[1]
          when "left"
            event.turn_left
          when "right"
            event.turn_right
          when "down"
            event.turn_down
          when "up"
            event.turn_up
          end
        when "move"
          event = get_character(args[2])
          case args[1]
          when "left"
            event.move_left
          when "right"
            event.move_right
          when "down"
            event.move_down
          when "up"
            event.move_up
          end
        when "sprite"
          event = get_character(args[args.length - 1])
          event.character_name = _format(args[1])
          if args.length > 3
            case args[2]
            when "left"
              event.turn_left
            when "right"
              event.turn_right
            when "down"
              event.turn_down
            when "up"
              event.turn_up
            end
          end
          if args.length > 4
            event.pattern = args[3]
          end
        when "switch"
          pbSetSelfSwitch(args[3], args[1], args[2])
        when "exclaim"
          event = get_character(args[args.length - 1])
          pbExclaim(event)
        when "emote"
          event = get_character(args[args.length - 2])
          pbEmote(event, args[args.length - 1])
        end
      when "dialog"
        if args[1]
          pbDialog(args[0], args[1])
        else
          pbDialog(args[0])
        end
      end
    when Dialog::If
      if (eval(action[1]))
        pbRunDialogFeed(action[2], msgwindows)
      else
        feed = action[2]
        done = false
        while feed[feed.length-1][0] == Dialog::Elsif
          if (eval(feed[feed.length-1][1]))
            ret = pbRunDialogFeed(feed[feed.length-1][2], msgwindows)
            done = true
            break
          end
          feed = feed[feed.length-1][2]
        end
        if !done
          if feed[feed.length-1][0] == Dialog::Else
            ret = pbRunDialogFeed(feed[feed.length-1][1], msgwindows)
          end
        end
      end
    when Dialog::Loop
      feed = action[1]
      loop do
        ret = pbRunDialogFeed(feed, msgwindows)
        break if [Dialog::Break, Dialog::Exit, Dialog::Return].include?(ret[0])
      end
    when Dialog::Break
      return [Dialog::Break]
    when Dialog::Exit
      return [Dialog::Exit]
    when Dialog::Return
      return [Dialog::Return, eval(action[1])]
    end

    if ret == Dialog::Break && type != Dialog::Loop
      return ret
    end

    # Exit early
    if [Dialog::Exit, Dialog::Return].include?(ret[0])
      return ret
    end

  end

  return ret
end