module Dialog

  def Dialog.getCharColor(name, tint, haswindow = true)

    tint = (tint + 1) % 2 if !haswindow

    if name == "PLAYER"
      return Color.new(135, 175, 196) if tint == 0
      return Color.new(85, 98, 104) if tint == 1
    elsif name == "Kira"
      return Color.new(206, 139, 122) if tint == 0
      return Color.new(109, 83, 82) if tint == 1
    elsif name == "Amethyst"
      return Color.new(190, 132, 187) if tint == 0
      return Color.new(102, 85, 104) if tint == 1
    elsif name == "Nekane"
      return Color.new(96, 45, 71) if tint == 0
      return Color.new(30, 11, 20) if tint == 1
    elsif name == "Duke"
      return Color.new(132, 190, 135) if tint == 0
      return Color.new(87, 104, 85) if tint == 1
      #return Color.new(120, 170, 140) if tint == 0
      #return Color.new(70, 100, 80) if tint == 1
    elsif name == "Mesprit"
      return Color.new(113, 60, 86) if tint == 0
      return Color.new(249, 204, 218) if tint == 1
    elsif name == "Azelf"
      return Color.new(54, 108, 135) if tint == 0
      return Color.new(183, 215, 247) if tint == 1
    elsif name == "Uxie"
      return Color.new(198, 129, 22) if tint == 0
      return Color.new(224, 222, 145) if tint == 1
    elsif name == "Giratina"
      return Color.new(235, 50, 0) if tint == 0
      return Color.new(114, 37, 11) if tint == 1
    elsif name == "Celebi"
      return Color.new(164, 222, 82) if tint == 0
      return Color.new(74, 114, 74) if tint == 1
    elsif name == "R-Celebi"
      return Color.new(180, 140, 222) if tint == 0
      return Color.new(92, 32, 172) if tint == 1
    elsif name == "Eliana"
      return Color.new(146, 146, 146) if tint == 0
      return Color.new(40, 40, 40) if tint == 1
    elsif name == "Fintan"
      return Color.new(234, 234, 234) if tint == 0
      return Color.new(173, 173, 173) if tint == 1
    else
      return Color.new(252, 252, 252) if tint == 0
      return Color.new(120, 120, 132) if tint == 1
    end
  end

  def Dialog.getTextWindow(name)
    if name == "Sign"
      return "sign"
    elsif name == "PLAYER"
      return "speech vb player"
    elsif name == "Duke"
      return "speech vb duke"
    elsif name == "Amethyst"
      return "speech vb amethyst"
    elsif name == "Kira"
      return "speech vb kira"
    elsif name == "Nekane"
      return "speech vb nekane"
    elsif name == "Fintan"
      return "speech vb fintan"
    elsif name == "Eliana"
      return "speech vb eliana"
    elsif name == "Mesprit"
      return "telepathy_mesprit"
    elsif name == "Azelf"
      return "telepathy_azelf"
    elsif name == "Uxie"
      return "telepathy_uxie"
    elsif name == "Giratina"
      return "giratina"
    else
      return false
    end
  end

  def Dialog.getNameBox(name)
    ret = "name_box"
    if name == "PLAYER"
      ret = "name_box_player"
    elsif name == "Duke"
      ret = "name_box_duke"
    elsif name == "Amethyst"
      ret = "name_box_amethyst"
    elsif name == "Kira"
      ret = "name_box_kira"
    elsif name == "Nekane"
      ret = "name_box_nekane"
    elsif name == "Fintan"
      ret = "name_box_fintan"
    elsif name == "Eliana"
      ret = "name_box_eliana"
    elsif name == "Mesprit"
      ret = "name_box_mesprit"
    elsif name == "Azelf"
      ret = "name_box_azelf"
    elsif name == "Uxie"
      ret = "name_box_uxie"
    elsif name == "Giratina"
      ret = "name_box_giratina"
    end
    return _INTL("Graphics/Messages/{1}", ret)
  end 

end