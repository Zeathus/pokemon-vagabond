def pbFireSpread(fire_id, burnable_id)
  player_burnt = false
  play_se = false
  to_burn = []
  for y in 0...$game_map.height
    for x in 0...$game_map.width
      if $game_map.data[x, y, 2] == fire_id
        if $game_player.x == x && $game_player.y == y
          player_burnt = true
        end
        if $game_map.data[x, y - 1, 1] == burnable_id
          to_burn.push([x, y - 1])
        end
        if $game_map.data[x - 1, y, 1] == burnable_id
          to_burn.push([x - 1, y])
        end
        if $game_map.data[x + 1, y, 1] == burnable_id
          to_burn.push([x + 1, y])
        end
        if $game_map.data[x, y + 1, 1] == burnable_id
          to_burn.push([x, y + 1])
        end
      end
    end
  end
  to_burn.each do |i|
    next if $game_map.data[i[0], i[1], 2] == fire_id
    $game_map.set_tile(i[0], i[1], 1, burnable_id + 1)
    $game_map.set_tile(i[0], i[1], 2, fire_id)
    if $game_player.x == i[0] && $game_player.y == i[1]
      player_burnt = true
    end
    play_se = true
  end
  pbSEPlay("Fire1", 70, 130) if play_se
  return player_burnt
end