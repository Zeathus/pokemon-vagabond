def pbPlayer2vsDuke
  party = [
    createPartyPokemon(PBParty::Player2,:ABSOL,56,[],1,:ADAMANT,0,[3,3,3,3,3,3]),
    createPartyPokemon(PBParty::Player2,:GARGANACL,55,[],0,:ADAMANT,0,[3,3,3,3,3,3]),
    createPartyPokemon(PBParty::Player2,:KYUREM,60,[],0,:MODEST,0,[3,3,3,3,3,3])
  ]
  party[0].moves = [
    Pokemon::Move.new(:NIGHTSLASH)
  ]
  party[0].item = :RAZORCLAW
  party[1].moves = [
    Pokemon::Move.new(:EARTHQUAKE)
  ]
  party[2].moves = [
    Pokemon::Move.new(:ICEBEAM)
  ]
  $game_variables[PARTY_POKEMON][PBParty::Player2] = party
  setBattleRule("1v1")
  setBattleRule("playeruseai")
  setBattleRule("canlose")
  setBattleRule("noexp")
  setBattleRule("nomoney")
  setBattleRule("noplayerlevelupdate")

  t = BossTrigger.new(:Start, [0, 1])
  t.effect(BossEff_Dialog.new(t, "CH8_INTERMISSION1", 3))
  t.max_activations = 1
  pbBoss.add(t)

  t = BossTrigger.new(:EndOfTurn, [0, 1])
  t.effect(BossEff_Dialog.new(t, "CH8_INTERMISSION1", 4))
  t.effect(BossEff_Eval.new(t, "triggerer.pbOwnSide.effects[PBEffects::LuckyChant] = 10"))
  t.effect(BossEff_Eval.new(t, "triggerer.pbOpposingSide.effects[PBEffects::LuckyChant] = 10"))
  t.max_activations = 1
  pbBoss.add(t)

  t = BossTrigger.new(:EndOfTurn, [0, 1])
  t.requires(BossReq_TurnCount.new(t, 2))
  t.effect(BossEff_Dialog.new(t, "CH8_INTERMISSION1", 5))
  t.max_activations = 1
  pbBoss.add(t)

  t = BossTrigger.new(:EndOfTurn, [0, 1])
  t.requires(BossReq_TurnCount.new(t, 3))
  t.effect(BossEff_Dialog.new(t, "CH8_INTERMISSION1", 6))
  t.max_activations = 1
  pbBoss.add(t)

  TrainerBattle.start(:FORETELLER2, "Duke")
end