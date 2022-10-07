class QuestList
  attr_accessor :enabled

  def initialize
    @enabled = false
    @quests = {}
  end

  def [](quest_id)
    if !@quests[quest_id]
      @quests[quest_id] = QuestState.new(quest_id)
    end
    return @quests[quest_id]
  end

  def do_unlocks
    unlocked = 0
    self.each { |quest|
      if quest.unlock? && quest.status == -1
        quest.status = 0
        unlocked += 1
      end
    }
    pbDisplayQuestAvailable(unlocked) if unlocked > 0
  end

  def do_auto_finishes
    self.each { |quest|
      if quest.auto_finish?
        quest.finish
      end
    }
  end

  def enabled?
    return @enabled
  end

  def enabled=(value)
    @enabled = value
    self.update
  end

  def update
    return if !self.enabled?
    self.do_unlocks
    self.do_auto_finishes
  end

  def keys
    ret = []
    GameData::Quest.each { |key| ret.push(key.id) }
    return ret
  end

  def each
    GameData::Quest.each { |key| yield self[key.id] }
  end
end

EventHandlers.add(:on_step_taken, :grass_rustling,
  proc { |event|
    next if event != $game_player
    $quests.update
  }
)

module GameData
  class Quest
    attr_reader(:id)            # ID used for the display order
    attr_reader(:id_number)     # ID used for the display order
    attr_reader(:name)          # The name of the quest
    attr_reader(:type)          # Decices what quest marker to show
    attr_reader(:description)   # The description of the quest
    attr_reader(:steps)         # Array of steps required to complete the quest
    attr_reader(:done)          # Text to display when a quest is complete
    attr_reader(:location)      # The location of the quest
    attr_reader(:full_location) # The location as used when appended to "can be found..."
    attr_reader(:money)         # Money rewarded by the quest
    attr_reader(:exp)           # Exp reward multiplier, is divided by 100
    attr_reader(:items)         # Item rewarded by the quest
    attr_reader(:hide_items)    # Show item as unknown
    attr_reader(:hide_name)     # If the quest name and area is shown or not
    attr_reader(:require_maps)  # IDs of required maps to be visited for unlock
    attr_reader(:require_quests)# IDs for finished quests for unlock
    attr_reader(:require)       # Condition required for unlock
    attr_reader(:auto_finish)   # Condition to automatically finish the quest
    attr_reader(:map_guides)    # Display where to go on the map
    attr_reader(:show_available)# Whether to show the quest in the list as soon as it's available

    DATA = {}
    DATA_FILENAME = "quests.dat"
    MAX_STEPS = 50

    extend ClassMethods
    include InstanceMethods

    def self.schema
      ret = {
        "InternalName"  => [0, "n"],
        "Name"          => [0, "s"],
        "Type"          => [0, "s"],
        "Description"   => [0, "s"],
        "Location"      => [0, "s"],
        "FullLocation"  => [0, "s"],
        "Done"          => [0, "s"],
        "Money"         => [0, "u"],
        "Exp"           => [0, "u"],
        "Items"         => [0, "*eU", :Item, nil],
        "HideItems"     => [0, "b"],
        "HideName"      => [0, "b"],
        "RequireMaps"   => [0, "*u"],
        "RequireQuests" => [0, "*e", :Quest],
        "Require"       => [0, "s"],
        "AutoFinish"    => [0, "s"],
        "ShowAvailable" => [0, "b"]
      }
      for i in 1...MAX_STEPS
        ret[_INTL("Step{1}", i)] = [0, "s"]
      end
      for i in 1...MAX_STEPS
        ret[_INTL("Map{1}", i)] = [0, "*uu"]
      end
      return ret
    end

    def initialize(hash)
      @id             = hash[:id]
      @id_number      = hash[:id_number]      || -1
      @name           = hash[:name]           || "Unnamed"
      @type           = hash[:type]           || PBQuestType::Basic
      @description    = hash[:description]    || ""
      @steps          = hash[:steps]
      @done           = hash[:done]           || "The quest was completed."
      @location       = hash[:location]       || ""
      @full_location  = hash[:full_location]  || hash[:location]
      @money          = hash[:money]          || 0
      @exp            = hash[:exp]            || 0
      @items          = hash[:items]          || []
      @hide_items     = hash[:hide_items]     || false
      @hide_name      = hash[:hide_name]      || false
      @require_maps   = hash[:require_maps]   || []
      @require_quests = hash[:require_quests] || []
      @require        = hash[:require]        || "true"
      @auto_finish    = hash[:auto_finish]    || "false"
      @map_guides     = hash[:map_guides]     || []
      @show_available = hash[:show_available]
    end

    def display_name(status=0)
      if status <= 0 && @hide_name
        return "?????"
      elsif status == -1
        return "Unavailable"
      else
        return @name
      end
    end

    def display_description(status=0)
      case status
      when -1
        return "This quest is not available yet."
      when 0
        return _INTL("This quest can be found {1}", @location)
      when 1, 2
        return @description
      end
    end
  end
end

class QuestState
  attr_reader(:quest_id)
  attr_accessor(:status)
  attr_accessor(:step)   # -1 = Unavailable, 0 = Available, 1 = Active, 2 = Complete
  attr_accessor(:dummy)

  def initialize(quest_id)
    @quest_id = quest_id
    @status   = -1
    @step     = 0
    @dummy    = nil
  end

  def complete?
    return @status == 2
  end

  def active?
    return @status == 1
  end

  def available?
    return @status == 0
  end

  def unavailable?
    return @status == -1
  end

  def at_step?(step)
    return false if !self.active?
    return @step == step
  end

  def before_step?(step)
    return false if !self.active?
    return @step < step
  end

  def after_step?(step)
    return false if !self.active?
    return @step > step
  end

  def at_or_before_step?(step)
    return false if !self.active?
    return @step <= step
  end

  def at_or_after_step?(step)
    return false if !self.active?
    return @step >= step
  end

  def unlock
    if @status < 0
      @status = 0
      $quests.update
      pbUpdateMarkers
      return true
    end
    echo "Cannot unlock an unlocked quest.\n"
    return false
  end

  def start(silent=false)
    if @status < 1
      if !silent
        if self.type == PBQuestType::Main
          pbTitleDisplay("Main Quest", self.display_name)
        else
          pbDisplayQuestDiscovery(self)
        end
      end
      @status = 1
      $quests.update
      pbUpdateMarkers
      return true
    end
    echo "Cannot start a quest again.\n"
    return false
  end

  def advance(silent=false)
    if @status == 1
      @step = [@step+1, self.steps.length-1].min
      pbDisplayQuestProgress(self) if !silent
      $quests.update
      pbUpdateMarkers
      return true
    end
    echo "Cannot advance an inactive quest.\n"
    return false
  end

  def finish(silent=false)
    if @status < 2
      pbTitleDisplay(self.display_name, "Quest Completed!") if !silent
      if self.money > 0
        pbMessage(_INTL("{1} received ${2}!", $player.name, self.money))
        $player.money += money
      end
      for item in self.items
        pbReceiveItem(item[0],item[1] || 1)
      end
      exp_reward = self.real_exp
      if exp_reward > 0
        pbEXPScreen(0,exp_reward,true)
      end
      @status = 2
      $quests.update
      pbUpdateMarkers
      return true
    end
    echo "Cannot finish a finished quest.\n"
    return false
  end

  def status=(value)
    @status = value
  end

  def step=(value)
    @step = value
  end

  def unlock?
    return false if @status != -1
    return false if !self.show_available
    for map in self.require_maps
      return false if !$PokemonGlobal.visitedMaps[map]
    end
    for quest in self.require_quests
      return false if !$quests[quest].complete?
    end
    return eval(self.require)
  end

  def auto_finish?
    if @status == 1
      return eval(self.auto_finish)
    end
    return false
  end

  def quest
    return GameData::Quest.get(@quest_id)
  end

  def name
    return GameData::Quest.get(@quest_id).name
  end

  def display_name
    return GameData::Quest.get(@quest_id).display_name
  end

  def type
    return GameData::Quest.get(@quest_id).type
  end

  def description
    return GameData::Quest.get(@quest_id).description
  end

  def display_description
    return GameData::Quest.get(@quest_id).display_description
  end

  def steps
    return GameData::Quest.get(@quest_id).steps
  end

  def done
    return GameData::Quest.get(@quest_id).done
  end

  def location
    return GameData::Quest.get(@quest_id).location
  end

  def full_location
    return GameData::Quest.get(@quest_id).full_location
  end

  def exp
    return GameData::Quest.get(@quest_id).exp
  end

  def real_exp
    level = pbPlayerLevel
    exp_need = (((level+1)**3) - (level**3))
    return ((self.exp * 1.0) * exp_need / 100).ceil
  end

  def money
    return GameData::Quest.get(@quest_id).money
  end

  def items
    return GameData::Quest.get(@quest_id).items
  end

  def hide_items
    return GameData::Quest.get(@quest_id).hide_items
  end

  def hide_name
    return GameData::Quest.get(@quest_id).hide_name
  end

  def require_maps
    return GameData::Quest.get(@quest_id).require_maps
  end

  def require_quests
    return GameData::Quest.get(@quest_id).require_quests
  end

  def require
    return GameData::Quest.get(@quest_id).require
  end

  def auto_finish
    return GameData::Quest.get(@quest_id).auto_finish
  end

  def map_guides
    return GameData::Quest.get(@quest_id).map_guide
  end

  def show_available
    return GameData::Quest.get(@quest_id).show_available
  end
end

module PBQuestType
  Basic        = 0
  Feature      = 1
  Story        = 2
  Challenge    = 3
  Main         = 4
  Botanist     = 5
  Miner        = 6
  Crafter      = 7
  Doctor       = 8
  Fisher       = 9
  Breeder      = 10
  Engineer     = 11
  Professor    = 12
  Ranger       = 13
  Archeologist = 14
end