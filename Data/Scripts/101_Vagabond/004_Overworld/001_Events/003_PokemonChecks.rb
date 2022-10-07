def pbHasPinkPearlPokemon
  for pkmn in ($player.party + $player.inactive_party)
    if pbPinkPearlPokemon?(pkmn) > 0
      return pkmn
    end
  end
  return false
end

def pbPinkPearlPokemon?(pkmn)
  normal = [
    :PERSIAN,
    :SLOWKING,
    :SPOINK,
    :CLAMPERL
  ]
  shiny = [
    :PERSIAN,
    :SLOWKING
  ]
  rare = [
    :PALKIA,
    :PHIONE,
    :MANAPHY,
    :DIANCIE
  ]
  return 3 if pkmn.shiny? && pkmn.species == :MELOETTA && pkmn.form == 1
  return 0 if pkmn.form != 0
  return 1 if !pkmn.shiny? && normal.include?(pkmn.species)
  return 1 if pkmn.shiny? && shiny.include?(pkmn.species)
  return 2 if rare.include?(pkmn.species)
  return 0
end