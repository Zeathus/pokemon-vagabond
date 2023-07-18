def pbItemPickupAnimation(item, quantity=1)

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

  (item.is_key_item? ? 160 : 80).times do
      timer += 1.0
      sprites["item"].angle = -Math.sin(timer * 0.05) * 12
      Graphics.update
      Input.update
      viewport.update
      pbUpdateSpriteHash(sprites)
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

  16.times do
      timer += 1.0
      timer2 += 1.0
      sprites["item"].angle = -Math.sin(timer * 0.05) * 12
      sprites["bag"].opacity = timer2 * 256.0 / 16.0
      Graphics.update
      Input.update
      viewport.update
      pbUpdateSpriteHash(sprites)
  end

  sprites["bagoverlay"].opacity = 255

  x_mod = [-2, -2,  0,  0,  2,  4, 6, 4, 4, 4, 4, 2, 2, 2, 0, 0]
  y_mod = [-2, -4, -6, -6, -4, -2, 0, 2, 4, 6, 6, 6, 6, 6, 6, 8]

  for i in 0...x_mod.length * 3
      timer += 1.0
      sprites["item"].angle -= 0.05 * 24
      sprites["item"].x += x_mod[i / 3]
      sprites["item"].y += y_mod[i / 3]
      zoom -= 0.02
      sprites["item"].zoom_x = zoom
      sprites["item"].zoom_y = zoom
      if sprites["text"].opacity > 0
          sprites["text"].opacity -= 16
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
      Graphics.update
      Input.update
      viewport.update
      pbUpdateSpriteHash(sprites)
  end

  pbDisposeSpriteHash(sprites)
  viewport.dispose

end