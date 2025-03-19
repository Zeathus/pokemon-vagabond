def pbNekaneGainTrait(trait)

  words = []
  if trait == "emotion"
    words = [
      "Joy",
      "Sadness",
      "Anger",
      "Guilt",
      "Envy",
      "Happiness",
      "Trust",
      "Fear",
      "Disgust",
      "Surprise",
      "Anticipation",
      "Grief",
      "Uncertainy",
      "Worry",
      "Love",
      "Hate"
    ]
  elsif trait == "willpower"
    words = [
      "Strength",
      "Want",
      "Determination",
      "Focus",
      "Ambition",
      "Initiative",
      "Yearning",
      "Drive",
      "Aspiration",
      "Desire",
      "Dream",
      "Hope",
      "Purpose",
      "Wish",
      "Urge",
      "Passion"
    ]
  elsif trait == "knowledge"
    words = [
      "Learning",
      "Memory",
      "Curiosity",
      "Intelligence",
      "Insight",
      "Wisdom",
      "Intuition",
      "Thought",
      "Logic",
      "Reasoning",
      "Reflection",
      "Deduction",
      "Ponder",
      "Information",
      "Study",
      "Cognition"
    ]
  end

  words = words.shuffle

  background_bitmap = Graphics.snap_to_bitmap

  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 999999

  background = Sprite.new(viewport)
  background.bitmap = background_bitmap
  background.ox = Graphics.width / 2
  background.oy = Graphics.height / 2
  background.x = Graphics.width / 2
  background.y = Graphics.height / 2
  background.z = 0

  start_angles = []
  for i in 0...64
    start_angles.push(i * (Math::PI + Math::PI / 8))
  end
  start_angles = start_angles.shuffle

  word_sprites = []
  start_coords = []
  for i in 0...64
    sprite = Sprite.new(viewport)
    sprite.bitmap = Bitmap.new(160, 32)
    sprite.ox = sprite.bitmap.width / 2
    sprite.oy = sprite.bitmap.height / 2
    start_coords.push([
      Graphics.width / 2 + Math.sin(start_angles[i]) * 400,
      Graphics.height / 2 + Math.cos(start_angles[i]) * 360
    ])
    sprite.x = start_coords[i][0]
    sprite.y = start_coords[i][1]
    sprite.z = 1
    sprite.opacity = 0
    sprite.zoom_x = 3.0
    sprite.zoom_y = 3.0
    pbSetSystemFont(sprite.bitmap)
    pbDrawTextPositions(sprite.bitmap, [[words[i % 16], 80, 4, :center, Color.new(248, 248, 248), Color.new(0, 0, 0), 1]])
    word_sprites.push(sprite)
  end

  # Zoom in
  start_time = System.uptime
  time_now = start_time
  while time_now - start_time < 0.25
    progress = (time_now - start_time) * 4
    background.zoom_x = 1.0 + progress
    background.zoom_y = 1.0 + progress
    Graphics.update
    Input.update
    viewport.update
    background.update
    time_now = System.uptime
  end
  background.zoom_x = 2
  background.zoom_y = 2

  pbSEPlay("fog2", 80, 50)
  # Send words in towards the center
  start_time = System.uptime
  time_now = start_time
  last_time = time_now
  between_words = 0.1
  word_time = 1.0
  while time_now - start_time < 7.4
    if ((last_time - start_time) * 2).floor != ((time_now - start_time) * 2).floor && time_now - start_time < 7.0
      pbSEPlay("fog2", 80, 50 + ((time_now - start_time) * 2).floor * 10)
    end
    progress = (time_now - start_time)
    for i in 0...64
      sprite = word_sprites[i]
      word_progress = 0
      if progress >= i * between_words + word_time
        word_progress = 1
      elsif progress >= i * between_words
        word_progress = (progress - i * between_words) / word_time
      end
      sprite.x = start_coords[i][0] * (1.0 - word_progress) + (Graphics.width / 2) * word_progress
      sprite.y = start_coords[i][1] * (1.0 - word_progress) + (Graphics.height / 2) * word_progress
      sprite.zoom_x = 3.0 * (1.0 - word_progress)
      sprite.zoom_y = 3.0 * (1.0 - word_progress)
      sprite.opacity = 255 * word_progress * 2
      sprite.update
    end
    viewport.update
    Graphics.update
    Input.update
    last_time = time_now
    time_now = System.uptime
  end
  pbSEPlay("Recovery")

  start_time = System.uptime
  time_now = start_time
  while time_now - start_time < 0.5
    Graphics.update
    Input.update
    time_now = System.uptime
  end

  # Zoom out
  start_time = System.uptime
  time_now = start_time
  while time_now - start_time < 0.25
    progress = (time_now - start_time) * 4
    background.zoom_x = 2.0 - progress
    background.zoom_y = 2.0 - progress
    Graphics.update
    Input.update
    viewport.update
    background.update
    time_now = System.uptime
  end
  background.zoom_x = 1
  background.zoom_y = 1

  for i in 0...32
    word_sprites[i].dispose
  end
  background.dispose
  viewport.dispose

end