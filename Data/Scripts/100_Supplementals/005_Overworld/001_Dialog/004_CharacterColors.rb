module Dialog

  def Dialog.getCharColor(name, tint, haswindow = true, force = false)

    name = name.downcase

    return nil if haswindow && !force && !["azelf", "mesprit", "uxie", "fintan"].include?(name)

    tint = (tint + 1) % 2 if !haswindow

    if name == "<player>" || name == "player" || name == "<player2>" || name == "player2" 
      return Color.new(85, 98, 104) if tint == 0
      return Color.new(135, 175, 196) if tint == 1
      return Color.new(103, 134, 150) if tint == 2
    elsif name == "kira"
      return Color.new(206, 139, 122) if tint == 0
      return Color.new(109, 83, 82) if tint == 1
      return Color.new(171, 100, 98) if tint == 2
    elsif name == "amethyst"
      return Color.new(190, 132, 187) if tint == 0
      return Color.new(102, 85, 104) if tint == 1
      return Color.new(150, 106, 156) if tint == 2
    elsif name == "nekane"
      return Color.new(96, 45, 71) if tint == 0
      return Color.new(30, 11, 20) if tint == 1
      return Color.new(66, 21, 44) if tint == 2
    elsif name == "duke"
      return Color.new(132, 190, 135) if tint == 0
      return Color.new(87, 104, 85) if tint == 1
      return Color.new(112, 156, 106) if tint == 2
      #return Color.new(120, 170, 140) if tint == 0
      #return Color.new(70, 100, 80) if tint == 1
    elsif name == "mesprit"
      return Color.new(160, 64, 99) if tint == 0
      return Color.new(219, 174, 188) if tint == 1
      return Color.new(200, 104, 139) if tint == 0
      return Color.new(249, 204, 218) if tint == 1
      return Color.new(113, 60, 86) if tint == 2
    elsif name == "azelf"
      return Color.new(54, 108, 135) if tint == 0
      return Color.new(183, 215, 247) if tint == 1
      return Color.new(71, 87, 95) if tint == 2
    elsif name == "uxie"
      return Color.new(198, 129, 22) if tint == 0
      return Color.new(224, 222, 145) if tint == 1
      return Color.new(113, 100, 60) if tint == 2
    elsif name == "giratina"
      return Color.new(235, 50, 0) if tint == 0
      return Color.new(114, 37, 11) if tint == 1
      return Color.new(0, 0, 0) if tint == 2
    elsif name == "celebi"
      return Color.new(74, 114, 74) if tint == 0
      return Color.new(164, 222, 82) if tint == 1
      return Color.new(0, 0, 0) if tint == 2
    elsif name == "r-celebi"
      return Color.new(92, 32, 172) if tint == 0
      return Color.new(180, 140, 222) if tint == 1
      return Color.new(0, 0, 0) if tint == 2
    elsif name == "eliana"
      return Color.new(40, 40, 40) if tint == 0
      return Color.new(146, 146, 146) if tint == 1
      return Color.new(61, 61, 61) if tint == 2
    elsif name == "fintan"
      return Color.new(40, 40, 40) if tint == 0
      return Color.new(146, 146, 146) if tint == 1
      return Color.new(173, 173, 173) if tint == 2
    else
      return nil
    end
  end

  def Dialog.defaultTextColor(tint, haswindow = true)
    if haswindow
      return Color.new(252, 252, 252) if tint == 0
      return Color.new(120, 120, 132) if tint == 1
      return Color.new(40, 40, 56) if tint == 2
    end
    tint = (tint + 1) % 2 if !haswindow
    return Color.new(80, 80, 88) if tint == 0
    return Color.new(160, 160, 168) if tint == 1
    return Color.new(40, 40, 56) if tint == 2
  end

  def Dialog.getWindowSkin(name)
    name = name.downcase if name
    if name == "sign"
      return "sign"
    elsif name == "<player>" || name == "player" || name == "<player2>" || name == "player2" 
      return "speech vb player"
    elsif name == "duke"
      return "speech vb duke"
    elsif name == "amethyst"
      return "speech vb amethyst"
    elsif name == "kira"
      return "speech vb kira"
    elsif name == "nekane"
      return "speech vb nekane"
    elsif name == "fintan"
      return "speech vb fintan"
    elsif name == "eliana"
      return "speech vb eliana"
    elsif name == "mesprit"
      return "telepathy_mesprit"
    elsif name == "azelf"
      return "telepathy_azelf"
    elsif name == "uxie"
      return "telepathy_uxie"
    elsif name == "giratina"
      return "giratina"
    end
    return nil  # false means default
  end

  def Dialog.getNameBox(name)
    name = name.downcase if name
    ret = "name_box"
    if name == "<player>" || name == "player" || name == "<player2>" || name == "player2" 
      ret = "name_box_player"
    elsif name == "duke"
      ret = "name_box_duke"
    elsif name == "amethyst"
      ret = "name_box_amethyst"
    elsif name == "kira"
      ret = "name_box_kira"
    elsif name == "nekane"
      ret = "name_box_nekane"
    elsif name == "fintan"
      ret = "name_box_fintan"
    elsif name == "eliana"
      ret = "name_box_eliana"
    elsif name == "mesprit"
      ret = "name_box_mesprit"
    elsif name == "azelf"
      ret = "name_box_azelf"
    elsif name == "uxie"
      ret = "name_box_uxie"
    elsif name == "giratina"
      ret = "name_box_giratina"
    end
    return _INTL("Graphics/Messages/{1}", ret)
  end 

end