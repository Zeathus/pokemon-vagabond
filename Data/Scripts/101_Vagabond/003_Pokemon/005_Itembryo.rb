def pbEvolveItembryo(pkmn, scene = nil)
  return false if pkmn.form == 1
  evolutions = {
    :AIRBALLOON => [:DRIFBLIM, 0],
    :BRIGHTPOWDER => [:VENOMOTH, 2],
    :EVIOLITE => [:EEVEE, 0],
    :FLOATSTONE => [:MINIOR, 0],
    :DESTINYKNOT => [:DELCATTY, 0],
    :ROCKYHELMET => [:FERROTHORN, 0],
    :ASSAULTVEST => [:FROSMOTH, 2],
    :SAFETYGOGGLES => [:LEAVANNY, 2],
    :PROTECTIVEPADS => [:DECIDUEYE, 2],
    :HEAVYDUTYBOOTS => [:SIGILYPH, 1],
    :UTILITYUMBRELLA => [:GOLDUCK, 1],
    :EJECTBUTTON => [:GOLISOPOD, 0],
    :EJECTPACK => [:PALAFIN, 0],
    :REDCARD => [:CINDERACE, 0],
    :SHEDSHELL => [:DUDUNSPARCE, 1],
    :SMOKEBALL => [:THIEVUL, 0],
    :LUCKYEGG => [:BLISSEY, 1],
    :AMULETCOIN => [:PERSIAN, 0],
    :SOOTHEBELL => [:CHIMECHO, 0],
    :CLEANSETAG => [:GARBODOR, 0],
    :CHOICEBAND => [:RAMPARDOS, 0],
    :CHOICESPECS => [:CHANDELURE, 0],
    :CHOICESCARF => [:NINJASK, 0],
    :HEATROCK => [:NINETALES, 2],
    :DAMPROCK => [:POLITOED, 2],
    :SMOOTHROCK => [:HIPPOWDON, 0],
    :ICYROCK => [:AURORUS, 2],
    :TERRAINEXTENDER => [:STUNFISK, 0, 1],
    :LIGHTCLAY => [:CLAYDOL, 1],
    :GRIPCLAW => [:CARNIVINE, 0],
    :BINDINGBAND => [:GRAPPLOCT, 2],
    :BIGROOT => [:SHIINOTIC, 2],
    :BLACKSLUDGE => [:MUK, 2],
    :LEFTOVERS => [:SNORLAX, 2],
    :SHELLBELL => [:WALREIN, 1],
    :MENTALHERB => [:SLOWBRO, 0],
    :WHITEHERB => [:GARGANACL, 2],
    :POWERHERB => [:SHIFTRY, 2],
    :ABSORBBULB => [:MARACTUS, 0],
    :CELLBATTERY => [:PLUSLE, 0],
    :LUMINOUSMOSS => [:ARAQUANID, 0],
    :SNOWBALL => [:NINETALES, 2, 1],
    :WEAKNESSPOLICY => [:RHYPERIOR, 1],
    :BLUNDERPOLICY => [:DURANT, 1],
    :THROATSPRAY => [:SKELEDIRGE, 0],
    :ADRENALINEORB => [:GRANBULL, 2],
    :ROOMSERVICE => [:HATTERENE, 0],
    :ELECTRICSEED => [:PINCURCHIN, 2],
    :GRASSYSEED => [:TORTERRA, 2],
    :MISTYSEED => [:WEEZING, 2, 1],
    :PSYCHICSEED => [:INDEEDEE, 2],
    :LIFEORB => [:NIDOKING, 2],
    :EXPERTBELT => [:KECLEON, 2],
    :METRONOME => [:MILTANK, 0],
    :MUSCLEBAND => [:CONKELDURR, 2],
    :WISEGLASSES => [:DRAMPA, 0],
    :RAZORCLAW => [:HONCHKROW, 1],
    :SCOPELENS => [:ABSOL, 1],
    :WIDELENS => [:GALVANTULA, 0],
    :ZOOMLENS => [:BEHEEYEM, 2],
    :KINGSROCK => [:WEEZING, 2],
    :RAZORFANG => [:SKUNTANK, 0],
    :LAGGINGTAIL => [:SABLEYE, 1],
    :QUICKCLAW => [:SLOWBRO, 0, 1],
    :FOCUSBAND => [:THROH, 1],
    :FOCUSSASH => [:SAWK, 0],
    :FLAMEORB => [:MAGCARGO, 1],
    :FROSTORB => [:GLALIE, 0],
    :TOXICORB => [:QWILFISH, 0, 1],
    :STICKYBARB => [:CACTURNE, 0],
    :IRONBALL => [:AGGRON, 0],
    :RINGTARGET => [:WOBBUFFET, 0],
    :LAXINCENSE => [:WYNAUT, 0],
    :FULLINCENSE => [:MUNCHLAX, 0],
    :LUCKINCENSE => [:HAPPINY, 0],
    :PUREINCENSE => [:CHINGLING, 0],
    :SEAINCENSE => [:AZURILL, 0],
    :WAVEINCENSE => [:MANTYKE, 0],
    :ROSEINCENSE => [:BUDEW, 0],
    :ODDINCENSE => [:MIMEJR, 0],
    :ROCKINCENSE => [:BONSLY, 0],
    :CHARCOAL => [:TURTONATOR, 0],
    :MYSTICWATER => [:LAPRAS, 0],
    :MIRACLESEED => [:TROPIUS, 0],
    :MAGNET => [:MAGNEZONE, 0],
    :NEVERMELTICE => [:VANILLUXE, 0],
    :BLACKBELT => [:HARIYAMA, 0],
    :POISONBARB => [:BEEDRILL, 0],
    :SOFTSAND => [:DUGTRIO, 0],
    :SHARPBEAK => [:FEAROW, 0],
    :TWISTEDSPOON => [:ALAKAZAM, 0],
    :SILVERPOWDER => [:BUTTERFREE, 0],
    :HARDSTONE => [:GIGALITH, 0],
    :SPELLTAG => [:BANETTE, 0],
    :DRAGONFANG => [:SHELGON, 0],
    :BLACKGLASSES => [:KROOKODILE, 0],
    :METALCOAT => [:BRONZONG, 0],
    :SILKSCARF => [:CINCCINO, 0],
    :PIXIEDUST => [:CLEFABLE, 0],
    :FAIRYFEATHER => [:CLEFABLE, 0],
    :BERRYJUICE => [:SHUCKLE, 0],
    :ALLSEEINGTOTEM => [:GOLURK, 2],
    :MENTALWARD => [:GRUMPIG, 1],
    :STURDYHELMET => [:MAROWAK, 0],
    :HEAVYSTONE => [:MUDSDALE, 0],
    :VELVETYROCK => [:SWELLOW, 1],
    :BEETLEBARK => [:HERACROSS, 0],
    :BLACKLOTUS => [:ZOROARK, 0],
    :DRACOSHIELD => [:DURALUDON, 0],
    :FACEMASK => [:CLODSIRE, 0],
    :SPELLBOOKOFWISDOM => [:ORANGURU, 0],
    :CARVEDRAFFLESIA => [:VILEPLUME, 0],
    :SILVERGAUNTLETS => [:LUCARIO, 0],
    :HEATMEDALLION => [:HEATMOR, 0],
    :JOYPENDANT => [:WIGGLYTUFF, 0],
    :BRICKDUMBBELL => [:MACHAMP, 0],
    :SPIRITBURNER => [:MAROWAK, 0, 1],
    :SCALENECKLACE => [:MILOTIC, 0],
    :GROUNDWIRE => [:STUNFISK, 1],
    :GUSTFAN => [:PIDGEOT, 0],
    :EERILYREGULARRING => [:ZOROARK, 0, 1],
    :TUNDRATORC => [:JYNX, 0],
    :SANDSTONESLAB => [:PALOSSAND, 0],
    :ROCKHEAD => [:TYRANTRUM, 2],
    :AEGISTALISMAN => [:KLEFKI, 0],
    :ZENCHARM => [:DARMANITAN, 2],
    :NOXIOUSCHOKER => [:SALAZZLE, 0],
    :TROPICALINCENSE => [:PALMINO, 0],
    :INFERNOINCENSE => [:BOOMINE, 0],
    :AURORAINCENSE => [:LAZU, 0],
    :ABILITYSHIELD => [:COFAGRIGUS, 0],
    :CLEARAMULET => [:CARBINK, 0],
    :MIRRORHERB => [:SMEARGLE, 0],
    :PUNCHINGGLOVE => [:HITMONCHAN, 1],
    :COVERTCLOAK => [:RIBOMBEE, 1],
    :LOADEDDICE => [:CLOYSTER, 1],
    :MATTERAMPLIFIER => [:AMALGARATUS, 0]
  }
  item = pkmn.item
  evolution = evolutions[item.id]
  if evolution
    if scene
      scene.pbDisplay(_INTL("{1} absorbed the {2}!", pkmn.name, item.name))
    else
      pbMessage(_INTL("{1} absorbed the {2}!", pkmn.name, item.name))
    end
    newspecies = evolution[0]
    newspecies = :NIDOQUEEN if newspecies == :NIDOKING && pkmn.gender == 1
    newspecies = :MINUN if newspecies == :PLUSLE && rand(2) == 0
    pkmn.form = evolution[2] if evolution[2]
    pbFadeOutInWithMusic do
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pkmn, newspecies)
      evo.pbEvolution(false)
      evo.pbEndScreen
    end
    pkmn.item = nil
    pkmn.ability_index = evolution[1]
    return true
  elsif item == :EVERSTONE
    if scene
      scene.pbDisplay(_INTL("{1} absorbed the {2}!", pkmn.name, item.name))
    else
      pbMessage(_INTL("{1} absorbed the {2}!", pkmn.name, item.name))
    end
    pkmn.form = 1
    pkmn.item = nil
  end
  return false
end

class AmalgaratusSprite

  def initialize(parent, pokemon, back, viewport)
    @viewport = viewport
    @parent = parent
    @pokemon = nil
    @back = nil
    @item = nil
    @itemSprite = nil
    @layer2Bitmap = nil
    @layer2 = nil
    @disposed = false
    setPokemon(pokemon, back)
  end

  def setPokemon(pokemon, back)
    if pokemon != @pokemon || back != @back || pokemon.item != @item
      @pokemon = pokemon
      @back = back
      @item = pokemon.item
      refresh
    end
  end

  def isAmalgaratus
    return @pokemon.species == :AMALGARATUS
  end

  def refresh
    return if @disposed
    if !isAmalgaratus || !@item
      @parent.setFrameCallback(nil)
      @itemSprite&.dispose
      @layer2&.dispose
      @layer2Bitmap&.dispose
      @itemSprite = nil
      @layer2 = nil
      @layer2Bitmap = nil
      return
    end
    if @item
      if !@itemSprite
        @itemSprite = ItemIconSprite.new(0, 0, @item, @viewport)
        @itemSprite.ox = 24
        @itemSprite.oy = 24
      end
      @itemSprite.item = @item
      if !@layer2
        sp_data = GameData::SpeciesMetrics.get_species_form(:AMALGARATUS, 0, false)
        folder = @back ? "Back" : "Front"
        folder += " shiny" if @pokemon.shiny?
        @layer2Bitmap = DeluxeBitmapWrapper.new(
          sprintf("Graphics/Pokemon/%s/A/AMALGARATUS_layer2", folder),
          sp_data,
          @back
        )
        @layer2Bitmap.compile_strip(@pokemon, @back)
        @layer2 = Sprite.new(@viewport)
        @layer2.bitmap = @layer2Bitmap.bitmap
        @layer2Bitmap.speed = 0
        @layer2Bitmap.deanimate
        @parent.setFrameCallback(lambda { |frame|
          @layer2Bitmap.to_frame(frame)
          @layer2.bitmap = @layer2Bitmap.bitmap
          @layer2.update
        })
      else
        @layer2Bitmap.setPokemon(@pokemon, @back)
        @layer2Bitmap.speed = 0
        @layer2Bitmap.deanimate
      end
    end
    update
  end

  def update
    if @pokemon.item != @item
      @item = @pokemon.item
      refresh
      return
    end
    if @itemSprite
      @itemSprite.visible = @parent.visible
      @itemSprite.opacity = (128 * @parent.opacity / 255).floor
      @itemSprite.tone = @parent.tone
      @itemSprite.color = @parent.color
      @itemSprite.x = @parent.x - @parent.ox + @parent.bitmap.width / 2 + (Math.cos(System.uptime * 3) * 2).round * 2
      @itemSprite.y = @parent.y - @parent.oy + @parent.bitmap.height / 2 - 2 + (Math.sin(System.uptime * 3) * 2).round * 2
      @itemSprite.z = @parent.z + 1
      @itemSprite.zoom_x = @parent.zoom_x * (@back ? 1.5 : 1)
      @itemSprite.zoom_y = @parent.zoom_y * (@back ? 1.5 : 1)
      @itemSprite.update
    end
    if @layer2
      @layer2.visible = @parent.visible
      @layer2.opacity = @parent.opacity
      @layer2.tone = @parent.tone
      @layer2.color = @parent.color
      @layer2.ox = @parent.ox
      @layer2.oy = @parent.oy
      @layer2.x = @parent.x
      @layer2.y = @parent.y
      @layer2.z = @parent.z + 2
      @layer2.zoom_x = @parent.zoom_x
      @layer2.zoom_y = @parent.zoom_y
      @layer2.mirror = @parent.mirror
      @layer2.update
    end
    return isAmalgaratus
  end

  def dispose
    @parent.setFrameCallback(nil)
    @itemSprite&.dispose
    @layer2&.dispose
    @layer2Bitmap&.dispose
    @itemSprite = nil
    @layer2 = nil
    @layer2Bitmap = nil
    @disposed = true
  end

  def color=(value)
    @itemSprite.color = value if @itemSprite
    @layer2.color = value if @layer2
  end

  def tone=(value)
    @itemSprite.tone = value if @itemSprite
    @layer2.tone = value if @layer2
  end

  def visible=(value)
    @itemSprite.visible = value if @itemSprite
    @layer2.visible = value if @layer2
  end

  def opacity=(value)
    @itemSprite.opacity = value if @itemSprite
    @layer2.opacity = value if @layer2
  end

end

class PokemonSprite < Sprite

  alias amalgaratus_clearBitmap clearBitmap
  def clearBitmap
    amalgaratus_clearBitmap
    refreshAmalgaratusItem(nil, false)
  end

  alias amalgaratus_setPokemonBitmap setPokemonBitmap
  def setPokemonBitmap(pokemon, back = false)
    amalgaratus_setPokemonBitmap(pokemon, back)
    refreshAmalgaratusItem(pokemon, back)
  end

  alias amalgaratus_setPokemonBitmapSpecies setPokemonBitmapSpecies
  def setPokemonBitmapSpecies(pokemon, species, back = false)
    amalgaratus_setPokemonBitmapSpecies(pokemon, species, back)
    refreshAmalgaratusItem(pokemon, back)
  end

  alias amalgaratus_setSpeciesBitmap setSpeciesBitmap
  def setSpeciesBitmap(species, gender = 0, form = 0, shiny = false, shadow = false, back = false, egg = false)
    amalgaratus_setSpeciesBitmap(species, gender, form, shiny, shadow, back, egg)
    refreshAmalgaratusItem(nil, back)
  end

  alias amalgaratus_update update
  def update
    amalgaratus_update
    @amalgaratusItem&.update
  end

  alias amalgaratus_dispose dispose
  def dispose
    @amalgaratusItem&.dispose
    amalgaratus_dispose
  end

  def refreshAmalgaratusItem(pokemon, back)
    if pokemon && pokemon.species == :AMALGARATUS
      if @amalgaratusItem
        @amalgaratusItem.setPokemon(pokemon, back)
      else
        @amalgaratusItem = AmalgaratusSprite.new(self, pokemon, back, viewport)
      end
    elsif @amalgaratusItem
      @amalgaratusItem.dispose
      @amalgaratusItem = nil
    end
  end
end

class Battle::Scene::BattlerSprite < RPG::Sprite

  def refreshAmalgaratusItem(pokemon, back)
    if pokemon && pokemon.species == :AMALGARATUS
      if @amalgaratusItem
        @amalgaratusItem.setPokemon(pokemon, back)
      else
        @amalgaratusItem = AmalgaratusSprite.new(self, pokemon, back, viewport)
      end
    elsif @amalgaratusItem
      @amalgaratusItem.dispose
      @amalgaratusItem = nil
    end
  end

end

class Battle::Battler

  def amplifyItem?
    return hasActiveAbility?(:AMPLIFY) || hasActiveItem?(:MATTERAMPLIFIER)
  end

end