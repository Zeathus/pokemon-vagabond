class Game_Temp
  attr_accessor :textSize
end

def pbTextEffect(type, startc=false, endc=false, speed=false)

  type = type.downcase

  if speed
    $game_system.message_effect=[type,startc,endc,speed]
  elsif endc
    $game_system.message_effect=[type,startc,endc]
  elsif startc
    $game_system.message_effect=[type,startc]
  else
    $game_system.message_effect=[type]
  end

end

def pbFormat(phrase)

  #Removing automatic line breaks
  phrase.gsub!("\n","")

  #Place player name safely (no crash if not defined)
  begin
    phrase.gsub!("PLAYER",$player.name)
  rescue
    phrase.gsub!("PLAYER","(player name undefined!)")
  end

  #Replacing text variables
  phrase.gsub!("<MONEY>","\\G")
  phrase.gsub!("<BR>","\\n")
  phrase.gsub!("WTNP","\\wtnp[20]")
  phrase.gsub!("WT","\\wt[10]")
  phrase.gsub!("STP","\\!")
  if $player
    if false #$PokemonSystem.genderid==2
      phrase.gsub!("XE is","they are")
      phrase.gsub!("XE has","they have")
      phrase.gsub!("XE's","they're")
      phrase.gsub!("XE'S","they've")
      phrase.gsub!("XE","they")
      phrase.gsub!("XIM","them")
      phrase.gsub!("XIS","their")
      phrase.gsub!("GENDER","person")
    elsif $player.gender == 0 #&& $PokemonSystem.genderid==0) ||
          #($player.gender==1 && $PokemonSystem.genderid==1)
      phrase.gsub!("XE'S","XE's")
      phrase.gsub!("XE","he")
      phrase.gsub!("XIM","him")
      phrase.gsub!("XIS","his")
      phrase.gsub!("GENDER","boy")
    else
      phrase.gsub!("XE'S","XE's")
      phrase.gsub!("XE","she")
      phrase.gsub!("XIM","her")
      phrase.gsub!("XIS","her")
      phrase.gsub!("GENDER","girl")
    end
  end

  phrase.gsub!("[R]","[r]")
  phrase.gsub!("[G]","[g]")
  phrase.gsub!("[B]","[b]")
  phrase.gsub!("[Y]","[y]")
  phrase.gsub!("[P]","[p]")
  phrase.gsub!("[O]","[o]")
  phrase.gsub!("[W]","[w]")

  phrase.gsub!("[r]","<c2=043c3aff>")
  phrase.gsub!("[g]","<c2=06644bd2>")
  phrase.gsub!("[b]","<c2=65467b14>")
  phrase.gsub!("[y]","<c2=129B43DF>")
  phrase.gsub!("[p]","<c2=7C1F7EFF>")
  phrase.gsub!("[o]","<c2=017F473F>")
  phrase.gsub!("[w]","<c2=2D497FFF>")

  phrase.gsub!("[/R]","[/]")
  phrase.gsub!("[/G]","[/]")
  phrase.gsub!("[/B]","[/]")
  phrase.gsub!("[/Y]","[/]")
  phrase.gsub!("[/O]","[/]")
  phrase.gsub!("[/r]","[/]")
  phrase.gsub!("[/g]","[/]")
  phrase.gsub!("[/b]","[/]")
  phrase.gsub!("[/y]","[/]")
  phrase.gsub!("[/o]","[/]")
  phrase.gsub!("[/]","</c2>")

  if phrase.include?("[RBOW]") && phrase.include?("[/RBOW]")
    start_index = phrase.index("[RBOW]") + 6
    end_index = phrase.index("[/RBOW]")

    color1 = Color.new(255,0,0)
    color2 = Color.new(255,170,170)

    old_str = phrase[start_index...end_index]
    new_str = ""

    if $game_system.message_effect && $game_system.message_effect[0]=="wavebow"
      hue_step = (360 / old_str.length).ceil
    else
      hue_step = (340 / old_str.length).ceil
    end

    for i in 0...old_str.length
      new_str += "<c2="
      new_str += colorToRgb16(pbHueShift(color1,-i*hue_step)).to_s
      new_str += colorToRgb16(pbHueShift(color2,-i*hue_step)).to_s
      new_str += ">"
      new_str += old_str[i..i]
      new_str += "</c2>"
    end

    phrase.gsub!("[RBOW]"+old_str+"[/RBOW]",new_str)

  end

  if phrase.include?("[RBOW2]") && phrase.include?("[/RBOW2]")
    start_index = phrase.index("[RBOW2]") + 7
    end_index = phrase.index("[/RBOW2]")

    color1 = Color.new(255,0,0)
    color2 = Color.new(255,170,170)

    old_str = phrase[start_index...end_index]
    new_str = ""

    hue_step = 360 / 12

    for i in 0...old_str.length
      new_str += "<c2="
      new_str += colorToRgb16(pbHueShift(color1,-i*hue_step)).to_s
      new_str += colorToRgb16(pbHueShift(color2,-i*hue_step)).to_s
      new_str += ">"
      new_str += old_str[i..i]
      new_str += "</c2>"
    end

    phrase.gsub!("[RBOW2]"+old_str+"[/RBOW2]",new_str)

  end

  return phrase

end