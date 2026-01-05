module BattleStatus
  None          = 0
  Healing       = 1 # Aqua Ring, Ingrain
  HealBlock     = 2
  Attract       = 3
  Confused      = 4
  CritRateUp    = 5 # Focus Energy
  Endure        = 6
  DeathLink     = 7 # Destiny Bond, Grudge
  Substitute    = 8
  Recharge      = 9
  FollowMe      = 10
  MoveLocked    = 11 # Encore, Outrage
  CannotEscape  = 12 # Mean Look, Jaw Lock, etc.
  Taunt         = 13
  LeechSeed     = 14
  Trapped       = 15 # Wrap, Whirlpool, etc.
  Charge        = 16
  Electrify     = 17
  IonDeluge     = 18
  FlashFire     = 19
  Protect       = 32
  WideGuard     = 33
  QuickGuard    = 34
  BanefulBunker = 35
  BurningBulwark= 36
  SpikyShield   = 37
  KingsShield   = 38
  CraftyShield  = 39
  MatBlock      = 40
  Obstruct      = 41
  SilkTrap      = 42
  SureHit       = 48 # Lock On
  SureCrit      = 49 # Laser Focus
  Rage          = 50
  Uproar        = 51
  Silenced      = 52 # Throat Chop
  Curse         = 53
  Identified    = 54 # Foresight, Odor Sleuth
  MiracleEye    = 55
  Minimized     = 56
  Airborne      = 57 # Magnet Rise, Telekinesis
  Grounded      = 58 # Smack Down, Roost
  PowerTrick    = 59
  Drowzy        = 60 # Yawn
  Perishing     = 61 # Perish Song
  HelpingHand   = 62
  Quashed       = 63
  MagicCoat     = 64
  Reflect       = 65
  LightScreen   = 66
  AuroraVeil    = 67
  Safeguard     = 68
  Mist          = 69
  WaterSport    = 70
  MudSport      = 71
  LuckyChant    = 72
  Rainbow       = 73
  SeaOfFire     = 74
  Swamp         = 75
  Tailwind      = 76
  Spikes        = 77
  Spikes2       = 78
  Spikes3       = 79
  ToxicSpikes   = 80
  ToxicSpikes2  = 81
  StealthRock   = 82
  StickyWeb     = 83
  Wiretap       = 84
  NegateItems   = 96 # Embargo, Magic Room
  CannotEvade   = 97 # Telekinesis
  Wish          = 98
  FutureSight   = 99
  Disabled      = 100
  Nightmare     = 101
  SlowStart     = 102
  Bide          = 103
  Torment       = 104
  Imprison      = 105
  GastroAcid    = 106
  ShellTrap     = 107
  Stockpile     = 108
  TarCovered    = 109 # Tar Shot
  SyrupCovered  = 110 # Syrup Bomb
  SaltCovered   = 111 # Salt Cure
  CorrosiveAcid = 112
  Permanence    = 113
  Nihility      = 114
  SleepImmune   = 115
  Infinity      = 116
  Revert        = 117
  DualStance    = 118
  TrickRoom     = 128
  WonderRoom    = 129

  # Status Conditions
  StatusSleep     = 208
  StatusPoison    = 210
  StatusToxic     = 211
  StatusBurn      = 212
  StatusParalysis = 214
  StatusFrostbite = 216
  StatusFreeze    = 217

  # Effects not in a pokemon, side, or field's "effects" list
  WeatherSun         = 224
  WeatherHarshSun    = 225
  WeatherRain        = 226
  WeatherHeavyRain   = 227
  WeatherSnow        = 228
  WeatherHail        = 229
  WeatherSandstorm   = 230
  WeatherNoxStorm    = 231
  WeatherWinds       = 232
  WeatherStrongWinds = 233
  TerrainElectric    = 236
  TerrainGrassy      = 237
  TerrainMisty       = 238
  TerrainPsychic     = 239

  ORDERING = [
    :Heal
  ]
  
  BATTLER_EFFECTS = {
    # -------------------
    # Battler Effects
    # -------------------
    PBEffects::AquaRing => {
      "name"        => _INTL("Aqua Ring"),
      "default"     => false,
      "icons"       => [:Healing],
      "description" => _INTL("The Pokémon recovers 1/16 of its max HP at the end of each turn.")
    },
    PBEffects::Attract => {
      "name"        => _INTL("Infatuated"),
      "default"     => -1,
      "icons"       => [:Attract],
      "description" => _INTL("The Pokémon's moves have a 50% to fail. This effect is removed if either the afflicted Pokémon or the Pokémon it was infatuated by leaves the field.")
    },
    PBEffects::BanefulBunker => {
      "name"        => _INTL("Baneful Bunker"),
      "default"     => false,
      "icons"       => [:BanefulBunker],
      "description" => _INTL("The Pokémon is protected from moves. If an attack that makes contact is blocked, the attacker is poisoned.")
    },
    PBEffects::Bide => {
      "name"        => _INTL("Bide"),
      "default"     => 0,
      "icons"       => [:Bide],
      "description" => _INTL("Cannot attack. Stores attack damage taken for 2 turns, then attacks for twice the total damage taken.")
    },
    PBEffects::Charge => {
      "name"        => _INTL("Charged"),
      "default"     => 0,
      "icons"       => [:Charge],
      "description" => _INTL("The Pokémon's next Electric-type attack deals 50% more damage.")
    },
    PBEffects::Confusion => {
      "name"        => _INTL("Confused"),
      "default"     => 0,
      "icons"       => [:Confused],
      "description" => _INTL("The Pokémon has a 1/3 chance of hitting itself instead of using a move.")
    },
    PBEffects::CorrosiveAcid => {
      "name"        => _INTL("Corroded"),
      "default"     => false,
      "icons"       => [:CorrosiveAcid],
      "description" => _INTL("The Pokémon can be hit by Poison-type moves if it is a Steel-type.")
    },
    PBEffects::Curse => {
      "name"        => _INTL("Cursed"),
      "default"     => false,
      "icons"       => [:Curse],
      "description" => _INTL("The Pokémon loses 1/4 of its max HP at the end of each turn.")
    },
    PBEffects::DestinyBond => {
      "name"        => _INTL("Destiny Bond"),
      "default"     => false,
      "icons"       => [:DeathLink],
      "description" => _INTL("If an attacker causes the Pokémon to faint before the Pokémon uses its next move, the attacker also faints afterwards.")
    },
    PBEffects::Disable => {
      "name"        => _INTL("Disabled"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Disabled],
      "description" => _INTL("The Pokémon is unable to use one of its moves.")
    },
    PBEffects::Electrify => {
      "name"        => _INTL("Electrify"),
      "default"     => false,
      "icons"       => [:Electrify],
      "description" => _INTL("The Pokémon's moves become Electric-type this turn.")
    },
    PBEffects::Embargo => {
      "name"        => _INTL("Embargo"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:NegateItems],
      "description" => _INTL("The Pokémon's held item is negated and its trainer cannot use items.")
    },
    PBEffects::Encore => {
      "name"        => _INTL("Encored"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:MoveLocked],
      "description" => _INTL("The Pokémon is forced to use only one of its moves.")
    },
    PBEffects::Endure => {
      "name"        => _INTL("Endure"),
      "default"     => false,
      "icons"       => [:Endure],
      "description" => _INTL("Attacks cannot cause the Pokémon's HP to drop below 1 this turn.")
    },
    PBEffects::FlashFire => {
      "name"        => _INTL("Flash Fire"),
      "default"     => false,
      "icons"       => [:FlashFire],
      "description" => _INTL("The Pokémon's Fire-type attacks deal 50% more damage.")
    },
    PBEffects::FocusEnergy => {
      "name"        => _INTL("Focus Energy"),
      "default"     => 0,
      "icons"       => [:CritRateUp],
      "description" => _INTL("The Pokémon's critical hit rate is sharply raised.")
    },
    PBEffects::FollowMe => {
      "name"        => _INTL("Follow Me"),
      "default"     => 0,
      "icons"       => [:FollowMe],
      "description" => _INTL("Opposing moves that hit a single target are redirected to the Pokémon.")
    },
    PBEffects::Foresight => {
      "name"        => _INTL("Identified"),
      "default"     => false,
      "icons"       => [:Identified],
      "description" => _INTL("The Pokémon can be hit by Normal and Fighting-type moves if it is a Ghost-type. Moves ignore the Pokémon's raised evasion.")
    },
    PBEffects::GastroAcid => {
      "name"        => _INTL("Gastro Acid"),
      "default"     => false,
      "icons"       => [:GastroAcid],
      "description" => _INTL("The Pokémon's ability is negated.")
    },
    PBEffects::Grudge => {
      "name"        => _INTL("Grudge"),
      "default"     => false,
      "icons"       => [:DeathLink],
      "description" => _INTL("If an attacker causes the Pokémon to faint before the Pokémon uses its next move, the attack used has its PP reduced to 0.")
    },
    PBEffects::HealBlock => {
      "name"        => _INTL("Heal Block"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:HealBlock],
      "description" => _INTL("The Pokémon cannot recover HP.")
    },
    PBEffects::HelpingHand => {
      "name"        => _INTL("Helping Hand"),
      "default"     => false,
      "icons"       => [:HelpingHand],
      "description" => _INTL("The Pokémon's attack this turn deals 50% more damage.")
    },
    PBEffects::HyperBeam => {
      "name"        => _INTL("Recharging"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Recharge],
      "description" => _INTL("The Pokémon's next turn is skipped.")
    },
    PBEffects::Imprison => {
      "name"        => _INTL("Imprison"),
      "default"     => false,
      "icons"       => [:Imprison],
      "description" => _INTL("Opponents cannot use moves the Pokémon has in its moveset.")
    },
    PBEffects::Ingrain => {
      "name"        => _INTL("Ingrain"),
      "default"     => false,
      "icons"       => [:Healing, :CannotEscape, :Grounded],
      "description" => _INTL("The Pokémon recovers 1/16 of its max HP at the end of each turn, but it cannot switch out and is grounded if it was airborne.")
    },
    PBEffects::JawLock => {
      "name"        => _INTL("Jaw Lock"),
      "default"     => -1,
      "icons"       => [:CannotEscape],
      "description" => _INTL("The Pokémon cannot switch out while the Pokémon that caused this effect is on the field.")
    },
    PBEffects::KingsShield => {
      "name"        => _INTL("King's Shield"),
      "default"     => false,
      "icons"       => [:KingsShield],
      "description" => _INTL("The Pokémon is protected from non-status moves. If an attack that makes contact is blocked, the attacker's Attack is reduced.")
    },
    PBEffects::LaserFocus => {
      "name"        => _INTL("Laser Focus"),
      "default"     => 0,
      "icons"       => [:SureCrit],
      "description" => _INTL("The Pokémon's next attack will be a critical hit.")
    },
    PBEffects::LeechSeed => {
      "name"        => _INTL("Seeded"),
      "default"     => -1,
      "icons"       => [:LeechSeed],
      "description" => _INTL("The Pokémon loses 1/8 of its max HP at the end of each turn, healing the Pokémon that used Leech Seed by the same amount.")
    },
    PBEffects::LockOn => {
      "name"        => _INTL("Lock-On"),
      "default"     => 0,
      "icons"       => [:SureHit],
      "description" => _INTL("The Pokémon's next attack will always hit.")
    },
    PBEffects::MagicCoat => {
      "name"        => _INTL("Magic Coat"),
      "default"     => false,
      "icons"       => [:MagicCoat],
      "description" => _INTL("Status moves targetting the Pokémon or its side of the field are reflected back at the user.")
    },
    PBEffects::MagnetRise => {
      "name"        => _INTL("Magnet Rise"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Airborne],
      "description" => _INTL("The Pokémon is airborne, and is immune to Ground-type moves.")
    },
    PBEffects::MeanLook => {
      "name"        => _INTL("Mean Look"),
      "default"     => -1,
      "icons"       => [:CannotEscape],
      "description" => _INTL("The Pokémon cannot switch out while the Pokémon that caused this effect is on the field.")
    },
    PBEffects::Minimize => {
      "name"        => _INTL("Minimized"),
      "default"     => false,
      "icons"       => [:Minimized],
      "description" => _INTL("Certain moves always hit the Pokémon and deal twice their normal damage.")
    },
    PBEffects::MiracleEye => {
      "name"        => _INTL("Miracle Eye"),
      "default"     => false,
      "icons"       => [:MiracleEye],
      "description" => _INTL("The Pokémon can be hit by Psychic-type moves if it is a Dark-type. Moves ignore the Pokémon's raised evasion.")
    },
    PBEffects::MudSport => {
      "name"        => _INTL("Mud Sport"),
      "default"     => false,
      "icons"       => [:MudSport],
      "description" => _INTL("All Electric-type attacks have their damage reduced by 2/3.")
    },
    PBEffects::Nightmare => {
      "name"        => _INTL("Nightmare"),
      "default"     => false,
      "icons"       => [:Nightmare],
      "description" => _INTL("The Pokémon loses 1/4 of its max HP at the end of each turn, until it wakes up.")
    },
    PBEffects::Nihility => {
      "name"        => _INTL("Nihility"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Nihility],
      "description" => _INTL("The Pokémon's stats cannot be raised or lowered, and any active stat changes are removed.")
    },
    PBEffects::NoRetreat => {
      "name"        => _INTL("No Retreat"),
      "default"     => false,
      "icons"       => [:CannotEscape],
      "description" => _INTL("The Pokémon cannot switch out.")
    },
    PBEffects::Obstruct => {
      "name"        => _INTL("Obstruct"),
      "default"     => false,
      "icons"       => [:Obstruct],
      "description" => _INTL("The Pokémon is protected from non-status moves. If an attack that makes contact is blocked, the attacker's Defense is harshly reduced.")
    },
    PBEffects::Octolock => {
      "name"        => _INTL("Octolock"),
      "default"     => -1,
      "icons"       => [:CannotEscape],
      "description" => _INTL("The Pokémon cannot switch out while the Pokémon that caused this effect is on the field. The Pokémon's Defense and Special Defense are lowered at the end of each turn.")
    },
    PBEffects::Outrage => {
      "name"        => _INTL("Outrage"),
      "default"     => 0,
      "icons"       => [:MoveLocked],
      "description" => _INTL("The Pokémon is forced to use only one of its moves.")
    },
    PBEffects::PerishSong => {
      "name"        => _INTL("Perishing"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Perishing],
      "description" => _INTL("The Pokémon will faint once this effect expires.")
    },
    PBEffects::PowerTrick => {
      "name"        => _INTL("Power Trick"),
      "default"     => false,
      "icons"       => [:PowerTrick],
      "description" => _INTL("The Pokémon has its Attack and Defense stats swapped, and its Special Attack and Special Defense stats swapped.")
    },
    PBEffects::Protect => {
      "name"        => _INTL("Protected"),
      "default"     => false,
      "icons"       => [:Protect],
      "description" => _INTL("The Pokémon is protected from moves.")
    },
    PBEffects::Quash => {
      "name"        => _INTL("Quashed"),
      "default"     => 0,
      "icons"       => [:Quashed],
      "description" => _INTL("The Pokémon will move after all other Pokémon in its priority bracket this turn.")
    },
    PBEffects::Rage => {
      "name"        => _INTL("Rage"),
      "default"     => false,
      "icons"       => [:Rage],
      "description" => _INTL("If the Pokémon is damaged by an opponent's attack, the Pokémon's Attack is raised.")
    },
    PBEffects::RagePowder => {
      "name"        => _INTL("Rage Powder"),
      "default"     => false,
      "icons"       => [:FollowMe],
      "description" => _INTL("Opposing moves that hit a single target are redirected to the Pokémon, unless the user is immune to powder moves.")
    },
    PBEffects::Roost => {
      "name"        => _INTL("Roost"),
      "default"     => false,
      "icons"       => [:Grounded],
      "description" => _INTL("The Pokémon is momentarily no longer airborne, and can be hit by Ground-type moves.")
    },
    PBEffects::ShellTrap => {
      "name"        => _INTL("Shell Trap"),
      "default"     => false,
      "icons"       => [:ShellTrap],
      "description" => _INTL("If the Pokémon is hit by a physical attack, it activates a powerful Fire-type attack.")
    },
    PBEffects::ShellTrapSpecial => {
      "name"        => _INTL("Shell Trap"),
      "default"     => false,
      "icons"       => [:ShellTrap],
      "description" => _INTL("If the Pokémon is hit by a special attack, it activates a powerful Fire-type attack.")
    },
    PBEffects::SlowStart => {
      "name"        => _INTL("Slow Start"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:SlowStart],
      "description" => _INTL("The Pokémon's Attack and Speed stats are halved.")
    },
    PBEffects::SpikyShield => {
      "name"        => _INTL("King's Shield"),
      "default"     => false,
      "icons"       => [:KingsShield],
      "description" => _INTL("The Pokémon is protected from moves. If an attack that makes contact is blocked, the attacker's loses 1/8 of its max HP.")
    },
    PBEffects::SmackDown => {
      "name"        => _INTL("Grounded"),
      "default"     => false,
      "icons"       => [:Grounded],
      "description" => _INTL("The Pokémon is no longer airborne, and can be hit by Ground-type moves.")
    },
    PBEffects::Stockpile => {
      "name"        => _INTL("Stockpile"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Stockpile],
      "description" => _INTL("The Pokémon can consume this effect to use Swallow or Spit Up. Doing so also removes the Defense and Special Defense gained by using Stockpile.")
    },
    PBEffects::Substitute => {
      "name"        => _INTL("Substitute"),
      "default"     => 0,
      "icons"       => [:Substitute],
      "description" => _INTL("Moves hit a substitute instead of the Pokémon, unless the move is a sound move. Once the substitute's HP reached 0, it disappears.")
    },
    PBEffects::TarShot => {
      "name"        => _INTL("Tar Covered"),
      "default"     => false,
      "icons"       => [:TarCovered],
      "description" => _INTL("The Pokémon takes twice as much damage from Fire-type attacks.")
    },
    PBEffects::Taunt => {
      "name"        => _INTL("Taunted"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Taunt],
      "description" => _INTL("The Pokémon cannot use status moves.")
    },
    PBEffects::Telekinesis => {
      "name"        => _INTL("Telekinesis"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Airborne, :CannotEvade],
      "description" => _INTL("The Pokémon is airborne, and is immune to Ground-type moves, but cannot evade attacks.")
    },
    PBEffects::ThroatChop => {
      "name"        => _INTL("Silenced"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Silenced],
      "description" => _INTL("The Pokémon cannot use sound moves.")
    },
    PBEffects::Torment => {
      "name"        => _INTL("Torment"),
      "default"     => false,
      "icons"       => [:Torment],
      "description" => _INTL("The Pokémon cannot use the same move twice in a row.")
    },
    PBEffects::Trapping => {
      "name"        => _INTL("Trapping"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Trapped],
      "description" => _INTL("The Pokémon is trapped while the Pokémon that caused this effect is on the field. It loses 1/8 of its max HP at the end of each turn and cannot switch out.")
    },
    PBEffects::Uproar => {
      "name"        => _INTL("Uproar"),
      "default"     => 0,
      "icons"       => [:Uproar],
      "description" => _INTL("The Pokémon prevents all Pokémon on the field from falling asleep, and wakes up those that are asleep.")
    },
    PBEffects::WaterSport => {
      "name"        => _INTL("Water Sport"),
      "default"     => false,
      "icons"       => [:WaterSport],
      "description" => _INTL("All Fire-type attacks have their damage reduced by 2/3.")
    },
    PBEffects::WellRested => {
      "name"        => _INTL("Well Rested"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:SleepImmune],
      "description" => _INTL("The Pokémon cannot be put to sleep after recently waking up. This effect lasts longer if the Pokémon slept for longer.")
    },
    PBEffects::Permanence => {
      "name"        => _INTL("Permanence"),
      "default"     => false,
      "icons"       => [:Permanence],
      "description" => _INTL("The Pokémon's item and ability cannot be negated or removed.")
    },
    PBEffects::DualStance => {
      "name"        => _INTL("Dual Stance"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:DualStance],
      "description" => _INTL("The Pokémon uses its highest Attack stat for all attacks, and all damage is reduced by its highest Defense stat.")
    },
    PBEffects::Yawn => {
      "name"        => _INTL("Drowzy"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Drowzy],
      "description" => _INTL("The Pokémon will fall asleep when this effect expires.")
    }
  }
  POSITION_EFFECTS = {
    # -------------------
    # Position Effects
    # -------------------
    PBEffects::FutureSightCounter => {
      "name"        => _INTL("Foreseen Attack"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:FutureSight],
      "description" => _INTL("The Pokémon in this position will be hit by a move when this effect expires.")
    },
    PBEffects::Wish => {
      "name"        => _INTL("Wish"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Wish],
      "description" => _INTL("The Pokémon in this position will be healed for half the max HP of the Pokémon that used Wish when this effect expires.")
    }
  }
  SIDE_EFFECTS = {
    # -------------------
    # Effects for a side of the field
    # -------------------
    PBEffects::AuroraVeil => {
      "name"        => _INTL("Aurora Veil"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:AuroraVeil],
      "description" => _INTL("The Pokémon and its allies take 1/3 less damage from attacks. In single battles, damage is halved instead. Does not stack with Reflect or Light Screen.")
    },
    PBEffects::CraftyShield => {
      "name"        => _INTL("Crafty Shield"),
      "default"     => false,
      "icons"       => [:CraftyShield],
      "description" => _INTL("The Pokémon and its allies are protected from status moves.")
    },
    PBEffects::LightScreen => {
      "name"        => _INTL("Light Screen"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:LightScreen],
      "description" => _INTL("The Pokémon and its allies take 1/3 less damage from special attacks. In single battles, damage is halved instead.")
    },
    PBEffects::LuckyChant => {
      "name"        => _INTL("Lucky Chant"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:LuckyChant],
      "description" => _INTL("The Pokémon and its allies cannot be critical hit.")
    },
    PBEffects::MatBlock => {
      "name"        => _INTL("Mat Block"),
      "default"     => false,
      "icons"       => [:MatBlock],
      "description" => _INTL("The Pokémon and its allies are protected from non-status moves.")
    },
    PBEffects::Mist => {
      "name"        => _INTL("Mist"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Mist],
      "description" => _INTL("The Pokémon and its allies cannot have their stats lowered by opposing Pokémon.")
    },
    PBEffects::QuickGuard => {
      "name"        => _INTL("Quick Guard"),
      "default"     => false,
      "icons"       => [:QuickGuard],
      "description" => _INTL("The Pokémon and its allies are protected from moves with a priority of 1 or more.")
    },
    PBEffects::Rainbow => {
      "name"        => _INTL("Rainbow"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Rainbow],
      "description" => _INTL("The Pokémon and its allies have twice the usual chance of activating the side effects of their moves.")
    },
    PBEffects::Reflect => {
      "name"        => _INTL("Reflect"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Reflect],
      "description" => _INTL("The Pokémon and its allies take 1/3 less damage from physical attacks. In single battles, damage is halved instead.")
    },
    PBEffects::Safeguard => {
      "name"        => _INTL("Safeguard"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Safeguard],
      "description" => _INTL("The Pokémon and its allies cannot be confused, poisoned, paralyzed, burned, frostbitten, slept or made drowzy by opposing Pokémon.")
    },
    PBEffects::SeaOfFire => {
      "name"        => _INTL("Sea of Fire"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:SeaOfFire],
      "description" => _INTL("The Pokémon and its allies lose 1/8 of their max HP at the end of each turn, unless they are Fire-type.")
    },
    PBEffects::Spikes => {
      "name"        => [_INTL("Spikes x1"), _INTL("Spikes x2"), _INTL("Spikes x3")],
      "default"     => 0,
      "has_levels"  => true,
      "icons"       => [[:Spikes], [:Spikes2], [:Spikes3]],
      "description" => [
        _INTL("Pokémon that enter the field lose 1/8 their max HP, unless they are airborne."),
        _INTL("Pokémon that enter the field lose 1/6 their max HP, unless they are airborne."),
        _INTL("Pokémon that enter the field lose 1/4 their max HP, unless they are airborne.")
      ]
    },
    PBEffects::StealthRock => {
      "name"        => _INTL("Stealth Rock"),
      "default"     => false,
      "icons"       => [:StealthRock],
      "description" => _INTL("Pokémon that enter the field lose 1/8 of their max HP multiplied by their weakness or resistance to Rock-type attacks.")
    },
    PBEffects::StickyWeb => {
      "name"        => _INTL("Sticky Web"),
      "default"     => false,
      "icons"       => [:StickyWeb],
      "description" => _INTL("Pokémon that enter the field have their Speed lowered, unless they are airborne.")
    },
    PBEffects::Swamp => {
      "name"        => _INTL("Swamp"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Swamp],
      "description" => _INTL("The Pokémon and its allies have their Speed reduced by 3/4.")
    },
    PBEffects::Tailwind => {
      "name"        => _INTL("Tailwind"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Tailwind],
      "description" => _INTL("The Pokémon and its allies have their Speed doubled.")
    },
    PBEffects::ToxicSpikes => {
      "name"        => [_INTL("Toxic Spikes x1"), _INTL("Toxic Spikes x2")],
      "default"     => 0,
      "has_levels"  => true,
      "icons"       => [[:ToxicSpikes], [:ToxicSpikes2]],
      "description" => [
        _INTL("Pokémon that enter the field are poisoned, unless they are airborne. If a grounded Poison-type enters the field, this effect is removed."),
        _INTL("Pokémon that enter the field are badly poisoned, unless they are airborne. If a grounded Poison-type enters the field, this effect is removed.")
      ]
    },
    PBEffects::WideGuard => {
      "name"        => _INTL("Wide Guard"),
      "default"     => false,
      "icons"       => [:WideGuard],
      "description" => _INTL("The Pokémon and its allies are protected from moves that hit multiple targets.")
    }
  }
  FIELD_EFFECTS = {
    # -------------------
    # Effects for the entire field
    # -------------------
    PBEffects::Gravity => {
      "name"        => _INTL("Gravity"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:Grounded],
      "description" => _INTL("All Pokémon are grounded, and can be hit by Ground-type moves. All moves have their accuracy raised by 2/3 their usual accuracy.")
    },
    PBEffects::IonDeluge => {
      "name"        => _INTL("Ion Deluge"),
      "default"     => false,
      "icons"       => [:IonDeluge],
      "description" => _INTL("All Normal-type moves become Electric-type.")
    },
    PBEffects::MagicRoom => {
      "name"        => _INTL("Magic Room"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:MagicRoom],
      "description" => _INTL("All held items have their effects negated.")
    },
    PBEffects::MudSportField => {
      "name"        => _INTL("Mud Sport"),
      "default"     => 0,
      "icons"       => [:MudSport],
      "description" => _INTL("All Electric-type attacks have their damage reduced by 2/3.")
    },
    PBEffects::TrickRoom => {
      "name"        => _INTL("Trick Room"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:TrickRoom],
      "description" => _INTL("Pokémon move from slowest to fastest instead of fastest to slowest.")
    },
    PBEffects::WaterSportField => {
      "name"        => _INTL("Water Sport"),
      "default"     => 0,
      "icons"       => [:WaterSport],
      "description" => _INTL("All Fire-type attacks have their damage reduced by 2/3.")
    },
    PBEffects::WonderRoom => {
      "name"        => _INTL("Wonder Room"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:WonderRoom],
      "description" => _INTL("All Pokémon have their Defense and Special Defense swapped.")
    }
  }
  STATUS_EFFECTS = {
    # -------------------
    # Major status conditions
    # -------------------
    :SLEEP => {
      "name"        => _INTL("Asleep"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:StatusSleep],
      "description" => _INTL("When the Pokémon tries to use a move, this effect counts down instead. If the Pokémon is hit by a damaging move, it wakes up.")
    },
    :POISON => {
      "name"        => _INTL("Poisoned"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:StatusPoison],
      "description" => _INTL("The Pokémon loses 1/8 of its max HP at the end of each turn.")
    },
    :BURN => {
      "name"        => _INTL("Burned"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:StatusBurn],
      "description" => _INTL("The Pokémon's physical attacks deal half as much damage, and it loses 1/16 of its max HP at the end of each turn.")
    },
    :PARALYSIS => {
      "name"        => _INTL("Paralyzed"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:StatusParalysis],
      "description" => _INTL("The Pokémon's Speed stat is halved. The turn this effect expires, the Pokémon will be fully paralyzed and its move will fail.")
    },
    :FROSTBITE => {
      "name"        => _INTL("Frostbitten"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:StatusFrostbite],
      "description" => _INTL("The Pokémon's special attacks deal half as much damage, and it loses 1/16 of its max HP at the end of each turn.")
    },
    :FREEZE => {
      "name"        => _INTL("Frozen"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:StatusFreeze],
      "description" => _INTL("When the Pokémon tries to use a move, it has a 20% chance to thaw out, otherwise the move fails.")
    }
  }
  STRONG_STATUS_EFFECTS = {
    # -------------------
    # Major status conditions, with a negative turn count (Toxic)
    # -------------------
    :POISON => {
      "name"        => _INTL("Badly Poisoned"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:StatusToxic],
      "description" => _INTL("The Pokémon loses x/16 of its max HP at the end of each turn, where x is 1 plus how many times the Pokémon has taken poison damage without leaving the field or being cured.")
    }
  }
  WEATHER_EFFECTS = {
    # -------------------
    # Effects held in the battle weather variable
    # -------------------
    :Sun => {
      "name"        => _INTL("Sunny"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:WeatherSun],
      "description" => _INTL("Fire-type moves deal 50% more damage and Water-type moves deal 50% less damage. Pokémon cannot be frozen.")
    },
    :HarshSun => {
      "name"        => _INTL("Harsh Sunlight"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:WeatherHarshSun],
      "description" => _INTL("Fire-type moves deal 50% more damage and Water-type moves fail. Pokémon cannot be frozen.")
    },
    :Rain => {
      "name"        => _INTL("Rain"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:WeatherRain],
      "description" => _INTL("Water-type moves deal 50% more damage and Fire-type moves deal 50% less damage.")
    },
    :HeavyRain => {
      "name"        => _INTL("Heavy Rain"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:WeatherHeavyRain],
      "description" => _INTL("Water-type moves deal 50% more damage and Fire-type moves fail.")
    },
    :Snow => {
      "name"        => _INTL("Snow"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:WeatherSnow],
      "description" => _INTL("Ice-type Pokémon have their Defense stat raised by 50%.")
    },
    :Hail => {
      "name"        => _INTL("Hail"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:WeatherHail],
      "description" => _INTL("Pokémon that are not Ice-type lose 1/16 of their max HP at the end of each turn. Ice-type Pokémon have their Defense stat raised by 50%.")
    },
    :Sandstorm => {
      "name"        => _INTL("Sandstorm"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:WeatherSandstorm],
      "description" => _INTL("Pokémon that are not Rock, Ground, or Steel-type lose 1/16 of their max HP at the end of each turn. Rock-type Pokémon have their Special Defense stat raised by 50%.")
    },
    :NoxiousStorm => {
      "name"        => _INTL("Noxious Sandstorm"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:WeatherNoxStorm],
      "description" => _INTL("All Pokémon are badly poisoned at the end of each turn. Pokémon lose 1/4 of their max HP at the end of each turn. Pokémon immune to sandstorm or poison status take less damage.")
    },
    :Winds => {
      "name"        => _INTL("Winds"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:WeatherWinds],
      "description" => _INTL("Airborne Pokémon have their Speed stat raised by 30%. Certain wind based moves have their power doubled.")
    },
    :StrongWinds => {
      "name"        => _INTL("Strong Winds"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:WeatherStrongWinds],
      "description" => _INTL("Electric, Ice, and Rock-type moves deal neutral damage to Flying-type Pokémon.")
    }
  }
  TERRAIN_EFFECTS = {
    # -------------------
    # Effects held in the battle terrain variable
    # -------------------
    :Electric => {
      "name"        => _INTL("Electric Terrain"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:TerrainElectric],
      "description" => _INTL("Grounded Pokémon deal 30% more damage with Electric-type moves, cannot be put to sleep or made drowzy, and wake up if they are asleep.")
    },
    :Grassy => {
      "name"        => _INTL("Grassy Terrain"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:TerrainGrassy],
      "description" => _INTL("Grounded Pokémon deal 30% more damage with Grass-type moves, and they recover 1/16 of their max HP at the end of each turn. The power of Bulldoze, Earthquake and Magnitude is halved.")
    },
    :Misty => {
      "name"        => _INTL("Misty Terrain"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:TerrainMisty],
      "description" => _INTL("Grounded Pokémon take half as much damage from Dragon-type moves, and they cannot be confused, poisoned, paralyzed, burned, frostbitten, or slept.")
    },
    :Psychic => {
      "name"        => _INTL("Psychic Terrain"),
      "default"     => 0,
      "show_value"  => true,
      "icons"       => [:TerrainPsychic],
      "description" => _INTL("Grounded Pokémon deal 30% more damage with Psychic-type moves, and they cannot be hit by moves with a priority of 1 or more.")
    }
  }
end

class BattleStatusRow < Sprite

  def initialize(viewport, databox)
    super(viewport)
    @databox = databox
    self.bitmap = Bitmap.new(256, 32)
    pbSetSmallestFont(self.bitmap)
    @types_bitmap = AnimatedBitmap.new("Graphics/UI/type_icons_bordered")
    @stages_bitmap = AnimatedBitmap.new("Graphics/UI/Battle/stat_change")
    @condition_bitmap = AnimatedBitmap.new("Graphics/UI/Battle/condition")
    @@timer = 0
    @@page = 0
    @@pages = [1]
    @battler = nil
    @statuses = {}
    @status_icons = []
    @stat_changes = {
      :ATTACK          => 0,
      :SPECIAL_ATTACK  => 0,
      :DEFENSE         => 0,
      :SPECIAL_DEFENSE => 0,
      :SPEED           => 0,
      :ACCURACY        => 0,
      :EVASION         => 0
    }
  end

  def battler=(value)
    @@page = 0
    @@timer = 0
    @battler = value
    refresh
  end

  def refresh
    self.bitmap.clear
    return if !@battler
    return if !@battler.pokemon
    if self.page == 0
      type_icon_position = GameData::Type.get(@battler.pokemon.affinity).icon_position
      if @battler.index % 2 == 0
        self.bitmap.blt(0, 0, @types_bitmap.bitmap, Rect.new(64, 32 * type_icon_position, 32, 32))
        pbDrawTextPositions(self.bitmap, [[
          "- AFFINITY", 32, 8, 0, Color.new(248, 248, 248), Color.new(15, 15, 15), 1
        ]])
      else
        self.bitmap.blt(self.bitmap.width - 32, 0, @types_bitmap.bitmap, Rect.new(64, 32 * type_icon_position, 32, 32))
        pbDrawTextPositions(self.bitmap, [[
          "AFFINITY - ", self.bitmap.width - 30, 8, 1, Color.new(248, 248, 248), Color.new(15, 15, 15), 1
        ]])
      end
    else
      icons_to_show = @status_icons[((self.page - 1) * 6)...(self.page * 6)]
      icons_to_show.each_with_index do |icon_id, i|
        next if icon_id.nil?
        if icon_id <= 0
          # Stat Change
          x = (-icon_id * 32) % 192
          y = (-icon_id / 6).floor * 32
          if @battler.index % 2 == 0
            self.bitmap.blt(32 * i, 0, @stages_bitmap.bitmap, Rect.new(x, y, 32, 32))
          else
            self.bitmap.blt(self.bitmap.width - 32 * (i + 1), 0, @stages_bitmap.bitmap, Rect.new(x, y, 32, 32))
          end
        else
          # Condition
          x = (icon_id * 32) % 512
          y = (icon_id / 16).floor * 32
          if @battler.index % 2 == 0
            self.bitmap.blt(32 * i, 0, @condition_bitmap.bitmap, Rect.new(x, y, 32, 32))
          else
            self.bitmap.blt(self.bitmap.width - 32 * (i + 1), 0, @condition_bitmap.bitmap, Rect.new(x, y, 32, 32))
          end
        end
      end
    end
  end

  def update_statuses
    return if !@battler
    should_refresh = false
    [
      :ATTACK, :SPECIAL_ATTACK,
      :DEFENSE, :SPECIAL_DEFENSE,
      :SPEED, :ACCURACY, :EVASION
    ].each_with_index do |stat, i|
      if @battler.stages[stat] != @stat_changes[stat]
        should_refresh = true
        @stat_changes[stat] = @battler.stages[stat]
      end
    end
    BattleStatus::BATTLER_EFFECTS.each do |key, value|
      if !@battler.effects[key].nil? && @battler.effects[key] != value["default"]
        should_refresh = true if !@statuses.key?(key)
        @statuses[key] = value
      elsif @statuses.key?(key)
        should_refresh = true
        @statuses.delete(key)
      end
    end
    BattleStatus::POSITION_EFFECTS.each do |key, value|
      
    end
    BattleStatus::SIDE_EFFECTS.each do |key, value|
      if !@battler.pbOwnSide.effects[key].nil? && @battler.pbOwnSide.effects[key] != value["default"]
        should_refresh = true if !@statuses.key?(key)
        @statuses[key] = value
      elsif @statuses.key?(key)
        should_refresh = true
        @statuses.delete(key)
      end
    end
    if should_refresh
      @status_icons.clear
      [
        :ATTACK, :SPECIAL_ATTACK,
        :DEFENSE, :SPECIAL_DEFENSE,
        :SPEED, :ACCURACY, :EVASION
      ].each_with_index do |stat, i|
        if @stat_changes[stat] > 0
          @status_icons.push(-(12 * i - 1 + @stat_changes[stat]))
        elsif @stat_changes[stat] < 0
          @status_icons.push(-(12 * i + 5 - @stat_changes[stat]))
        end
      end
      @statuses.each do |key, value|
        if value["has_levels"]
          # Kinda hacky because only sided effects have levels right now
          value["icons"][@battler.pbOwnSide.effects[key] - 1].each do |i|
            @status_icons.push(getID(BattleStatus, i))
          end
        else
          value["icons"].each do |i|
            @status_icons.push(getID(BattleStatus, i))
          end
        end
      end
      @@pages[@battler.index] = self.pages
      refresh
    end
  end

  def page
    return [@@page, self.pages - 1].min
  end

  def pages
    return 1 + (@status_icons.length.to_f / 6).ceil
  end

  def max_pages
    ret = 1
    @@pages.each do |i|
      ret = i if i && i > ret
    end
    return ret
  end

  def update
    update_statuses
    if @battler.index == 0
      @@timer += 1
      if @@timer >= 180
        @@page = (@@page + 1) % self.max_pages
        @@timer = 0
      end
    end
    if self.pages > 1
      if @@timer == 0 && self.pages > @@page
        self.opacity = 0
        refresh
      elsif @@timer >= 160 && (self.pages > @@page + 1 || self.max_pages == @@page + 1)
        self.opacity = (255 * (180 - @@timer) / 20).floor
      elsif @@timer < 20 && self.pages > @@page
        self.opacity = (255 * @@timer / 20).floor
      else
        self.opacity = 255
      end
    else
      self.opacity = 255
    end
    self.visible = @databox.visible
    self.opacity = self.opacity * @databox.opacity / 255
  end

  def dispose
    @types_bitmap.dispose
    @stages_bitmap.dispose
    @condition_bitmap.dispose
    super
  end

end