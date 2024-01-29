def pbStadiumShop1
  items = [
    [:TM03, 160], # Facade
    [:TM07, 320], # Power-Up Punch
    [:TM11, 320], # Acrobatics
    [:TM22, 1280], # Earthquake
    [:TM24, 960], # Rock Slide
    [:TM30, 640], # Pollen Puff
    [:TM34, 320], # Phantom Force
    [:TM38, 1280], # Steel Beam
    [:TM40, 160], # Flame Charge
    [:TM50, 640], # Leaf Blade
    [:TM59, 640], # Psyshock
    [:TM63, 480], # Icy Wind
    [:TM68, 480], # Dragon Tail
    [:TM75, 640], # Throat Chop
    [:TM78, 960], # Play Rough
    [:TM104, 160], # Hone Claws
    [:TM107, 160], # Agility
    [:TM110, 320], # Taunt
    [:TM116, 640] # Defog
  ]

  items = items.sort_by { |k| k[1] }

  items.each do |i|
    if $bag.quantity(i[0]) == 0
      pbStadiumShop(items)
      bought_all = true
      items.each do |i|
        if $bag.quantity(i[0]) == 0
          bought_all = false
          break
        end
      end
      if bought_all
        pbDialog("STADIUM_SHOP_UPGRADE")
      else
        return
      end
    end
  end

  pbStadiumShop2
end

def pbStadiumShop2
  items = [
    [:ULTRABALL,5],
    [:MAXREPEL,5],
    [:HEALTHWING,10],
    [:MUSCLEWING,10],
    [:RESISTWING,10],
    [:GENIUSWING,10],
    [:CLEVERWING,10],
    [:SWIFTWING,10],
    [:HPUP,40],
    [:PROTEIN,40],
    [:IRON,40],
    [:CALCIUM,40],
    [:ZINC,40],
    [:CARBOS,40],
    [:HEMATITEGEMSTONE,120],
    [:HELIODORGEMSTONE,120],
    [:AEGIRINEGEMSTONE,120],
    [:AMETRINEGEMSTONE,120],
    [:HOWLITEGEMSTONE,120],
    [:PHENACITEGEMSTONE,120],
    [:PPUP,80],
    [:PPMAX,200],
    [:ABILITYCAPSULE,80],
    [:ABILITYPATCH,160],
    [:NUGGET,80]
  ]

  pbStadiumShop(items)
end

def pbStadiumShop(items_and_prices)
  items = []
  items_and_prices.each do |i|
    setPrice(i[0], i[1])
    items.push(i[0])
  end
  money = $player.money
  $player.money = $game_variables[STADIUM_POINTS]
  $game_switches[STADIUM_POINT_SHOP]=true
  pbPokemonMart(items,nil,true)
  $game_switches[STADIUM_POINT_SHOP]=false
  $game_variables[STADIUM_POINTS] = $player.money
  $player.money = money
end 