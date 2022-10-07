def pbInnDialog(city="", price=100)

  if city=="placeholder" # For city-specific dialog



  else

    pbSpeech("Innkeeper","none",
      _INTL("\\GWelcome! Would you like to rest?BREAK(Costs ${1})",price),
      false,["Yes","No"])

  end

  if $game_variables[1]==0

    if $player.money>=price
      if pbGetLanguage()==2
        pbSpeech("Innkeeper","none",
          "\\GWhen would you like to wake up?",
          false,["Morning (06 AM)","Noon (12 PM)","Evening (06 PM)","Night (12 AM)","Cancel"])
      else
        pbSpeech("Innkeeper","none",
          "\\GWhen would you like to wake up?",
          false,["Morning (06:00)","Noon (12:00)","Evening (18:00)","Night (00:00)","Cancel"])
      end
      if $game_variables[1]<4
        $player.money-=price
        pbSEPlay("purchase.wav")
        pbSpeech("Innkeeper","none",
          "\\GEnjoy your stay!")
        for i in $player.party
          i.heal
        end
        case $game_variables[1]
        when 0 # 06:00
          pbGetTimeNow.forwardToTime(6, 0)
        when 1 # 12:00
          pbGetTimeNow.forwardToTime(12, 0)
        when 2 # 18:00
          pbGetTimeNow.forwardToTime(18, 0)
        when 3 # 00:00
          pbGetTimeNow.forwardToTime(0, 0)
        end
        return true
      else
        pbSpeech("Innkeeper","none",
          "\\GPlease come again!")
      end
    else
      pbSpeech("Innkeeper","none",
        "\\GYou don't have enough money.")
    end

    return false
  else
    pbSpeech("Innkeeper","none",
      "\\GPlease come again!")
  end

  return false

end