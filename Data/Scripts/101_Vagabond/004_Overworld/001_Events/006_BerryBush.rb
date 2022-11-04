def pbHarvestBerry(item, quantity)
  pbMessage(_INTL("It's a bush blooming of {1}. Do you want to pick them?{2}",
    GameData::Item.get(item).name_plural,"\\ch[1,2,Yes,No]"))
  quantity += 1 if GameData::Weather.get($game_screen.weather_type).category == :Sun
  if pbGet(1)==0
    realqnt = quantity
    if (pbPartyAbilityCount(:HARVEST)+
        pbPartyAbilityCount(:CHEEKPOUCH)+
        pbPartyAbilityCount(:SYMBIOSIS)+
        pbPartyMoveCount(:NATURALGIFT)+
        pbPartyMoveCount(:POLLENPUFF)+
        pbPartyMoveCount(:ROTOTILLER)+
        pbPartyMoveCount(:WATERSPORT))>0
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
    if realqnt > quantity
      if pbPartyAbilityPokemon(:HARVEST)
        pkmn = pbPartyAbilityPokemon(:HARVEST)
        text2 = pkmn.name + "'s " + "Harvest: +" + (realqnt-quantity).to_s + "x"
      elsif pbPartyAbilityPokemon(:CHEEKPOUCH)
        pkmn = pbPartyAbilityPokemon(:CHEEKPOUCH)
        text2 = pkmn.name + "'s " + "Cheek Pouch: +" + (realqnt-quantity).to_s + "x"
      elsif pbPartyAbilityPokemon(:SYMBIOSIS)
        pkmn = pbPartyAbilityPokemon(:SYMBIOSIS)
        text2 = pkmn.name + "'s " + "Symbiosis: +" + (realqnt-quantity).to_s + "x"
      elsif pbPartyMovePokemon(:NATURALGIFT)
        pkmn = pbPartyMovePokemon(:NATURALGIFT)
        text2 = pkmn.name + "'s " + "Natural Gift: +" + (realqnt-quantity).to_s + "x" 
      elsif pbPartyMovePokemon(:POLLENPUFF)
        pkmn = pbPartyMovePokemon(:POLLENPUFF)
        text2 = pkmn.name + "'s " + "Pollen Puff: +" + (realqnt-quantity).to_s + "x" 
      elsif pbPartyMovePokemon(:ROTOTILLER)
        pkmn = pbPartyMovePokemon(:ROTOTILLER)
        text2 = pkmn.name + "'s " + "Rototiller: +" + (realqnt-quantity).to_s + "x" 
      elsif pbPartyMovePokemon(:WATERSPORT)
        pkmn = pbPartyMovePokemon(:WATERSPORT)
        text2 = pkmn.name + "'s " + "Water Sport: +" + (realqnt-quantity).to_s + "x" 
      end
    end
    pbItemBall(item, realqnt)
    #$bag.pbStoreItem(item,realqnt)
    #pbSEPlay("ItemGet",100)
    #text = text.upcase if text
    #text2 = text2.upcase if text2
    #pbCollectNotification(text, text2, title)

    pbJob("botanist").register(item)

    loot = []
    loot.push([32, :TINYMUSHROOM])
    loot.push([128, :BIGMUSHROOM])
    loot.push([256, :BALMMUSHROOM])
    loot.push([1365, :REVIVALHERB])
    loot.push([96, :MENTALHERB])
    loot.push([128, :POWERHERB])
    loot.push([128, :WHITEHERB])

    # Ability Dependant drops
    loot.push([32, :HONEY]) if pbPartyAbilityCount(:HONEYGATHER)>0
    loot.push([pbPartyMoveCount(:ROTOTILLER) ? 48 : 128, :ENERGYROOT])
    loot.push([pbPartyMoveCount(:ROTOTILLER) ? 64 : 256, :BIGROOT])
    loot.push([pbPartyMoveCount(:WATERSPORT) ? 64 : 256, :ABSORBBULB])

    # Nectars (4x the chance if the player has an Oricorio)
    case item
    when :APICOTBERRY, :BELUEBERRY, :BLUKBERRY,
         :CHESTOBERRY, :CORNNBERRY, :GANLONBERRY,
         :PAMTREBERRY, :PAYAPABERRY, :RAWSTBERRY,
         :WIKIBERRY
      loot.push([pbHasInParty?(:ORICORIO) ? 32 : 128, :PURPLENECTAR])
    when :COLBURBERRY, :KASIBBERRY, :KEEBERRY,
         :LANSATBERRY, :MAGOBERRY, :MAGOSTBERRY,
         :NANABBERRY, :PECHABERRY, :PERSIMBERRY,
         :PETAYABERRY, :QUALOTBERRY, :SPELONBERRY
      loot.push([pbHasInParty?(:ORICORIO) ? 32 : 128, :PINKNECTAR])
    when :CHERIBERRY, :CHOPLEBERRY, :CUSTAPBERRY,
         :HABANBERRY, :LEPPABERRY, :OCCABERRY,
         :POMEGBERRY, :RAZZBERRY, :ROSELIBERRY,
         :TAMATOBERRY
      loot.push([pbHasInParty?(:ORICORIO) ? 32 : 128, :REDNECTAR])
    when :ASPEARBERRY, :CHARTIBERRY, :GREPABERRY,
         :HONDEWBERRY, :JABOCABERRY, :NOMELBERRY,
         :PINAPBERRY, :SHUCABERRY, :SITRUSBERRY,
         :WACANBERRY
      loot.push([pbHasInParty?(:ORICORIO) ? 32 : 128, :YELLOWNECTAR])
    end

    # Seeds
    case item
    when :APICOTBERRY, :COBABERRY, :CORNNBERRY,
         :KELPSYBERRY, :ROSELIBERRY, :ROWAPBERRY,
         :YACHEBERRY, :WIKIBERRY
      loot.push([64, :MISTYSEED])
    when :COLBURBERRY, :KASIBBERRY, :KEEBERRY,
         :LANSATBERRY, :MAGOBERRY, :MAGOSTBERRY,
         :NANABBERRY, :PECHABERRY, :PERSIMBERRY,
         :PETAYABERRY, :QUALOTBERRY, :SPELONBERRY
      loot.push([64, :PSYCHICSEED])
    when :AGUAVBERRY, :BABIRIBERRY, :DURINBERRY,
         :HONDEWBERRY, :KEBIABERRY, :LUMBERRY,
         :MICLEBERRY, :RABUTABERRY, :RINDOBERRY,
         :SALACBERRY, :STARFBERRY, :WEPEARBERRY,
         :TANGABERRY
      loot.push([64, :GRASSYSEED])
    when :ASPEARBERRY, :CHARTIBERRY, :GREPABERRY,
         :JABOCABERRY, :NOMELBERRY, :PINAPBERRY,
         :SHUCABERRY, :SITRUSBERRY, :WACANBERRY
      loot.push([64, :ELECTRICSEED])
    end

    for bonus in loot
      rng = rand(bonus[0])
      if rng < realqnt
        pbItemBall(bonus[1], 1)
        #$bag.pbStoreItem(bonus[1], 1)
        #pbCollectNotification(GameData::Item.get(item).name, "BONUS ITEM!")
      end
    end

    return true
  end
  return false
end