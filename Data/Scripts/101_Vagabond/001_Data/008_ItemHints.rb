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
    return text_scoria_market
  when :PASSHOBERRY
    return text_scoria_market
  when :WACANBERRY
    return text_scoria_market
  when :RINDOBERRY
    return text_scoria_market
  when :YACHEBERRY
    return text_scoria_market
  when :CHOPLEBERRY
    return text_scoria_market
  when :KEBIABERRY
    return text_scoria_market
  when :SHUCABERRY
    return text_scoria_market
  when :COBABERRY
    return text_scoria_market
  when :PAYAPABERRY
    return text_scoria_market
  when :TANGABERRY
    return text_scoria_market
  when :CHARTIBERRY
    return text_scoria_market
  when :KASIBBERRY
    return text_scoria_market
  when :HABANBERRY
    return text_scoria_market
  when :COLBURBERRY
    return text_scoria_market
  when :BABIRIBERRY
    return text_scoria_market
  when :CHILANBERRY
    return text_scoria_market
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
  end
  return nil
end