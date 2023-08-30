class PokemonSystem
  attr_accessor :difficulty
  attr_accessor :lock_difficulty
  attr_accessor :auto_surf
  attr_accessor :bag_mode
  attr_accessor :showexpgain

  alias sup_initialize initialize

  def initialize
    sup_initialize
    @difficulty      = 1      # Volume of background music and ME
    @lock_difficulty = false  # Volume of sound effects
    @auto_surf       = true   # Text input mode (0=cursor, 1=keyboard)
    @bag_mode        = 0
    @showexpgain     = 0     # Show exp gained after battle
  end

  def level_sync?
    return @difficulty >= 2
  end

  def showexpgain
    return @showexpgain || 0
  end
end

class ButtonOption
  attr_reader :name

  def initialize(name, unused1, unused2, set_proc)
    @name       = name
    @press_proc = set_proc
  end

  def next(current)
    return 0
  end

  def prev(current)
    return 0
  end

  def get
    return 0
  end

  def set(a, b)
    return 0
  end

  def press
    @press_proc&.call
  end
end

MenuHandlers.add(:options_menu, :screen_size, {
  "name"        => _INTL("Controls"),
  "order"       => 1000,
  "type"        => ButtonOption,
  "parameters"  => nil,
  "description" => _INTL("Change the current controls."),
  "get_proc"    => nil,
  "set_proc"    => proc { |value, _scene|
    System.show_settings
  }
})