def pbInnDialog(city=nil, price=100)

  dialog_file = "INN"
  dialog_file += "_" + city.upcase if city

  pbSet(1, price)
  if pbDialog(dialog_file, 0)

    if $player.money>=price
      response = (pbGetLanguage() == 2) ? pbDialog("INN",1) : pbDialog("INN",2)
      if response != -1
        $player.money-=price
        pbSEPlay("Mart buy item")
        pbDialog("INN",3)
        $player.heal_party
        case response
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
        pbDialog("INN",4)
      end
    else
      pbDialog("INN",5)
    end

    return false
  else
    pbDialog("INN",4)
  end

  return false

end