
alias sup_drawSingleFormattedChar drawSingleFormattedChar
alias sup_pbDrawShadowText pbDrawShadowText
alias sup_pbDrawOutlineText pbDrawOutlineText

def drawSingleFormattedChar(bitmap, ch)
  return sup_drawSingleFormattedChar(bitmap, ch) if ch[5] || !Supplementals::USE_HARD_CODED_FONT
  bitmap.font.size=ch[13] if bitmap.font.size!=ch[13]
  if ch[0]!="\n" && ch[0]!="\r" && ch[0]!=" " && !isWaitChar(ch[0])
    bitmap.font.bold = ch[6] if bitmap.font.bold != ch[6]
    bitmap.font.italic = ch[7] if bitmap.font.italic != ch[7]
    bitmap.font.name = ch[12] if bitmap.font.name != ch[12]
    offset = 0
    sp = $game_temp.textSize ? $game_temp.textSize : 2
    rects = ($BitmapFonts[bitmap.font.name][ch[0]] || $BitmapFonts[bitmap.font.name]["?"]).rects
    if ch[9] # shadow
      if (ch[16] & 1) != 0 # outline
        offset = 1
        rects.each do |r|
          bitmap.fill_rect(
            ch[1] + (r.x - 1 + offset) * sp,
            ch[2] + (r.y - 1) * sp,
            ((r.width + 2) * sp).ceil,
            ((r.height + 2) * sp).ceil,
            ch[9]
          )
        end
      elsif (ch[16] & 2) != 0 # outline 2
        offset = 2
      else
        rects.each do |r|
          bitmap.fill_rect(
            ch[1] + r.x * sp,
            ch[2] + r.y * sp,
            ((r.width + 1) * sp).ceil,
            ((r.height + 1) * sp).ceil,
            ch[9]
          )
        end
      end
    end
    rects.each do |r|
      bitmap.fill_rect(
        ch[1] + (r.x + offset) * sp,
        ch[2] + r.y * sp,
        (r.width * sp).ceil,
        (r.height * sp).ceil,
        ch[8]
      )
    end
  end
  if ch[10] # underline
    bitmap.fill_rect(ch[1],ch[2]+ch[4]-[(ch[4]-bitmap.font.size)/2,0].max-2,
        ch[3]-2,2,ch[8])
  end
  if ch[11] # strikeout
    bitmap.fill_rect(ch[1],ch[2]+(ch[4]/2),ch[3]-2,2,ch[8])
  end
end

def pbDrawShadowText(bitmap, x, y, width, height, string, baseColor, shadowColor = nil, align = 0)
  return if !bitmap || !string
  return sup_pbDrawShadowText(bitmap, x, y, width, height, string, baseColor, shadowColor, align) if !Supplementals::USE_HARD_CODED_FONT
  y += 6
  width = (width < 0) ? bitmap.text_size(string).width + 1 : width
  height = (height < 0) ? bitmap.text_size(string).height + 1 : height
  if shadowColor && shadowColor.alpha > 0
    bitmap.font.color = shadowColor
    bitmap.draw_text(x, y, width, height, string, align, 1)
  end
  if baseColor && baseColor.alpha > 0
    bitmap.font.color = baseColor
    bitmap.draw_text(x, y, width, height, string, align)
  end
end

def pbDrawOutlineText(bitmap, x, y, width, height, string, baseColor, shadowColor = nil, align = 0)
  return if !bitmap || !string
  return sup_pbDrawOutlineText(bitmap, x, y, width, height, string, baseColor, shadowColor, align) if !Supplementals::USE_HARD_CODED_FONT
  y += 6
  width = (width < 0) ? bitmap.text_size(string).width + 4 : width
  height = (height < 0) ? bitmap.text_size(string).height + 4 : height
  if shadowColor && shadowColor.alpha > 0
    bitmap.font.color = shadowColor
    bitmap.draw_text(x, y, width, height, string, align, 2)
  end
  if baseColor && baseColor.alpha > 0
    bitmap.font.color = baseColor
    bitmap.draw_text(x + 2, y + 2, width, height, string, align)
  end
end