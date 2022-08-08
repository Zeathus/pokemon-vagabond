module Scaling

  # At what rate different variables increase the player level variable
  PLAYER_MAX_LEVEL_WEIGHT = 0.20
  PLAYER_AVG_LEVEL_WEIGHT = 0.30
  OPPONENT_MAX_LEVEL_WEIGHT = 0.30
  OPPONENT_AVG_LEVEL_WEIGHT = 0.40

  # Add this number to opponent levels before changing the player level to give it an upwards pace
  PLAYER_LEVEL_GROWTH_RATE = 1.00

  # Define some trainer classes to be higher or lower level than usual (default: 0)
  TRAINER_SCALING_MODIFIERS = {
    :BUGCATCHER       => -1,
    :CAMPER           => -1,
    :PICNICKER        => -1,
    :YOUNGSTER        => -1,
    :LASS             => -1,
    :TUBER_M          => -1,
    :TUBER_F          => -1,
    :TUBER2_M         => -1,
    :TUBER2_F         => -1,
    :TWINS            => -1,
    :COOLTRAINER_M    => 1,
    :COOLTRAINER_F    => 1,
    :COOLCOUPLE       => 1,
    :POKEMONRANGER_M  => 1,
    :POKEMONRANGER_F  => 1
  }

  # For Pokémon with special evolution requirements
  # At what level should the scaling automatically evolve them, and to what species
  CUSTOM_EVOLUTION_LEVELS = {
    :AIPOM        => [:AMBIPOM, 32],
    :AMAURA       => [:AURORUS, 39],
    :BUDEW        => [:ROSELIA, 18],
    :BOLDORE      => [:GIGALITH, 40],
    :BONSLY       => [:SUDOWOODO, 15],
    :CHANSEY      => [:BLISSEY, 32],
    :CHINGLING    => [:CHIMECHO, 26],
    :COTTONEE     => [:WHIMSICOTT, 28],
    :CLEFAIRY     => [:CLEFABLE, 32],
    :DUSCLOPS     => [:DUSKNOIR, 45],
    :DOUBLADE     => [:AEGISLASH, 42],
    :EELEKTRIK    => [:EELEKTROSS, 46],
    :LICKITUNG    => [:LICKILICKY, 33],
    :ELECTABUZZ   => [:ELECTIVIRE, 42],
    :EXEGGCUTE    => [:EXEGGUTOR, 32],
    :FEEBAS       => [:MILOTIC, 20],
    :FLOETTE      => [:FLORGES, 32],
    :FOMANTIS     => [:LURANTIS, 34],
    :GLIGAR       => [:GLISCOR, 37],
    :GRAVELER     => [:GOLEM, 36],
    :GROWLITHE    => [:ARCANINE, 27],
    :GLOOM        => [:VILEPLUME, 34],
    :GURDURR      => [:CONKELDURR, 36],
    :HAPPINY      => [:CHANSEY, 16],
    :HAUNTER      => [:GENGAR, 32],
    :HELIOPTILE   => [:HELIOLISK, 30],
    :JIGGLYPUFF   => [:WIGGLYTUFF, 32],
    :KADABRA      => [:ALAKAZAM, 38],
    :KARRABLAST   => [:ESCAVALIER, 32],
    :LAMPENT      => [:CHANDELURE, 47],
    :LOMBRE       => [:LUDICOLO, 32],
    :MACHOKE      => [:MACHAMP, 36],
    :MAGMAR       => [:MAGMORTAR, 42],
    :MINCCINO     => [:CINCCINO, 26],
    :MIMEJR       => [:MRMIME, 22],
    :MISDREAVUS   => [:MISMAGIUS, 28],
    :MUNNA        => [:MUSHARNA, 27],
    :MURKROW      => [:HONCHKROW, 34],
    :NUZLEAF      => [:SHIFTRY, 32],
    :NIDORINA     => [:NIDOQUEEN, 36],
    :NIDORINO     => [:NIDOKING, 36],
    :ONIX         => [:STEELIX, 30],
    :PANSAGE      => [:SIMISAGE, 24],
    :PANSEAR      => [:SIMISEAR, 24],
    :PANPOUR      => [:SIMIPOUR, 24],
    :PETILIL      => [:LILLIGANT, 28],
    :PICHU        => [:PIKACHU, 14],
    :PIKACHU      => [:RAICHU, 25],
    :PILOSWINE    => [:MAMOSWINE, 44],
    :PHANTUMP     => [:TREVENANT, 32],
    :PUMPKABOO    => [:GOURGEIST, 32],
    :POLIWHIRL    => [:POLIWRATH, 34],
    :PORYGON      => [:PORYGON2, 16],
    :PORYGON2     => [:PORYGONZ, 32],
    :RHYDON       => [:RHYPERIOR, 50],
    :RIOLU        => [:LUCARIO, 28],
    :ROSELIA      => [:ROSERADE, 36],
    :SANDSHREW    => [:SANDSLASH, 22],
    :SCYTHER      => [:SCIZOR, 36],
    :SEADRA       => [:KINGDRA, 36],
    :SHELLDER     => [:CLOYSTER, 32],
    :SHELMET      => [:ACCELGOR, 32],
    :SKITTY       => [:DELCATTY, 22],
    :SUNKERN      => [:SUNFLORA, 20],
    :SNEASEL      => [:WEAVILE, 35],
    :STARYU       => [:STARMIE, 32],
    :STEENEE      => [:TSAREENA, 34],
    :SPRITZEE     => [:AROMATISSE, 30],
    :SWADLOON     => [:LEAVANNY, 32],
    :SWIRLIX      => [:SLURPUFF, 30],
    :TANGELA      => [:TANGROWTH, 38],
    :TOGETIC      => [:TOGEKISS, 42],
    :TYRUNT       => [:TYRANTRUM, 39],
    :VULPIX       => [:NINETALES, 27],
    :WEEPINBELL   => [:VICTREEBEL, 34],
    :YANMA        => [:YANMEGA, 30],
    :YUNGOOS      => [:GUMSHOOS, 20]
  }

  def Scaling.update(trainer = nil)
    old_player_level = $game_variables[Supplementals::PLAYER_LEVEL]
    player_level = old_player_level

    player_max_level = 0
    player_avg_level = 0

    $player.party.each do |i|
      player_max_level = [player_max_level, i.level].max
      player_avg_level += i.level
    end

    player_avg_level /= $player.party.length

    levels = [
      player_max_level,
      player_avg_level
    ]
    weights = [
      PLAYER_MAX_LEVEL_WEIGHT,
      PLAYER_AVG_LEVEL_WEIGHT
    ]

    if trainer
      opponent_max_level = 0
      opponent_avg_level = 0

      trainer.party.each do |i|
        opponent_max_level = [opponent_max_level, i.level].max
        opponent_avg_level += i.level
      end

      opponent_avg_level /= trainer.party.length

      opponent_max_level += PLAYER_LEVEL_GROWTH_RATE
      opponent_avg_level += PLAYER_LEVEL_GROWTH_RATE

      levels += [
        opponent_max_level,
        opponent_avg_level
      ]
      weights += [
        OPPONENT_MAX_LEVEL_WEIGHT,
        OPPONENT_AVG_LEVEL_WEIGHT
      ]
    end

    for i in 0...levels.length
      if levels[i] > player_level
        player_level = player_level * (1.0 - weights[i]) + levels[i] * weights[i]
      end
    end

    echoln _INTL("Scaling: Player Level updated {1} -> {2}", old_player_level, player_level)

    $game_variables[Supplementals::PLAYER_LEVEL] = player_level
  end

  def Scaling.wild(pokemon)
    species, level = Scaling.wild_core(pokemon.species, pokemon.level)
    
    pokemon.species = species
    pokemon.level = level
    pokemon.calc_stats
  end

  def Scaling.wild_core(species, level)
    old_level = level
    player_level = $game_variables[Supplementals::PLAYER_LEVEL]

    # Update level if player level is at least 10 above
    if level <= player_level - Supplementals::WILD_POKEMON_LEVEL_DIFFERENCE
      level_dif = player_level - level - Supplementals::WILD_POKEMON_LEVEL_DIFFERENCE
      level = [level + level_dif / 2, level_old + Supplementals::WILD_POKEMON_MAX_SCALING].max
    end

    evolve = (rand < Supplementals::WILD_POKEMON_EVOLVE_CHANCE)
    while evolve
      new_species = Scaling.evolve(species, level)
      if species != new_species
        species = new_species
        evolve = (rand < Supplementals::WILD_POKEMON_EVOLVE_CHANCE)
      end
    end

    level = clamp(level, 1, 100).floor

    return species, level
  end

  def Scaling.evolve(species, level, wild = false)
    poke = Pokemon.new(species, clamp(level - Supplementals::WILD_POKEMON_EVOLVE_EXTRA_LEVELS, 1, 100), $player)
    new_species = poke.check_evolution_on_level_up
    return new_species if new_species && new_species != species
    if CUSTOM_EVOLUTION_LEVELS.key?(species)
      custom = CUSTOM_EVOLUTION_LEVELS[species]
      evolve_level = custom[1]
      evolve_level += Supplementals::WILD_POKEMON_EVOLVE_EXTRA_LEVELS if wild
      evolve_level += Supplementals::TRAINER_POKEMON_EVOLVE_EXTRA_LEVELS if !wild
      return custom[0] if level >= evolve_level
    end
    return species
  end

  def Scaling.trainer(trainer)
    # Calculate level_base
    level_base = $game_variables[Supplementals::PLAYER_LEVEL]
    if TRAINER_SCALING_MODIFIERS.key?(trainer.trainer_type)
      level_base += TRAINER_SCALING_MODIFIERS[trainer.trainer_type]
    end

    # Check if the trainer has been battled recently
    $game_variables[Supplementals::RECENT_TRAINERS] = [] if !$game_variables[Supplementals::RECENT_TRAINERS].is_a?(Array)
    $game_variables[Supplementals::RECENT_TRAINERS].each do |i|
      if i[0] == trainer.trainer_type && i[1] == trainer.name && i[2]
        level_base = i[2]
        $game_variables[Supplementals::RECENT_TRAINERS] -= [i]
        break
      end
    end
    $game_variables[Supplementals::RECENT_TRAINERS].push([trainer.trainer_type, trainer.name, level_base])
    while $game_variables[Supplementals::RECENT_TRAINERS].length > Supplementals::MAX_RECENT_TRAINERS
      $game_variables[Supplementals::RECENT_TRAINERS].shift
    end

    # Get the highest level
    min_level = 100
    max_level = 1
    trainer.party.each do |pkmn|
      min_level = [pkmn.level, min_level].min
      max_level = [pkmn.level, max_level].max
    end
    mid_level = (min_level + max_level) / 2.0

    # Change pokemon levels
    trainer.party.each do |pkmn|
      level = pkmn.level
      level_dif = level - mid_level
      if level_base > level
        # Change the level
        original_level = pkmn.level
        new_level = clamp(level_base + level_dif, 1, 100)
        new_level = new_level.round
        pkmn.level = new_level
        # Check for evolutions
        species_changed = false
        evolve = Supplementals::TRAINER_POKEMON_EVOLVE
        while evolve
          new_species = Scaling.evolve(pkmn.species, pkmn.level)
          if pkmn.species != new_species
            pkmn.species = new_species
            species_changed = true
          else
            evolve = false
          end
        end
        pkmn.name = GameData::Species.get(pkmn.species).name if species_changed
        pkmn.reset_moves if new_level - original_level > 10 and original_level < 30
        pkmn.calc_stats
      end
    end
  end

  def Scaling.difficulty(pokemon)
    case $PokemonSystem.difficulty
    when 0 # Easy
      pkmn.level -= 1
      pkmn.natureflag = PBNatures::SERIOUS
      pkmn.iv = pbStatArrayToHash([0, 0, 0, 0, 0, 0])
      pkmn.calc_stats
    when 1 # Normal
      
    when 2 # Hard
      pkmn.level += 1
      pkmn.calc_stats
    end
  end

  # Mainly used for levels, to reset back to the original levels before applying Scaling.update
  def Scaling.reset_difficulty(pokemon)
    case $PokemonSystem.difficulty
    when 0 # Easy
      pkmn.level += 1
      pkmn.calc_stats
    when 1 # Normal

    when 2 # Hard
      pkmn.level -= 1
      pkmn.calc_stats
    end
  end

end