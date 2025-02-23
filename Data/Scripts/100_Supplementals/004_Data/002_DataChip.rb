def pbAllDataChipMoves
  moves = [
    [:WORKUP,1],
    [:AERIALACE,1],
    [:SHOCKWAVE,1],
    [:MAGICALLEAF,1],
    [:FORESIGHT,1],
    [:ROUND,1],
    [:THIEF,1],
    [:HEALPULSE,1],
    [:ANCIENTPOWER,2],
    [:OMINOUSWIND,2],
    [:SILVERWIND,2],
    [:HELPINGHAND,2],
    [:CURSE,2],
    [:PSYCHUP,2],
    [:THERMODYNAMICS,2],
    [:FLY,3],
    [:STRENGTH,3],
    [:STEALTHROCK,3],
    [:SEISMICTOSS,3],
    [:SUBSTITUTE,4]
  ]

  if pbJob("Engineer").level >= 2
    moves += [
      [:ROOST,3],
      [:TERRAINPULSE,3],
      [:WEATHERBALL,3],
      [:BOUNCE,3],
      [:SMARTSTRIKE,3],
      [:DRILLRUN,3],
      [:LIQUIDATION,3],
      [:SLUDGEWAVE,4],
      [:FREEZEDRY,4],
      [:EXPANDINGFORCE,4]
    ]
  end

  if pbJob("Engineer").level >= 4
    moves += [
      [:BODYPRESS,4],
      [:DYNAMICPUNCH,4],
      [:INFERNO,4],
      [:ZAPCANNON,4],
      [:PERMAFROST,4],
      [:EXPLOSION,4],
      [:HYPERBEAM,4],
      [:GIGAIMPACT,4],
      [:OVERHEAT,5],
      [:MEGAHORN,5],
      [:DRACOMETEOR,5],
      [:SKYATTACK,5],
      [:METRONOME,5]
    ]
  end

  return moves
end

def pbAddDataChipMove(move)
  pbSet(DATA_CHIP_MOVES,[]) if !pbGet(DATA_CHIP_MOVES).is_a?(Array)
  if !$game_variables[DATA_CHIP_MOVES].include?(move)
    $game_variables[DATA_CHIP_MOVES].push(move)
  end
end

def pbHasDataChipMove(move)
  pbSet(DATA_CHIP_MOVES,[]) if !pbGet(DATA_CHIP_MOVES).is_a?(Array)
  return $game_variables[DATA_CHIP_MOVES].include?(move)
end

def pbGetDataChipMoves(pokemon)
  return [] if !pokemon || pokemon.egg? || (pokemon.shadowPokemon? rescue false)
  allMoves = pbAllDataChipMoves
  chipMoves=[]
  # First add unlocked moves
  for i in allMoves
    if pbHasDataChipMove(i[0])
      chipMoves.push(i)
    end
  end
  # Then add locked moves
  for i in allMoves
    if !chipMoves.include?(i)
      chipMoves.push(i)
    end
  end
  # Finally, add a compatability value to each move
  # Sort compatible moves first in list
  for i in chipMoves
    i[2] = pokemon.compatible_with_move?(i[0])
  end
  moves = []
  for i in chipMoves
    moves.push(i) if i[2]
  end
  for i in chipMoves
    moves.push(i) if !i[2]
  end
  return moves|[] # remove duplicates
end

def pbGetTMMoves(pokemon)
  return [] if !pokemon || pokemon.egg? || (pokemon.shadowPokemon? rescue false)
  moves=[]
  GameData::Item.each { |i|
    if i.is_TM? && $bag.quantity(i) > 0
      if pokemon.compatible_with_move?(i.move)
        moves.push([i.move, i.name])
      end
    end
  }
  return moves | [] # remove duplicates
end

def pbGiveAllTMs
  for i in 0...$ItemData.length
    if $ItemData[i][ITEMUSE]==3 && $bag.quantity(i)<=0
      $bag.pbStoreItem(i,1)
    end
  end
  Kernel.pbMessage("Got all TMs")
end

def pbGetLevelUpMoves(pokemon)
  return [] if !pokemon || pokemon.egg? || pokemon.shadowPokemon?
  moves = []
  level_moves = []
  pokemon.getMoveList.each do |m|
    if !moves.include?(m[1])
      level_moves.push([m[1], m[0]])
      moves.push(m[1])
    end
  end
  if pokemon.first_moves
    for i in pokemon.first_moves
      if !moves.include?(i)
        level_moves.push([i, 0])
        moves.push(i)
      end
    end
  end
  level_moves.sort! {|a,b|
    if a[1] == 0 or b[1] == 0
      a[1]<=>b[1]
    elsif a[1] > pokemon.level || b[1] > pokemon.level
      a[1]<=>b[1]
    else
      b[1]<=>a[1]
    end
  }
  return level_moves
end 