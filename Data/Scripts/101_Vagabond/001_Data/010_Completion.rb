class CompletionRate
  attr_accessor :items
  attr_accessor :items_max
  attr_accessor :trainers
  attr_accessor :trainers_max
  attr_accessor :bosses
  attr_accessor :bosses_max
  attr_accessor :quests
  attr_accessor :quests_max
  attr_accessor :pokedex
  attr_accessor :pokedex_full
  attr_accessor :secrets
  attr_accessor :secrets_max

  def initialize
    @items = 0
    @items_max = 0
    @trainers = 0
    @trainers_max = 0
    @bosses = 0
    @bosses_max = 0
    @quests = 0
    @quests_max = 0
    @pokedex = []
    @pokedex_full = []
    @secrets = 0
    @secrets_max = 0
  end

  def item(map_id, event_id, switch = "A")
    @items_max += 1
    @items += 1 if $game_self_switches[[map_id, event_id, switch]]
  end

  def trainer(map_id, event_id, switch = "A")
    @trainers_max += 1
    @trainers += 1 if $game_self_switches[[map_id, event_id, switch]]
  end

  def boss(boss_id)
    @bosses_max += 1
    @bosses += 1 if $game_variables && pbBossDefeated?(boss_id)
  end

  def quest(quest_id)
    @quests_max += 1
    @quests += 1 if $quests[quest_id].complete?
  end

  def secret_switch(switch)
    @secrets_max += 1
    @secrets += 1 if $game_switches[switch]
  end

  def secret_self_switch(map_id, event_id, switch = "A")
    @secrets_max += 1
    @secrets += 1 if $game_self_switches[[map_id, event_id, switch]]
  end

  def secret_map(secret_map_id)
    @secrets_max += 1
    @secrets += 1 if $PokemonGlobal.visitedMaps[secret_map_id]
  end

  def secret_item(item_id)
    @secrets_max += 1
    @secrets += 1 if $bag.quantity(item_id) > 0
  end

  def check_dex(map_id)
    encounter_data = GameData::Encounter.get(map_id, $PokemonGlobal.encounter_version)
    encounters = Marshal.load(Marshal.dump(encounter_data.types))

    encounters.each_value do |encounter_type|
      encounter_type.each do |pokemon|
        species = pokemon[1]
        if !@pokedex_full.include?(species)
          @pokedex_full.push(species)
          if $player.owned?(species)
            @pokedex.push(species)
          end
        end
      end
    end
  end

  def caught
    return @pokedex.length
  end

  def caught_max
    return @pokedex_full.length
  end
end

def pbGetCompletion(area, subarea = "")
  c = CompletionRate.new
  case area
  when "Halcyon Clearing"
    c.check_dex(58)
  when "Halcyon Forest"
    c.check_dex(61)
    c.item(61, 3) # 5x Pokéball
    c.item(61, 4) # Dawn Stone
  when "Crosswoods"
    c.check_dex(7)
    c.item(7, 15) # TM02 False Swipe
    c.item(7, 16) # TM16 Venoshock
    c.item(7, 29) # 5x Pokéball
    c.item(7, 34) # 5x Pokéball
    c.item(7, 35) # 5x Pokéball
    c.item(7, 36) # 5x Potion
    c.item(115, 8) # Silk Scarf (Ruins)
    c.secret_item(:TM80) # Generic Boost
    c.quest(:SICKZAGOON)
    c.quest(:CURIOUSRUINS)
  when "Breccia Trail"
    c.check_dex(62)
    c.item(62,  3) # TM98 Toxic
    c.item(62,  5) # Antidote
    c.item(62, 14) # Big Mushroom
    c.item(62, 15) # Zinc
    c.item(62, 17) # Swift Wing
    c.item(62, 21) # Super Potion
    c.item(62, 22) # Lure Ball (Fish)
    c.item(62, 24) # Silver Powder
    c.item(62, 26) # Full Heal (Hidden)
    c.item(62, 27) # Heart Scale (Fish)
    c.item(62, 28) # Miracle Seed
    c.item(62, 29) # Pearl (Fish)
    c.item(62, 30) # Max Potion (Fish)
    c.trainer(62, 20) # Lass Alex
    c.trainer(62, 23) # Lass Karine
    c.trainer(62, 25) # Youngster Jeff
    c.trainer(62, 35) # Bug Catcher Wade
    c.boss("Vespiquen")
    c.quest(:SORROWFULZORUA)
  when "Breccia Undergrowth"
    c.check_dex(11)
    c.item(11, 12) # Tiny Mushroom (Hidden)
    c.item(11, 13) # Tiny Mushroom (Hidden)
    c.item(11, 24) # Tiny Mushroom (Hidden)
    c.item(11, 26) # Tiny Mushroom (Hidden)
    c.item(11, 49) # Data Chip
    c.item(11, 50) # TM08 Circle Throw
    c.item(166, 8) # Miracle Seed (Ruins)
    c.trainer(11, 39) # Birdkeeper Revali
    c.trainer(11, 40) # Ranger Peter
    c.boss("Tropius")
    c.secret_item(:TM91) # Flora Boost
    c.quest(:WILDLIFEPROTECTORS)
    c.quest(:BERRYIMPORTANT)
  when "Breccia City"
    c.quest(:BRECCIAGYM)
    c.quest(:LUMBERLESSCARPENTER)
    c.quest(:THEFIERYROBIN)
  when "Breccia Ranch"
    c.check_dex(204)
  when "Lazuli Lake"
    c.check_dex(9)
    c.item(9, 10) # TM54 Charge Beam
    c.item(9, 11) # Great Ball
    c.item(9, 39) # TM67 Breaking Swipe
    c.item(9, 44) # Iron (Hidden)
    c.item(9, 45) # Ice Heal (Hidden)
    c.item(9, 46) # Net Ball
    c.item(9, 47) # Protein (Hidden)
    c.item(9, 48) # Mystic Water
    c.item(9, 49) # Blue Shard (Hidden)
    c.item(9, 52) # Blue Shard (Hidden)
    c.item(9, 53) # Hyper Potion
    c.item(9, 54) # Heart Scale (Fish)
    c.item(9, 55) # Lure Ball (Fish)
    c.trainer(9, 6) # Preschooler Riki
    c.trainer(9, 8) # Youngster Robin
    c.trainer(9, 9) # Lass Susie
    c.boss("Lapras")
    c.secret_self_switch(9, 65) # Finn
    c.quest(:FISHYBUSINESS)
    c.quest(:SMALLFRY)
    c.quest(:HOOKLINEANDSINKER)
    c.quest(:BIGFISH)
    c.quest(:MASTEROFTHESEA)
  when "Lapis Lazuli City"
    if subarea == "Lazuli District"
      c.quest(:LAPISLAZULIGYM)
      c.boss("RotomHard")
    elsif subarea == "Lapis District"
      c.check_dex(27)
      c.quest(:NEEDFORINSPIRATION)
      c.boss("RotomEasy")
    elsif subarea == "Lazuli Park"
      c.check_dex(22)
    elsif subarea == "G.P.O. HQ"
      c.quest(:LITTLEPOKEMONBIGCITY)
      c.quest(:NULLPOINTEREXCEPTION)
      c.secret_switch(HAS_HABITAT_DEX)
    end
  when "Quartz Passing"
    c.check_dex(72)
    c.item(72, 2) # Burn Heal (Hidden)
    c.item(72, 4) # Tiny Mushroom (Hidden)
    c.item(72, 5) # Nest Ball (Hidden)
    c.item(72, 6) # Hyper Potion
    c.item(72, 7) # TM07 Brick Break
    c.item(72, 8) # Ether
    c.item(72, 15) # Health Wing
    c.trainer(72, 10) # Backpacker Frankie
    c.trainer(72, 11) # Roughneck Agnol
    c.trainer(72, 13) # Hiker Mark
    c.trainer(72, 14) # Gambler Vilko
  when "Pegma City"
    if subarea == "Feldspar District"
      c.check_dex(21)
      c.item(21, 20) # Red Shard (Hidden)
      c.quest(:GROWLINGSTOMACH)
      c.quest(:PEGMAGYM)
    elsif subarea == "Mica District"
      c.item(12, 11) # Great Ball (Hidden)
      c.item(12, 16) # Iron
    elsif subarea == "Feldspar Lake"
      c.check_dex(21)
      c.item(21, 12) # TM23 Smack Down
      c.item(21, 22) # Charcoal
      c.secret_self_switch(21, 26) # Cerise
      c.boss("Swampert")
    end
  when "Mt. Pegma"
    c.check_dex(20) # 1F
    c.check_dex(44) # 1F Part 2
    c.check_dex(45) # 2F
    c.check_dex(47) # 3F
    c.check_dex(110) # B1F
    c.item(20, 7) # Dusk Ball
    c.item(48, 3) # TM102 Bulk Up
    c.item(48, 4) # Muscle Wing
    c.item(48, 5) # Moon Stone
    c.item(110, 9) # Data Chip
    c.item(110, 10) # Fire Stone
    c.item(110, 11) # Heat Rock
    c.item(110, 13) # Iron
    c.item(111, 1) # TM43 Flare Blitz
    c.item(111, 2) # Rare Bone
    c.item(111, 3) # Stardust
    c.item(111, 4) # Star Piece
    c.item(134, 2) # Hard Stone (Ruins)
    c.trainer(20, 5) # Hiker Ludovic
    c.trainer(20, 8) # Miner Oli
    c.boss("Turtonator")
    c.secret_item(:TM43) # Secret Room
    c.secret_item(:TM85) # Boulder Boost
  when "Pegma Quarry"
    c.check_dex(92)
    c.check_dex(93)
    c.check_dex(94)
    c.check_dex(95)
    c.check_dex(96)
    c.check_dex(97)
    c.check_dex(98)
    c.check_dex(99)
    c.quest(:DIGGYDIGGYHOLE)
    c.quest(:DIGGINGDEEPER)
    c.quest(:DAWNOFTHEDEEPSTONES)
  when "Mt. Pegma Hillside"
    c.check_dex(14)
    c.item(14, 7) # Super Potion
    c.item(14, 8) # Burn Heal
    c.item(14, 9) # Hard Stone (Hidden)
    c.item(14, 14) # Health Wing
    c.item(140, 8) # Charcoal (Ruins)
    c.trainer(14,  3) # Youngster Eddie
    c.trainer(14,  6) # Hiker Rico
    c.trainer(14, 13) # Black Belt Kenshi
    c.secret_item(:TM89) # Flame Boost
  when "Mt. Pegma Falls"
    c.check_dex(73)
    c.item(73, 3) # Genius Wing
    c.item(73, 6) # TM46 Waterfall
    c.item(73, 19) # Max Repel
    c.item(73, 20) # Carbos
    c.item(73, 21) # Hyper Potion
  when "Everstone River"
    if subarea == "Upper"

    elsif subarea == "Lower"
      c.check_dex(173)
      c.item(173, 1) # TM45 Brine
      c.item(173, 2) # Data Chip
      c.item(170, 8) # Mystic Water (Ruins)
      c.secret_self_switch(173, 17) # Cerise
      c.secret_item(:TM90) # Aqua Boost
    end
  when "Evergone Crater"
    c.check_dex(70)
    c.item(70, 6) # Data Chip
  when "Evergone Mangrove"
    c.check_dex(208)
    c.check_dex(209)
    c.check_dex(210)
    c.item(208,  1) # TM15 Clear Smog
    c.item(208,  4) # Health Wing
    c.item(208, 27) # Big Root
    c.item(208, 28) # Balm Mushroom
    c.item(209, 15) # Dusk Ball
    c.item(209, 16) # TM31 Hex
    c.item(209, 17) # Leaf Stone
    c.item(209, 18) # Big Mushroom
    c.boss("Deino")
  when "Evergone Ruins"
    c.item(211, 11) # Smoke Ball
  when "Scoria Canyon"
    c.check_dex(216)
    c.item(216, 76) # TM56 Wild Charge
    c.item(216, 77) # HP Up
    c.secret_self_switch(216, 72) # Cerise
  when "Scoria City"
    c.check_dex(198)
    c.quest(:SCORIAGYM)
  when "Scoria Desert"
    c.check_dex(132)
    c.check_dex(135)
    c.check_dex(245)
    c.item(132,  3) # 3x Antidote
    c.item(132,  7) # Smooth Rock
    c.item(132,  8) # Sun Stone
    c.item(132, 89) # TM35 Gyro Ball
    c.item(132, 90) # Shiny Stone
    c.item(135,  3) # Nugget
    c.item(135, 30) # Carbos
    c.item(135, 31) # Data Chip
    c.item(245, 30) # TM25 Power Gem
    c.item(80,   8) # Soft Sand (Ruins)
    c.secret_item(:TM84) # Earth Boost
  when "Scoria Grove"
    c.item(249, 10) # Elixir
    c.item(251, 33) # TM70 Dragon Pulse
    c.item(251, 34) # 3x Premier Ball
    c.item(251, 35) # 3x Luxury Ball
    c.item(251, 36) # Calcium
    c.item(251, 37) # Protein
  when "Scoria Valley"
    c.check_dex(106)
    c.secret_self_switch(106, 24)
  when "West Sea"
    c.check_dex(207)
    c.item(207, 14) # TM99 Thunder Wave
    c.item(207, 15) # Zinc
    c.item(207, 17) # Big Pearl
    c.item(253, 8) # Magnet (Ruins)
    c.boss("Dragalge")
    c.secret_item(:TM92) # Plasma Boost
  when "Central West Sea"
    c.check_dex(206)
    c.item(206, 17) # HP Up
    c.item(206, 19) # TM106 Swords Dance
    c.item(206, 20) # Water Stone
  when "East Sea"
    c.check_dex(163)
    c.item(163, 72) # Clever Wing
    c.item(163, 73) # Hyper Potion
    c.item(163, 74) # Calcium
    c.item(163, 75) # King's Rock
    c.boss("Overqwil")
    c.boss("Clawitzer")
    c.boss("Palafin")
  when "Central East Sea"
    c.check_dex(154)
    c.item(154, 30) # Resist Wing
    c.item(154, 31) # 3x Ultra Ball
    c.item(154, 32) # Soft Sand
    c.boss("Primarina")
    c.secret_self_switch(154, 25) # Primarina Puzzle
  when "Smokey Forest"
    c.item(130, 6) # Stardust
    c.item(133, 1) # TM116 Defog
    c.item(133, 5) # Soothe Bell
    c.item(146, 2) # Spell Tag (Ruins)
    c.item(146, 8) # Brick Piece
    c.secret_item(:TM87) # Spirit Boost
  end
  return c
end