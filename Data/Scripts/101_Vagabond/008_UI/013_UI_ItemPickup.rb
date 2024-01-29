def pbItemPickupAnimation(item, quantity = 1, show_description = false)

  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999

  sprites = {}

  sprites["item"] = IconSprite.new(
      Graphics.width / 2,
      Graphics.height / 2,
      viewport
  )
  sprites["item"].ox = 24
  sprites["item"].oy = 24
  sprites["item"].setBitmap(GameData::Item.icon_filename(item))
  sprites["item"].z = 2

  sprites["text"] = Sprite.new(viewport)
  sprites["text"].bitmap = Bitmap.new(Graphics.width, 96)
  pbSetSystemFont(sprites["text"].bitmap)
  itemname = item.name
  if GameData::Item.get(item).is_TM? || GameData::Item.get(item).is_HM?
      move = GameData::Item.get(item).move
      itemname = _INTL("{1} {2}", itemname, GameData::Move.get(move).name)
  elsif quantity>1
      itemname = _INTL("{1}x {2}", quantity, item.name_plural)
  end
  textpos = [
      [itemname,Graphics.width/2,32,2,Color.new(252,252,252),Color.new(0,0,0),true]
  ]
  pbDrawTextPositions(sprites["text"].bitmap, textpos)
  sprites["text"].y = Graphics.height / 2
  sprites["text"].z = 4
  sprites["text"].opacity = 0

  zoom = 0.0
  sprites["item"].zoom_x = zoom
  sprites["item"].zoom_y = zoom
  timer = 0.0

  while timer * 0.08 < 3.14 * 0.5
      timer += 1.0
      timer += 1.0 if Input.press?(Input::B)
      zoom = Math.sin(timer * 0.08) * 1.5
      sprites["item"].zoom_x = zoom
      sprites["item"].zoom_y = zoom
      angle = Math.sin(timer * 0.05 - Math::PI * 0.1)
      sprites["item"].angle = 50 - angle * 75
      if sprites["text"].opacity < 255
          sprites["text"].opacity += 16
      end
      Graphics.update
      Input.update
      viewport.update
      pbUpdateSpriteHash(sprites)
  end
  sprites["item"].zoom_x = 1.5
  sprites["item"].zoom_y = 1.5

  timer = 0.0
  if item.is_key_item?
    pbMEPlay("Key item get",100)
  else
    pbSEPlay("Item get",100)
  end

  to_do = (show_description ? 40 : (item.is_key_item? ? 160 : 80))
  i = 0
  while i < to_do
      timer += 1.0
      timer += 1.0 if Input.press?(Input::B)
      sprites["item"].angle = -Math.sin(timer * 0.05) * 12
      Graphics.update
      Input.update
      viewport.update
      pbUpdateSpriteHash(sprites)
      i += 1
      i += 1 if Input.press?(Input::B)
  end

  if show_description
    desc_viewport = Viewport.new(0, 348, Graphics.width, 2)
    desc_viewport.z = 99999
    sprites["description"] = Window_AdvancedTextPokemon.new("", 1)
    sprites["description"].viewport = desc_viewport
    sprites["description"].opacity = 0
    sprites["description"].resizeToFit(item.description, Graphics.width * 2 / 3)
    sprites["description"].text = item.description
    sprites["description"].x = Graphics.width / 2 - sprites["description"].width / 2
    sprites["description"].y = -sprites["description"].height / 2 + 6
    sprites["desc_box"] = Sprite.new(desc_viewport)
    sprites["desc_box"].bitmap = Bitmap.new(Graphics.width, sprites["description"].height)
    sprites["desc_box"].bitmap.fill_rect(0, 0, Graphics.width, sprites["description"].height, Color.new(0, 0, 0))
    sprites["desc_box"].opacity = 192
    desc_viewport.rect.y += sprites["description"].height / 2
    frames = (1..16).to_a.reverse
    frames_sum = frames.sum
    frames.each do |i|
      progress = sprites["description"].height * i / frames_sum
      sprites["description"].y += progress / 2
      desc_viewport.rect.y -= progress / 2
      desc_viewport.rect.height += progress
      timer += 1.0
      sprites["item"].angle = -Math.sin(timer * 0.05) * 12
      Graphics.update
      Input.update
      viewport.update
      desc_viewport.update
      pbUpdateSpriteHash(sprites)
    end
    loop do
      timer += 1.0
      sprites["item"].angle = -Math.sin(timer * 0.05) * 12
      Graphics.update
      Input.update
      viewport.update
      desc_viewport.update
      pbUpdateSpriteHash(sprites)
      break if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
    end
    frames = (1..16).to_a
    frames_sum = frames.sum
    frames.each do |i|
      progress = sprites["description"].height * i / frames_sum
      sprites["description"].y -= progress / 2
      desc_viewport.rect.y += progress / 2
      desc_viewport.rect.height -= progress
      timer += 1.0
      sprites["item"].angle = -Math.sin(timer * 0.05) * 12
      Graphics.update
      Input.update
      viewport.update
      desc_viewport.update
      pbUpdateSpriteHash(sprites)
    end
    sprites["description"].dispose
    sprites["desc_box"].dispose
    desc_viewport.dispose
  end

  sprites["bag"] = IconSprite.new(
      Graphics.width / 2,
      Graphics.height / 2,
      viewport
  )
  sprites["bag"].setBitmap("Graphics/Pictures/ItemPickup/bag")
  sprites["bag"].x += 32
  sprites["bag"].z = 1
  sprites["bag"].src_rect = Rect.new(68*3, 0, 68, 68)
  sprites["bag"].opacity = 0
  sprites["bag"].zoom_x = 2
  sprites["bag"].zoom_y = 2

  sprites["bagoverlay"] = IconSprite.new(
      Graphics.width / 2,
      Graphics.height / 2,
      viewport
  )
  sprites["bagoverlay"].setBitmap("Graphics/Pictures/ItemPickup/bag")
  sprites["bagoverlay"].x += 32
  sprites["bagoverlay"].z = 3
  sprites["bagoverlay"].src_rect = Rect.new(68*3, 68, 68, 68)
  sprites["bagoverlay"].opacity = 0
  sprites["bagoverlay"].zoom_x = 2
  sprites["bagoverlay"].zoom_y = 2

  timer2 = 0.0

  to_do = 16
  i = 0
  while i < to_do
      timer += 1.0
      timer += 1.0 if Input.press?(Input::B)
      timer2 += 1.0
      timer2 += 1.0 if Input.press?(Input::B)
      sprites["item"].angle = -Math.sin(timer * 0.05) * 12
      sprites["bag"].opacity = timer2 * 256.0 / 16.0
      Graphics.update
      Input.update
      viewport.update
      pbUpdateSpriteHash(sprites)
      i += 1
      i += 1 if Input.press?(Input::B)
  end

  sprites["bagoverlay"].opacity = 255

  x_mod = [-2, -2,  0,  0,  2,  4, 6, 4, 4, 4, 4, 2, 2, 2, 0, 0]
  y_mod = [-2, -4, -6, -6, -4, -2, 0, 2, 4, 6, 6, 6, 6, 6, 6, 8]

  i = 0
  while i < x_mod.length * 3
    if Input.press?(Input::B)
      timer += 2.0
      sprites["item"].angle -= 0.05 * 24 * 2
      for j in i...(i+2)
        sprites["item"].x += x_mod[j / 3] || 0
        sprites["item"].y += y_mod[j / 3] || 0
      end
      zoom -= 0.04
      sprites["item"].zoom_x = zoom
      sprites["item"].zoom_y = zoom
      if sprites["text"].opacity > 0
        sprites["text"].opacity -= 32
      end
      i += 2
    else
      timer += 1.0
      sprites["item"].angle -= 0.05 * 24
      sprites["item"].x += x_mod[i / 3] || 0
      sprites["item"].y += y_mod[i / 3] || 0
      zoom -= 0.02
      sprites["item"].zoom_x = zoom
      sprites["item"].zoom_y = zoom
      if sprites["text"].opacity > 0
        sprites["text"].opacity -= 16
      end
      i += 1
    end
    Graphics.update
    Input.update
    viewport.update
    pbUpdateSpriteHash(sprites)
  end

  sprites["item"].opacity = 0
  sprites["bagoverlay"].opacity = 0

  while sprites["bag"].opacity > 0
      sprites["bag"].opacity -= 16
      sprites["bag"].opacity -= 48 if Input.press?(Input::B)
      Graphics.update
      Input.update
      viewport.update
      pbUpdateSpriteHash(sprites)
  end

  pbDisposeSpriteHash(sprites)
  viewport.dispose

end