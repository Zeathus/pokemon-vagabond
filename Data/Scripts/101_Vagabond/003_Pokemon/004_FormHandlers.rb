def pbElementalOrbs(pkmn, bitmap)
  orbs = [nil, nil, nil, nil]
  for i in 0...pkmn.moves.length
    case pkmn.moves[i].type
    when :GROUND
      orbs[i] = "VENUS"
    when :FLYING
      orbs[i] = "JUPITER"
    when :FIRE
      orbs[i] = "MARS"
    when :WATER
      orbs[i] = "MERCURY"
    end
  end
  front_sprite_filename = GameData::Species.front_sprite_filename(
    pkmn.species, pkmn.form, pkmn.gender, pkmn.shiny?, pkmn.shadowPokemon?
  ).gsub(".png", "")
  for i in 0...4
    next if orbs[i].nil?
    orb_bitmap = AnimatedBitmap.new(_INTL("{1}_ORB_{2}_{3}", front_sprite_filename, i + 1, orbs[i]))
    bitmap.blt(0, 0, orb_bitmap.bitmap, Rect.new(0, 0, orb_bitmap.width, orb_bitmap.height))
    orb_bitmap.dispose
  end
end

MultipleForms.register(:RIBOMBEE, {
  "alterBitmap" => proc { |pkmn, bitmap|
    next if pkmn.form != 1
    pbElementalOrbs(pkmn, bitmap)
  }
})