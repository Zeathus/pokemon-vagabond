def getActivePokemon(pos)
  id = getPartyActive(pos)
  return [] if id == -1
  return $player.party if id == PBParty::Player
  return pbGet(PARTY_POKEMON)[id]
end

def getPartyPokemon(id)
  id = getID(PBParty,id) if id.is_a?(Symbol)
  if id == PBParty::Player
    return $player.party
  elsif id == -1
    return $player.inactive_party
  end
  return pbGet(PARTY_POKEMON)[id]
end

def getInactivePartyPokemon(id)
  pbSet(INACTIVE_POKEMON,[]) if !pbGet(INACTIVE_POKEMON).is_a?(Array)
  id = getID(PBParty,id) if id.is_a?(Symbol)
  if id == PBParty::Player
    return $player.inactive_party
  end
  inactive_pokemon = pbGet(INACTIVE_POKEMON)
  if inactive_pokemon[id].nil?
    inactive_pokemon[id] = []
  end
  return inactive_pokemon[id]
end

def getAllPartyPokemon(id)
  return getPartyPokemon(id) + getInactivePartyPokemon(id)
end

def initPartyPokemon(id)
  pbSet(PARTY_POKEMON,[]) if !pbGet(PARTY_POKEMON).is_a?(Array)
  id = getID(PBParty,id) if id.is_a?(Symbol)
  parties = pbGet(PARTY_POKEMON)
  party = []
  case id
  when PBParty::Duke
    party.push(createPartyPokemon(
      id,:RIOLU,10,[:QUICKATTACK,:METALCLAW,:VACUUMWAVE,:ENDURE],1,
      :HASTY,0,[1,3,2,3,2,0]))
    party.push(createPartyPokemon(
      id,:BRONZOR,9,[:CONFUSION,:TACKLE,:CONFUSERAY,:PAYBACK],0,
      :CALM,2,[2,0,3,1,2,3]))
  when PBParty::Amethyst
    levels = [18, 18]
    for i in getPartyPokemon(PBParty::Duke)
      if i.species == :BRONZOR || i.species == :BRONZONG
        levels[0] = i.level if i.level > levels[0]
      elsif i.species == :RIOLU || i.species == :LUCARIO
        levels[1] = i.level if i.level > levels[1]
      end
    end
    party.push(createPartyPokemon(
      id,:MISDREAVUS,levels[0],[],1,:TIMID,1,[2,0,1,3,3,2]))
    party.push(createPartyPokemon(
      id,:STARMIE,levels[1],[],0,:MODEST,0,[3,0,1,3,2,2]))
  when PBParty::Kira
    levels = [20, 20]
    for i in getPartyPokemon(PBParty::Amethyst)
      if i.species == :MISDREAVUS || i.species == :MISMAGIUS
        levels[0] = i.level if i.level > levels[0]
      elsif i.species == :STARMIE
        levels[1] = i.level if i.level > levels[1]
      end
    end
    party.push(createPartyPokemon(
      id,:SANDSLASH,levels[1],[],1,:ADAMANT,0,[2,3,3,2,0,1]))
    party.push(createPartyPokemon(
      id,:LARVESTA,levels[0],[],0,:TIMID,0,[2,0,2,1,3,3]))
    party.push(createPartyPokemon(
      id,:TYRUNT,levels[0],[],0,:ADAMANT,0,[3,3,2,1,0,2]))
  when PBParty::Eliana

  when PBParty::Fintan

  when PBParty::Nekane

  when PBParty::Ziran

  when PBParty::Azelf
    party.push(createPartyPokemon(
      id,:AZELF,35,[],0,:ADAMANT,2,[1,3,2,3,3,2]))
  when PBParty::Uxie
    party.push(createPartyPokemon(
      id,:UXIE,35,[],0,:CALM,2,[3,2,3,1,2,3]))
  when PBParty::Mesprit
    party.push(createPartyPokemon(
      id,:MESPRIT,35,[],0,:BASHFUL,2,[3,2,2,1,3,3]))
  when PBParty::Player2
    party.push(createPartyPokemon(
      id,:VICTINI,70,[],0,:BASHFUL,2,[3,2,2,1,3,3]))
  when PBParty::YoungKira
    party.push(createPartyPokemon(
      id,:SANDSHREW,9,[:FALSESWIPE,:DEFENSECURL,:SANDATTACK,:POISONSTING],1,:ADAMANT,0,[2,3,3,2,0,1]))
  end
  parties[id]=party
end

def addTestPokemon
  $player.party.push(createPartyPokemon(
    0,:RIOLU,5,[],1,:HASTY,0,[10,31,16,31,16,5]))
end

def addTestPokemon2
  party = pbGet(PARTY_POKEMON)[PBParty::Kira]
  party.push(createPartyPokemon(
    PBParty::Kira,:TYRANTRUM,50,[],1,:ADAMANT,0,[31,31,16,10,5,16]))
  party = pbGet(PARTY_POKEMON)[PBParty::Duke]
  party.push(createPartyPokemon(
    PBParty::Duke,:CELEBI,50,[],1,:SERIOUS,0,[31,31,16,16,31,16]))
  party = pbGet(PARTY_POKEMON)[PBParty::Amethyst]
  party.push(createPartyPokemon(
    PBParty::Amethyst,:STARMIE,50,[],1,:TIMID,0,[31,31,16,10,5,16]))
end

def createPartyPokemon(id,species,level,moves,ability,nature,gender,els=nil)
  id = getID(PBParty,id) if id.is_a?(Symbol)

  poke = Pokemon.new(species,level)

  # Trainer fields
  poke.owner.name   = PBParty.getName(id)
  poke.owner.id     = PBParty.getTrainerID(id)
  poke.owner.gender = PBParty.getGender(id)

  # Set Moves
  for i in moves
    #i = getID(PBMoves,i) if i.is_a?(Symbol)
    poke.learn_move(i)
  end
  poke.record_first_moves

  # Ability
  poke.ability_index = ability

  # Gender
  poke.gender = gender

  # Nature
  poke.nature = nature

  # ELs
  poke.el = pbStatArrayToHash(els)

  poke.calc_stats

  return poke
end

def addPartyPokemon(owner, pokemon)
  owner = getID(PBParty,owner) if owner.is_a?(Symbol)
  party = getPartyPokemon(owner)
  case pokemon
  when :WEAVILE
    pokemon = createPartyPokemon(
      owner,:WEAVILE,24,[],0,:JOLLY,1,[0,3,2,3,1,2])
  end
  party.push(pokemon)
end

def alignMemberLevels(source, target)
  source = getID(PBParty,source) if source.is_a?(Symbol)
  target = getID(PBParty,target) if target.is_a?(Symbol)
  levels = [18, 18]

  pokemon = {
    PBParty::Duke => [[:RIOLU, :LUCARIO], [:BRONZOR, :BRONZONG], []],
    PBParty::Amethyst => [[:WEAVILE], [:MISDREAVUS, :MISMAGIUS], [:STARMIE]],
    PBParty::Kira => [[:SANDSHREW, :SANDSLASH, :SANDOLIN], [:LARVESTA, :VOLCARONA], [:TYRUNT, :TYRANTRUM]],
    PBParty::Eliana => [[:LUXIO, :LUXRAY], [:MIMIKYU], []]
  }

  getPartyPokemon(target).each do |target_pkmn|
    index = -1
    for i in 0...3
      index = i if pokemon[target][i].include?(target_pkmn.species)
    end
    next if index == -1
    getPartyPokemon(source).each do |source_pkmn|
      if pokemon[source][index].include?(source_pkmn.species)
        if target_pkmn.level < source_pkmn.level
          target_pkmn.level = source_pkmn.level
          target_pkmn.calc_stats
        end
        next
      end
    end
  end
end

def pbFindPokemon(owner, species)
  owner = getID(PBParty,owner) if owner.is_a?(Symbol)
  for pkmn in getPartyPokemon(owner)
    if pkmn.species == species
      return pkmn
    end
  end
  return nil
end