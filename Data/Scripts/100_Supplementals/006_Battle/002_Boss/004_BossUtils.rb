def pbBoss
  if $game_variables[Supplementals::BOSS_BATTLE].is_a?(Numeric)
    $game_variables[Supplementals::BOSS_BATTLE] = BossBattle.new
  end
  return $game_variables[Supplementals::BOSS_BATTLE]
end

def pbPokemonBossBGM
  $PokemonGlobal.nextBattleBGM = nil
end

def pbBossGeneral
  setBattleRule("2v1")
  setBattleRule("smartwildbattle")
  pbPokemonBossBGM
end