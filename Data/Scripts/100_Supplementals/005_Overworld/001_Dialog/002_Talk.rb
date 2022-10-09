def pbTalk(text, msgwindows = nil)
  
  #window_type = opts["window_type"]
  #has_window = ($game_system.message_frame == 0)
  #speaker = opts["speaker"]
  #speaker = nil if speaker == "none"
  #name_tag = opts["name_tag"] || speaker
  #name_tag = $player.name if name_tag == "PLAYER"
  #namepos = opts["namepos"] || ["right", "center", "left"][$game_system.message_position]
  #portrait = opts["portrait"] || speaker
  #expression = opts["expression"] || "neutral"
  #portrait_left = opts["portrait_left"]
  #expression_left = opts["expression_left"] || "neutral"
  #hide_name = opts["hide_name"] || 0
  #hide_namebox = opts["hide_namebox"] || (!has_window && 1) || 0
  #shout = opts["shout"]
  #textpos = opts["textpos"]
  #lines = opts["lines"] || 2

  # Only show portrait if message boxes are at the bottom and frame visible
  #if $game_system.message_position != 2 || !has_window
  #  portrait = nil
  #end

  # Set speaker character specific properties if there is one
  #if speaker
  #  window_type = Dialog::getTextWindow(speaker) if !window_type
  #end

  create_window = msgwindows.nil?
  msgwindows = TalkMessageWindows.new if create_window

  # Defining the viewport
  #viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  #viewport.z = 999999
  #sprites = {}

  #color = nil
  #if speaker
  #  color = "<c2="
  #  color += colorToRgb16(Dialog::getCharColor(speaker, 0, has_window)).to_s
  #  color += colorToRgb16(Dialog::getCharColor(speaker, 1, has_window)).to_s
  #  color += ">"
  #end

  #if opts["choices"]
  #  choices = opts["choices"]
  #  format_text += "\\ch[1,"
  #  format_text += choices.length.to_s
  #  for choice in choices
  #    format_text += ","
  #    format_text += choice
  #  end
  #  format_text += "]"
  #end

  #format_text = _INTL("\\l[{1}]{2}", lines, format_text) if lines != 2 && !shout

  #msgwindow = pbCreateMessageWindow(nil, nil)
  #msgwindow2 = pbCreateMessageWindow(nil, nil)
  #temp, controls = pbPrepareMessageWindow(msgwindow, format_text, false)
  #format_text, controls2 = pbPrepareMessageWindow(msgwindow2, format_text, false)

  #window_height = 32 * (lines + 1)

  # Create portrait sprite
  #if portrait && expression && expression != "none"
  #  file = pbPortraitFile(portrait, expression, false)
  #  if file
  #    sprites["portrait"] = IconSprite.new(0, 0, viewport)
  #    sprites["portrait"].setBitmap(file)
  #    sprites["portrait"].x = 300
  #    sprites["portrait"].y = Graphics.height - window_height - sprites["portrait"].bitmap.height + 2
  #  end
  #end

  # Create left portrait sprite
  #if portrait_left && expression_left && expression_left != "none"
  #  file = pbPortraitFile(portrait_left, expression_left, true)
  #  mirror = false
  #  if !file
  #    file = pbPortraitFile(portrait_left, expression_left, false)
  #    mirror = true
  #  end
  #  if file
  #    sprites["portrait_left"] = IconSprite.new(0, 0, viewport)
  #    sprites["portrait_left"].setBitmap(file)
  #    sprites["portrait_left"].x = 12
  #    sprites["portrait_left"].y = Graphics.height - window_height - sprites["portrait_left"].bitmap.height + 2
  #    if mirror
  #      sprites["portrait_left"].zoom_x = -1
  #      sprites["portrait_left"].x += sprites["portrait_left"].bitmap.width
  #    end
  #  end
  #end

  # Create name tag sprite
  #if name_tag && hide_name != 2
  #  # Background
  #  sprites["namebox"] = IconSprite.new(0, 0, viewport)
  #  name_box_image = Dialog::getNameBox(speaker)
  #  sprites["namebox"].setBitmap(name_box_image)
  #  case namepos
  #  when "left"
  #    sprites["namebox"].x = 6
  #  when "center"
  #    sprites["namebox"].x = Graphics.width / 2 - sprites["namebox"].bitmap.width / 2
  #  when "right"
  #    sprites["namebox"].x = 350
  #  end
  #  case $game_system.message_position
  #  when 0
  #    sprites["namebox"].y = window_height
  #  when 1
  #    sprites["namebox"].y = Graphics.height / 2 - window_height / 2 - 48
  #  when 2
  #    sprites["namebox"].y = Graphics.height - window_height - 48
  #  end
  #  sprites["namebox"].z = 1
  #  sprites["namebox"].visible = (hide_namebox == 0)
  #  # Actual Name
  #  sprites["name"] = Sprite.new(viewport)
  #  sprites["name"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
  #  sprites["name"].z = 2
  #  pbSetSystemFont(sprites["name"].bitmap)
  #  sprites["name"].bitmap.clear
  #  text_x = sprites["namebox"].x + sprites["namebox"].bitmap.width / 2
  #  text_y = sprites["namebox"].y + 12
  #  char_color1 = Dialog::getCharColor(speaker, 0, true)
  #  char_color2 = Dialog::getCharColor(speaker, 1, true)
  #  textpositions = [[(hide_name == 0 ? name_tag : "???"), text_x, text_y, 2, char_color1, char_color2, 1]]
  #  pbDrawTextPositions(sprites["name"].bitmap, textpositions)
  #end

  shout = false
  if !shout
    # Apply formatting for text
    #if textpos
    #  if textpos == "center"
    #    format_text = _INTL("<ac>{1}</ac>", format_text)
    #  elsif textpos == "right"
    #    format_text = _INTL("<ar>{1}</ar>", format_text)
    #  else
    #    format_text = _INTL("<al>{1}</al>", format_text)
    #  end
    #end
    #format_text = _INTL("{1}{2}</c2>", color, format_text) if color
    #format_text = _INTL("\\w[{1}]{2}", window_type, format_text) if window_type

    msgwindows.display(text)

    #pbMessagesDisplay(msgwindow, format_text, controls)
    #pbMessagesDisplay(msgwindow2, format_text, controls2)
  else
    # Real textbox has commands only, actual message is drawn manually
    command = ""
    if format_text.downcase.include?("\\wtnp")
      temp_text = format_text[(format_text.index("\\wtnp"))...format_text.length]
      temp_text = temp_text[0..temp_text.index("]")]
      command = temp_text
      format_text = format_text[0...format_text.index(temp_text)] +
        format_text[(format_text.index(temp_text)+temp_text.length)...format_text.length]
    end
    command = _INTL("\\w[{1}]{2}", window_type, command) if window_type
    command = _INTL("\\l[{1}]{2}", lines, command) if lines != 3

    # Create actual text
    sprites["text"] = Sprite.new(viewport)
    sprites["text"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(sprites["text"].bitmap)
    sprites["text"].bitmap.font.size = 52
    sprites["text"].bitmap.clear
    text_y = 0
    case $game_system.message_position
    when 0
      text_y = window_height / 2 - 36
    when 1
      text_y = Graphics.height / 2 - 36
    when 2
      text_y = Graphics.height - window_height / 2 - 36
    end
    textpos = [[format_text, 128, text_y, false, Dialog::getCharColor(speaker, 0), Dialog::getCharColor(speaker, 1)]]
    sprites["text"].z = 3

    $game_temp.textSize = 4
    pbDrawTextPositions(sprites["text"].bitmap,textpos)
    $game_temp.textSize = 2

    pbSEPlay("Damage1",100,100)
    $game_screen.start_shake(2, 25, 10)

    pbMessage(command)

  end

  msgwindows.dipose if create_window
end

def pbPortraitFile(character, expression, left = false)
  files = left ? [
      _INTL("Graphics/Messages/{1}/left/{2}", character.downcase, expression.downcase),
      _INTL("Graphics/Messages/{1}/left/neutral", character.downcase)
    ] : [
      _INTL("Graphics/Messages/{1}/{2}", character.downcase, expression.downcase),
      _INTL("Graphics/Messages/{1}/neutral", character.downcase)
    ]
  files.each do |file|
    if pbResolveBitmap(file)
      return file
    end
  end
  return nil
end

def pbText(text)
  pbTalk(text)
end

def pbSpeech(name, expression="neutral", phrase=nil, unknown=false, choices=nil, opts={})
  name = "none" if !name
  expression = "none" if !expression

  if phrase==nil
    phrase = name
    for event in $game_map.events.values
      name = event.name if @event_id == event.id
    end
  end

  opts = {}
  opts["speaker"] = name
  opts["expression"] = expression
  opts["choices"] = choices if choices
  opts["hide_name"] = 1 if unknown

  pbTalk(phrase, opts)
end

def pbShout(name, expression="neutral", phrase=nil, unknown=false)
  if phrase==nil
    phrase = name
    for event in $game_map.events.values
      name = event.name if @event_id == event.id
    end
  end

  opts = {}
  opts["speaker"] = name
  opts["expression"] = expression
  opts["hide_name"] = 1 if unknown
  opts["shout"] = true

  pbTalk(phrase, opts)
end

def pbShowUnownText(text)
  text.gsub!("\n","")
  showtext = ""
  alpha = "abcdefghijklmnopqrstuvwxyz!?"
  size1 = "aijlprtvyz!?"
  size2 = "bdefgkqx"
  size3 = "chmnosuw"
  length = 0
  for i in 0..text.length-1
    char = text[i..i]
    char = char.downcase
    if alpha.include?(char)
      length += 12 if size1.include?(char)
      length += 16 if size2.include?(char)
      length += 20 if size3.include?(char)
      char = "qmark" if char == "?"
      showtext += _INTL("<icon=unown_{1}>",char)
    else
      if char == " " && length >= 340
        showtext += " \n"
        length = 0
      else
        showtext += char
        showtext += " " if char == " "
        length += 8
      end
    end
  end
  showtext += " "
  Kernel.pbMessage(showtext)
end