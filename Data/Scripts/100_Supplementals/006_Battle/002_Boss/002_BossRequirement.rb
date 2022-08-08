class BossRequirement
  def initialize(trigger)
    @trigger = trigger
  end
  def check(battle, triggerer)
    return true
  end
end

class BossReq_Eval < BossRequirement
  def initialize(trigger, code)
    super(trigger)
    @code = code
  end
  def check(battle, triggerer)
    move = GameData::Move.get(battle.lastMoveUsed)
    return eval(@code)
  end
end

class BossReq_Interval < BossRequirement
  def initialize(trigger, interval, offset=0)
    super(trigger)
    @interval = interval
    @offset = offset
  end
  def check(battle, triggerer)
    return ((battle.turnCount - @offset) % @interval) == 0
  end
end

class BossReq_HP < BossRequirement
  def initialize(trigger, comparator, hp)
    super(trigger)
    @comparator = comparator
    @hp = hp
  end
  def check(battle, triggerer)
    hp_percent = (triggerer.hp * 100.0 / triggerer.totalhp).floor
    return hp_percent.send(@comparator, @hp)
  end
end

class BossReq_Damage < BossRequirement
  def initialize(trigger, comparator=:>, damage=0)
    super(trigger)
    @comparator = comparator
    @damage = damage
  end
  def check(battle, triggerer)
    hp_percent = (triggerer.damageState.hpLost * 100.0 / triggerer.totalhp).floor
    return hp_percent.send(@comparator, @damage)
  end
end

class BossReq_TotalDamage < BossRequirement
  def initialize(trigger, comparator=:>, damage=0)
    super(trigger)
    @comparator = comparator
    @damage = damage
  end
  def check(battle, triggerer)
    hp_percent = (triggerer.damageState.totalHPLost * 100.0 / triggerer.totalhp).floor
    return hp_percent.send(@comparator, @damage)
  end
end

class BossReq_Weather < BossRequirement
  def initialize(trigger, weather, state=true)
    super(trigger)
    @weather = weather
    @state = state
  end
  def check(battle, triggerer)
    return (battle.pbWeather == @weather) == @state
  end
end

class BossReq_Terrain < BossRequirement
  def initialize(trigger, terrain, state=true)
    super(trigger)
    @terrain = terrain
    @state = state
  end
  def check(battle, triggerer)
    return (battle.field.terrain == @terrain) == @state
  end
end

class BossReq_BattlerFainted < BossRequirement
  def initialize(trigger, idx, state=true)
    super(trigger)
    @idx = idx
    @state = state
  end
  def check(battle, triggerer)
    return battle.battlers[@idx].fainted? == @state
  end
end

class BossReq_Gauge < BossRequirement
  def initialize(trigger, gauge, comparator, value)
    super(trigger)
    @gauge = gauge
    @comparator = comparator
    @value = value
  end
  def check(battle, triggerer)
    return @gauge.value.send(@comparator, @value)
  end
end

class BossReq_GaugeEnabled < BossRequirement
  def initialize(trigger, gauge, state=true)
    super(trigger)
    @gauge = gauge
    @state = state
  end
  def check(battle, triggerer)
    return @gauge.enabled == @state
  end
end 