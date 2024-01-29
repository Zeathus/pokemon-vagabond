def pbAddStarter(species)

  pokemon = Pokemon.new(species, 10, $player)
  $game_variables[STARTER_ID] = pokemon.personalID
  pokemon.ability_index = 0
  pokemon.nature = :BASHFUL
  case species
  when :SKIDDO
    pokemon.el = pbStatArrayToHash([3,3,2,0,1,2])
  when :NUMEL
    pokemon.el = pbStatArrayToHash([3,2,2,0,3,1])
  when :KRABBY
    pokemon.el = pbStatArrayToHash([3,3,2,0,1,2])
  when :PALMINO
    pokemon.el = pbStatArrayToHash([3,2,1,0,3,2])
  when :BOOMINE
    pokemon.el = pbStatArrayToHash([3,2,2,0,3,1])
  when :LAZU
    pokemon.el = pbStatArrayToHash([3,2,1,0,3,2])
  end

  pokemon.happiness = 128

  pokemon.calc_stats

  pbAddPokemon(pokemon)
  $player.pokedex.set_seen(species)
  $player.pokedex.set_owned(species)

end