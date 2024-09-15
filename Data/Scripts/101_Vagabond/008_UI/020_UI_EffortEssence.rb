class EffortEssence_Scene
  ITEMTEXTBASECOLOR     = Color.new(248, 248, 248)
  ITEMTEXTSHADOWCOLOR   = Color.new(0, 0, 0)
  UITEXTBASECOLOR       = Color.new(56, 56, 56)
  UITEXTSHADOWCOLOR     = Color.new(176, 176, 192)
  ITEM_COST             = [20, 40, 80]
  ESSENCE_COLORS = {
    :HP => Color.new(255, 89, 89),
    :ATTACK => Color.new(245, 172, 120),
    :DEFENSE => Color.new(249, 234, 177),
    :SPECIAL_ATTACK => Color.new(157, 183, 245),
    :SPECIAL_DEFENSE => Color.new(167, 219, 141),
    :SPEED => Color.new(250, 146, 178)
  }

  def pbStartScene
    @stats = [:HP, :ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED]
    @index = 0
    @press_time = 0
    @bubble_time = 0
    @essence_counts = pbGetEffortEssence
    @shake_start_time = 0
    @viewport_dark = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport_dark.z = 99997
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99998
    @viewport_item = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport_item.z = 99999
    @sprites = {}
    @sprites["darken"] = Sprite.new(@viewport_dark)
    @sprites["darken"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @sprites["darken"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
    @sprites["darken"].opacity = 0
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/UI/EffortEssence/bg")
    @sprites["foreground"] = IconSprite.new(0, 0, @viewport)
    @sprites["foreground"].setBitmap("Graphics/UI/EffortEssence/fg")
    @sprites["foreground"].z = 3
    @sprites["essence"] = Sprite.new(@viewport)
    @sprites["essence"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @sprites["essence"].z = 1
    for i in 0...6
      sprite = IconSprite.new(0, 0, @viewport)
      sprite.setBitmap("Graphics/UI/EffortEssence/bubbles")
      sprite.src_rect = Rect.new(32 * i, 0, 32, 224)
      sprite.z = 2
      @sprites["bubbles_" + @stats[i].to_s] = sprite

      for j in 0...3
        item = Supplementals::EFFORT_LEVEL_INCREASE_ITEMS[@stats[i]][j]
        sprite = ItemIconSprite.new(192 + 68 * i, 296 + 56 * j, item, @viewport)
        sprite.setOffset(PictureOrigin::TOP_LEFT)
        sprite.z = 5
        @sprites["item_" + @stats[i].to_s + j.to_s] = sprite
        pbSetScreenOrigin(sprite, 186, 464)
      end
    end
    @sprites["essence_border"] = Sprite.new(@viewport)
    @sprites["essence_border"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @sprites["essence_border"].z = 4
    @sprites["control_buy"] = KeybindSprite.new(Input::USE, "Create Item", 590, 304, @viewport)
    @sprites["control_exit"] = KeybindSprite.new(Input::BACK, "Exit", 590, 304 + 36, @viewport)
    pbSetScreenOrigin(
      [@sprites["background"], @sprites["foreground"],
       @sprites["essence"], @sprites["essence_border"],
       @sprites["control_buy"], @sprites["control_exit"]],
      186, 464
    )
    @sprites["arrow_right"] = AnimatedSprite.new("Graphics/UI/right_arrow", 8, 40, 28, 2, @viewport)
    @sprites["arrow_right"].visible = false
    @sprites["arrow_right"].z = 6
    @sprites["arrow_left"] = AnimatedSprite.new("Graphics/UI/right_arrow", 8, 40, 28, 2, @viewport)
    @sprites["arrow_left"].visible = false
    @sprites["arrow_left"].zoom_x = -1
    @sprites["arrow_left"].z = 6
    @sprites["button"] = IconSprite.new(0, 0, @viewport)
    @sprites["button"].setBitmap("Graphics/UI/EffortEssence/button_pressed")
    @sprites["button"].z = 4
    @sprites["button"].visible = false
    @sprites["help_box"] = IconSprite.new(0, 0, @viewport_item)
    @sprites["help_box"].setBitmap("Graphics/UI/EffortEssence/help_box")
    @sprites["itemicon"] = ItemIconSprite.new(112, Graphics.height - 48, nil, @viewport_item)
    @sprites["itemtext"] = Window_UnformattedTextPokemon.newWithSize(
      "", 140, 464, Graphics.width - 224, 128, @viewport_item
    )
    @sprites["itemtext"].baseColor   = ITEMTEXTBASECOLOR
    @sprites["itemtext"].shadowColor = ITEMTEXTSHADOWCOLOR
    @sprites["itemtext"].visible     = true
    @sprites["itemtext"].windowskin  = nil
    @output_items = []
    @essences = AnimatedBitmap.new(_INTL("Graphics/UI/EffortEssence/essence"))
    @essence_borders = AnimatedBitmap.new(_INTL("Graphics/UI/EffortEssence/essence_border"))
    pbRefresh

    # OPENING ANIMATION
    @viewport.rect.x += 768
    @viewport_item.rect.y = 128

    start_time = System.uptime
    pbSEPlay("GUI party switch")
    while true
      Graphics.update
      Input.update
      progress = [(System.uptime - start_time) * 100, 16].min
      @viewport.update
      @viewport.rect.x = 768 - 768 * progress / 16
      @viewport_item.rect.y = 128 - 128 * progress / 16
      break if progress >= 16
    end

    start_time = System.uptime
    time_now = start_time
    while true
      finish = (time_now - start_time >= Math::PI / 8)
      angle = finish ? 0 : (Math.sin(Math::PI / 4 + (time_now - start_time) * 4) - Math.sin(Math::PI / 4)) * 15
      Graphics.update
      Input.update
      @viewport.update
      @sprites["background"].angle = angle
      @sprites["foreground"].angle = angle
      @sprites["essence"].angle = angle
      @sprites["essence_border"].angle = angle
      @sprites["control_buy"].angle = angle
      @sprites["control_exit"].angle = angle
      for j in 0...6
        @sprites["bubbles_" + @stats[j].to_s].angle = angle
        for k in 0...3
          @sprites["item_" + @stats[j].to_s + k.to_s].angle = angle
        end
      end
      @sprites["darken"].opacity = [(120 * (time_now - start_time)) / (Math::PI / 8), 120].min
      time = System.uptime
      pbUpdateBubbles(time - time_now)
      time_now = time
      break if finish
    end
    pbSEPlay("Player bump")

    @sprites["arrow_right"].visible = true
    @sprites["arrow_right"].play
    @sprites["arrow_left"].visible = true
    @sprites["arrow_left"].play

    pbMain
  end

  def pbMain
    last_time = System.uptime
    last_choice = 0
    loop do
      time = System.uptime
      choice = pbUpdate(time - last_time)
      if choice > 0
        if @essence_counts[pbGetStat] >= pbGetCost
          pbSEPlay("Battle ball shake")
          $bag.add(pbGetItem)
          @essence_counts[pbGetStat] -= pbGetCost
          pbCreateItemSprite(pbGetItem)
          @shake_start_time = time
          pbRefresh
          last_choice = 1
        elsif choice == 1 || last_choice != choice
          pbSEPlay("GUI sel buzzer")
          last_choice = 2
        end
      elsif choice == -1
        break
      end
      last_time = time
    end
  end

  def pbCreateItemSprite(item)
    sprite = ItemIconSprite.new(214, 424, item, @viewport)
    sprite.z = 2
    start_angle = rand() * 360
    @output_items.push([0, start_angle, sprite])
  end

  def pbUpdateBubbles(delta)
    @bubble_time += delta
    while @bubble_time >= 0.07
      @bubble_time -= 0.07
      for i in 0...6
        bubbles = @sprites["bubbles_" + @stats[i].to_s]
        bubbles.src_rect.y = (bubbles.src_rect.y + 1)
        bubbles.src_rect.y -= 144 if bubbles.src_rect.y > 144
      end
    end
  end

  def pbUpdateItems(delta)
    for item in @output_items
      item[0] += delta
      time = item[0]
      sprite = item[2]
      sprite.angle = item[1] + time * 120
      sprite.x = 214 - time * 300
      if time > 0.25
        sprite.x += ((time - 0.25) * 100)
        sprite.y = 424 + ((time - 0.25) * 10)**3
      end
    end
    for i in 0...@output_items.length
      j = @output_items.length - i - 1
      time = @output_items[j][0]
      if time > 1
        @output_items[j][2].dispose
        @output_items.delete_at(j)
      end
    end
  end

  def pbUpdateShake
    return if @shake_start_time == 0
    time = System.uptime - @shake_start_time
    time *= 20
    angle = (time >= Math::PI) ? 0 : (Math.sin(time) / 2)
    @sprites["background"].angle = angle
    @sprites["foreground"].angle = angle
    @sprites["essence"].angle = angle
    @sprites["essence_border"].angle = angle
    for j in 0...6
      @sprites["bubbles_" + @stats[j].to_s].angle = angle
      for k in 0...3
        @sprites["item_" + @stats[j].to_s + k.to_s].angle = angle
      end
    end
    @sprites["button"].angle = angle
    if (time >= Math::PI)
      @shake_start_time = 0
    end
  end

  def pbUpdate(delta)
    Graphics.update
    Input.update
    @viewport.update
    pbUpdateSpriteHash(@sprites)
    pbUpdateBubbles(delta)
    pbUpdateItems(delta)
    pbUpdateShake()
    old_index = @index
    if Input.trigger?(Input::USE)
      @sprites["button"].visible = true
      @press_time = 0
      return 1
    elsif Input.press?(Input::USE)
      @press_time += delta
      if @press_time >= 0.5 && ((@press_time - delta) * 4).floor < (@press_time * 4).floor
        return 2
      end
    else
      @sprites["button"].visible = false
    end
    if Input.trigger?(Input::BACK)
      return -1
    end
    if Input.repeat?(Input::RIGHT)
      if Input.trigger?(Input::RIGHT) || @index % 6 < 5
        @index = (@index / 6) * 6 + (@index + 1) % 6
        pbRefresh
      end
    end
    if Input.repeat?(Input::LEFT)
      if Input.trigger?(Input::LEFT) || @index % 6 > 0
        @index = (@index / 6) * 6 + (@index - 1) % 6
        pbRefresh
      end
    end
    if Input.repeat?(Input::DOWN)
      if Input.trigger?(Input::DOWN) || @index < 12
        @index = (@index + 6) % 18
        pbRefresh
      end
    end
    if Input.repeat?(Input::UP)
      if Input.trigger?(Input::UP) || @index >= 6
        @index = (@index - 6) % 18
        pbRefresh
      end
    end
    if old_index != @index
      pbPlayCursorSE
    end
    return 0
  end

  def pbRefresh
    @sprites["essence"].bitmap.clear
    @sprites["essence_border"].bitmap.clear
    textpos = []
    item = pbGetItem
    @sprites["itemicon"].item = item
    @sprites["itemtext"].text = GameData::Item.get(item).name + ": " + GameData::Item.get(item).description.sub(". ", ".\n")
    for i in 0...6
      fill = ((@essence_counts[@stats[i]] / 1000.0) * 112).floor * 2
      bubbles = @sprites["bubbles_" + @stats[i].to_s]
      @sprites["essence"].bitmap.blt(198 + 68 * i, 34 + 224 - fill, @essences.bitmap, Rect.new(36 * i, 224 - fill, 36, fill))
      if fill > 2
        @sprites["essence"].bitmap.fill_rect(198 + 68 * i, 34 + 224 - fill, 36, 2, ESSENCE_COLORS[@stats[i]])
      end
      bubbles.x = 200 + i * 68
      bubbles.y = 34 + 224 - fill
      pbSetScreenOrigin(bubbles, 186, 464)
      bubbles.src_rect.height = fill
      @sprites["essence_border"].bitmap.blt(198 + 68 * i, 34 + 224 - fill, @essence_borders.bitmap, Rect.new(36 * i, 224 - fill, 36, fill))
      textpos.push([@essence_counts[@stats[i]].to_s, 216 + i * 68, 268, :center, UITEXTBASECOLOR, UITEXTSHADOWCOLOR])
    end
    textpos.push(["Cost:", 64, 310, :left, UITEXTBASECOLOR, UITEXTSHADOWCOLOR])
    textpos.push(["In Bag:", 64, 310 + 36, :left, UITEXTBASECOLOR, UITEXTSHADOWCOLOR])
    textpos.push([pbGetCost.to_s, 172, 310, :right, UITEXTBASECOLOR, UITEXTSHADOWCOLOR])
    textpos.push([$bag.quantity(item).to_s, 172, 310 + 36, :right, UITEXTBASECOLOR, UITEXTSHADOWCOLOR])
    pbSetSystemFont(@sprites["essence"].bitmap)
    pbDrawTextPositions(@sprites["essence"].bitmap, textpos)
    @sprites["arrow_right"].x = 162 + (@index % 6) * 68
    @sprites["arrow_right"].y = 306 + (@index / 6) * 56
    @sprites["arrow_left"].x = @sprites["arrow_right"].x + 108
    @sprites["arrow_left"].y = @sprites["arrow_right"].y
    @sprites["button"].x = 190 + (@index % 6) * 68
    @sprites["button"].y = 294 + (@index / 6) * 56
    pbSetScreenOrigin(@sprites["button"], 186, 464)
  end

  def pbGetItem
    return Supplementals::EFFORT_LEVEL_INCREASE_ITEMS[@stats[@index % 6]][@index / 6]
  end

  def pbGetCost
    return [20, 40, 80][@index / 6]
  end

  def pbGetStat
    return @stats[@index % 6]
  end

  def pbEndScene
    pbSEPlay("GUI storage hide party panel")
    for i in 0...16
      Graphics.update
      Input.update
      @viewport.update
      @viewport.rect.y += 576 / 16
      @viewport_item.rect.y += 128 / 16
      @sprites["darken"].opacity -= 16
    end
    pbDisposeSpriteHash(@sprites)
    for i in @output_items
      i[2].dispose
    end
    @viewport.dispose
    @viewport_item.dispose
    @viewport_dark.dispose
    @essences.dispose
    @essence_borders.dispose
  end
end

#===============================================================================
#
#===============================================================================
class EffortEssenceScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbEndScene
  end
end

def pbStartEffortExchange
  scene = EffortEssence_Scene.new
  screen = EffortEssenceScreen.new(scene)
  screen.pbStartScreen
end

def pbGetEffortEssence
  if $game_variables[EFFORT_ESSENCE].is_a?(Numeric)
    essence = {}
    GameData::Stat.each_main { |s| essence[s.id] = 0 }
    $game_variables[EFFORT_ESSENCE] = essence
  end
  return $game_variables[EFFORT_ESSENCE]
end