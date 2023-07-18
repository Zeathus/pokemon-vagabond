class Game_Temp
  attr_accessor :textSize
end

def pbTalk(text, msgwindows = nil)
  create_window = msgwindows.nil?
  msgwindows = TalkMessageWindows.new if create_window

  msgwindows.display(text)

  msgwindows.dispose if create_window
end

def pbShout(text, msgwindows = nil)
  create_window = msgwindows.nil?
  msgwindows = TalkMessageWindows.new if create_window

  msgwindows.shout(text)

  msgwindows.dispose if create_window
end

def pbWhisper(text, msgwindows = nil)
  create_window = msgwindows.nil?
  msgwindows = TalkMessageWindows.new if create_window

  msgwindows.whisper(text)

  msgwindows.dispose if create_window
end

def pbSilent(text, msgwindows = nil)
  create_window = msgwindows.nil?
  msgwindows = TalkMessageWindows.new if create_window

  msgwindows.silent(text)

  msgwindows.dispose if create_window
end

def pbSpeech(name, expression="neutral", phrase=nil)
  if phrase.nil?
    phrase = name
    name = nil
  end
  msgwindows = TalkMessageWindows.new
  msgwindows.focused.portrait.set(name, expression)
  msgwindows.display(phrase)
  msgwindows.dispose
  Graphics.update
  Input.update
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

#def pbSpeech(name, expression="neutral", phrase=nil, unknown=false, choices=nil, opts={})
#  name = "none" if !name
#  expression = "none" if !expression
#
#  if phrase==nil
#    phrase = name
#    for event in $game_map.events.values
#      name = event.name if @event_id == event.id
#    end
#  end
#
#  opts = {}
#  opts["speaker"] = name
#  opts["expression"] = expression
#  opts["choices"] = choices if choices
#  opts["hide_name"] = 1 if unknown
#
#  pbTalk(phrase, opts)
#end

#def pbShout(name, expression="neutral", phrase=nil, unknown=false)
#  if phrase==nil
#    phrase = name
#    for event in $game_map.events.values
#      name = event.name if @event_id == event.id
#    end
#  end
#
#  opts = {}
#  opts["speaker"] = name
#  opts["expression"] = expression
#  opts["hide_name"] = 1 if unknown
#  opts["shout"] = true
#
#  pbTalk(phrase, opts)
#end

def pbShowUnownText(text)
  has_dictionary = $bag && $bag.quantity(:UNOWNDICTIONARY) > 0

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
      if has_dictionary
        showtext += _INTL("<icon=unown2_{1}>",char)
      else
        showtext += _INTL("<icon=unown_{1}>",char)
      end
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
  showtext = "\\w[speech vb unown]" + showtext
  pbMessage(showtext)
end