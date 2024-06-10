def pbPokemonBossBGM
  $PokemonGlobal.nextBattleBGM="Battle! VS Wild Strong Pokemon (Hero Encore)"
end

def pbRuinBossLevel(mod = 0)
  level = 14
  level += (pbGet(RUINS_DONE) + mod)*6
  level = 80 if level > 80
  return level
end

def pbBossGeneral
  setBattleRule("2v1")
  setBattleRule("smartwildbattle")
  setBattleRule("outcomevar", 1)
  pbPokemonBossBGM
end

def pbBossRuinGeneral
  if $PokemonSystem.level_sync?
    setBattleRule("levelsync", pbRuinBossLevel)
  end
  pbBossGeneral
  setBattleRule("disablepokeballs")
end

def pbBossGiratina1
  pbBossGeneral
  $PokemonGlobal.nextBattleBGM="Battle! VS Giratina"
  $PokemonGlobal.nextBattleBack="Giratina"
  pbModifier.optimize
  pbModifier.hpmult=10.0
  pbModifier.form=1
  pbModifier.moves=[
    :SHADOWFORCE,
    :AURASPHERE,
    :EARTHPOWER,
    :SHADOWSNEAK]
  pbBoss.add(
    [:Start],
    [:Message,"Survive for 10 turns until Giratina calms down!"])
  for i in 1..8
    pbBoss.add(
      [:Timed,i],
      [:Message,_INTL("{1} turns remaining.",10-i)])
  end
  pbBoss.add(
    [:Timed,9],
    [:Message,"1 turn remaining."])
  pbBoss.add(
    [:Timed,10],
    [:Message,"Giratina calmed down!"],
    [:WinBattle])
end

# --- Dunsparce ---
def pbBossRuinNormal
  pbBossRuinGeneral
  pbModifier.optimize
  pbModifier.hpmult = 3.0
  pbModifier.moves = [
    :ROLLOUT,
    :DEFENSECURL
  ]

  # Start: Gets +2 Defense/Sp.Def
  # If hit by a Physical attack, +Defense/-Sp.Def
  # If hit by a Special attack, +Sp.Def/-Defense
  # Counters: Clear Smog

  t = BossTrigger.new(:Start)
  t.effect(BossEff_Message.new(t, "Dunsparce is preparing for your attacks."))
  t.effect(BossEff_ChangeStat.new(t, [:DEFENSE, :SPECIAL_DEFENSE], 2))
  pbBoss.add(t)

  t = BossTrigger.new(:Damaged)
  t.requires(BossReq_Eval.new(t, "move.category == 0"))
  t.effect(BossEff_Message.new(t, "Dunsparce is getting ready for more Physical attacks."))
  t.effect(BossEff_ChangeStat.new(t, [:DEFENSE], 2))
  t.effect(BossEff_ChangeStat.new(t, [:SPECIAL_DEFENSE], -2))
  pbBoss.add(t)

  t = BossTrigger.new(:Damaged)
  t.requires(BossReq_Eval.new(t, "move.category == 1"))
  t.effect(BossEff_Message.new(t, "Dunsparce is getting ready for more Special attacks."))
  t.effect(BossEff_ChangeStat.new(t, [:SPECIAL_DEFENSE], 2))
  t.effect(BossEff_ChangeStat.new(t, [:DEFENSE], -2))
  pbBoss.add(t)
end

# --- Primeape ---
def pbBossRuinFighting
  pbBossRuinGeneral
  pbModifier.hpmult = 2.0

  # Start: Gets +4 Attack/Speed
  # Each Turn: -1 Defense/Sp.Def
  # Goes back to +4 Attack/Speed when at -2 Attack/Speed
  # Counters: Clear Smog

  t = BossTrigger.new(:Start)
  t.effect(BossEff_Message.new(t, "Primeape is full of energy and charges ahead!"))
  t.effect(BossEff_ChangeStat.new(t, [:ATTACK, :SPEED], 4))
  pbBoss.add(t)

  t = BossTrigger.new(:EndOfTurn)
  t.requires(BossReq_Interval.new(t, 1))
  t.effect(BossEff_Message.new(t, "Primeape is getting tired."))
  t.effect(BossEff_ChangeStat.new(t, [:ATTACK, :SPEED], -1))
  pbBoss.add(t)

  t = BossTrigger.new(:EndOfTurn)
  t.requires(BossReq_Interval.new(t, 6, 5))
  t.effect(BossEff_Message.new(t, "Primeape got rested and is rearing to go!"))
  t.effect(BossEff_ChangeStat.new(t, [:ATTACK, :SPEED], 6))
  pbBoss.add(t)
end

# --- Skarmory ---
def pbBossRuinSteel
  pbBossRuinGeneral
  pbModifier.hpmult = 3.0
  pbModifier.moves = [
    :SPIKES,
    :STEALTHROCK,
    :STEELWING,
    :DRILLPECK
  ]

  # Start: Lays Stealth Rock and 3 spike layers
  # Each Turn: Uses Whirlwind
  # Counters: Suction Cups, Ingrain, Rapid Spin, Defog

  t = BossTrigger.new(:Start)
  t.effect(BossEff_Message.new(t, "Skarmory laid rocks and spikes on your side of the field!"))
  t.effect(BossEff_Eval.new(t, "triggerer.pbOpposingSide.effects[PBEffects::StealthRock] = true"))
  t.effect(BossEff_Eval.new(t, "triggerer.pbOpposingSide.effects[PBEffects::Spikes] = 3"))
  t.effect(BossEff_Message.new(t, "Skarmory readies itself to blow you away every turn."))
  pbBoss.add(t)

  t = BossTrigger.new(:EndOfTurn)
  t.requires(BossReq_Interval.new(t, 1))
  t.effect(BossEff_UseMove.new(t, :WHIRLWIND, [0, 2]))
  pbBoss.add(t)
end

# --- Spiritomb ---
def pbBossRuinGhost
  pbBossRuinGeneral
  pbModifier.hpmult = 3.0
  pbModifier.hpmult += ($game_variables[RUINS_DONE] / 4.0).floor
  pbModifier.moves = [
    :SPITE,
    :TORMENT,
    :FOULPLAY,
    :SHADOWSNEAK
  ]
  pbModifier.ability = :PRESSURE

  # Each Turn: Lowers all moves by 2 PP (3 on hard)
  # Counters: Leppa Berry, Recycle

  t = BossTrigger.new(:Start)
  t.effect(BossEff_Message.new(t, "Spiritomb emits an aura that sends shivers down your spine."))
  pbBoss.add(t)

  t = BossTrigger.new([:Start, :EndOfTurn])
  t.effect(BossEff_Message.new(t,
    _INTL("Spiritomb's aura lowered the PP of all your Pokémon's moves by {1}!",
      ($PokemonSystem.difficulty < 2) ? 2 : 3)))
  pbBoss.add(t)

  if $PokemonSystem.difficulty < 2
    t = BossTrigger.new([:Start, :EndOfTurn])
    t.requires(BossReq_BattlerFainted.new(t, 0, false))
    t.effect(BossEff_Eval.new(t, "target.moves.each do |m|; m.pp = [m.pp - 2, 0].max; end").set_target(0))
    pbBoss.add(t)
    t = BossTrigger.new([:Start, :EndOfTurn])
    t.requires(BossReq_BattlerFainted.new(t, 2, false))
    t.effect(BossEff_Eval.new(t, "target.moves.each do |m|; m.pp = [m.pp - 2, 0].max; end").set_target(2))
    pbBoss.add(t)
  else
    t = BossTrigger.new([:Start, :EndOfTurn])
    t.requires(BossReq_BattlerFainted.new(t, 0, false))
    t.effect(BossEff_Eval.new(t, "target.moves.each do |m|; m.pp = [m.pp - 3, 0].max; end").set_target(0))
    pbBoss.add(t)
    t = BossTrigger.new([:Start, :EndOfTurn])
    t.requires(BossReq_BattlerFainted.new(t, 2, false))
    t.effect(BossEff_Eval.new(t, "target.moves.each do |m|; m.pp = [m.pp - 3, 0].max; end").set_target(2))
    pbBoss.add(t)
  end
end

# --- Darmanitan ---
def pbBossRuinFire
  pbBossRuinGeneral
  pbModifier.hpmult = 1.0
  pbModifier.moves = [
    :BULKUP
  ]
  pbModifier.item = :ZENCHARM
  pbModifier.ability = :ZENMODE

  # Start: Increases defenses and is in Zen forme
  # Each Turn: Has only Bulk Up
  # When at low HP, turns aggressive and changes moves
  # Counters: Clear Smog

  t = BossTrigger.new(:Start)
  t.effect(BossEff_Message.new(t, "Darmanitan is taking a defensive position."))
  t.effect(BossEff_ChangeStat.new(t, [:DEFENSE, :SPECIAL_DEFENSE], 2))
  pbBoss.add(t)

  t = BossTrigger.new(:Any, 1)
  t.requires(BossReq_HP.new(t, :<=, 33))
  t.effect(BossEff_Message.new(t, "The pinch made Darmanitan aggressive!"))
  t.effect(BossEff_Eval.new(t, "target.pokemon.ability_index = 0"))
  t.effect(BossEff_Ability.new(t, :SHEERFORCE))
  t.effect(BossEff_Form.new(t, 0))
  t.effect(BossEff_ChangeStat.new(t, [:DEFENSE, :SPECIAL_DEFENSE], -2))
  t.effect(BossEff_ChangeStat.new(t, [:SPEED], 2))
  t.effect(BossEff_Moveset.new(t, [:FIREPUNCH, :BRICKBREAK, :ROCKSLIDE]))
  t.max_activations = 1
  pbBoss.add(t)
end

# --- Corsola ---
def pbBossRuinWater
  pbBossRuinGeneral
  pbModifier.hpmult = 3.0
  pbModifier.moves = [
    :RECOVER,
    :SANDSTORM,
    :SCREECH,
    :ROCKTOMB
  ]
  pbModifier.item = :BIGROOT
  if $PokemonSystem.difficulty > 1
    pbModifier.ability = :REGENERATOR
  else
    pbModifier.ability = :HUSTLE
  end

  # Start: Sets both Aqua Ring and Ingrain for recovery
  # Lowers player defense to threaten them to switch out,
  # but switching out also means Corsola gets time to regenerate.
  # Counters: Heal Block, damage over time

  t = BossTrigger.new(:Start)
  t.effect(BossEff_Message.new(t, "Corsola's body is regenerating quickly!"))
  t.effect(BossEff_UseMove.new(t, :AQUARING, [1]))
  t.effect(BossEff_UseMove.new(t, :INGRAIN, [1]))
  if $PokemonSystem.difficulty > 1
    t.effect(BossEff_Message.new(t, "Corsola is honing its accuracy!"))
    t.effect(BossEff_ChangeStat.new(t, :ACCURACY, 2))
  end
  pbBoss.add(t)
end

# --- Shiinotic ---
def pbBossRuinGrass
  pbBossRuinGeneral
  pbModifier.hpmult = ($PokemonSystem.difficulty > 1) ? 3.0 : 2.0
  pbModifier.moves = [
    :STRENGTHSAP,
    ($PokemonSystem.difficulty > 1) ? :GIGADRAIN : :MEGADRAIN,
    :SPORE,
    :DRAININGKISS
  ]
  pbModifier.item = :BIGROOT if $PokemonSystem.difficulty > 1
  pbModifier.ability = :EFFECTSPORE

  # Lowers all the player's stats every turn, eventually forcing switchouts
  # Counters: Mist, Clear Body, Topsy-Turvy, Contrary, Defiant, Competitive

  t = BossTrigger.new(:Start)
  t.effect(BossEff_Message.new(t, "TRIGGERER is periodically releasing numbing spores!"))
  t.effect(BossEff_ChangeStatQuick.new(t, [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED], -1).set_target([0, 2]))
  pbBoss.add(t)

  t = BossTrigger.new(:EndOfTurn)
  t.effect(BossEff_Message.new(t, "TRIGGERER is releasing numbing spores!"))
  t.effect(BossEff_ChangeStatQuick.new(t, [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED], -1).set_target([0, 2]))
  pbBoss.add(t)
end

# --- Chimecho ---
def pbBossSmokeyForest
  pbBossGeneral
  pbModifier.hpmult = [2.0, 3.0, 4.0, 4.0][$PokemonSystem.difficulty]
  pbModifier.item = :AEGISTALISMAN
  pbModifier.moves = [:ECHOEDVOICE]

  # Start: Sets infinite Misty Terrain and gains Pixilate
  # Each Turn: Powers up Echoed Voice one turn
  # Counters: Protect, Soundproof

  t = BossTrigger.new(:Start)
  t.effect(BossEff_Terrain.new(t, :Misty, 999))
  t.effect(BossEff_Ability.new(t, :PIXILATE))
  t.effect(BossEff_Message.new(t, "What's this?\nThe Chimecho has the Pixilate ability!"))
  pbBoss.add(t)

  t = BossTrigger.new(:EndOfTurn)
  t.requires(BossReq_Terrain.new(t, :Misty, false))
  t.effect(BossEff_Terrain.new(t, :Misty, 999))
  pbBoss.add(t)

  t = BossTrigger.new(:EndOfTurn)
  t.effect(BossEff_Message.new(t, "Chimecho's voice echoes through the forest."))
  t.effect(BossEff_Eval.new(t, "triggerer.pbOwnSide.effects[PBEffects::EchoedVoiceCounter] += 1"))
  pbBoss.add(t)
end

def pbBossVespiquen
  pbBossGeneral
  setBattleRule("2v3")
  pbModifier.moves = [
    :STRUGGLEBUG
  ]
  pbModifier.gender = 0
  pbModifier.next.hpmult = 4.0
  pbModifier.next.moves = [
    :ATTACKORDER,:AERIALACE,:FELLSTINGER
  ]
  pbModifier.next.next.moves = [
    :STRUGGLEBUG
  ]
  pbModifier.next.next.gender = 0

  # Start: Vespiquen +4 Defense/Sp.Def
  # Start: Combees +2 Speed
  # When a Combee dies, -2 Defense/Sp.Def on Vespiquen
  # When both Combees die, +2 Attack/Sp.Atk on Vespiquen

  t = BossTrigger.new(:Start, 3)
  t.effect(BossEff_Message.new(t, "The Combee protect their queen!"))
  t.effect(BossEff_ChangeStat.new(t, [:DEFENSE, :SPECIAL_DEFENSE], 4))
  t.effect(BossEff_Message.new(t, "Vespiquen motivates its subjects!"))
  t.effect(BossEff_ChangeStat.new(t, :SPEED, 2).set_target([1, 5]))
  pbBoss.add(t)

  t = BossTrigger.new(:Faint, [1, 5])
  t.requires(BossReq_BattlerFainted.new(t, 3, false))
  t.effect(BossEff_Message.new(t, "Combee is unable to protect their queen any longer..."))
  t.effect(BossEff_ChangeStat.new(t, [:DEFENSE, :SPECIAL_DEFENSE], -2).set_target(3))
  pbBoss.add(t)

  t = BossTrigger.new(:Faint, [1, 5])
  t.requires(BossReq_BattlerFainted.new(t, 1))
  t.requires(BossReq_BattlerFainted.new(t, 5))
  t.effect(BossEff_Message.new(t, "Vespiquen grows mad as it wants to avenge its fallen subjects!"))
  t.effect(BossEff_ChangeStat.new(t, [:ATTACK], 2).set_target(3))
  pbBoss.add(t)
end

def pbBossRotomGroupEasy
  pbBossGeneral
  setBattleRule("2v3")
  pbModifier.hpmult = 2.0
  pbModifier.optimize
  pbModifier.nature = :MODEST
  pbModifier.next.hpmult = 1.0
  pbModifier.next.optimize
  pbModifier.next.nature = :TIMID
  pbModifier.next.next.hpmult = 2.0
  pbModifier.next.next.optimize
  pbModifier.next.next.nature = :MODEST

  pbModifier.moves = [
    :LEAFSTORM,
    :SHOCKWAVE,
    :THUNDERWAVE,
    :HEX
  ]
  pbModifier.next.moves = [
    :SHOCKWAVE,
    :ELECTROBALL,
    :HEX,
    :CHARGE
  ]
  pbModifier.next.next.moves = [
    :HYDROPUMP,
    :SHOCKWAVE,
    :THUNDERWAVE,
    :HEX
  ]
  pbModifier.item = :WHITEHERB

  pbModifier.form = 5
  pbModifier.next.next.form = 2
end

def pbBossRotomGroupHard
  pbBossGeneral
  setBattleRule("2v3")
  pbModifier.hpmult = 2.0
  pbModifier.optimize
  pbModifier.nature = :TIMID
  pbModifier.next.hpmult = 2.0
  pbModifier.next.optimize
  pbModifier.next.nature = :QUIET
  pbModifier.next.next.hpmult = 2.0
  pbModifier.next.next.optimize
  pbModifier.next.next.nature = :MODEST

  pbModifier.moves = [
    :AIRSLASH,
    :THUNDERBOLT,
    :THUNDERWAVE,
    :HEX
  ]
  pbModifier.next.moves = [
    :BLIZZARD,
    :DISCHARGE,
    :HEX,
    :THUNDERBOLT
  ]
  pbModifier.next.next.moves = [
    :OVERHEAT,
    :THUNDERBOLT,
    :THUNDERWAVE,
    :HEX
  ]
  pbModifier.next.next.item = :WHITEHERB

  pbModifier.form = 4
  pbModifier.next.form = 3
  pbModifier.next.next.form = 1
end

def pbBossTropius
  pbBossGeneral
  pbModifier.moves = [
    :GROWTH,
    :WEATHERBALL,
    :SOLARBEAM,
    :AIRSLASH
  ]
  pbModifier.hpmult = 8.0
  pbModifier.ability = :CHLOROPHYLL
  pbModifier.item = :SITRUSBERRY
  pbModifier.gender = 1
  pbModifier.nature = :TIMID

  # Always keeps sun up
  # Alternates between Solar Power, Harvest and Chlorophyll

  t = BossTrigger.new(:Start)
  t.effect(BossEff_Message.new(t, "The clear skies shine on the outlook."))
  t.effect(BossEff_Weather.new(t, :Sun, 999))
  t.effect(BossEff_Message.new(t, "Tropius is speeding up due to its Chlorophyll."))
  pbBoss.add(t)

  t = BossTrigger.new(:EndOfTurn)
  t.requires(BossReq_Weather.new(t, :Sun, false))
  t.effect(BossEff_Message.new(t, "The clear skies shine on the outlook."))
  t.effect(BossEff_Weather.new(t, :Sun, 999))
  pbBoss.add(t)

  t = BossTrigger.new(:EndOfTurn)
  t.requires(BossReq_Interval.new(t, 3))
  t.effect(BossEff_Ability.new(t, :SOLARPOWER))
  pbBoss.add(t)

  t = BossTrigger.new(:EndOfTurn)
  t.requires(BossReq_Interval.new(t, 3, 1))
  t.effect(BossEff_Ability.new(t, :HARVEST))
  pbBoss.add(t)

  t = BossTrigger.new(:EndOfTurn)
  t.requires(BossReq_Interval.new(t, 3, 2))
  t.effect(BossEff_Ability.new(t, :CHLOROPHYLL))
  pbBoss.add(t)
end

def pbPuzzleBossDeino
  pbBossGeneral
  pbModifier.gender=0
  pbModifier.hpmult=0.20

  t = BossTrigger.new(:Start)
  t.effect(BossEff_Message.new(t, "The Deino is weak and afraid."))
  pbBoss.add(t)

  t = BossTrigger.new(:Any)
  t.requires(BossReq_HP.new(t, :>=, 30))
  t.effect(BossEff_Eval.new(t, "$game_variables[2] = 1"))
  t.effect(BossEff_WinBattle.new(t))
  pbBoss.add(t)

  t = BossTrigger.new(:Any)
  t.requires(BossReq_HP.new(t, :<=, 5))
  t.effect(BossEff_WinBattle.new(t))
  pbBoss.add(t)

  pbBoss.add_sturdy(0)
end

def pbMiniBossRotom(form=0)
  pbBossGeneral
  pbModifier.hpmult = $PokemonSystem.difficulty == 0 ? 1.0 : 2.0
  moveset = [
    :THUNDERSHOCK,
    :ASTONISH
  ]
  if $game_variables[BADGE_COUNT] > 0 || $PokemonSystem.difficulty > 1
    moveset[2] = :UPROAR
  end
  if $game_variables[BADGE_COUNT] > 0
    moveset[3] = :ELECTROBALL
  end
  if $game_variables[BADGE_COUNT] > 1
    moveset[1] = :HEX
    moveset[2] = :THUNDERWAVE
  end
  if form > 0
    rotom_moves = [:THUNDERSHOCK, :OVERHEAT, :HYDROPUMP, :BLIZZARD, :AIRSLASH, :LEAFSTORM]
    moveset[0] = rotom_moves[form]
    if $game_variables[BADGE_COUNT] > 2 && (form == 1 || form == 5)
      pbModifier.item = :WHITEHERB
    end
  end
  pbModifier.moves = moveset
  pbModifier.form = form if form > 0
end

def pbMiniBossGraveler
  pbBossGeneral
  pbModifier.hpmult = 2.0
  moveset = [
    :TACKLE,
    :ROCKTHROW,
    :ROLLOUT,
    :DEFENSECURL
  ]
  if $game_variables[BADGE_COUNT] > 0
    moveset[2] = :SANDSTORM
    moveset[3] = :BULLDOZE
  end
  if $game_variables[BADGE_COUNT] > 1
    moveset[1] = :ROCKBLAST
    moveset[3] = :EARTHQUAKE
  end
  pbModifier.moves = moveset
end

def pbMiniBossCarnivine
  pbBossGeneral
  pbModifier.hpmult = 2.0
  pbModifier.nature = :SERIOUS
  pbModifier.moves = [
    :INGRAIN,
    :VINEWHIP,
    ($PokemonSystem.difficulty > 1 ? :BITE : :BIND),
    :LEECHSEED
  ]
end

def pbMiniBossAbsol
  pbBossGeneral
  pbModifier.hpmult = 2.0
  pbModifier.nature = :MODEST
  pbModifier.moves = [
    :SLASH,
    ($PokemonSystem.difficulty > 1 ? :KNOCKOFF : :TAUNT),
    :QUICKATTACK,
    :LEER
  ]
end

# --- Chapter 4 Archeops ---
def pbBossArcheops
  pbBossGeneral
  setBattleRule("1v1")
  kira_pokemon = getPartyPokemon(:Kira)
  if kira_pokemon[0].species != :SANDOLIN
    if kira_pokemon[1].species == :SANDOLIN
      kira_pokemon[0], kira_pokemon[1] = kira_pokemon[1], kira_pokemon[0]
    elsif kira_pokemon[2].species == :SANDOLIN
      kira_pokemon[0], kira_pokemon[2] = kira_pokemon[2], kira_pokemon[0]
    end
  end
  kira_pokemon[0].heal

  pbModifier.optimize
  pbModifier.hpmult = 5.0
  pbModifier.moves = [:ROCKTOMB,:ROCKTHROW,:WINGATTACK,:QUICKATTACK]

  t = BossTrigger.new(:Start)
  t.effect(BossEff_Dialog.new(t, "CH4_DESERT", 11))
  pbBoss.add(t)
end

def pbTestBoss
  pbBossGeneral
  pbModifier.hpmult = 10.0

  t = BossTrigger.new(:Any)
  t.max_activations = 0

  e = BossEff_ChangeStat.new(t, [:ATTACK, :SPECIAL_ATTACK], [2, 1])

  gauge = BossGauge.new(:Full, "Test 1", "hp", 100, 50)

  pbBoss.add_gauge(gauge)
  pbBoss.add_gauge(BossGauge.new(:Half, "Test 2", "hp", 200, 100))
  pbBoss.add_gauge(BossGauge.new(:Half, "Test 3", "hp", 300, 100))
  pbBoss.add_gauge(BossGauge.new(:Long, "Test 4", "hp", 400, 100))

  t = BossTrigger.new(:Damaged)
  t.requires(BossReq_Gauge.new(t, gauge, :<, 100))
  t.effect(BossEff_Gauge.new(t, gauge, :+, 30))
  #pbBoss.add(t)

  t2 = BossTrigger.new(:Gauge)
  t2.requires(BossReq_Gauge.new(t2, gauge, :==, 100))
  t2.effect(BossEff_RemoveGauge.new(t2, gauge))
  t2.effect(BossEff_AddTrigger.new(t2, t))
  pbBoss.add(t)

  pbWildBattle(:MAGIKARP, 10)
end

def pbStoryBossElianaAzelf
  t = BossTrigger.new(:Start, 1)
  t.max_activations = 1
  t.effect(BossEff_Message.new(t, "Azelf is holding back against you!"))
  levels = -3
  levels = -2 if $PokemonSystem.difficulty == 1
  levels = -1 if $PokemonSystem.difficulty == 2
  t.effect(BossEff_ChangeStat.new(t, [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED], levels))
  pbBoss.add(t)
end