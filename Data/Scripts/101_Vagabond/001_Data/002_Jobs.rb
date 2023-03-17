def pbJobClass(name)
  return {
      "G.P.O." => JobGPO,
      "Professor" => JobProfessor,
      "Doctor" => JobDoctor,
      "Crafter" => JobCrafter,
      "Breeder" => JobBreeder,
      "Ranger" => JobRanger,
      "Fisher" => JobFisher,
      "Botanist" => JobBotanist,
      "Miner" => JobMiner,
      "Ruin Maniac" => JobRuinManiac,
      "Engineer" => JobEngineer
  }[name]
end

def pbAllJobs
  return [
      "G.P.O.",
      "Botanist",
      "Miner",
      "Fisher",
      "Crafter",
      "Engineer",
      "Ruin Maniac",
      "Ranger",
      "Doctor",
      "Professor",
      "Breeder"
  ]
end

def pbJob(name)
  if !$game_variables[JOBS].is_a?(Hash)
    $game_variables[JOBS] = {}
  end
  if !$game_variables[JOBS].key?(name)
    $game_variables[JOBS][name] = pbJobClass(name).new
  end
  return $game_variables[JOBS][name]
end

def pbJobs
  if !$game_variables[JOBS].is_a?(Hash)
    $game_variables[JOBS] = {}
  end
  return $game_variables[JOBS].values
end

def pbHasJob(job)
  if !$game_variables[JOBS].is_a?(Hash)
    $game_variables[JOBS] = {}
  end
  if $game_variables[JOBS].key?(job)
    return (pbJob(job).level > 0)
  end
  return false
end

class Job

  attr_reader :name
  attr_reader :teacher
  attr_reader :teacher_title
  attr_reader :card_file
  attr_accessor :level
  attr_accessor :counter
  attr_accessor :dummy

  def initialize(name, teacher, card_file, teacher_title="Teacher")
      @name = name
      @teacher = teacher
      @teacher_title = teacher_title
      @card_file = card_file
      @level = 0
      @counter = 0
      @dummy = 0
  end

  def quests
      return [
          nil,
          nil,
          nil,
          nil,
          nil
      ]
  end

  def rewards
      return [
          "Level 1",
          "Level 2",
          "Level 3",
          "Level 4",
          "Level 5"
      ]
  end

  def location
    return "???"
  end

  def progress_text
      return ""
  end

  def requirement
      return 1
  end

  def progress
      return 0
  end

  def update
      if @level < 5 && self.progress >= self.requirement
          q = self.quests[@level]
          if q && $quests[q].unavailable?
              $quests[q].unlock
          end
      end
  end

  def to_s
      return _INTL("{1} Lv. {2}", @name, @level)
  end
end

class JobGPO < Job

  def initialize
      super("G.P.O.", "Amethyst", "job_gpo", "Boss")
  end

  def quests
      return [
          nil,
          nil,
          nil,
          nil,
          nil
      ]
  end

  def location
    return "G.P.O. HQ"
  end

  def rewards
      return [
          "Rookie Tasks",
          "Intermediate Tasks",
          "Advanced Tasks",
          "Expert Tasks",
          "Master Tasks"
      ]
  end

  def progress_text
      return _INTL("Completed {1} / {2} {3}", self.progress, self.requirement, self.rewards[self.level - 1])
  end

  def requirement
      return 4
  end

  def progress
      return 0
  end

end

class JobBotanist < Job

  def initialize
      super("Botanist", "Faunus", "job_botanist")
      @dummy = []
  end

  def quests
      return [
          :BERRYIMPORTANT,
          nil,
          nil,
          nil,
          nil
      ]
  end

  def location
    return "Breccia City"
  end

  def rewards
      return [
          "Directional Harvest",
          "+1 Berry per Harvest",
          "Directional Harvest 2",
          "+1 Berry per Harvest",
          "Random Berry per Harvest"
      ]
  end

  def progress_text
      if @level == 5
          return _INTL("Harvested {1} Kinds of Berries",
              self.progress)
      end
      return _INTL("Harvested {1} / {2} Kinds of Berries",
          self.progress, self.requirement)
  end

  def requirement
      return [0,16,24,32,48][@level]
  end

  def progress
      return @dummy.length
  end

  def register(berry)
      if !@dummy.include?(berry)
          @dummy.push(berry)
          self.update
      end
  end

end

class JobMiner < Job

  def initialize
      super("Miner", "Alister", "job_miner", "Supervisor")
  end

  def quests
      return [
          :DIGGYDIGGYHOLE,
          nil,
          nil,
          nil,
          nil
      ]
  end

  def location
    return "Pegma Quarry"
  end

  def rewards
      return [
          "Level 1",
          "Level 2",
          "Level 3",
          "Level 4",
          "Level 5"
      ]
  end

  def progress_text
      return ""
  end

  def requirement
      return 1
  end

  def progress
      return 0
  end

end

class JobDoctor < Job

  def initialize
      super("Doctor", "???", "job_doctor")
  end

  def quests
      return [
          nil,
          nil,
          nil,
          nil,
          nil
      ]
  end

  def location
    return "???"
  end

  def rewards
      return [
          "Level 1",
          "Level 2",
          "Level 3",
          "Level 4",
          "Level 5"
      ]
  end

  def progress_text
      return ""
  end

  def requirement
      return 1
  end

  def progress
      return 0
  end

end

class JobCrafter < Job

  def initialize
      super("Crafter", "???", "job_crafter")
  end

  def quests
      return [
          nil,
          nil,
          nil,
          nil,
          nil
      ]
  end

  def location
    return "???"
  end

  def rewards
      return [
          "Level 1",
          "Level 2",
          "Level 3",
          "Level 4",
          "Level 5"
      ]
  end

  def progress_text
      return ""
  end

  def requirement
      return 1
  end

  def progress
      return 0
  end

end

class JobProfessor < Job

  def initialize
      super("Professor", "Zeathus", "job_professor")
  end

  def quests
      return [
          nil,
          nil,
          nil,
          nil,
          nil
      ]
  end

  def location
    return "G.P.O. HQ"
  end

  def rewards
      return [
          "Level 1",
          "Level 2",
          "Level 3",
          "Level 4",
          "Level 5"
      ]
  end

  def progress_text
      return ""
  end

  def requirement
      return 1
  end

  def progress
      return 0
  end

end

class JobRanger < Job

  def initialize
      super("Ranger", "???", "job_ranger")
  end

  def quests
      return [
          nil,
          nil,
          nil,
          nil,
          nil
      ]
  end

  def location
    return "???"
  end

  def rewards
      return [
          "Level 1",
          "Level 2",
          "Level 3",
          "Level 4",
          "Level 5"
      ]
  end

  def progress_text
      return ""
  end

  def requirement
      return 1
  end

  def progress
      return 0
  end

end

class JobBreeder < Job

  def initialize
      super("Breeder", "???", "job_breeder")
  end

  def quests
      return [
          nil,
          nil,
          nil,
          nil,
          nil
      ]
  end

  def location
    return "???"
  end

  def rewards
      return [
          "Level 1",
          "Level 2",
          "Level 3",
          "Level 4",
          "Level 5"
      ]
  end

  def progress_text
      return ""
  end

  def requirement
      return 1
  end

  def progress
      return 0
  end

end

class JobFisher < Job

  def initialize
      super("Fisher", "Ivan", "job_fisher")
      @dummy = []
  end

  def quests
      return [
          nil,
          nil,
          nil,
          nil,
          nil
      ]
  end

  def location
    return "Lazuli River"
  end

  def rewards
      return [
          "Fishing Rod",
          "Powerful Hookset",
          "Quick Move",
          "Fish Eyes",
          "???"
      ]
  end

  def progress_text
    case @level
    when 1
      return _INTL("Hook Seaking & Poliwhirl ({1} / {2})", self.progress, self.requirement)
    when 2
      return _INTL("Gyarados, Dragonair, Whiscash ({1} / {2})", self.progress, self.requirement)
    when 3
      return _INTL("Hook Wailord, Milotic, Walrein ({1} / {2})", self.progress, self.requirement)
    when 4
      return _INTL("Hook the Master of the Sea")
    when 5
      return _INTL("Hooked {1} / {2} Species of Pokémon", self.progress, self.requirement)
    end
  end

  def requirement
    case @level
    when 1
        return 2
    when 2
        return 3
    when 3
        return 3
    when 4
        return 1
    when 5
        return pbFishStats.length
    end
    return 0
  end

  def progress
    total = 0
    case @level
    when 1
        total += 1 if hooked?(:SEAKING)
        total += 1 if hooked?(:POLIWHIRL)
    when 2
        total += 1 if hooked?(:GYARADOS)
        total += 1 if hooked?(:DRAGONAIR)
        total += 1 if hooked?(:WHISCASH)
    when 3
        total += 1 if hooked?(:WAILORD)
        total += 1 if hooked?(:MILOTIC)
        total += 1 if hooked?(:WALREIN)
    when 4
        total += 1 if hooked?(:MANAPHY)
    when 5
        total = @dummy.length
    end
    return total
  end

  def register(fish)
      if !@dummy.include?(fish)
          @dummy.push(fish)
      end
  end

  def hooked?(fish)
    return @dummy.include?(fish)
  end

end

class JobRuinManiac < Job

  def initialize
      super("Ruin Maniac", "Asako", "job_ruin_maniac")
  end

  def quests
      return [
          nil,
          nil,
          nil,
          nil,
          nil
      ]
  end

  def location
    return "???"
  end

  def rewards
      return [
          "Level 1",
          "Level 2",
          "Level 3",
          "Level 4",
          "Level 5"
      ]
  end

  def progress_text
      return ""
  end

  def requirement
      return 1
  end

  def progress
      return 0
  end

end

class JobEngineer < Job

  def initialize
      super("Engineer", "Leroy", "job_engineer")
      @dummy = []
      @frames = [PBFrame::Null]
  end

  def quests
      return [
          :NULLPOINTEREXCEPTION,
          nil,
          nil,
          nil,
          nil
      ]
  end

  def location
    return "G.P.O. HQ"
  end

  def rewards
      return [
          "Custom Pokémon",
          @level < 2 ? "New Frame" : _INTL("{1} Frame", @dummy[0]),
          @level < 3 ? "New Frame + More" : _INTL("{1} Frame + More", @dummy[1]),
          @level < 4 ? "New Frame + More" : _INTL("{1} Frame + More", @dummy[2]),
          @level < 5 ? "New Frame + More" : "RKS Frame + More",
      ]
  end

  def progress_text
      return _INTL("Found {1} / {2} Data Chips", self.progress, self.requirement)
  end

  def requirement
    return [0, 16, 32, 64, 96, 128][@level]
  end

  def progress
    count = $bag.quantity(:DATACHIP)
    pbAllDataChipMoves.each do |m|
      count += m[1] if pbHasDataChipMove(m[0])
    end
    return count
  end

  def frames
    return @frames
  end

end