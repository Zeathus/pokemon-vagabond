class PokemonSystem
  attr_accessor :difficulty
  attr_accessor :lock_difficulty
  attr_accessor :auto_surf
  attr_accessor :bag_mode

  alias sup_initialize initialize

  def initialize
    sup_initialize
    @difficulty      = 1
    @lock_difficulty = false
    @auto_surf       = true
    @bag_mode        = 0
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
  "description" => _INTL("Adjust the difficulty of the game."),
  "get_proc"    => proc { next $PokemonSystem.difficulty },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.difficulty = value },
  "disabled"    => proc { $PokemonSystem.lock_difficulty }
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