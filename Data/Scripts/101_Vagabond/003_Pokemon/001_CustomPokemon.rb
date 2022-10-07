module PBChip
  None    = 0
  Attack  = 1
  Defense = 2
  SpAtk   = 3
  SpDef   = 4
  Speed   = 5
  Bulk    = 6
  Mind    = 7
  Claw    = 8
  Light   = 9
  Heavy   = 10
  Weak    = 11
  Frail   = 12
  Numb    = 13
  Dull    = 14
  Lag     = 15
  Round   = 16
  Potato  = 17

  def PBChip.len
      return 18
  end

  def PBChip.getName(id)
      id = getID(PBChip, id) if id.is_a?(Symbol)
      return [
          "None",
          "Atk",
          "Def",
          "Sp.Atk",
          "Sp.Def",
          "Speed",
          "Bulk",
          "Mind",
          "Claw",
          "Light",
          "Heavy",
          "Weak",
          "Frail",
          "Numb",
          "Dull",
          "Lag",
          "Round",
          "Potato"
      ][id]
  end

  def PBChip.getType(id)
      id = getID(PBChip, id) if id.is_a?(Symbol)
      if id == 0
          return -1 # No Chip
      elsif id <= 5
          return 0  # Normal Chip
      elsif id <= 10
          return 1  # Trade-Off Chip
      elsif id <= 15
          return 2  # Negative Chip
      elsif id == 16
          return 3  # Rounded Chip
      elsif id == 17
          return 4  # Potato Chip
      end
  end

  def PBChip.getMods(id)
      id = getID(PBChip, id) if id.is_a?(Symbol)
      return [
          [  0,   0,   0,   0,   0,   0], # None
          [  0,  10,   0,   0,   0,   0], # Attack
          [  0,   0,  10,   0,   0,   0], # Defense
          [  0,   0,   0,   0,  10,   0], # SpAtk
          [  0,   0,   0,   0,   0,  10], # SpDef
          [  0,   0,   0,  10,   0,   0], # Speed
          [  0,  20,  20,   0, -20, -20], # Bulk
          [  0, -20, -20,   0,  20,  20], # Mind
          [  0,  20, -20,   0,  20, -20], # Claw
          [  0,   0, -20,  35,   0, -20], # Light
          [  0,   0,  10, -20,   0,  10], # Heavy
          [  0, -50,   0,   0,   0,   0], # Weak
          [  0,   0, -50,   0,   0,   0], # Frail
          [  0,   0,   0,   0, -50,   0], # Numb
          [  0,   0,   0,   0,   0, -50], # Dull
          [  0,   0,   0, -50,   0,   0], # Lag
          [  0,   5,   5,   5,   5,   5], # Rounded
          [  0, -20, -20, -20, -20, -20], # Potato
      ][id]
  end

  def PBChip.getAdjective(id)
      id = getID(PBChip, id) if id.is_a?(Symbol)
      return [
          "",
          "Aggro",
          "Armor",
          "Smart",
          "Keen",
          "Agile",
          "Bulky",
          "Mindful",
          "Brutal",
          "Swift",
          "Massive",
          "Weak",
          "Frail",
          "Numb",
          "Dull",
          "Laggy",
          "Round",
          "Potato"
      ][id]
  end
end

module PBFrame
  Null    = 0
  Slim    = 1
  Tank    = 2
  Sharp   = 3
  RKS     = 4

  def PBFrame.len
      return 5
  end

  def PBFrame.getName(id)
      id = getID(PBFrame, id) if id.is_a?(Symbol)
      return [
          "Null",
          "Slim",
          "Tank",
          "Sharp",
          "RKS"
      ][id]
  end

  def PBFrame.getMods(id)
      id = getID(PBFrame, id) if id.is_a?(Symbol)
      return [
          [  0,   0,   0,   0,   0,   0], # Null
          [  0, -15, -15,  35, -15, -15], # Slim
          [  0, -15,  15, -15, -15,  15], # Tank
          [  0,  15, -15, -15,  15, -15], # Sharp
          [  0,  -5,  -5,  -5,  -5,  -5]
      ][id]
  end

  def PBFrame.getCategory(id)
      id = getID(PBFrame, id) if id.is_a?(Symbol)
      return [
          "Variable",
          "Booster",
          "Ironclad",
          "Bruiser",
          "Godlike"
      ][id]
  end

  def PBFrame.getHeight(id)
      id = getID(PBFrame, id) if id.is_a?(Symbol)
      return [
          23,
          19,
          25,
          21,
          24
      ][id]
  end

  def PBFrame.getWeight(id)
      id = getID(PBFrame, id) if id.is_a?(Symbol)
      return [
          1005,
          405,
          2205,
          865,
          1205
      ][id]
  end
end


class CustomPokemon

  attr_accessor :name
  attr_accessor :type
  attr_accessor :affinity
  attr_accessor :ability
  attr_accessor :frame
  attr_accessor :chips

  def initialize
      @name = "Silvally"
      @type = :NORMAL
      @affinity = :NORMAL
      @ability = :MAINFRAME
      @frame = PBFrame::Null
      @chips = [PBChip::None, PBChip::None, PBChip::None]
  end

  def max_chips
      return 2 if $DEBUG || pbJob("Engineer").level == 3
      return 1
  end

  def available_chip_types
      return [0, 1, 2, 3, 4] if $DEBUG
      ret = [0, 3]
      ret.push(2, 4) if pbJob("Engineer").level >= 3
      ret.push(1) if pbJob("Engineer").level >= 4
      return ret
  end

  def available_frames
      return (0...PBFrame.len).to_a if $DEBUG
      ret = [PBFrame::Null]
      ret += pbJob("Engineer").frames
      return ret
  end

  def base_stats
      stats = [95] + [90] * 5
      frame_mods = PBFrame.getMods(@frame)
      chip_mods = self.total_chip_mods
      for i in 0...6
          stats[i] += frame_mods[i]
          stats[i] += chip_mods[i]
          stats[i] = 1 if stats[i] < 1
      end
      return {
          :HP => stats[0],
          :ATTACK => stats[1],
          :DEFENSE => stats[2],
          :SPEED => stats[3],
          :SPECIAL_ATTACK => stats[4],
          :SPECIAL_DEFENSE => stats[5]
      }
  end

  def total_chip_mods
      stats = [0, 0, 0, 0, 0, 0]
      for chip in @chips
          chip_mods = PBChip.getMods(chip)
          for i in 0...6
              stats[i] += chip_mods[i]
          end
      end
      if @frame == PBFrame::RKS
          for i in 0...6
              stats[i] *= 2
          end
      end
      return stats
  end

  def total_chips
      ret = 0
      for i in @chips
          ret += 1 if i != PBChip::None
      end
      return ret
  end

  def form
      return GameData::Type.get(@type).id_number + @frame * 19
  end

  def category
      ret = ""
      for chip in @chips
          if chip != PBChip::None
              adjective = PBChip.getAdjective(chip)
              ret += adjective
              ret += " "
              break
          end
      end
      ret += PBFrame.getCategory(@frame)
      return ret
  end

  def height
      return PBFrame.getHeight(@frame)
  end

  def weight
      return PBFrame.getWeight(@frame)
  end

  def update
      for i in $player.party
          self.updateSingle(i)
      end
      for i in $player.inactive_party
          self.updateSingle(i)
      end
      for box in $PokemonStorage.boxes
          box.each { |i|
              self.updateSingle(i) if i
          }
      end
  end

  def updateSingle(pkmn)
      return if pkmn.species != :SILVALLY
      pkmn.form = self.form
      pkmn.calc_stats
  end
end

def pbCustomPokemon
  return CustomPokemon.new if !$game_variables
  if $game_variables[CUSTOM_POKEMON].is_a?(Numeric)
      $game_variables[CUSTOM_POKEMON] = CustomPokemon.new
  end
  return $game_variables[CUSTOM_POKEMON]
end