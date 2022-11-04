def pbAddStarter(species)

  pokemon = Pokemon.new(species, 10, $player)
  $game_variables[STARTER_ID] = pokemon.personalID
  pokemon.ability_index = 0
  pokemon.nature = :BASHFUL
  case species
  when :SKIDDO
    pokemon.iv = pbStatArrayToHash([31,31,16,5,10,16])
  when :NUMEL
    pokemon.iv = pbStatArrayToHash([31,16,16,5,31,10])
  when :KRABBY
    pokemon.iv = pbStatArrayToHash([31,31,16,5,10,16])
  end

  pokemon.happiness = 128

  pokemon.calc_stats

  pbAddPokemon(pokemon)
  $player.pokedex.set_seen(species)
  $player.pokedex.set_owned(species)

end