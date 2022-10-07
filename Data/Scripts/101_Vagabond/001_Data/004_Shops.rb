def pbShopScoriaStatBerries
  items = [
    :POMEGBERRY,
    :KELPSYBERRY,
    :QUALOTBERRY,
    :HONDEWBERRY,
    :GREPABERRY,
    :TAMATOBERRY
  ]
  for i in items
    setPrice(i,200)
  end
  return items
end

def pbShopScoriaSeeds
  items = [
    :ELECTRICSEED,
    :GRASSYSEED,
    :MISTYSEED,
    :PSYCHICSEED,
    :MIRACLESEED,
    :ABSORBBULB,
    #:LUMINOUSMOSS
  ]
  for i in items
    setPrice(i,400)
  end
  setPrice(:MIRACLESEED,1000)
  setPrice(:ABSORBBULB,300)
  return items
end

def pbShopScoriaBerries
  items = [
    :BABIRIBERRY,
    :CHARTIBERRY,
    :CHILANBERRY,
    :CHOPLEBERRY,
    :COBABERRY,
    :COLBURBERRY,
    :HABANBERRY,
    :KASIBBERRY,
    :KEBIABERRY,
    :OCCABERRY,
    :PASSHOBERRY,
    :PAYAPABERRY,
    :RINDOBERRY,
    :ROSELIBERRY,
    :SHUCABERRY,
    :TANGABERRY,
    :WACANBERRY,
    :YACHEBERRY
  ]
  for i in items
    setPrice(i,400)
  end
  return items
end

def pbShopScoriaHerbs
  return [
    :ENERGYPOWDER,
    :ENERGYROOT,
    :HEALPOWDER,
    :REVIVALHERB,
    :MENTALHERB,
    :POWERHERB,
    :WHITEHERB
  ]
end

def pbShopGeneral
  return [
    :POKEBALL,:GREATBALL,
    :ULTRABALL,:POTION,
    :SUPERPOTION,:HYPERPOTION,
    :MAXPOTION,:FULLRESTORE,
    :REVIVE,:ANTIDOTE,
    :PARALYZEHEAL,:AWAKENING,
    :BURNHEAL,:ICEHEAL,
    :FULLHEAL,:ESCAPEROPE,
    :REPEL,:SUPERREPEL,:MAXREPEL
  ]
end

def pbShopMall(type="general")
  case type
  when "general"
    return pbShopGeneral
  when "medicine"
    return [
      :POTION, :SUPERPOTION, :HYPERPOTION, :MAXPOTION, :FULLRESTORE,
      :REVIVE,
      :ANTIDOTE, :PARALYZEHEAL, :AWAKENING, :BURNHEAL, :ICEHEAL,
      :FULLHEAL
    ]
  when "field"
    return [
      :POKEBALL, :GREATBALL, :ULTRABALL,
      :REPEL, :SUPERREPEL, :MAXREPEL,
      :ESCAPEROPE
    ]
  when "vitamins"
    return [
      :HPUP, :PROTEIN, :IRON, :CALCIUM, :ZINC, :CARBOS,
      :XATTACK, :XDEFENSE, :XSPATK, :XSPDEF, :XSPEED,
      :GUARDSPEC, :DIREHIT
    ]
  when "powerup"
    return [
      :FIRESTONE, :WATERSTONE, :THUNDERSTONE, :LEAFSTONE,
      :POWERANKLET, :POWERBAND, :POWERBELT, :POWERBRACER, :POWERLENS, :POWERWEIGHT,
      :MACHOBRACE
    ]
  when "toys"
    return [
      :POKEDOLL, :FLUFFYTAIL, :POKETOY,
      :AIRBALLOON,
      :BINDINGBAND, :GRIPCLAW,
      :LAGGINGTAIL,
      :STICKYBARB,
    ]
  when "tech"
    return [
      :UPGRADE, :DUBIOUSDISC,
      :ELECTIRIZER, :MAGMARIZER,
      :CELLBATTERY, :EJECTBUTTON,
      :MAGNET, :METRONOME, #:METALCOAT,
      :SCOPELENS, :ZOOMLENS, :WIDELENS,
      :LUCKYPUNCH
    ]
  when "tms"
    return [
      :TM111, # Protect
      :TM112, # Safeguard
      :TM113, :TM114, # Screens
      :TM117, :TM118, :TM119, :TM120, :TM121, # Weather
      :TM122, :TM123, :TM124, :TM125, # Terrains
      :TM126, :TM127, :TM128 # Rooms
    ]
  end
  return pbShopGeneral
end