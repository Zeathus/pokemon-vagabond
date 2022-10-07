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
      return [10,20,30,40,50][@level]
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

  def rewards
      return [
          "Fishing Rod",
          "Level 2",
          "Level 3",
          "Level 4",
          "Level 5"
      ]
  end

  def progress_text
      if @level == 5
          return _INTL("Hooked {1} Kinds of Pokémon",
              self.progress)
      end
      return _INTL("Hooked {1} / {2} Kinds of Pokémon",
          self.progress, self.requirement)
  end

  def requirement
      return [10, 20, 30, 40, 50][@level]
  end

  def progress
      return @dummy.length
  end

  def register(fish)
      if !@dummy.include?(fish)
          @dummy.push(fish)
      end
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
      @frames = []
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
      return ""
  end

  def requirement
      return 1
  end

  def progress
      return 0
  end

end