module PBParty
  Player    = 0
  Duke      = 1
  Amethyst  = 2
  Kira      = 3
  Eliana    = 4
  Fintan    = 5
  Nekane    = 6
  Cerise    = 7
  Ziran     = 8

  def PBParty.len
    return 9
  end

  def PBParty.getName(id)
    id = getID(PBParty,id) if id.is_a?(Symbol)
    case id
    when -1
      return "Inactive"
    when PBParty::Player
      return $player ? $player.name : "Player"
    when PBParty::Duke
      return "Duke"     # Duke sounds large
    when PBParty::Amethyst
      return "Amethyst" # The gem, colored after her name
    when PBParty::Kira
      return "Kira"     # Reference to Akira, the Sandslash user from the anime
    when PBParty::Eliana
      return "Eliana"   # Hebrew, meaning "My God has answered" (Ziran)
    when PBParty::Fintan
      return "Fintan"   # Irish, meaning "White Fire" (Reshiram)
    when PBParty::Nekane
      return "Nekane"   # Basque, meaning "Sorrows", as she is empty at first
    when PBParty::Cerise
      return "Cerise"   # French word for Cherry
    when PBParty::Ziran
      return "Ziran"    # Chinese, refers to a point of view in Daoist belief
    end
    return "n/a"
  end

  def PBParty.getTrainerType(id)
    id = getID(PBParty,id) if id.is_a?(Symbol)
    case id
    when PBParty::Player
      return :PROTAGONIST
    when PBParty::Duke
      return :FORETELLER
    when PBParty::Amethyst
      return :AMETHYST
    when PBParty::Kira
      return :RIVAL
    when PBParty::Eliana
      return :DAO_Eliana
    when PBParty::Fintan
      return :DAO_Fintan
    when PBParty::Nekane
      return :NEKANE
    when PBParty::Cerise
      return :CERISE
    when PBParty::Ziran
      return :DAO_Ziran
    end
    return -1
  end

  def PBParty.getTrainerID(id)
    id = getID(PBParty,id) if id.is_a?(Symbol)
    case id
    when PBParty::Player
      return $player ? $player.id : 0
    when PBParty::Duke
      return 25111 # Celebi, with last digit repeated
    when PBParty::Amethyst
      return 1482  # SiO2: Chemical Symbol for Amethyst
    when PBParty::Kira
      return 11011 # Binary for Sandslash DEX#
    when PBParty::Eliana
      return 81204 # 8 + Zekrom dex number in octal (base 8)
    when PBParty::Fintan
      return 16283 # 16 + Reshiram dex num in hex (base 16)
    when PBParty::Nekane
      return 66666 # Obvious
    when PBParty::Cerise
      return 153298 # Keldeo's regional DEX# in BW followed by B2W2
    when PBParty::Ziran
      return 65829 # Mirrorable, balanced
    end
    return 0
  end

  def PBParty.getGender(id)
    id = getID(PBParty,id) if id.is_a?(Symbol)
    case id
    when PBParty::Player
      return $player ? $player.gender : 2
    when PBParty::Duke
      return 0
    when PBParty::Amethyst
      return 1
    when PBParty::Kira
      return 0
    when PBParty::Eliana
      return 1
    when PBParty::Fintan
      return 0
    when PBParty::Nekane
      return 1
    when PBParty::Cerise
      return 1
    when PBParty::Ziran
      return 0
    end
    return 2
  end
end

def isInParty
  return getPartyActive(0)>=0 && getPartyActive(1)>=0
end

def hasPartyMember(id)
  id = getID(PBParty,id) if id.is_a?(Symbol)
  pbSet(PARTY,[true]) if !pbGet(PARTY).is_a?(Array)
  return pbGet(PARTY)[id]
end

def isPartyMemberActive(id)
  id = getID(PBParty,id) if id.is_a?(Symbol)
  pbSet(PARTY,[true]) if !pbGet(PARTY).is_a?(Array)
  return pbGet(PARTY_ACTIVE)[0]==id || pbGet(PARTY_ACTIVE)[1]==id
end

def addPartyMember(id)
  id = getID(PBParty,id) if id.is_a?(Symbol)
  pbSet(PARTY,[true]) if !pbGet(PARTY).is_a?(Array)
  pbGet(PARTY)[id]=true
  if pbGet(PARTY_POKEMON)==0 || !pbGet(PARTY_POKEMON)[id]
    initPartyPokemon(id)
  end
  if !pbGet(PARTY_ACTIVE).is_a?(Array)
    pbSet(PARTY_ACTIVE,[0,-1])
  end
  members = pbGet(PARTY_ACTIVE)
  if members[1] < 0
    setPartyActive(id,1)
  elsif members[0] < 0
    setPartyActive(id,0)
  end
end

def removePartyMember(id)
  id = getID(PBParty,id) if id.is_a?(Symbol)
  pbSet(PARTY,[true]) if !pbGet(PARTY).is_a?(Array)
  pbGet(PARTY)[id]=false
  members = pbGet(PARTY_ACTIVE)
  if members[0] == id
    setPartyActive(members[1], 0)
  end
  if members[1] == id
    active = -1
    for i in 0...PBParty.len
      if pbGet(PARTY)[i] && i != members[0]
        active = i
        break
      end
    end
    setPartyActive(active, 1)
  end
end

def setPartyActive(id,pos)
  id = getID(PBParty,id) if id.is_a?(Symbol)
  if !pbGet(PARTY_ACTIVE).is_a?(Array)
    pbSet(PARTY_ACTIVE,[0,-1])
  end
  members = pbGet(PARTY_ACTIVE)
  if members[0] != id && members[1] != id
    if members[0] < 0
      members[0] = id
    elsif members[1] < 0
      members[1] = id
    else
      members[pos] = id
    end
  elsif members[0]>=0 && members[1]>=0
    otherpos=(pos + 1) % 2
    if id == members[otherpos]
      members[otherpos] = members[pos]
      members[pos] = id
    end
  end
  $game_player.sprite.partner.character = _INTL("member{1}", members[1])
  $game_player.sprite.update
end

def getPartyActive(pos=nil)
  if !pbGet(PARTY_ACTIVE).is_a?(Array)
    pbSet(PARTY_ACTIVE,[0,-1])
  end
  if pos
    return pbGet(PARTY_ACTIVE)[pos]
  else
    return pbGet(PARTY_ACTIVE)
  end
end

def pbSetPartnerVisibility(value)
  $game_player.sprite.partner.visibility=value
end

def pbForceVisualPartyLeader(value)
  if value == -1
    $game_variables[FORCED_VISUAL_LEADER] = 0
    $game_switches[FORCE_VISUAL_LEADER] = false
  else
    id = getID(PBParty,id) if id.is_a?(Symbol)
    $game_variables[FORCED_VISUAL_LEADER] = id
    $game_switches[FORCE_VISUAL_LEADER] = true
  end
end