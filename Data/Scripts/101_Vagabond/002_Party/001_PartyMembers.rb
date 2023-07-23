module PBParty
  Player    = 0
  Duke      = 1
  Amethyst  = 2
  Kira      = 3
  Eliana    = 4
  Fintan    = 5
  Cerise    = 6
  Nekane    = 7
  Ziran     = 8
  Azelf     = 9
  Uxie      = 10
  Mesprit   = 11
  Player2   = 12

  def PBParty.len
    return 13
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
    when PBParty::Azelf
      return "Azelf"
    when PBParty::Uxie
      return "Uxie"
    when PBParty::Mesprit
      return "Mesprit"
    when PBParty::Player2
      return $player ? $player.name : "Player"
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
    when PBParty::Azelf
      return :AZELF
    when PBParty::Uxie
      return :UXIE
    when PBParty::Mesprit
      return :MESPRIT
    when PBParty::Player2
      return :ANTAGONIST
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
    when PBParty::Azelf
      return -1
    when PBParty::Uxie
      return -1
    when PBParty::Mesprit
      return -1
    when PBParty::Player2
      return $player ? $player.id : 0
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
    when PBParty::Player2
      return $player ? $player.gender : 2
    end
    return 2
  end

  def PBParty.secondOnly(id)
    id = getID(PBParty,id) if id.is_a?(Symbol)
    return [9, 10, 11].include?(id)
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
  pbUpdatePartySprites
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

def getPartyActiveSprite(pos)
  return -1 if !$game_variables
  if $game_variables[VISUAL_PARTY] == 0
    member_id = getPartyActive(pos)
  else
    member_id = $game_variables[VISUAL_PARTY][pos]
  end
end

def pbStartTempParty(member1, member2=-1)
  member1 = -1 if member1.nil?
  member2 = -1 if member2.nil?
  member1 = getID(PBParty,member1) if member1.is_a?(Symbol)
  member2 = getID(PBParty,member2) if member2.is_a?(Symbol)
  if $game_variables[SAVED_PARTY] == 0
    $game_variables[SAVED_PARTY] = $game_variables[PARTY]
    $game_variables[SAVED_PARTY_ACTIVE] = $game_variables[PARTY_ACTIVE]
  end
  $game_variables[PARTY] = [false]
  $game_variables[PARTY_ACTIVE] = [member1, member2]
  addPartyMember(member1)
  addPartyMember(member2)
  pbUpdatePartySprites
end

def pbEndTempParty
  $game_variables[PARTY] = $game_variables[SAVED_PARTY]
  $game_variables[PARTY_ACTIVE] = $game_variables[SAVED_PARTY_ACTIVE]
  pbUpdatePartySprites
end

def pbStartVisualParty(member1, member2=-1)
  member1 = -1 if member1.nil?
  member2 = -1 if member2.nil?
  member1 = getID(PBParty,member1) if member1.is_a?(Symbol)
  member2 = getID(PBParty,member2) if member2.is_a?(Symbol)
  $game_variables[VISUAL_PARTY] = [member1, member2]
  pbUpdatePartySprites
end

def pbEndVisualParty
  $game_variables[VISUAL_PARTY] = 0
  pbUpdatePartySprites
end

def pbUpdatePartySprites
  $game_player.sprite.partner.character = _INTL("member{1}", getPartyActiveSprite(1))
  $game_player.refresh_charset
  $game_player.sprite.update
end