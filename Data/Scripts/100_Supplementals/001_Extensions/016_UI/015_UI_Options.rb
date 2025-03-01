class PokemonSystem
  attr_accessor :difficulty
  attr_accessor :lock_difficulty
  attr_accessor :auto_surf
  attr_accessor :bag_mode
  attr_accessor :showexpgain
  attr_accessor :control_style

  alias sup_initialize initialize

  def initialize
    sup_initialize
    @difficulty      = 1
    @lock_difficulty = false
    @auto_surf       = true
    @bag_mode        = 0
    @showexpgain     = 0
    @force_sync      = 1
    @control_style   = 0
  end

  def level_sync?
    return @difficulty >= 2 || self.force_sync?
  end

  def lock_difficulty=(value)
    @lock_difficulty = (value == 1)
  end

  def showexpgain
    return @showexpgain || 0
  end

  def showexpgain=(value)
    @showexpgain = value
  end

  def force_sync?
    return @force_sync && @force_sync == 1
  end

  def force_sync
    return @force_sync || 1
  end

  def force_sync=(value)
    @force_sync = value
  end

  def control_style
    return @control_style || 0
  end

  def control_style=(value)
    @control_style = value
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

MenuHandlers.add(:options_menu, :difficulty, {
  "name"        => _INTL("Difficulty"),
  "order"       => 900,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Easy"), _INTL("Normal"), _INTL("Hard")],
  "description" => _INTL("Easy: Easier battles, enjoy the journey.\nHard: Harder battles, forced level sync."),
  "get_proc"    => proc { next $PokemonSystem.difficulty },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.difficulty = value },
  "disabled"    => proc { $PokemonSystem.lock_difficulty }
})

MenuHandlers.add(:options_menu, :level_sync, {
  "name"        => _INTL("Level Sync"),
  "order"       => 910,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Off"), _INTL("On")],
  "description" => _INTL("Have your Pokémon's levels be temporarily lowered for important battles."),
  "get_proc"    => proc { next $PokemonSystem.force_sync },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.force_sync = value },
  "disabled"    => proc { $PokemonSystem.lock_difficulty }
})

MenuHandlers.add(:options_menu, :lock_difficulty, {
  "name"        => _INTL("Lock Difficulty"),
  "order"       => 920,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Off"), _INTL("On")],
  "description" => _INTL("Lock the game's difficulty, preventing it from being changed later."),
  "get_proc"    => proc { next $PokemonSystem.lock_difficulty },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.lock_difficulty = value },
  "confirm"     => proc { pbConfirmMessageSerious("Locking difficulty cannot be undone.\nAre you sure?") },
  "disabled"    => proc { $PokemonSystem.lock_difficulty }
})

MenuHandlers.add(:options_menu, :control_style, {
  "name"        => _INTL("Control Style"),
  "order"       => 990,
  "type"        => EnumOption,
  "parameters"  => [_INTL("Keyboard"), _INTL("Nintendo"), _INTL("Xbox"), _INTL("Playstation")],
  "description" => _INTL("Changes the button prompt style.\n\"Nintendo\" makes A/B and X/Y correct."),
  "get_proc"    => proc { next $PokemonSystem.control_style },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.control_style = value }
})

MenuHandlers.add(:options_menu, :controls, {
  "name"        => _INTL("Controls"),
  "order"       => 1000,
  "type"        => ButtonOption,
  "parameters"  => nil,
  "description" => _INTL("Change individual controls."),
  "get_proc"    => nil,
  "set_proc"    => proc { |value, _scene|
    System.show_settings
  }
})