def pbPartyTypeCount(type)
  ret = 0
  $player.party.each do |pkmn|
    if pkmn.types.include?(type)
      ret += 1
    end
  end
  return ret
end

def pbPartyTypePokemon(type)
  $player.party.each do |pkmn|
    if pkmn.types.include?(type)
      return pkmn
    end
  end
  return nil
end

def pbPartyAbilityCount(ability)
  ret = 0
  $player.party.each do |pkmn|
    if pkmn.ability == ability
      ret += 1
    end
  end
  return ret
end

def pbPartyAbilityPokemon(ability)
  $player.party.each do |pkmn|
    if pkmn.ability == ability
      return pkmn
    end
  end
  return nil
end

def pbPartyMoveCount(move)
  ret = 0
  $player.party.each do |pkmn|
    for m in pkmn.moves
      if m.id == move
        ret += 1
      end
    end
  end
  return ret
end

def pbPartyMovePokemon(move)
  $player.party.each do |pkmn|
    for m in pkmn.moves
      if m.id == move
        return pkmn
      end
    end
  end
  return nil
end

def pbPartySpeciesCount(species)
  ret = 0
  $player.party.each do |pkmn|
    if pkmn.species == species
      ret += 1
    end
  end
  return ret
end

def pbPartySpeciesPokemon(species)
  $player.party.each do |pkmn|
    if pkmn.species == species
      return pkmn
    end
  end
  return nil
end