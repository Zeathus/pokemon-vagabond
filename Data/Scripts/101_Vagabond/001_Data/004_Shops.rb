def pbShopScoria(type)
  case type
  when "organics"
    return [
      :LEFTOVERS,
      :LAVACOOKIE,
      :RAGECANDYBAR,
      :BERRYJUICE,
      :SHOALSALT
    ]
  when "accessories"
    return [
      :FOCUSSASH,
      :EXPERTBELT,
      :MUSCLEBAND,
      :WISEGLASSES,
      :BINDINGBAND
    ]
  when "orbs"
    return [
      :LIFEORB,
      :FLAMEORB,
      :FROSTORB,
      :TOXICORB,
      :ADRENALINEORB
    ]
  when "misc"
    return [
      :BLACKSLUDGE,
      :FLOATSTONE,
      :DESTINYKNOT,
      :RINGTARGET,
      :THICKCLUB
    ]
  end
  return [:POKEBALL]
end

def pbShopSecretMarket
  return [
    :ABILITYCAPSULE,
    :ABILITYPATCH,
    :CHOICEBAND,
    :CHOICESPECS,
    :CHOICESCARF,
    :SAFETYGOGGLES,
    :TERRAINEXTENDER,
    :WEAKNESSPOLICY,
    :DUBIOUSDISC
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
    :FULLHEAL,
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
      :POKEBALL, :GREATBALL, :ULTRABALL, :LUXURYBALL,
      :REPEL, :SUPERREPEL, :MAXREPEL
    ]
  when "vitamins"
    return [
      :HEALTHWING, :MUSCLEWING, :RESISTWING, :GENIUSWING, :CLEVERWING, :SWIFTWING,
      :HPUP, :PROTEIN, :IRON, :CALCIUM, :ZINC, :CARBOS
    ]
  when "powerup"
    return [
      :FIRESTONE, :WATERSTONE, :THUNDERSTONE, :LEAFSTONE,
      :POWERWEIGHT, :POWERBRACER, :POWERBELT, :POWERLENS, :POWERBAND, :POWERANKLET,
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
      :LINKINGCORD,
      :UPGRADE,
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