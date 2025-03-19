def pbFormatHint(hint1, hint2=nil)
  if hint2
    return hint1 + " or " +
      hint2[0...1].downcase + hint2[1...hint2.length]
  else
    return hint1
  end
end

def pbItemHint(item)
  text_berries = "Found when harvesting"
  text_mining = "Found when mining"
  text_scoria_market = "Bought at the Scoria Market"
  text_smith = "Crafted by a smith"
  text_jeweler = "Crafted by a jeweler"
  text_carpenter = "Crafted by a carpenter"
  text_mall = "Bought at a mall"
  case item
  when :CHARCOAL
    return text_smith
  when :MYSTICWATER
    return text_jeweler
  when :MAGNET
    return ""
  when :MIRACLESEED
    return text_carpenter
  when :NEVERMELTICE
    return ""
  when :BLACKBELT
    return ""
  when :POISONBARB
    return ""
  when :SOFTSAND
    return ""
  when :SHARPBEAK
    return ""
  when :TWISTEDSPOON
    return ""
  when :SILVERPOWDER
    return text_berries
  when :HARDSTONE
    return text_mining
  when :SPELLTAG
    return ""
  when :DRAGONFANG
    return ""
  when :BLACKGLASSES
    return ""
  when :METALCOAT
    return ""
  when :SILKSCARF
    return ""
  when :PIXIEDUST
    return ""
  when :CHERIBERRY
  when :CHESTOBERRY
  when :PECHABERRY
  when :RAWSTBERRY
  when :ASPEARBERRY
  when :LEPPABERRY
  when :ORANBERRY
  when :PERSIMBERRY
  when :LUMBERRY
  when :SITRUSBERRY
  when :FIGYBERRY
  when :WIKIBERRY
  when :MAGOBERRY
  when :AGUAVBERRY
  when :IAPAPABERRY
  when :RAZZBERRY
  when :BLUKBERRY
  when :NANABBERRY
  when :WEPEARBERRY
  when :PINAPBERRY
  when :POMEGBERRY
  when :KELPSYBERRY
  when :QUALOTBERRY
  when :HONDEWBERRY
  when :GREPABERRY
  when :TAMATOBERRY
  when :CORNNBERRY
  when :MAGOSTBERRY
  when :RABUTABERRY
  when :NOMELBERRY
  when :SPELONBERRY
  when :PAMTREBERRY
  when :WATMELBERRY
  when :DURINBERRY
  when :BELUEBERRY
  when :OCCABERRY
    return text_berries
  when :PASSHOBERRY
    return text_berries
  when :WACANBERRY
    return text_berries
  when :RINDOBERRY
    return text_berries
  when :YACHEBERRY
    return text_berries
  when :CHOPLEBERRY
    return text_berries
  when :KEBIABERRY
    return text_berries
  when :SHUCABERRY
    return text_berries
  when :COBABERRY
    return text_berries
  when :PAYAPABERRY
    return text_berries
  when :TANGABERRY
    return text_berries
  when :CHARTIBERRY
    return text_berries
  when :KASIBBERRY
    return text_berries
  when :HABANBERRY
    return text_berries
  when :COLBURBERRY
    return text_berries
  when :BABIRIBERRY
    return text_berries
  when :CHILANBERRY
    return text_berries
  when :LIECHIBERRY
  when :GANLONBERRY
  when :SALACBERRY
  when :PETAYABERRY
  when :APICOTBERRY
  when :LANSATBERRY
  when :STARFBERRY
  when :ENIGMABERRY
  when :MICLEBERRY
  when :CUSTAPBERRY
  when :JABOCABERRY
  when :ROWAPBERRY
  when :DAMPROCK
    return text_mining
  when :HEATROCK, :SMOOTHROCK, :ICYROCK, :VELVETYROCK
    return text_mining
  when :TINYMUSHROOM, :BIGMUSHROOM, :BALMMUSHROOM
    return text_berries
  when :GRASSYSEED, :MISTYSEED, :PSYCHICSEED, :ELECTRICSEED
    return text_berries
  when :HONEY
    return text_berries
  when :RAREBONE
    return text_mining
  when :MENTALHERB, :WHITEHERB, :POWERHERB
    return text_berries
  when :BLUESHARD, :REDSHARD, :GREENSHARD, :YELLOWSHARD
    return text_mining
  when :LEAFSTONE, :FIRESTONE, :THUNDERSTONE, :WATERSTONE, :ICYSTONE
    return pbFormatHint(text_mining, text_mall)
  when :SUNSTONE, :MOONSTONE
    return text_mining
  when :EVERSTONE
    return text_mining
  when :FROSTORB, :FLAMEORB
    return text_scoria_market
  end
  return nil
end