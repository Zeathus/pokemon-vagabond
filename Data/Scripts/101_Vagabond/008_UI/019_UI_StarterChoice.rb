def pbStarterChoice(choices)

  viewport = Viewport.new(0, Graphics.height / 2, Graphics.width, 0)
  viewport.z = 99998

  bg = Sprite.new(viewport)
  bg.bitmap = Bitmap.new(Graphics.width, Graphics.height)
  bg.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
  bg.opacity = 192

  for i in 0...16
    progress = 16 - i
    viewport.rect.y -= progress
    viewport.rect.height += progress *2
    viewport.update
    bg.update
    Graphics.update
    Input.update
  end

  8.times do
    Graphics.update
    Input.update
  end

  selected = (choices.length / 2).floor

  small_zoom = 1.0
  large_zoom = 1.5
  small_tone = Tone.new(-64, -64, -64, 128)
  large_tone = Tone.new(0, 0, 0)

  pokemon = []
  pokemon_sprites = []
  max_height = 0
  choices.each do |p|
    poke = Pokemon.new(p, 10)
    sprite=PokemonSprite.new(viewport)
    sprite.setPokemonBitmap(poke)
    sprite.setOffset(PictureOrigin::CENTER)
    sprite.mirror=false
    sprite.x = Graphics.width / 2 - (192 * ((choices.length - 1) / 2.0 - pokemon.length))
    sprite.y = viewport.rect.height / 2
    sprite.opacity = 0
    if pokemon.length == selected
      sprite.zoom_x = large_zoom
      sprite.zoom_y = large_zoom
      sprite.tone = large_tone
    else
      sprite.zoom_x = small_zoom
      sprite.zoom_y = small_zoom
      sprite.tone = small_tone
    end
    pokemon.push(poke)
    pokemon_sprites.push(sprite)
  end

  16.times do
    viewport.update
    bg.update
    pokemon_sprites.each do |sprite|
      sprite.opacity += 16
      sprite.update
    end
    Graphics.update
    Input.update
  end

  description = Window_AdvancedTextPokemon.new("")
  description.viewport = viewport
  description.opacity = 0
  description.width = Graphics.width * 3 / 4
  description.height = 128
  description.text = _INTL("<ac>{1} the {2} Pokémon</ac>", pokemon[selected].name, pokemon[selected].species_data.category)
  description.x = Graphics.width / 2 - description.width / 2
  description.y = viewport.rect.height - 64

  loop do
    viewport.update
    bg.update
    Graphics.update
    Input.update
    pokemon_sprites.each do |sprite|
      sprite.update
    end
    index_changed = false
    if Input.repeat?(Input::LEFT)
      selected = (selected - 1) % pokemon.length
      index_changed = true
    elsif Input.repeat?(Input::RIGHT)
      selected = (selected + 1) % pokemon.length
      index_changed = true
    end
    if index_changed
      pbPlayCursorSE
      for i in 0...pokemon.length
        zoom = (i == selected) ? large_zoom : small_zoom
        pokemon_sprites[i].zoom_x = zoom
        pokemon_sprites[i].zoom_y = zoom
        pokemon_sprites[i].tone = (i == selected) ? large_tone : small_tone
      end
      description.text = _INTL("<ac>{1} the {2} Pokémon</ac>", pokemon[selected].name, pokemon[selected].species_data.category)
    end
    if Input.trigger?(Input::USE)
      if pbConfirmMessage(_INTL("Do you want {1} the {2} Pokémon?", pokemon[selected].name, pokemon[selected].species_data.category))
        break
      end
    end
  end

  16.times do
    viewport.update
    bg.update
    pokemon_sprites.each do |sprite|
      sprite.opacity -= 16
      sprite.update
    end
    Graphics.update
    Input.update
  end

  for i in 1..16
    viewport.rect.y += i
    viewport.rect.height -= i * 2
    viewport.update
    bg.update
    Graphics.update
    Input.update
  end

  8.times do
    Graphics.update
    Input.update
  end

  bg.dispose
  pokemon_sprites.each do |sprite|
    sprite.dispose
  end
  viewport.dispose

  return selected

end