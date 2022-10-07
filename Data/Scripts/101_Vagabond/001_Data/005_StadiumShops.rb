def pbStadiumShop1
  items = []

  # TM Roar
  items.push(:TM05)
  setPrice(:TM05,400)
  # TM Smack Down
  items.push(:TM23)
  setPrice(:TM23,400)
  # TM Quash
  items.push(:TM60)
  setPrice(:TM60,400)
  # TM Taunt
  items.push(:TM12)
  setPrice(:TM12,800)
  # TM Sky Drop
  items.push(:TM58)
  setPrice(:TM58,800)
  # TM Rock Polish
  items.push(:TM69)
  setPrice(:TM69,800)
  # TM Acrobatics
  items.push(:TM62)
  setPrice(:TM62,1400)
  # TM Gyro Ball
  items.push(:TM74)
  setPrice(:TM74,1400)
  # TM U-Turn
  items.push(:TM89)
  setPrice(:TM89,2000)
  # TM Surf
  items.push(:TM94)
  setPrice(:TM94,2000)
  # TM Earthquake
  items.push(:TM26)
  setPrice(:TM26,3000)

  pbStadiumShop(items)
end

def pbStadiumShop2
  items = []

  # Oval Charm
  items.push(:OVALCHARM)
  setPrice(:OVALCHARM,800)
  # DNA Splicers
  if $player.owned[:KYUREM]
    items.push(:DNASPLICERS)
    setPrice(:DNASPLICERS,1600)
  end
  # Reveal Glass
  if $player.owned[:TORNADUS] ||
     $player.owned[:THUNDURUS] ||
     $player.owned[:LANDORUS]
    items.push(:REVEALGLASS)
    setPrice(:REVEALGLASS,1600)
  end

  megaRings=[:MEGARING,:MEGABRACELET,:MEGACUFF,:MEGACHARM,:ZRING]
  hasRing = false
  for i in megaRings
    next if !hasConst?(PBItems,i)
    hasRing = true if $PokemonBag.pbQuantity(i)>0
  end
  if hasRing
    items.push(:DECIDIUMZ)
    setPrice(:DECIDIUMZ,1600)
    items.push(:INCINIUMZ)
    setPrice(:INCINIUMZ,1600)
    items.push(:PRIMARIUMZ)
    setPrice(:PRIMARIUMZ,1600)
    items.push(:SNORLIUMZ)
    setPrice(:SNORLIUMZ,1600)
    items.push(:PIKANIUMZ)
    setPrice(:PIKANIUMZ,1600)
    items.push(:ALORAICHIUMZ)
    setPrice(:ALORAICHIUMZ,1600)
    items.push(:EEVEEIUMZ)
    setPrice(:EEVEEIUMZ,1600)
  end

  pbStadiumShop(items)
end

def pbStadiumShop(items)
  money = $player.money
  $player.money = $game_variables[STADIUM_POINTS]
  $game_switches[STADIUM_POINT_SHOP]=true
  pbPokemonMart(items,nil,true)
  $game_switches[STADIUM_POINT_SHOP]=false
  $game_variables[STADIUM_POINTS] = $player.money
  $player.money = money
end 