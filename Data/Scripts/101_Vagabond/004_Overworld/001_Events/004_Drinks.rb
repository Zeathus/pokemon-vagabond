def pbDrinkShop(town)
  choices = "\\ch[1,5,"
  if town=="lapis"
    choices += "$750 Sweet Swig,"
    #choices += "$1000 Warding Water,"
    choices += "$1200 Eggnog Express,"
    choices += "$2000 Rising Refresh,"
    choices += "Cancel]"
    drinks=["Sweet Swig","Eggnog Express","Rising Refresh"]
  elsif town=="chert"
    choices += "$750 Sweet Swig,"
    #choices += "$1200 Effort Extract,"
    choices += "$2000 Rising Refresh,"
    choices += "$3000 Golden Glass,"
    choices += "Cancel]"
    drinks=["Sweet Swig","Rising Refresh","Golden Glass"]
  elsif town="town3"
    choices += "$750 Sweet Swig,"
    choices += "$1000 Warding Water,"
    #choices += "$1600 Capture Cup,"  #NOT CODED
    #choices += "$2500 Mending Mix," #NOT CODED (heal after combat)
    choices += "Cancel]"
    drinks=["Sweet Swig","Warding Water"]
  end
  Kernel.pbMessage("\\GWhat would you like to drink?"+choices)
  if pbGet(1)==4
    pbSpeech("Shopkeep", "none", "\\GCome again!")
  else
    drink = drinks[pbGet(1)]
    if drink == "Sweet Swig"
      if $player.money>=750
        $player.money-=750
        $game_variables[DRINK_ACTIVE]="happiness"
      else
        pbSpeech("Shopkeep", "none", "I'm sorry, but you can't afford that.")
      end
    elsif drink == "Warding Water"
      if $player.money>=1000
        $player.money-=1000
        $game_variables[DRINK_ACTIVE]="repel"
      else
        pbSpeech("Shopkeep", "none", "I'm sorry, but you can't afford that.")
      end
    elsif drink == "Eggnog Express"
      if $player.money>=1200
        $player.money-=1200
        $game_variables[DRINK_ACTIVE]="hatch"
      else
        pbSpeech("Shopkeep", "none", "I'm sorry, but you can't afford that.")
      end
    elsif drink == "Rising Refresh"
      if $player.money>=2000
        $player.money-=2000
        $game_variables[DRINK_ACTIVE]="exp"
      else
        pbSpeech("Shopkeep", "none", "I'm sorry, but you can't afford that.")
      end
    elsif drink == "Effort Extract"
      if $player.money>=1200
        $player.money-=1200
        $game_variables[DRINK_ACTIVE]="effort"
      else
        pbSpeech("Shopkeep", "none", "I'm sorry, but you can't afford that.")
      end
    elsif drink == "Golden Glass"
      if $player.money>=3000
        $player.money-=3000
        $game_variables[DRINK_ACTIVE]="money"
      else
        pbSpeech("Shopkeep", "none", "I'm sorry, but you can't afford that.")
      end
    elsif drink == "Capture Cup"
      if $player.money>=1600
        $player.money-=1600
        $game_variables[DRINK_ACTIVE]="capture"
      else
        pbSpeech("Shopkeep", "none", "I'm sorry, but you can't afford that.")
      end
    elsif drink == "Mending Mix"
      if $player.money>=2500
        $player.money-=2500
        $game_variables[DRINK_ACTIVE]="heal"
      else
        pbSpeech("Shopkeep", "none", "I'm sorry, but you can't afford that.")
      end
    end
    pbSpeech("Shopkeep", "none", "\\GHere you go, enjoy your drink!")
    $game_variables[DRINK_TIME]=pbGetTimeNow.to_i_min
    msg = ["Sip...\\wt[10] Sip...\\wt[10] Sip...\\wt[10]",
      "Glug...\\wt[10] Glug...\\wt[10] Glug...\\wt[10]",
      "Chug...\\wt[10] Chug...\\wt[10] Chug...\\wt[10]"]
    Kernel.pbMessage(msg[rand(3)])
    Kernel.pbMessage("You feel refreshed after the great drink.")
  end
end

def pbActiveDrink
  if pbGet(DRINK_ACTIVE)!=0 && pbGet(DRINK_TIME)!=0
    if pbHasTimePassed(pbGet(DRINK_TIME),360)
      $game_variables[DRINK_ACTIVE] = 0
      $game_variables[DRINK_TIME] = 0
    else
      return pbGet(DRINK_ACTIVE)
    end
  end
  return "none"
end

