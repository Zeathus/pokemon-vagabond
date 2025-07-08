alias sup_pbSetSystemFont pbSetSystemFont
alias sup_pbSetSmallFont pbSetSmallFont
alias sup_pbSetNarrowFont pbSetNarrowFont

# Sets a bitmap's font to the system font.
def pbSetSystemFont(bitmap)
  return sup_pbSetSystemFont(bitmap) if !Supplementals::USE_HARD_CODED_FONT
  bitmap.font.name = "system"
  bitmap.font.size = 32
  bitmap.text_offset_y = MessageConfig::FONT_Y_OFFSET
  bitmap.set_font_data("system")
end

# Sets a bitmap's font to the system small font.
def pbSetSmallFont(bitmap)
  return sup_pbSetSmallFont(bitmap) if !Supplementals::USE_HARD_CODED_FONT
  bitmap.font.name = "small"
  bitmap.font.size = 32
  bitmap.text_offset_y = MessageConfig::SMALL_FONT_Y_OFFSET
  bitmap.set_font_data("small")
end

# Sets a bitmap's font to the system narrow font.
def pbSetNarrowFont(bitmap)
  return sup_pbSetNarrowFont(bitmap) if !Supplementals::USE_HARD_CODED_FONT
  bitmap.font.name = "system"
  bitmap.font.size = 32
  bitmap.text_offset_y = MessageConfig::NARROW_FONT_Y_OFFSET
  bitmap.set_font_data("system")
end

# Sets a bitmap's font to the system smallest font.
def pbSetSmallestFont(bitmap)
  bitmap.font.name = "smallest"
  bitmap.font.size = 32
  bitmap.text_offset_y = MessageConfig::SMALL_FONT_Y_OFFSET
  bitmap.set_font_data("smallest")
end

# Sets a bitmap's font to the system bold font.
def pbSetBoldFont(bitmap)
  bitmap.font.name = "bold"
  bitmap.font.size = 32
  bitmap.text_offset_y = MessageConfig::SMALL_FONT_Y_OFFSET
  bitmap.set_font_data("bold")
end