def pbBossDefeated?(boss)
  if $game_variables[BOSSES_DEFEATED].is_a?(Numeric)
    $game_variables[BOSSES_DEFEATED] = {}
  end
  return false if !$game_variables[BOSSES_DEFEATED].key?(boss)
  return $game_variables[BOSSES_DEFEATED][boss]
end

def pbSetBossDefeated(boss)
  if $game_variables[BOSSES_DEFEATED].is_a?(Numeric)
    $game_variables[BOSSES_DEFEATED] = {}
  end
  return $game_variables[BOSSES_DEFEATED][boss] = true
end

def pbPokemonBossBGM
  $PokemonGlobal.nextBattleBGM="Battle! VS Wild Strong Pokemon (Hero Encore)"
end

def pbRuinBossLevel
  level = 14
  level += pbGet(RUINS_DONE)*6
  level = 80 if level > 80
  return level
end

def pbBossGeneral
  setBattleRule("2v1")
  pbPokemonBossBGM
  $game_variables[WILD_AI_LEVEL] = 100
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
  pbBossGeneral
  pbModifier.optimize
  pbModifier.hpmult = 3.0
  pbModifier.moves = [
    :ROLLOUT,
    :DEFENSECURL
  ]

  # Start: Gets +2 Defense/Sp.Def
  # If hit by a Physical attack, +Defense/-Sp.Def
  # If hit by a Special attack, +Sp.Def/-Defense

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
  pbBossGeneral
  pbModifier.hpmult = 2.0

  # Start: Gets +4 Attack/Speed
  # Each Turn: -1 Defense/Sp.Def
  # Goes back to +4 Attack/Speed when at -2 Attack/Speed

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
  pbBossGeneral
  pbModifier.hpmult = 3.0
  pbModifier.moves = [
    :SPIKES,
    :STEALTHROCK,
    :STEELWING,
    :DRILLPECK
  ]

  # Start: Lays Stealth Rock and 3 spike layers
  # Each Turn: Uses Whirlwind

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
  pbBossGeneral
  pbModifier.hpmult = 3.0
  pbModifier.hpmult += ($game_variables[RUINS_DONE] / 4.0).floor
  pbModifier.moves = [
    :SPITE,
    :TORMENT,
    :FOULPLAY,
    :SHADOWSNEAK
  ]

  # Each Turn: Uses Spite
  pbBoss.add(
    [:Start],
    [:Message,"NAME emits an aura that sends shivers down your spine."],
    [:Message,"Be mindful of your PP."])
  pbBoss.add(
    [:Interval,1],
    [:UseMove,:SPITE])
end

# --- Darmanitan ---
def pbBossRuinFire
  pbBossGeneral
  pbModifier.hpmult = 1.0
  pbModifier.moves = [
    :BULKUP
  ]
  pbModifier.item = :ZENCHARM
  pbModifier.ability = 2

  # Start: Increases defenses and is in Zen forme
  # Each Turn: Has only Bulk Up
  # When at low HP, turns aggressive and changes moves

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

# --- Chimecho ---
def pbBossSmokeyForest
  pbBossGeneral
  # Start: Sets infinite Misty Terrain and gains Pixilate
  # Each Turn: Powers up Echoed Voice one turn
  pbBoss.add(
    [:Start],
    [:Terrain,:MistyTerrain,999],
    [:Message,"The forest is covered in mist."],
    [:Ability,:PIXILATE],
    [:Message,"What's this?"],
    [:Message,"The Chimecho has Pixilate!"])
  pbBoss.add(
    [:Interval,1],
    [:Message,"Chimecho's voice echoes through the forest."],
    [:AddField,:EchoedVoiceCounter,1])
  pbBoss.add(
    [:Timed,1],
    [:Message,"Echoed Voice grows in power."])
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
    :HYDROPUMP,
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
    :LEAFSTORM,
    :SHOCKWAVE,
    :THUNDERWAVE,
    :HEX
  ]
  pbModifier.next.next.item = :WHITEHERB

  pbModifier.form = 2
  pbModifier.next.next.form = 5
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
  pbModifier.ability = 0
  pbModifier.item = :SITRUSBERRY
  pbModifier.gender = 1
  pbModifier.nature = :TIMID
  pbBoss.add(
    [:Start],
    [:Message,"The clear skies shine on the outlook."],
    [:Weather, :Sun],
    [:Message,"Tropius is speeding up due to its Chlorophyll."]
  )
  pbBoss.add(
    [:Interval, 1],
    [:If, "battle.field.weather != :Sun"],
    [:Message,"The clear skies shine on the outlook."],
    [:Weather, :Sun]
  )
  pbBoss.add(
    [:Timed, 2],
    [:Message, "Tropius' ability changed to Solar Power!"],
    [:Ability, :SOLARPOWER]
  )
  pbBoss.add(
    [:HP, 100],
    [:Message, "Tropius' ability changed to Harvest!"],
    [:Ability, :HARVEST]
  )
end

def pbPuzzleBossDeino
  pbBossGeneral
  pbModifier.gender=0
  pbModifier.hpmult=0.20
  pbBoss.add(
    [:Start],
    [:Message, "NAME is weak and afraid."]
  )
  pbBoss.add(
    [:Sturdy, 1]
  )
  pbBoss.add(
    [:HP, 10],
    [:WinBattle]
  )
  pbBoss.add(
    [:Damaged],
    [:If, "boss.hp<=boss.totalhp/10"],
    [:WinBattle]
  )
  pbBoss.add(
    [:Custom, "boss.hp>=boss.totalhp/3"],
    [:Custom, "$game_variables[2]=1"],
    [:WinBattle]
  )
end

def pbMiniBossRotom(form=0)
  pbBossGeneral
  pbModifier.hpmult = 2.0
  moveset = [
    :THUNDERSHOCK,
    :UPROAR,
    :DOUBLETEAM
  ]
  if $game_variables[BADGE_COUNT] > 0
    moveset[2] = :THUNDERWAVE
    moveset[3] = :ELECTROBALL
  end
  if $game_variables[BADGE_COUNT] > 1
    moveset[1] = :HEX
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
    :BITE,
    :LEECHSEED
  ]
end

def pbMiniBossAbsol
  pbBossGeneral
  pbModifier.hpmult = 2.0
  pbModifier.nature = :MODEST
  pbModifier.moves = [
    :SLASH,
    :KNOCKOFF,
    :QUICKATTACK,
    :LEER
  ]
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


