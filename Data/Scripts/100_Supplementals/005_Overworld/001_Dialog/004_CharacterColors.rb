module Dialog

  def Dialog.getCharColor(name, tint, haswindow = true)

    tint = (tint + 1) % 2 if !haswindow

    if name == "PLAYER"
      return Color.new(85, 98, 104) if tint == 0
      return Color.new(135, 175, 196) if tint == 1
    else
      return Color.new(80, 80, 88) if tint == 0
      return Color.new(160, 160, 168) if tint == 1
    end
  end

  def Dialog.getTextWindow(name)
    return false  # false means default
  end

  def Dialog.getNameBox(name)
    ret = "name_box"
    return _INTL("Graphics/Messages/{1}", ret)
  end 

end