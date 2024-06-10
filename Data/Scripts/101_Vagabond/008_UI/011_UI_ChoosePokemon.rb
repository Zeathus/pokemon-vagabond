class ChoosePokemonSprite < IconSprite

  def initialize(size, viewport)
      super(viewport)
      @pokemon = nil
      @size = size
      @hp = @pokemon ? @pokemon.hp : 0
      @totalhp = @pokemon ? @pokemon.totalhp : 1
      @selected = false
      self.setBitmap("Graphics/UI/Party/choose_pokemon")
      if @size == 1
          self.src_rect = Rect.new(0, 0, 232, 64)
      elsif @size == 0
          self.src_rect = Rect.new(232, 0, 128, 64)
      end
      @icon = PokemonIconSprite.new(nil, viewport)
      @overlay = Sprite.new(viewport)
      @overlay.bitmap = Bitmap.new(self.src_rect.width, self.src_rect.height)
      @icon.z = 3
      pbSetSmallFont(@overlay.bitmap)
  end

  def x=(value)
      super(value)
      @icon.x = value + 8
      @overlay.x = value
  end

  def y=(value)
      super(value)
      @icon.y = value - 6
      @overlay.y = value
  end

  def selected=(value)
      @selected = value
  end

  def update
      super
      if @pokemon
          if @hp != @pokemon.hp || @totalhp != @pokemon.totalhp
              @hp = @pokemon.hp
              @totalhp = @pokemon.totalhp
              self.refresh
          end
      end
      @icon.update if @selected
  end

  def refresh
      @overlay.bitmap.clear
      return if @size == 0

      pbDrawTextPositions(@overlay.bitmap,[[
          @pokemon.name, 74, 12, 0, Color.new(252, 252, 252), Color.new(0, 0, 0)
      ]])
      bar_width = 78
      hpzone=0
      hpzone=1 if @hp<=(@totalhp/2).floor
      hpzone=2 if @hp<=(@totalhp/4).floor
      hpcolors=[
      Color.new(14,152,22),Color.new(24,192,32),   # Green
      Color.new(202,138,0),Color.new(232,168,0),   # Orange
      Color.new(218,42,36),Color.new(248,72,56)    # Red
      ]
      bar_len = 78
      for i in 0...4
      color_index = [0,1,1,0][i]
      @overlay.bitmap.fill_rect(106, 40+i*2, [(@hp*1.0*bar_len/@totalhp/2).ceil*2,bar_len-i*2].min, 2, hpcolors[hpzone*2 + color_index])
      end
  end

  def pokemon=(value)
      @pokemon = value
      @icon.pokemon = value
      @hp = @pokemon ? @pokemon.hp : 0
      @totalhp = @pokemon ? @pokemon.totalhp : 1
      self.refresh
  end

  def visible=(value)
      super(value)
      @icon.visible = value
      @overlay.visible = value
  end

  def color=(value)
      super(value)
      @icon.color = value
      @overlay.color = value
  end

  def opacity=(value)
      super(value)
      @icon.opacity = value
      @overlay.opacity = value
  end

  def dispose
      super
      @icon.dispose
      @overlay.dispose
  end

end

class ChooseMemberSprite < IconSprite

  def initialize(size, viewport)
      super(viewport)
      @member = 0
      @size = size
      self.setBitmap("Graphics/UI/Party/choose_member")
      if @size == 1
          self.src_rect = Rect.new(0, 0, 232, 64)
      elsif @size == 0
          self.src_rect = Rect.new(232, 0, 128, 64)
      end
      @icon = IconSprite.new(0, 0, viewport)
      @overlay = Sprite.new(viewport)
      @overlay.bitmap = Bitmap.new(self.src_rect.width, self.src_rect.height)
      pbSetSystemFont(@overlay.bitmap)
  end

  def x=(value)
      super(value)
      @icon.x = value + 40
      @overlay.x = value
  end

  def y=(value)
      super(value)
      @icon.y = value + 56
      @overlay.y = value
  end

  def member=(value)
      @member = value
      type=PBParty.getTrainerType([@member, 0].max)
      @icon.setBitmap(sprintf("Graphics/Characters/trainer_%s",type.to_s))
      @icon.src_rect = Rect.new(0, 0, @icon.bitmap.width / 4, @icon.bitmap.height / 4)
      @icon.oy = @icon.bitmap.height / 4
      @icon.ox = @icon.bitmap.width / 8
      @overlay.bitmap.clear
      if @size == 1
          pbDrawTextPositions(@overlay.bitmap,[[
              PBParty.getName(@member), 70, 14, 0, Color.new(252, 252, 252), Color.new(0, 0, 0), true
          ]])
          self.src_rect = Rect.new(0, [64 * value,0].max, 232, 64)
      elsif @size == 0
          self.src_rect = Rect.new(232, [64 * value,0].max, 128, 64)
      end
      if @member == -1
          @icon.tone = Tone.new(-60, -60, -60, 120)
          self.tone = Tone.new(-60, -60, -60, 120)
      else
          @icon.tone = Tone.new(0, 0, 0, 0)
          self.tone = Tone.new(0, 0, 0, 0)
      end
  end

  def visible=(value)
      super(value)
      @icon.visible = value
      @overlay.visible = value
  end

  def color=(value)
      super(value)
      @icon.color = value
      @overlay.color = value
  end

  def opacity=(value)
      super(value)
      @icon.opacity = value
      @overlay.opacity = value
  end

  def dispose
      super
      @icon.dispose
      @overlay.dispose
  end

end

class ChoosePokemonScreen

  def initialize(mode, z = nil)
      @mode = mode
      @member = 0
      @index = 0
      @z = z || 99990
      has_members = []
      has_members.append(0)
      has_members.append(-1) if ![2, 3].include?(@mode)
      if ![1, 2].include?(@mode)
          for i in 1...PBParty.len
              if hasPartyMember(i)
                  has_members.push(i)
              end
          end
      end
      @members = []
      for m in has_members
          @members.push(m) if getPartyPokemon(m).length > 0 
      end
  end

  def refreshCursor
      @sprites["cursor"].y = 196 + 68 * @index
      for y in 0...3
          @sprites[_INTL("pokemon_1_{1}", y)].selected = (@index == y)
      end
  end

  def refresh
      for x in 0...3
          member_index = (@member-1+x) % @members.length
          member_id = @members[member_index]
          party = getPartyPokemon(member_id)
          member = @sprites[_INTL("member_{1}", x)]
          if (x % 2 == 0 && @members.length == 1)
              member.visible = false
              for y in 0...3
                  @sprites[_INTL("pokemon_{1}_{2}", x, y)].visible = false
              end
          else
              member.visible = true
              member.member = member_id
              for y in 0...3
                  pokemon = @sprites[_INTL("pokemon_{1}_{2}", x, y)]
                  if y <= party.length - 1
                      pokemon.visible = true
                      pokemon.pokemon = party[y]
                  else
                      pokemon.visible = false
                  end
              end
          end
      end
      self.refreshCursor
  end

  def pbStartScreen
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = @z

      @sprites = {}

      @sprites["bg"] = Sprite.new(@viewport)
      @sprites["bg"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
      #@sprites["bg"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0, 128))

      x_pos = [178, 268, 462]
      y_pos = 130
      for x in 0...3
          member = ChooseMemberSprite.new(x % 2, @viewport)
          member.x = x_pos[x]
          member.y = y_pos
          @sprites[_INTL("member_{1}", x)] = member
          for y in 0...3
              pokemon = ChoosePokemonSprite.new(x % 2, @viewport)
              pokemon.x = x_pos[x]
              pokemon.y = y_pos + 68 * (y+1)
              @sprites[_INTL("pokemon_{1}_{2}", x, y)] = pokemon
          end
      end

      @sprites["cursor"] = IconSprite.new(x_pos[1] - 2, y_pos + 66, @viewport)
      @sprites["cursor"].setBitmap("Graphics/UI/Party/choose_cursor")
      @sprites["cursor"].z = 1

      self.refresh
      pbFadeInAndShow(@sprites)
  end

  def pbEndScreen
      pbFadeOutAndHide(@sprites)
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
  end

  def pbChoosePokemon
      loop do
          Graphics.update
          Input.update
          @viewport.update
          pbUpdateSpriteHash(@sprites)
          if @members.length > 1
              if Input.repeat?(Input::RIGHT)
                  @member = (@member + 1) % @members.length
                  @index = [@index, getPartyPokemon(@members[@member]).length-1].min
                  self.refresh
              end
              if Input.repeat?(Input::LEFT)
                  @member = (@member - 1) % @members.length
                  @index = [@index, getPartyPokemon(@members[@member]).length-1].min
                  self.refresh
              end
          end
          if Input.repeat?(Input::UP)
              @index = (@index - 1) % getPartyPokemon(@members[@member]).length
              self.refreshCursor
          end
          if Input.repeat?(Input::DOWN)
              @index = (@index + 1) % getPartyPokemon(@members[@member]).length
              self.refreshCursor
          end
          if Input.trigger?(Input::USE)
              return [@members[@member], @index]
          elsif Input.trigger?(Input::BACK)
              return nil
          end
      end
  end

end

# Modes:
# 0 = Any Pokemon
# 1 = Player Only (including Inactive Party)
# 2 = Active Player Only
# 3 = Any Active Pokemon
# Returns:
# - List: [<Member ID>, <Pkmn Index>]
def pbChoosePokemonScreen(mode=0,z=nil)
  screen = ChoosePokemonScreen.new(mode, z)
  screen.pbStartScreen
  choice = nil
  if block_given?
      loop do
          choice = screen.pbChoosePokemon
          choice = [nil, nil] if !choice
          break if yield choice[0], choice[1]
      end
  else
      choice = screen.pbChoosePokemon
  end
  choice = nil if choice.is_a?(Array) && !choice[0] && !choice[1]
  screen.pbEndScreen
  return choice
end

def pbDeliverPokemon(species)
  removed = false
  pbChoosePokemonScreen(1) { |member, pkmn|
      if !member && !pkmn
          true
      elsif member == PBParty::Player && $player.party.length <= 1
          pbMessage("You can't deliver your last active Pokémon.")
          false
      else
          pokemon = getPartyPokemon(member)[pkmn]
          if pokemon.species == species
              if pbMessage(_INTL("Do you want to give away {1}?", pokemon.name), ["Yes", "No"], 2) == 0
                  removed = pokemon
                  getPartyPokemon(member).delete_at(pkmn)
                  true
              end
          else
              pbMessage(_INTL("{1} does not meet the recipient's requirements.", pokemon.name))
              false
          end
      end
  }
  return removed
end