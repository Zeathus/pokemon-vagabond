class Spriteset_Map
  @@viewport1b = Viewport.new(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT) # Visual Effects
  @@viewport1b.z = 101

  alias sup_initialize initialize
  alias sup_dispose dispose
  alias sup_update update

  def initialize(map = nil)
    @vfx = RPG::VFX.new(@viewport1b)

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
      @vfx.type = $game_screen.vfx_type
    else
      @vfx.type = PBVFX::None
    end
    sup_update
    @vfx.update
    @@viewport1b.update
    updateOverworldPokemon if @spawn_areas && Supplementals::OVERWORLD_POKEMON
  end

end