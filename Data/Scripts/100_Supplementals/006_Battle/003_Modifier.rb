class EncounterModifiers
  attr_accessor(:iv)
  attr_accessor(:ev)
  attr_accessor(:item)
  attr_accessor(:hp)
  attr_accessor(:name)
  attr_accessor(:status)
  attr_accessor(:moves)
  attr_accessor(:ability)
  attr_accessor(:nature)
  attr_accessor(:gender)
  attr_accessor(:shiny)
  attr_accessor(:hpmult)
  attr_accessor(:form)
  attr_accessor(:species)

  def initialize()
    @iv      = nil
    @ev      = nil
    @item    = nil
    @hp      = nil
    @name    = nil
    @status  = nil
    @moves   = nil
    @ability = nil
    @nature  = nil
    @gender  = nil
    @shiny   = nil
    @hpmult  = nil
    @form    = nil
    @species = nil
    @next    = nil
  end

  def moves=(value)
    @moves=value
  end

  def status=(value)
    @status = value
  end

  def nature=(value)
    @nature = value
  end

  def item=(value)
    @item = value
  end

  def next
    @next = EncounterModifiers.new if !@next
    return @next
  end

  def optimize
    @iv      = [31,31,31,31,31,31]
    @nature  = :SERIOUS
  end
end

class Pokemon
  def modify
    if $game_variables[Supplementals::WILD_MODIFIER] && $game_variables[Supplementals::WILD_MODIFIER] != 0
      mod = $game_variables[Supplementals::WILD_MODIFIER]
      if mod.moves # Custom Moves
        @moves[0] = PBMove.new(mod.moves[0])
        @moves[1] = PBMove.new(mod.moves[1])
        @moves[2] = PBMove.new(mod.moves[2])
        @moves[3] = PBMove.new(mod.moves[3])
      end
      if mod.iv
        for i in 0..5
          @iv[i] = mod.iv[i]
          if @oiv && @oiv[i]
            @oiv[i] = mod.iv[i]
          end
        end
      end
      if mod.ev
        for i in 0..5
          @ev[i] = mod.ev[i]
        end
      end
      @name = mod.name if mod.name
      @ability_index = mod.ability if mod.ability
      @gender = mod.gender if mod.gender
      @item = mod.item if mod.item
      @natureflag = mod.nature if mod.nature
      @shinyflag = mod.shiny if mod.shiny
      @status = mod.status if mod.status
      calc_stats
      @hp = @totalhp
      @hp = mod.hp if mod.hp
      $game_variables[Supplementals::WILD_MODIFIER] = 0
    end
  end
end

def pbModifier
  if $game_variables[Supplementals::WILD_MODIFIER] == 0
    $game_variables[Supplementals::WILD_MODIFIER] = EncounterModifiers.new()
  end
  return $game_variables[Supplementals::WILD_MODIFIER]
end

def pbWildModify(pokemon)
  mod = $game_variables[Supplementals::WILD_MODIFIER]

  pokemon.name = mod.name if mod.name
  pokemon.ability = mod.ability if mod.ability
  pokemon.gender = mod.gender if mod.gender
  pokemon.item = mod.item if mod.item
  pokemon.nature = mod.nature if mod.nature
  pokemon.shiny = mod.shiny if mod.shiny
  pokemon.status = mod.status if mod.status
  pokemon.iv = pbStatArrayToHash(mod.iv) if mod.iv
  pokemon.ev = pbStatArrayToHash(mod.ev) if mod.ev
  if mod.moves
    pokemon.moves = []
    mod.moves.each do |m|
      pokemon.moves.push(Pokemon::Move.new(m))
    end
  end
  if mod.form
    pokemon.form = mod.form
  end
  pokemon.calc_stats
  pokemon.hp = pokemon.totalhp * mod.hpmult if mod.hpmult
  pokemon.hp = mod.hp if mod.hp

  $game_variables[Supplementals::WILD_MODIFIER] = (mod.next || 0)
end