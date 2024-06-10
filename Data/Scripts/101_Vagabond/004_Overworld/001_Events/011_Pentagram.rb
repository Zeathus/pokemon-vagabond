def pbDrawPentagram(pentagram, bitmap)
  if pentagram == bitmap
    pentagram = Bitmap.new(96, 96)
  end

  corners = [[46, 20], [30, 68], [70, 38], [22, 38], [62, 68]]

  element = $game_variables[PENTAGRAM_ELEMENT]

  base, shadow = pbElementColors(element)

  parts = $game_variables[PENTAGRAM_PARTS]
  current_part = parts[parts.length - 1]
  if parts.length > 1
    parts = parts[0...(parts.length - 1)]
  else
    parts = []
  end
  progress = $game_variables[PENTAGRAM_PROGRESS]
  direction = $game_variables[PENTAGRAM_DIRECTION]
  last_spot = nil
  if direction == :Normal
    last_spot = corners[current_part]
  elsif direction == :Reverse
    last_spot = corners[(current_part + 1) % 5]
  end
  last_spot_clr = -1

  if current_part
    [shadow, base].each do |fill|
      size = (fill == base) ? 2 : 4
      (0...96).step(2).each do |y|
        (0...96).step(2).each do |x|
          clr = bitmap.get_pixel(x + 96, y)
          next if clr.alpha == 0
          draw = false
          parts.each do |part|
            pclr = bitmap.get_pixel(x + 64*part, y + 96)
            if pclr.alpha != 0
              draw = true
              break
            end
          end
          if !draw
            pclr = bitmap.get_pixel(x + 64*current_part, y + 96)
            if pclr.alpha != 0
              if direction == :Normal
                if 255 - pclr.red <= progress
                  draw = true
                  if 255 - pclr.red > last_spot_clr
                    last_spot_clr = 255 - pclr.red
                    last_spot = [x, y]
                  end
                end
              else
                if pclr.red <= progress
                  draw = true
                  if pclr.red > last_spot_clr
                    last_spot_clr = pclr.red
                    last_spot = [x, y]
                  end
                end
              end
            end
          end
          if draw
            pentagram.fill_rect(x, y, size, size, fill)
          end
        end
      end
    end
  else
    if element == :None
      (0...5).each do |i|
        x = corners[i][0]
        y = corners[i][1]
        colors = pbElementColors(i)
        if Graphics.frame_count % 32 < 16
          pentagram.fill_rect(x - 2, y, 8, 4, colors[1])
          pentagram.fill_rect(x, y - 2, 4, 8, colors[1])
          pentagram.fill_rect(x, y, 4, 4, colors[0])
        else
          pentagram.fill_rect(x - 4, y, 12, 4, colors[1])
          pentagram.fill_rect(x - 2, y - 2, 8, 8, colors[1])
          pentagram.fill_rect(x, y - 4, 4, 12, colors[1])
          pentagram.fill_rect(x - 2, y, 8, 4, colors[0])
          pentagram.fill_rect(x, y - 2, 4, 8, colors[0])
        end
      end
    end
  end
  if element != :None && !(parts.length >= 4 && progress >= 255)
    i = pbElementID(element)
    if !last_spot.nil?
      corners[i] = last_spot
    end
    x = corners[i][0]
    y = corners[i][1]
    colors = pbElementColors(i)
    if Graphics.frame_count % 32 < 16
      pentagram.fill_rect(x - 2, y, 8, 4, colors[1])
      pentagram.fill_rect(x, y - 2, 4, 8, colors[1])
      pentagram.fill_rect(x, y, 4, 4, colors[0])
    else
      pentagram.fill_rect(x - 4, y, 12, 4, colors[1])
      pentagram.fill_rect(x - 2, y - 2, 8, 8, colors[1])
      pentagram.fill_rect(x, y - 4, 4, 12, colors[1])
      pentagram.fill_rect(x - 2, y, 8, 4, colors[0])
      pentagram.fill_rect(x, y - 2, 4, 8, colors[0])
    end
  end

  return pentagram
end

def pbPentagramElement(element)
  if pbGet(PENTAGRAM_ELEMENT) == :None
    pbSet(PENTAGRAM_ELEMENT, element)
    pbSet(PENTAGRAM_PROGRESS, 0)
    return true
  end

  parts = pbGet(PENTAGRAM_PARTS)
  if parts.length == 0
    cur_element = pbGet(PENTAGRAM_ELEMENT)
    dist = pbElementID(element) - pbElementID(cur_element)
    if dist == 1 || dist == -4
      pbSet(PENTAGRAM_ELEMENT, element)
      pbSet(PENTAGRAM_DIRECTION, :Normal)
      parts.push(pbElementID(cur_element))
      pbSet(PENTAGRAM_PROGRESS, 0)
      return true
    elsif dist == 4 || dist == -1
      pbSet(PENTAGRAM_ELEMENT, element)
      pbSet(PENTAGRAM_DIRECTION, :Reverse)
      parts.push(pbElementID(element))
      pbSet(PENTAGRAM_PROGRESS, 0)
      return true
    end
  else
    if pbGet(PENTAGRAM_DIRECTION) == :Normal
      next_element = (parts[parts.length - 1] + 2) % 5
      if pbElementID(element) == next_element
        parts.push((next_element - 1) % 5)
        pbSet(PENTAGRAM_PROGRESS, 0)
        return true
      end
    else
      next_element = (parts[parts.length - 1] - 1) % 5
      if pbElementID(element) == next_element
        parts.push(next_element)
        pbSet(PENTAGRAM_PROGRESS, 0)
        return true
      end
    end
  end
  return false
end

def pbPentagramValid?
  incense = $game_variables[PENTAGRAM_INCENSE]
  element = $game_variables[PENTAGRAM_ELEMENT]
  direction = $game_variables[PENTAGRAM_DIRECTION]
  case incense
  when :Earth
    return true if element == :Earth && direction == :Normal
  when :Water
    return true if element == :Water && direction == :Reverse
  when :Air
    return true if element == :Air && direction == :Normal
  when :Fire
    return true if element == :Fire && direction == :Reverse
  end
  return false
end

def pbElementID(element)
  return [:Spirit, :Earth, :Water, :Air, :Fire].index(element)
end

def pbElementColors(element)
  base = Color.new(255, 255, 255)
  shadow = Color.new(0, 0, 0)
  case element
  when :Spirit, 0
    base = Color.new(232, 240, 248)
    shadow = Color.new(190, 198, 198)
  when :Earth, 1
    base = Color.new(167, 135, 92)
    shadow = Color.new(135, 112, 79)
  when :Water, 2
    base = Color.new(89, 107, 208)
    shadow = Color.new(63, 84, 204)
  when :Air, 3
    base = Color.new(143, 193, 149)
    shadow = Color.new(99, 153, 105)
  when :Fire, 4
    base = Color.new(194, 108, 101)
    shadow = Color.new(171, 62, 51)
  end
  return [base, shadow]
end