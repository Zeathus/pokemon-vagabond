def pbHarvestBerry(item, quantity)
  pbMessage(_INTL("The bush holds fresh {1}.\nDo you want to pick them?{2}",
    GameData::Item.get(item).name_plural,"\\ch[1,2,Yes,No]"))
  quantity += 1 if GameData::Weather.get($game_screen.weather_type).category == :Sun
  if pbGet(1)==0
    realqnt = quantity
    if (pbPartyAbilityCount(:HARVEST) +
        pbPartyAbilityCount(:CHEEKPOUCH) +
        pbPartyAbilityCount(:SYMBIOSIS)) > 0
      realqnt = (realqnt * 1.5).floor
    end
    title = "ITEM COLLECTED"
    text = ""
    text2 = nil
    itemobj = GameData::Item.get(item)
    itemname=(realqnt>1) ? itemobj.name_plural : itemobj.name
    if realqnt>1
      text += realqnt.to_s
      text += "x "
      text += itemname
    else
      text += itemname
    end

    loot = {
      :TINYMUSHROOM => 64,
      :BIGMUSHROOM => 128,
      :BALMMUSHROOM => 256,
      :MENTALHERB => 128,
      :POWERHERB => 128,
      :WHITEHERB => 128,
      :HONEY => 256,
      :HEALPOWDER => 128,
      :ENERGYPOWDER => 128,
      :ENERGYROOT => 256,
      :REVIVALHERB => 1024,
      :BIGROOT => 256,
      :ABSORBBULB => 256,
      :LUMINOUSMOSS => 256,
      :MIRACLESEED => 512,
      :SILVERPOWDER => 512
    }

    if pbPartyAbilityCount(:HONEYGATHER) > 0
      loot[:HONEY] /= 8
    end

    if pbPartyMoveCount(:ROTOTILLER) > 0
      loot[:ENERGYROOT] /= 4
      loot[:BIGROOT] /= 4
      loot[:MIRACLESEED] /= 4
    end

    if pbPartyMoveCount(:WATERSPORT) > 0
      loot[:ABSORBBULB] /= 4
      loot[:LUMINOUSMOSS] /= 4
      loot[:SILVERPOWDER] /= 4
    end

    # Nectars (4x the chance if the player has an Oricorio)
    case item
    when :APICOTBERRY, :BELUEBERRY, :BLUKBERRY,
         :CHESTOBERRY, :CORNNBERRY, :GANLONBERRY,
         :PAMTREBERRY, :PAYAPABERRY, :RAWSTBERRY,
         :WIKIBERRY
      loot[:PURPLENECTAR] = (pbHasInParty?(:ORICORIO) ? 32 : 128)
    when :COLBURBERRY, :KASIBBERRY, :KEEBERRY,
         :LANSATBERRY, :MAGOBERRY, :MAGOSTBERRY,
         :NANABBERRY, :PECHABERRY, :PERSIMBERRY,
         :PETAYABERRY, :QUALOTBERRY, :SPELONBERRY
      loot[:PINKNECTAR] = (pbHasInParty?(:ORICORIO) ? 32 : 128)
    when :CHERIBERRY, :CHOPLEBERRY, :CUSTAPBERRY,
         :HABANBERRY, :LEPPABERRY, :OCCABERRY,
         :POMEGBERRY, :RAZZBERRY, :ROSELIBERRY,
         :TAMATOBERRY
      loot[:REDNECTAR] = (pbHasInParty?(:ORICORIO) ? 32 : 128)
    when :ASPEARBERRY, :CHARTIBERRY, :GREPABERRY,
         :HONDEWBERRY, :JABOCABERRY, :NOMELBERRY,
         :PINAPBERRY, :SHUCABERRY, :SITRUSBERRY,
         :WACANBERRY
      loot[:YELLOWNECTAR] = (pbHasInParty?(:ORICORIO) ? 32 : 128)
    end

    # Seeds
    case item
    when :APICOTBERRY, :COBABERRY, :CORNNBERRY,
         :KELPSYBERRY, :ROSELIBERRY, :ROWAPBERRY,
         :YACHEBERRY, :WIKIBERRY
      loot[:MISTYSEED] = 64
    when :COLBURBERRY, :KASIBBERRY, :KEEBERRY,
         :LANSATBERRY, :MAGOBERRY, :MAGOSTBERRY,
         :NANABBERRY, :PECHABERRY, :PERSIMBERRY,
         :PETAYABERRY, :QUALOTBERRY, :SPELONBERRY
      loot[:PSYCHICSEED] = 64
    when :AGUAVBERRY, :BABIRIBERRY, :DURINBERRY,
         :HONDEWBERRY, :KEBIABERRY, :LUMBERRY,
         :MICLEBERRY, :RABUTABERRY, :RINDOBERRY,
         :SALACBERRY, :STARFBERRY, :WEPEARBERRY,
         :TANGABERRY
      loot[:GRASSYSEED] = 64
    when :ASPEARBERRY, :CHARTIBERRY, :GREPABERRY,
         :JABOCABERRY, :NOMELBERRY, :PINAPBERRY,
         :SHUCABERRY, :SITRUSBERRY, :WACANBERRY
      loot[:ELECTRICSEED] = 64
    end

    extra_berries = 0
    if pbJob("Botanist").level >= 1
      rate = 8
      rate = 16 if pbJob("Botanist").level >= 3
      if $game_player.direction == 2 # Down
        loot[:MENTALHERB] /= rate
        loot[:POWERHERB] /= rate
        loot[:WHITEHERB] /= rate
        loot[:HEALPOWDER] /= rate
        loot[:ENERGYPOWDER] /= rate
        loot[:REVIVALHERB] /= rate
        loot[:ABSORBBULB] /= rate
        loot[:SILVERPOWDER] /= rate
      elsif $game_player.direction == 8 # Up
        loot[:TINYMUSHROOM] /= rate
        loot[:BIGMUSHROOM] /= rate
        loot[:BALMMUSHROOM] /= rate
        loot[:ENERGYROOT] /= rate
        loot[:BIGROOT] /= rate
        loot[:MIRACLESEED] /= rate
        loot[:LUMINOUSMOSS] /= rate
        loot[:MISTYSEED] /= rate if loot.key?(:MISTYSEED)
        loot[:PSYCHICSEED] /= rate if loot.key?(:PSYCHICSEED)
        loot[:GRASSYSEED] /= rate if loot.key?(:GRASSYSEED)
        loot[:ELECTRICSEED] /= rate if loot.key?(:ELECTRICSEED)
      else # Left / Right
        extra_berries = rate / 8
      end
    end

    pbItemBall(item, realqnt + extra_berries)
    pbJob("Botanist").register(item)

    loot.each do |item, chance|
      rng = rand(chance)
      if rng < realqnt
        pbItemBall(item, 1)
      end
    end

    pbAddGuide("Berry Bushes")

    return true
  end
  return false
end