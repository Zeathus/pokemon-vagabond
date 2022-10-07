ItemHandlers::BattleUseOnPokemon.add(:BAKEDBALM,proc { |item,pokemon,battler,choices,scene|
    next pbBattleHPItem(pokemon,battler,pokemon.totalhp-pokemon.hp,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:PECHERIPASTRY,proc { |item,pokemon,battler,choices,scene|
    next pbBattleHPItem(pokemon,battler,pokemon.happiness,scene)
})

ItemHandlers::BattleUseOnPokemon.add(:MUSHROOMMUFFIN,proc { |item,pokemon,battler,choices,scene|
    next pbBattleHPItem(pokemon,battler,100,scene)
})