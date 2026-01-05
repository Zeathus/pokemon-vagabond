class ElementalOrbsSprite

  def initialize(parent, pokemon, back, viewport)
    @viewport = viewport
    @parent = parent
    @pokemon = nil
    @back = nil
    @orbs = []
    @types = []
    setPokemon(pokemon, back)
  end

  def setPokemon(pokemon, back)
    if pokemon != @pokemon || back != @back
      @pokemon = pokemon
      @back = back
      @curveWidth = 72
      @curveHeight = 56
      case pokemon.species
      when :SALAZZLE
        @curveWidth = 68
        @curveHeight = 40
      when :PRIMARINA
        @curveWidth = 64
        @curveHeight = 34
      when :GOLURK
        @curveWidth = 72
        @curveHeight = 56
      when :RIBOMBEE
        @curveWidth = 56
        @curveHeight = 48
      end
      @curveWidth *= 1.5 if @back
      @curveHeight *= 1.5 if @back
      refresh
    end
  end

  def isElemental
    return [:FIREADEPT, :WATERADEPT, :EARTHADEPT, :AIRADEPT].include?(@pokemon.ability.id)
  end

  def refresh
    @orbs.each do |orb|
      orb&.dispose
    end
    @orbs = []
    @types = []
    return if !isElemental
    @pokemon.moves.each_with_index do |move, i|
      @types[i] = move.type
      next if ![:FIRE, :WATER, :GROUND, :FLYING].include?(move.type)

      sprite = IconSprite.new(@parent.x, @parent.y, @viewport)
      filename = "Graphics/Pokemon/Other/ElementalOrb"
      sprite.setBitmap(filename)
      sprite.zoom_x = 2
      sprite.zoom_y = 2
      sprite.ox = 5
      sprite.oy = 5
      sprite.visible = @parent.visible
      sprite.opacity = @parent.opacity
      sprite.src_rect = Rect.new(0, 0, 10, 10)
      if move.type == :FIRE
        sprite.src_rect.x = 0
      elsif move.type == :WATER
        sprite.src_rect.x = 10
      elsif move.type == :GROUND
        sprite.src_rect.x = 20
      elsif move.type == :FLYING
        sprite.src_rect.x = 30
      end
      @orbs.push(sprite)
    end
    update
  end

  def update
    @pokemon.moves.each_with_index do |move, i|
      if @types[i] != move.type
        refresh
        return
      end
    end
    @orbs.each_with_index do |orb, i|
      orb.visible = @parent.visible
      orb.opacity = @parent.opacity
      orb.tone = @parent.tone
      orb.color = @parent.color
      time_now = System.uptime
      offset = time_now * 1.5 + Math::PI * i / 2
      orb_z = Math.sin(offset + Math::PI / 2)
      orb.x = @parent.x + Math.sin(offset) * @curveWidth * (i % 2 == 0 ? 1 : -1) + (@back ? -2 : 2)
      orb.y = @parent.y + Math.sin(offset + Math::PI / 6) * @curveHeight
      orb.z = @parent.z + ((orb_z > 0) ? 1 : -1)
      begin
        orb.x += @parent.bitmap.width / 2 - @parent.ox
        orb.y += @parent.bitmap.height / 2 - @parent.oy
      rescue
        # Catch in case bitmap or something doesn't exist
      end
      orb.zoom_x = (1.5 + orb_z / 2) * (@back ? 1.5 : 1.0)
      orb.zoom_y = orb.zoom_x
    end
    return isElemental
  end

  def dispose
    @orbs.each do |orb|
      orb&.dispose
    end
  end

  def color=(value)
    @orbs.each do |orb|
      orb.color = value
    end
  end

  def tone=(value)
    @orbs.each do |orb|
      orb.tone = value
    end
  end

  def visible=(value)
    @orbs.each do |orb|
      orb.visible = value
    end
  end

  def opacity=(value)
    @orbs.each do |orb|
      orb.opacity = value
    end
  end

end

class PokemonSprite < Sprite

  alias elemental_clearBitmap clearBitmap
  def clearBitmap
    elemental_clearBitmap
    refreshElementalOrbs(nil, false)
  end

  alias elemental_setPokemonBitmap setPokemonBitmap
  def setPokemonBitmap(pokemon, back = false)
    elemental_setPokemonBitmap(pokemon, back)
    refreshElementalOrbs(pokemon, back)
  end

  alias elemental_setPokemonBitmapSpecies setPokemonBitmapSpecies
  def setPokemonBitmapSpecies(pokemon, species, back = false)
    elemental_setPokemonBitmapSpecies(pokemon, species, back)
    refreshElementalOrbs(pokemon, back)
  end

  alias elemental_setSpeciesBitmap setSpeciesBitmap
  def setSpeciesBitmap(species, gender = 0, form = 0, shiny = false, shadow = false, back = false, egg = false)
    elemental_setSpeciesBitmap(species, gender, form, shiny, shadow, back, egg)
    refreshElementalOrbs(nil, back)
  end

  alias elemental_update update
  def update
    elemental_update
    @elementalOrbs&.update
  end

  alias elemental_dispose dispose
  def dispose
    @elementalOrbs&.dispose
    elemental_dispose
  end

  def refreshElementalOrbs(pokemon, back)
    if pokemon && pokemon.ability && [:FIREADEPT, :WATERADEPT, :EARTHADEPT, :AIRADEPT].include?(pokemon.ability.id)
      if @elementalOrbs
        @elementalOrbs.setPokemon(pokemon, back)
      else
        @elementalOrbs = ElementalOrbsSprite.new(self, pokemon, back, viewport)
      end
    elsif @elementalOrbs
      @elementalOrbs.dispose
      @elementalOrbs = nil
    end
  end
end

class Battle::Scene::BattlerSprite < RPG::Sprite

  def refreshElementalOrbs(pokemon, back)
    if pokemon && [:FIREADEPT, :WATERADEPT, :EARTHADEPT, :AIRADEPT].include?(pokemon.ability.id)
      if @elementalOrbs
        @elementalOrbs.setPokemon(pokemon, back)
      else
        @elementalOrbs = ElementalOrbsSprite.new(self, pokemon, back, viewport)
      end
    elsif @elementalOrbs
      @elementalOrbs.dispose
      @elementalOrbs = nil
    end
  end

end