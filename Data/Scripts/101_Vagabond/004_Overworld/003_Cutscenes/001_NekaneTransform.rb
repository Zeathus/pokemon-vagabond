def pbSceneNekaneTransform

  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999

  sprites = {}

  sprites["bg"] = Sprite.new(viewport)
  sprites["bg"].z = 0
  sprites["bg"].opacity = 0
  sprites["bg"].bitmap = Bitmap.new(Graphics.width,Graphics.height)
  sprites["bg"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0))

  sprites["bg2"] = IconSprite.new(0,0,viewport)
  sprites["bg2"].z = 1
  sprites["bg2"].opacity = 200
  sprites["bg2"].tone = Tone.new(6,-40,-86,200)
  sprites["bg2"].setBitmap("Graphics/Pictures/nekane_memory")
  sprites["bg2"].visible = false
  sprites["bg2"].src_rect = Rect.new(0,0,512,384)

  sprites["shine"] = IconSprite.new(0,0,viewport)
  sprites["shine"].setBitmap("Graphics/Pictures/evolutionshine")
  sprites["shine"].opacity = 0
  sprites["shine"].z = 5
  sprites["shine"].x = Graphics.width/2
  sprites["shine"].y = Graphics.height/2
  sprites["shine"].ox = Graphics.width
  sprites["shine"].oy = Graphics.height

  nekane_x = Graphics.width / 2 - 40
  nekane_y = Graphics.height / 2 - 60 - 12
  sprites["nekane"] = IconSprite.new(nekane_x,nekane_y,viewport)
  sprites["nekane"].setBitmap("Graphics/Pictures/nekane_transform")
  sprites["nekane"].src_rect = Rect.new(0,0,80,120)
  sprites["nekane"].opacity = 0
  sprites["nekane"].z=4
  sprites["nekane_prev"] = IconSprite.new(nekane_x,nekane_y,viewport)
  sprites["nekane_prev"].setBitmap("Graphics/Pictures/nekane_transform_prev")
  sprites["nekane_prev"].src_rect = Rect.new(0,0,80,120)
  sprites["nekane_prev"].z=3

  sparkle1 = Color.new(250,250,255,250)
  sparkle2 = Color.new(250,250,255,180)
  sparkle3 = Color.new(250,250,255,100)
  sparkle_x = Graphics.width / 2 - 4
  sparkle_y = nekane_y + 48

  for i in -3..3
    sname=_INTL("sparkle{1}",i)
    sprites[sname] = Sprite.new(viewport)
    bm = Bitmap.new(8,8)
    bm.fill_rect(0,0,8,8,sparkle3)
    bm.fill_rect(2,0,4,8,sparkle2)
    bm.fill_rect(0,2,8,4,sparkle2)
    bm.fill_rect(2,2,4,4,sparkle1)
    sprites[sname].bitmap = bm
    sprites[sname].x = sparkle_x
    sprites[sname].y = sparkle_y + i*10
    sprites[sname].z = 6
    sprites[sname].opacity = 0
  end

  for e in $game_map.events.values
    if e.id == @event_id
      e.character_name = ""
      e.update
      e.refresh
      break
    end
  end

  for i in 0...1536
    sprites["nekane"].src_rect.x = 80 if i % 48 == 0
    sprites["nekane"].src_rect.x = 0 if i % 48 == 24
    sprites["nekane_prev"].src_rect.x = 80 if i % 48 == 0
    sprites["nekane_prev"].src_rect.x = 0 if i % 48 == 24
    sprites["nekane"].opacity += 1 if sprites["nekane"].opacity < 240 && i <= 1200
    sprites["nekane"].opacity -= 1 if sprites["nekane"].opacity > 0 && i > 1200
    for j in -3..3
      sprite = sprites[_INTL("sparkle{1}",j)]
      if i > 1200
        opacity = 255 - (4-j.abs) * (i-1200) * 2
        sprite.opacity = opacity < 0 ? 0 : opacity
      else
        opacity = (4-j.abs) * i * 2
        sprite.opacity = opacity > 255 ? 255 : opacity
      end
      sprite.x = sparkle_x + Math.sin((i/(7.0-j.abs)+j)*0.65)*(40-j.abs*4)
      y_sin = Math.sin((i/(7.0-j.abs)*0.65)+Math::PI/2.0+j)
      sprite.y = sparkle_y + j*10 + y_sin*(24-j.abs*2)
      sprite.z = y_sin < 0 ? 2 : 6
    end
    sprites["bg"].opacity = i < 72 ? 0 : (i - 72 > 200 ? 200 : i - 72) if i <= 1200
    if i > 282 && i <= 840
      zoom = ((i-282.0)*1.0)/40.0
      zoom = 1.0 if zoom > 1.0
      sprites["shine"].angle += 1.4
      sprites["shine"].zoom_x = zoom
      sprites["shine"].zoom_y = zoom
      sprites["shine"].opacity = 255
      sprites["nekane"].src_rect.y = 240 if i == 560
      sprites["nekane_prev"].src_rect.y = 120 if i == 560
    elsif i > 840
      zoom = 1.0-((i-840.0)*1.0)/40.0
      zoom = 0.0 if zoom < 0.0
      sprites["shine"].angle += 1.4
      sprites["shine"].zoom_x = zoom
      sprites["shine"].zoom_y = zoom
    end
    sprites["bg2"].visible = true if i==930
    sprites["bg2"].src_rect.y += 384 if i==966 || i==1002 || i==1038 || i==1074
    if i > 1080
      sprites["bg2"].opacity-=3
    end
    if i > 1200
      sprites["bg"].opacity -= 3
    end
    Graphics.update
    Input.update
    viewport.update
  end

  pbDisposeSpriteHash(sprites)
  viewport.dispose

end