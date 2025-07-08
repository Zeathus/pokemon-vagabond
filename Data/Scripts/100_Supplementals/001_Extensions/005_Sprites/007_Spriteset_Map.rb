class Spriteset_Map
  alias sup_initialize initialize
  alias sup_dispose dispose
  alias sup_update update

  def initialize(map = nil)
    @vfx = RPG::VFX.new(@@viewport1)

    sup_initialize(map)

    # Overworld Pokemon
    @wild_battle_pending = false
    @in_wild_battle = false
    @spawn_areas = []
    initSpawnAreas if Supplementals::OVERWORLD_POKEMON

    pbUpdateMarkers
    pbUpdateSigns
  end

  def dispose
    despawnPokemon if Supplementals::OVERWORLD_POKEMON
    @vfx.dispose
    sup_dispose
  end

  def update
    if self.map == $game_map
      if @vfx.type != $game_screen.vfx_type
        @vfx.type = $game_screen.vfx_type
      end
    else
      @vfx.type = PBVFX::None
    end
    sup_update
    @vfx.update
    updateOverworldPokemon if @spawn_areas && Supplementals::OVERWORLD_POKEMON
  end

end