def pbShowRewardList(header, items)
  items = items.select { |i| GameData::Item.exists?(i) }

  return if items.length <= 0

  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  sprites = {}

  headersprite = Sprite.new(viewport)
  headersprite.bitmap = Bitmap.new(Graphics.width, 48)
  headersprite.y = Graphics.height / 2 - (28 * items.length) - 30
  pbSetBoldFont(headersprite.bitmap)
  pbDrawTextPositions(headersprite.bitmap, [[
    header.upcase, Graphics.width / 2, 0, 2, Color.new(252, 252, 252), Color.new(0, 0, 0), true
  ]])
  headersprite.bitmap.fill_rect(
    Graphics.width / 2 - 128, 36, 256, 1, Color.new(252, 252, 252)
  )
  headersprite.opacity = 0
  sprites["header"] = headersprite

  for i in 0...items.length
    y = Graphics.height / 2 - (28 * items.length) + 56 * (i + 1) - 10
    itemsprite = ItemIconSprite.new(308, y, items[i], viewport)
    itemsprite.ox = 24
    itemsprite.oy = 24
    itemsprite.opacity = 0

    itemtext = Sprite.new(viewport)
    itemtext.bitmap = Bitmap.new(Graphics.width, 32)
    itemtext.x = 340
    itemtext.y = y - 14 + 32
    itemtext.opacity = 0
    pbSetSystemFont(itemtext.bitmap)
    pbDrawTextPositions(itemtext.bitmap, [[
      GameData::Item.get(items[i]).name, 2, 0, 0, Color.new(252, 252, 252), Color.new(0, 0, 0), true
    ]])

    sprites[_INTL("item{1}", i)] = itemsprite
    sprites[_INTL("itemtext{1}", i)] = itemtext
  end

  headersprite.y = Graphics.height / 2 - (28 * items.length) - 30 + 32
  start_time = System.uptime
  time_now = start_time
  while time_now - start_time < 0.5
    headersprite.y = Graphics.height / 2 - (28 * items.length) - 30 + 64 * (0.5 - (time_now - start_time))
    headersprite.opacity = (time_now - start_time) * 255 * 2
    Graphics.update
    Input.update
    viewport.update
    pbUpdateSpriteHash(sprites)
    time_now = System.uptime
  end
  headersprite.y = Graphics.height / 2 - (28 * items.length) - 30
  headersprite.opacity = 255

  pbSEPlay("Mining reveal full")
  start_time = System.uptime
  time_now = start_time
  while time_now - start_time < 0.5 + items.length * 0.2
    for i in 0...items.length
      progress = [[1.0, (time_now - start_time - i * 0.2) * 2].min, 0].max
      y = Graphics.height / 2 - (28 * items.length) + 56 * (i + 1) - 10
      itemsprite = sprites[_INTL("item{1}", i)]
      itemsprite.y = y + 32 * (1.0 - progress)
      itemsprite.opacity = progress * 255
      itemtext = sprites[_INTL("itemtext{1}", i)]
      itemtext.y = y - 14 + 32 * (1.0 - progress)
      itemtext.opacity = progress * 255
    end
    Graphics.update
    Input.update
    viewport.update
    pbUpdateSpriteHash(sprites)
    time_now = System.uptime
  end
  for i in 0...items.length
    y = Graphics.height / 2 - (28 * items.length) + 56 * (i + 1) - 10
    itemsprite = sprites[_INTL("item{1}", i)]
    itemsprite.y = y
    itemsprite.opacity = 255
    itemtext = sprites[_INTL("itemtext{1}", i)]
    itemtext.y = y - 14
    itemtext.opacity = 255
  end

  start_time = System.uptime
  while System.uptime - start_time < 1.0
    Graphics.update
    Input.update
    viewport.update
    pbUpdateSpriteHash(sprites)
  end

  pbFadeOutAndHide(sprites)

  pbDisposeSpriteHash(sprites)
  viewport.dispose

end