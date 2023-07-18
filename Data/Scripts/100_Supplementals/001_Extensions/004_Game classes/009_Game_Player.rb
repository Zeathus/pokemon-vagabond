class Game_Player < Game_Character

  attr_accessor :under_overhang

  def sprite
    if $scene.is_a?(Scene_Map) && $scene.spriteset
      return $scene.spritesetGlobal.playersprite
    end
    return nil
  end

  def pbFacingSecondTerrainTag(dir=nil)
    dir = self.direction if !dir
    facing=pbFacingTile(dir, self)
    case dir
      when 2 # down
        return $game_map.terrain_tag(facing[1],facing[2]+1)
      when 4 # left
        return $game_map.terrain_tag(facing[1]-1,facing[2])
      when 6 # right
        return $game_map.terrain_tag(facing[1]+1,facing[2])
      when 8 # up
        return $game_map.terrain_tag(facing[1],facing[2]-1)
      end
    return 0
  end

  def show_as_species(value)
    @shown_as_species = value
  end

end

alias sup_pbGetPlayerCharset pbGetPlayerCharset

def pbGetPlayerCharset(charset, trainer = nil, force = false)
  if @shown_as_species
    species_id = GameData::Species.get(@shown_as_species).id_number
    return sprintf("Graphics/Characters/Pokemon/pkmn%03d", species_id)
  end
  return sup_pbGetPlayerCharset(charset, trainer, force)
end