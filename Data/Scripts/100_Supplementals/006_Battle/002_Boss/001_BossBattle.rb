class BossTrigger

  attr_reader :battler_idx

  def initialize(timings, battler_idx=[1,3,5])
    timings = [timings] if !timings.is_a?(Array)
    for i in 0...timings.length
      timings[i] = getID(PBBossTiming, timings[i]) if timings[i].is_a?(Symbol)
    end
    battler_idx = [battler_idx] if battler_idx.is_a?(Numeric)
    @timings = timings
    @battler_idx = battler_idx
    @requirements = []
    @effects = []
    @max_activations = -1
    @enabled = true
    @allow_recursion = false
  end

  def trigger?(battle, battler, timing)
    return false if !@enabled
    return false if !@battler_idx.include?(battler.index)
    return false if timing != PBBossTiming::Faint && battler.fainted?
    return false if !@timings.include?(timing) && !@timings.include?(PBBossTiming::Any)
    for r in @requirements
      return false if !r.check(battle, battler)
    end
    return true
  end

  def execute(battle, battler)
    pbBoss.block_triggers = !@allow_recursion
    if @max_activations > 0
      @max_activations -= 1
      if @max_activations == 0
        @enabled = false
      end
    end
    @effects.each do |e|
      targets = e.target_idx.nil? ? [battler.index] : e.target_idx
      targets.each do |target|
        t = battle.battlers[target]
        if !t.fainted?
          e.activate(battle, battler, t)
          t.pbItemHPHealCheck
          if t.fainted?
            t.pbFaint
            battle.pbGainExp
            battle.pbJudge
          end
        end
      end
    end
    pbBoss.block_triggers = false
  end

  def max_activations=(value)
    @max_activations = value
  end

  def allow_recursion=(value)
    @allow_recursion = value
  end

  def requires(req)
    @requirements.push(req)
  end

  def effect(eff)
    @effects.push(eff)
  end

  def disable
    @enabled = false
  end
end

module PBBossTiming
  None        = 0  # No effect
  Start       = 1  # Start of battle
  StartOfTurn = 2  # Start of turn (after choosing moves)
  EndOfTurn   = 3  # Each turn end
  Damaged     = 4  # When the boss is damaged
  Hit         = 5  # When the boss is hit my a move
  Miss        = 6  # When a move fails to hit the boss
  MoveUsed    = 7  # After any pokemon uses any move
  Switch      = 8  # After the player switches out
  Any         = 9  # After any of the boss timings
  Faint       = 10 # When the boss faints
  Weather     = 11 # When the weather changes
  Terrain     = 12 # When the terrain changes
  StatChange  = 13 # When a stat is raised or lowered
  Item        = 14 # After the player has used an item
  Gauge       = 15 # When a gauge value changes
end

class BossGauge
  attr_reader :type
  attr_reader :name
  attr_reader :max
  attr_accessor :value
  attr_accessor :enabled

  def initialize(type, name, color, max_value, start_value=0)
    type = getID(PBGauge,type) if type.is_a?(Symbol)
    @type = type
    @name = name.upcase
    @color = color
    @max = max_value
    @value = start_value
    @enabled = true
  end

  def get_colors
    if @color.is_a?(String)
      color = @color
      if @color == "hp"
        if @value * 4 <= @max
          color = "red"
        elsif @value * 2 <= @max
          color = "orange"
        else
          color = "green"
        end
      end
      case color
      when "red"
        return [Color.new(218,42,36),Color.new(248,72,56)]
      when "blue"
        return [Color.new(255,0,255),Color.new(200,0,200)]
      when "green"
        return [Color.new(14,152,22),Color.new(24,192,32)]
      when "orange"
        return [Color.new(202,138,0),Color.new(232,168,0)]
      end
      return [Color.new(255,255,255),Color.new(200,200,200)]
    else
      return [
        @color,
        Color.new(
          [@color.red - 50, 0].max,
          [@color.green - 50, 0].max,
          [@color.blue - 50, 0].max
        )
      ]
    end
  end

  def update(battle)
    self.clamp
    pbBoss.checkTriggers(battle, :Gauge)
  end

  def clamp
    @value = 0 if @value < 0
    @value = @max if @value > @max
  end
end

module PBGauge
  Full = 0
  Half = 1
  Long = 2
  None = 3
end

class BossBattle

  attr_accessor :triggers  # List of all triggers
  attr_accessor :sturdy    # Guaranteed to survive at specified HP
  attr_accessor :nextphase # BossBattle object called for new instance effect
  attr_accessor :backdrop  # Current background override
  attr_accessor :outside   # If the pokemon should be outside the screen
  attr_accessor :gauges
  attr_accessor :block_triggers

  def initialize
    self.triggers   = []
    self.sturdy     = []
    self.nextphase  = false
    self.backdrop   = false
    self.outside    = false
    self.gauges     = []
    self.block_triggers = false
  end

  def clear
    self.triggers   = []
    self.sturdy     = []
    self.nextphase  = false
    self.backdrop   = false
    self.outside    = false
    self.gauges     = []
    self.block_triggers = false
  end

  def changePokemon(battle, battler, pokemon)
    battle.scene.pbChangePokemon(battler,pokemon)
    if self.outside
      battle.scene.sprites["pokemon1"].x+=24*12
      battle.scene.sprites["shadow1"].x+=24*12
    end
  end

  def add_sturdy(hp, target=[1,3,5], uses=1)
    target = [target] if !target.is_a?(Array)
    for t in target
      self.sturdy.push([t, hp, uses])
    end
  end

  def sturdy?(target, damage)
    reduced_damage = damage
    sturdy_arr = nil
    for i in self.sturdy
      if i[2] != 0 && target.index == i[0]
        sturdy_hp = [(i[1] * target.totalhp / 100.0).floor, 1].max
        if target.hp > sturdy_hp && target.hp - damage <= sturdy_hp
          sturdy_damage = target.hp - sturdy_hp
          if reduced_damage > sturdy_damage
            reduced_damage = sturdy_damage
            sturdy_arr = i
          end
        end
      end
    end
    if sturdy_arr
      sturdy_arr[2] -= 1 if sturdy_arr[2] > 0
      return reduced_damage
    end
    return nil
  end

  def checkTriggers(battle, timing, battler=nil)
    timing = getID(PBBossTiming, timing) if timing.is_a?(Symbol)
    return if self.block_triggers && timing != PBBossTiming::Gauge
    for t in self.triggers
      if battler
        if t.trigger?(battle, battler, timing)
          t.execute(battle, battler)
        end
      else
        battle.eachBattler do |b|
          if t.trigger?(battle, b, timing)
            t.execute(battle, b)
          end
        end
      end
    end
  end

  def add(trigger)
    self.triggers.push(trigger)
  end

  def add_gauge(gauge)
    self.gauges.push(gauge)
  end

  def phase
    if !self.nextphase
      self.nextphase = BossBattle.new
    end
    return self.nextphase
  end

  def phase=(value)
      self.nextphase = value
  end
end