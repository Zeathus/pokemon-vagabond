def pbAllDataChipMoves
  moves = [
    [:WORKUP,1],
    [:AERIALACE,1],
    [:SHOCKWAVE,1],
    [:MAGICALLEAF,1],
    [:FORESIGHT,1],
    [:ANCIENTPOWER,2],
    [:HELPINGHAND,2],
    [:ROUND,2],
    [:THIEF,2],
    [:CURSE,2],
    [:PSYCHUP,2],
    [:FLY,3],
    [:STRENGTH,3],
    [:THERMODYNAMICS,3],
    [:STEALTHROCK,3],
    [:SEISMICTOSS,3],
    [:SUBSTITUTE,4]
  ]

  if $bag.quantity(:DATARECOVERYDEVICE)>0
    moves += [
      [:ROOST,3],
      [:TERRAINPULSE,3],
      [:WEATHERBALL,3],
      [:FUTURESIGHT,3],
      [:BOUNCE,3],
      [:FREEZEDRY,4],
      [:LIQUIDATION,4],
      [:PLAYROUGH,4],
      [:GIGADRAIN,4],
      [:DYNAMICPUNCH,5],
      [:PERMAFROST,5],
      [:INFERNO,5],
      [:ZAPCANNON,5]
    ]
  end

  if $bag.quantity(:DATARECOVERYDEVICEV2)>0
    moves += [
      [:BODYPRESS,4],
      [:EXPLOSION,4],
      [:FLAREBLITZ,5],
      [:HURRICANE,5],
      [:MEGAHORN,5],
      [:DRACOMETEOR,5],
      [:SKYATTACK,5],
      [:METRONOME,8]  
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
  return [] if !pokemon || pokemon.egg? || (pokemon.isShadow? rescue false)
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
  return [] if !pokemon || pokemon.egg? || (pokemon.isShadow? rescue false)
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
  level_moves.sort! {|a,b| a[1]<=>b[1]}
  return level_moves
end 