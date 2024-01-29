module GameData
  class TerrainTag
    attr_reader :shows_dust_particle
    attr_reader :land2_wild_encounters
    attr_reader :land3_wild_encounters
    attr_reader :land4_wild_encounters
    attr_reader :swamp_wild_encounters
    attr_reader :flower_wild_encounters
    attr_reader :water_edge
    attr_reader :stair_right
    attr_reader :stair_left
    attr_reader :stair_up

    alias sup_initialize initialize
    alias sup_can_surf_freely can_surf_freely

    def initialize(hash)
      sup_initialize(hash)
      @shows_dust_particle    = hash[:shows_dust_particle]    || false
      @land_wild_encounters   = hash[:land_wild_encounters]   || false
      @land2_wild_encounters  = hash[:land2_wild_encounters]  || false
      @land3_wild_encounters  = hash[:land3_wild_encounters]  || false
      @land4_wild_encounters  = hash[:land4_wild_encounters]  || false
      @swamp_wild_encounters  = hash[:swamp_wild_encounters]  || false
      @flower_wild_encounters = hash[:flower_wild_encounters] || false
      @water_edge             = hash[:water_edge]             || false
      @stair_right            = hash[:stair_right]            || false
      @stair_left             = hash[:stair_left]             || false
      @stair_up               = hash[:stair_up]               || false
    end

    def has_land_encounters?
      return @land_wild_encounters ||
        @land2_wild_encounters ||
        @land3_wild_encounters ||
        @land4_wild_encounters ||
        @swamp_wild_encounters ||
        @flowers_wild_encounters
    end

    def can_surf_freely
      return sup_can_surf_freely && !@water_edge
    end
  end
end

GameData::TerrainTag.register({
  :id                     => :StairsRight,
  :id_number              => 17,
  :stair_right            => true
})

GameData::TerrainTag.register({
  :id                     => :StairsLeft,
  :id_number              => 18,
  :stair_left             => true
})

GameData::TerrainTag.register({
  :id                     => :StairsUp,
  :id_number              => 19,
  :stair_up               => true
})

GameData::TerrainTag.register({
  :id                     => :Swamp,
  :id_number              => 20,
  :battle_environment     => :Puddle,
  :swamp_wild_encounters  => true
})

GameData::TerrainTag.register({
  :id                     => :Flowers,
  :id_number              => 21,
  :shows_grass_rustle     => true,
  :battle_environment     => :Grass,
  :flower_wild_encounters => true
})

GameData::TerrainTag.register({
  :id                     => :Rocky,
  :id_number              => 22,
  :shows_dust_particle    => true,
  :battle_environment     => :Rock,
  :land_wild_encounters   => true
})

GameData::TerrainTag.register({
  :id                     => :WaterEdge,
  :id_number              => 23,
  :can_fish               => true,
  :water_edge             => true
})

GameData::TerrainTag.register({
  :id                     => :Grass2,
  :id_number              => 24,
  :shows_grass_rustle     => true,
  :battle_environment     => :Grass,
  :land2_wild_encounters  => true
})

GameData::TerrainTag.register({
  :id                     => :Grass3,
  :id_number              => 25,
  :shows_grass_rustle     => true,
  :battle_environment     => :Grass,
  :land3_wild_encounters  => true
})

GameData::TerrainTag.register({
  :id                     => :Grass4,
  :id_number              => 26,
  :shows_grass_rustle     => true,
  :battle_environment     => :Grass,
  :land4_wild_encounters  => true
})

GameData::TerrainTag.register({
  :id                     => :Overhang,
  :id_number              => 27
})