class BitmapCharacter
  attr_reader :rects
  attr_reader :width

  def initialize(src_bitmap, src_rect)
    bitmap = Bitmap.new(src_rect.width, src_rect.height)
    bitmap.blt(0, 0, src_bitmap, src_rect)
    @rects = []
    @width = 0
    while self.push_rect(bitmap)
      rect = @rects[@rects.length - 1]
      if rect.x + rect.width > @width
        @width = rect.x + rect.width
      end
    end
    bitmap.dispose
  end

  def push_rect(bitmap)
    best_candidate = nil
    best_length = 0
    for y in 0...bitmap.height
      for x in 0...bitmap.width
        next if bitmap.get_pixel(x, y).alpha != 255
        x_len = 1
        y_len = 1
        while bitmap.get_pixel(x + x_len, y).alpha == 255
          x_len += 1
        end
        while bitmap.get_pixel(x, y + y_len).alpha == 255
          y_len += 1
        end
        if x_len > best_length
          best_candidate = Rect.new(x, y, x_len, 1)
          best_length = x_len
        end
        if y_len > best_length
          best_candidate = Rect.new(x, y, 1, y_len)
          best_length = y_len
        end
      end
    end
    return false if best_candidate.nil?
    @rects.push(best_candidate)
    bitmap.clear_rect(best_candidate)
    return true
  end

  def print_rects
    @rects.each do |rect|
      echo " #{@width}:[#{rect.x} #{rect.y} #{rect.width} #{rect.height}]"
    end
    echoln ""
  end

end

def pbCompileBitmapFonts
  chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz"
  chars += "1234567890"
  chars += ".…,!?¡¿'‘’\"“”-:;_+×÷=~()[]/\\&%@<>*|#^"
  chars += "ÀÁÂÄÃÅàáâäãåÆæÈÉÊËèéêëÇçÌÍÎÏìíîïŒœÒÓÔÖÕòóôöõØøÑñÙÚÛÜùúûüÝý"
  chars += "$§♂♀⚲←→↓↑•◎○□△♠♥♦♣★✨♈♌♒♐♩♪♫☽☾"
  fonts = {}
  for font_name in ["system", "small", "smallest", "bold"]
    echoln "Compiling font '#{font_name}'"
    fonts[font_name] = {}
    bm = AnimatedBitmap.new("Graphics/Fonts/font_#{font_name}")
    for i in 0...chars.length
      x_pos = 16 * (i % 16)
      y_pos = 16 * (i / 16).floor
      char = BitmapCharacter.new(bm.bitmap, Rect.new(x_pos, y_pos, 16, 16))
      fonts[font_name][chars[i..i]] = char
    end
    bm.dispose
  end
  fonts["Arial"] = fonts["system"]
  return fonts
end

$BitmapFonts = pbCompileBitmapFonts

class Bitmap
  alias sup_draw_text draw_text
  alias sup_text_size text_size

  def font_data
    return @font_data || $BitmapFonts["system"]
  end

  def set_font_data(style)
    @font_data = $BitmapFonts[style]
  end

  def draw_text(x, y, width, height = nil, text = "", align = 0, sizeMod = 0, skew = 0)
    return sup_draw_text(x, y, width, height, text, align) if !Supplementals::USE_HARD_CODED_FONT
    @font_data = $BitmapFonts[self.font.name] if @font_data.nil?
    y -= (@text_offset_y || 0)
    return if !text
    if align==1
      width = self.text_size(text).width
      x -= width
    elsif align==2
      width = self.text_size(text).width
      x -= width / 2
      x = x.round
    end

    cx=x
    cy=y - skew * (text.length / 2).floor
    sp = $game_temp.textSize ? $game_temp.textSize : 2

    text.split('').each { |c|
      if c != ' '
        data = @font_data[c] || @font_data["?"]
        for r in data.rects
          self.fill_rect(cx+r.x*sp,cy+(r.y - 2)*sp,((r.width+sizeMod)*sp).ceil,((r.height+sizeMod)*sp).ceil,self.font.color)
        end
        cx += realCharWidth(data.width * 2 + 2)
        cy += skew
      else
        cx += realCharWidth((self.font.name=="small" || self.font.name=="smallest") ? 4 : 6)
      end
    }
  end

  def text_size(text)
    return sup_text_size(text) if !Supplementals::USE_HARD_CODED_FONT
    @font_data = $BitmapFonts[self.font.name] if @font_data.nil?
    sizex = 0
    height = 32
    height = 26 if self.font.name == "small"
    height = 22 if self.font.name == "smallest"
    sizey = height
    total = 0
    text.split('').each { |c|
      if c == '\n'
        sizex = total if sizex < total
        sizey += self.font.size
        total = 0
      elsif c == ' '
        total += realCharWidth((self.font.name=="small" || self.font.name=="smallest") ? 4 : 6)
      else
        data = @font_data[c] || @font_data["?"]
        total += realCharWidth(data.width * 2 + 2)
      end
    }
    sizex = total if sizex < total
    return Rect.new(0,0,sizex,sizey)
  end

  def realCharWidth(width)
    return $game_temp.textSize ? (width * $game_temp.textSize / 2) : width
  end
end

def print_letters_to_files
  bitmap = Bitmap.new(512, 512)
  chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz"
  chars += "1234567890"
  chars += ".…,!?¡¿'‘’\"“”-:;_+×÷=~()[]/\\&%@<>*|#^"
  chars += "ÀÁÂÄÃÅàáâäãåÆæÈÉÊËèéêëÇçÌÍÎÏìíîïŒœÒÓÔÖÕòóôöõØøÑñÙÚÛÜùúûüÝý"
  chars += "$§♂♀⚲←→↓↑•◎○□△♠♥♦♣★✨♈♌♒♐♩♪♫☽☾"
  for font in 0...3
    bitmap.clear
    if font == 0
      pbSetSystemFont(bitmap)
    elsif font == 1
      pbSetSmallFont(bitmap)
    elsif font == 2
      pbSetSmallestFont(bitmap)
    end
    textpos = []
    for pos in 0...chars.length
      char = chars[pos..pos]
      x_pos = 32 * (pos % 16)
      y_pos = 6 + 32 * (pos / 16).floor
      textpos.push([char, x_pos, y_pos, 0, Color.new(0, 0, 0), Color.new(0, 0, 0, 0)])
    end
    pbDrawTextPositions(bitmap, textpos)
    if font == 0
      bitmap.to_file("font_system.png")
    elsif font == 1
      bitmap.to_file("font_small.png")
    elsif font == 2
      bitmap.to_file("font_smallest.png")
    end
  end
end