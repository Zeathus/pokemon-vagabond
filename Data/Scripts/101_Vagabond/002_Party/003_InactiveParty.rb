class Player < Trainer

  attr_accessor :inactive_party

  def inactive_party
      if !@inactive_party
          @inactive_party = []
      end
      return @inactive_party
  end

  def inactive_pokemon_count
      return inactive_party.length
  end

  def add_inactive(pokemon)
      inactive_party.push(pokemon)
  end

  def has_species?(species, form = -1)
    return full_party.any? { |p| p && p.isSpecies?(species) && (form < 0 || p.form == form) }
  end

  def full_party
      return @party + inactive_party
  end

  def inactive_full?
      return inactive_party.length >= 3
  end

end