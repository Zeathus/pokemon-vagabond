module GameData
  class Species
    attr_reader :extra_types

    alias sup_initialize initialize

    def initialize(hash)
      sup_initialize(hash)
      @extra_types = hash[:extra_types] || @types
    end
  end
end