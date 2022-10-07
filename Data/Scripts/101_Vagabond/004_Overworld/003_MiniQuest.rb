# ---------------------------------------
# NOTES ABOUT MINI QUESTS
# ---------------------------------------
# QUEST TYPES:
# Pokemon Catching:
# - Someone wants a specific Pokemon. The player has to find and catch it.
#   * There's an increased chance that the Pokemon is not caught by the
#     the player already, to incentivise pokedex completion.
#   * Additional requirements may include:
#     - Specific gender
#     - Specific ability
# Category Catching:
# - Someone will request any pokemon that fulfills some requirements.
#   These requirements may include one or more of these:
#   - Having a specific ability
#   - Being one or two types
#   - Being within an egg group (breeders can request this)
#   - Knowing a specific move
#   - Being above or below a certain weight
#   - Having a BST above or below a certain value
# Item Fetching:
# - Someone wants a specific Item. The player has to find and deliver it.
# Lost Pokemon:
# - A trainer's pokemon has gone missing. The player must catch the pokemon
#   in the specified area, and deliver it.
#   * The pokemon should be stored in a variable, to ensure its always the same.
#   * It should be unreleaseable.
#
# DIFFICULTY:
# A quest's difficulty determines the reward for the quest.
# These factors will increase the difficulty of the quest types specified.
# Pokemon Catching:
# - The closer the catch rate is to 0 (3-255)
#   * No Legends, Mythicals or one-time catchable Pokemon.
# - Increase difficulty if the Pokemon is evolved.
# - The difficulty is higher the higher BST the Pokemon has.
# - Slight increase if the Pokémon is not seen or not caught in
#   player's pokedex.
# Item Fetching:
# - Increase difficulty based on sale price of item.
#   * No unsellable items.
# Lost Pokemon:
# - Increase difficulty based on catch rate.
# ---------------------------------------

class MiniQuest
  # The person requesting the task
  attr_accessor(:trainername)
  attr_accessor(:trainertype)
  # Generic variables
  # type 0 = Pokemon Catching
  # type 1 = Category Catching
  # type 2 = Item Fetching
  # type 3 = Lost Pokemon
  attr_accessor(:type)
  attr_accessor(:difficulty) # 0 to 4 (5)
  attr_accessor(:requirements) # Array that varies by quest type
  attr_accessor(:rewards) # Array [money, item]
  attr_accessor(:day) # The day the quest was available (same day completion grants bonus)

  def initialize(tname, ttype, type, dif, req, reward)
    @trainername = tname
    @trainertype = ttype
    @type = type
    @difficulty = dif
    @requirements = req
    @rewards = reward
    @day = pbGetTimeNow.day
  end

  def self.generate(difficulty)
    type = rand(3) # (3) Lost Pokemon not implemented
    type = 0 if type==1

    gender = rand(2)
    ttype = pbRandomTrainerType(gender)
    tname = pbRandomName(gender)

    req = []
    bst_range = [
      0...250,
      200...300,
      300...350,
      350...450,
      450...550,
      550...700][difficulty]
    if type==0
      rand = rand(807)+1
      blacklist = pbLegendaryPokemon + pbStaticPokemon
      while blacklist.include?(rand) || !bst_range.include?(pbBST(rand))
        rand = rand(807)+1
      end
      species=rand
      req.push(species) # Pokemon
      # Might include catch rate later
      #dexdata=pbOpenDexData
      #pbDexDataOffset(dexdata,species,16)
      #rareness=dexdata.fgetb # Get rareness from dexdata file
      #dexdata.close
      #Kernel.pbMessage(_INTL("{1}: {2}",tname,PBSpecies.getName(species)))
    elsif type==1
      #Kernel.pbMessage(_INTL("{1}: Category",tname))
    elsif type==2
      item = pbRandomQuestItem(difficulty)
      req.push(item) # Item
      #Kernel.pbMessage(_INTL("{1}: {2}",tname,PBItems.getName(item)))
    end

    money = 1000 + (((20+rand(11))*10)*2*(2**(difficulty+1)))
    item = pbRandomRewardItem(difficulty)
    if type==2
      while item==req[0]
        item = pbRandomRewardItem(difficulty)
      end
    end

    return self.new(tname, ttype, type, difficulty, req, [money,item])
  end

  def name
    vocals = ['A','E','I','O','U','Y']
    if type==0
      species = PBSpecies.getName(requirements[0])
      if vocals.include?(species[0..0])
        return _INTL("Catch an {1}",species)
      else
        return _INTL("Catch a {1}",species)
      end
    elsif type==1
      return "Category"
    elsif type==2
      item = PBItems.getName(requirements[0])
      if vocals.include?(item[0..0])
        return _INTL("Find an {1}",item)
      else
        return _INTL("Find a {1}",item)
      end
    end
    return "N/A"
  end

  def trainer
    typename = PBTrainers.getName(@trainertype)
    if typename.length > 11 && typename.include?(" ")
      typename = typename[(typename.index(" ")+1)..typename.length]
    end
    return _INTL("{1} {2}",typename,@trainername)
  end

  def description
    ret = self.name + " and return it to HQ.\n\n"
    return ret
  end

  def rewardMoney
    return @rewards[0]
  end

  def rewardItem
    return @rewards[1]
  end

  def pbGetStepDescription
    ret = "G.P.O. TASK\n"
    ret += self.name + " and return it to HQ.\n\n"
    ret += "REWARD\n"
    ret += "Money: $" + rewardMoney.to_s + "\n"
    ret += "Item: " + PBItems.getName(rewardItem) + "\n\n"
    ret += "SUBMITTED BY\n" + self.trainer
    return ret
  end

  def mapguide
    return []
  end

  def status
    return 1
  end

  def step
    return 0
  end

  def hidden
    return false
  end

  def canComplete?
    if type==0 # Catching
      species = requirements[0]
      return true if pbHasInParty?(species)
    elsif type==1 # Category Catching
      return false
    elsif type==2 # Item Fetching
      item = requirements[0]
      return true if $PokemonBag.pbQuantity(item)>0
    end
    return false
  end

  def complete
    if type==0 # Catching
      species = PBSpecies.getName(requirements[0])
      if pbNumberInParty(requirements[0])>1
        pbSpeech("Receptionist", "none",
          _INTL("Do you want to deliver the first {1} in your party?",species),
          false,["Yes","No"])
      else
        pbSpeech("Receptionist", "none",
          _INTL("Do you want to deliver the {1} in your party?",species),
          false,["Yes","No"])
      end
      if pbGet(1)==0
        if !pbRemoveSpecies(requirements[0])
          pbSpeech("Receptionist", "none",
            "You do not have the required Pokémon.")
          return false
        end
      else
        pbSpeech("Receptionist", "none",
          "Please come back when you have the Pokémon you wish to deliver.")
        return false
      end
    elsif type==1 # Category Catching
      return
    elsif type==2 # Item Fetching
      item = PBItems.getName(requirements[0])
      pbSpeech("Receptionist", "none",
        _INTL("Do you want to deliver the {1}?",item),
        false,["Yes","No"])
      if pbGet(1)==0
        $PokemonBag.pbDeleteItem(requirements[0],1)
      else
        pbSpeech("Receptionist", "none",
          "Please come back when you wish to deliver the item.")
        return false
      end
    end
    pbSpeech("Receptionist", "none", "\\GThank you, your efforts are greatly appreciated.")
    if @day <= pbGetTimeNow.day
      bonus=(rewards[0]*0.5).round
      $player.money+=rewards[0]+bonus
      pbSEPlay("purchase",100,100)
      pbText(_INTL("\\GPLAYER received ${1}!BREAK(+${2} bonus for efficient work)",rewards[0],bonus))
    else
      $player.money+=rewards[0]
      pbSEPlay("purchase",100,100)
      pbText(_INTL("\\GPLAYER received ${1}!",rewards[0]))
    end
    Kernel.pbReceiveItem(rewards[1],1)
    pbRemoveMiniQuestFromList($game_variables[CURRENTMINIQUEST])
    $game_variables[CURRENTMINIQUEST]=0
    $game_variables[MINIQUESTCOUNT]+=1
    pbMiniQuestPromotion($game_variables[MINIQUESTCOUNT])
    return true
  end

end

def pbMiniQuestPromotion(count)
  refresh=false
  if count==1
    pbSpeech("Receptionist", "none",
      "You completed your first task, good job!")
    pbSpeech("Receptionist", "none",
      "You have been promoted from Newbie to Beginner.")
    pbSpeech("Receptionist", "none",
      "Your selection of tasks has expanded as well.")
    pbSpeech("Receptionist", "none",
      "Here is your reward for this achievement.")
    Kernel.pbReceiveItem(:POKEBALL,20)
    refresh=true
  elsif count==2
    pbSpeech("Receptionist", "none",
      "You've completed multiple tasks, and have therefore been promoted from Beginner to Novice!")
    pbSpeech("Receptionist", "none",
      "Your selection of tasks has expanded and more difficult tasks will be given to you.")
    pbSpeech("Receptionist", "none",
      "Here is your reward for this achievement.")
    Kernel.pbReceiveItem(:GREATBALL,20)
    refresh=true
  elsif count==6
    pbSpeech("Receptionist", "none",
      "You've completed many tasks, and have therefore been promoted from Novice to Competent!")
    pbSpeech("Receptionist", "none",
      "Your selection of tasks has expanded and more difficult tasks will be given to you.")
    pbSpeech("Receptionist", "none",
      "Here is your reward for this achievement.")
    Kernel.pbReceiveItem(:ULTRABALL,20)
    refresh=true
  elsif count==12
    pbSpeech("Receptionist", "none",
      "You've completed a lot tasks, and have therefore been promoted from Competent to Proficient!")
    pbSpeech("Receptionist", "none",
      "Your selection of tasks has expanded and more difficult tasks will be given to you.")
    pbSpeech("Receptionist", "none",
      "Here is your reward for this achievement.")
    Kernel.pbReceiveItem(:ABILITYCAPSULE,2)
    refresh=true
  elsif count==20
    pbSpeech("Receptionist", "none",
      "You've completed a large amount of tasks, and have therefore been promoted from Proficient to Expert!")
    pbSpeech("Receptionist", "none",
      "Your selection of tasks has expanded to the maximum and more difficult tasks will be given to you.")
    pbSpeech("Receptionist", "none",
      "Here is your reward for this achievement.")
    Kernel.pbReceiveItem(:BOTTLECAP,5)
    refresh=true
  elsif count==30
    pbSpeech("Receptionist", "none",
      "Few have completed as many tasks as you, you're therefore promoted from Expert to Elite!")
    pbSpeech("Receptionist", "none",
      "Very difficult tasks will now be given to you.")
    pbSpeech("Receptionist", "none",
      "Here is your reward for this achievement.")
    Kernel.pbReceiveItem(:GOLDBOTTLECAP,1)
    refresh=true
  elsif count==100
    pbSpeech("Receptionist", "none",
      "You've completed 100 tasks! Amazing! You have been promoted from Elite to Master!")
    pbSpeech("Receptionist", "none",
      "The highest difficulty of tasks we get will be given to you.")
    pbSpeech("Receptionist", "none",
      "Here is your reward for this achievement.")
    Kernel.pbReceiveItem(:MASTERBALL,1)
    refresh=true
  elsif count==1000
    pbSpeech("Receptionist", "none",
      "You have completed 1000 tasks!? Why? Just WHY?WT Do you not have anything better to do?")
    pbSpeech("Receptionist", "none",
      "Well, since you did all that work, you have been specially \"promoted\" from Master to 'Why?'")
    pbSpeech("Receptionist", "none",
      "Your task selection is the same as before.")
    pbSpeech("Receptionist", "none",
      "We don't have any more rewards, so... take this.")
    Kernel.pbReceiveItem(:PRETTYWING,1)
  end
  if refresh
    $game_variables[MINIQUESTLIST]=0
  end
end

def pbMiniQuest
  if $game_variables[CURRENTMINIQUEST].is_a?(MiniQuest)
    return $game_variables[CURRENTMINIQUEST]
  end
  return false
end

def pbRandomRewardItem(difficulty)
  difficulty -= rand(2) if difficulty > 0
  items = [
    # Difficulty 0
    [:SUPERPOTION,
     :HYPERPOTION,
     :SUPERREPEL,
     :MAXREPEL,
     :HEARTSCALE,
     :HONEY,
     :BIGMUSHROOM,
     :STARDUST,
     :FULLHEAL,
     :FLOATSTONE],
    # Difficulty 1
    [:BIGMUSHROOM,
     :SHELLBELL,
     [:HEATROCK,
      :ICYROCK,
      :SMOOTHROCK,
      :DAMPROCK,
      :VELVETYROCK],
     [:CHARCOAL,
      :MIRACLESEED,
      :MYSTICWATER,
      :PIXIEDUST,
      :SILKSCARF,
      :METALCOAT,
      :HARDSTONE,
      :NEVERMELTICE,
      :BLACKGLASSES,
      :POISONBARB,
      :SILVERPOWDER,
      :MAGNET,
      :BLACKBELT,
      :SOFTSAND,
      :SHARPBEAK,
      :TWISTEDSPOON,
      :SPELLTAG,
      :DRAGONFANG,
      :EXPERTBELT],
     :SMOKEBALL,
     :SOOTHEBELL,
     :LIGHTCLAY,
     :METRONOME,
     :MUSCLEBAND,
     :WISEGLASSES,
     :RAZORCLAW,
     :RAZORFANG,
     :SCOPELENS,
     :WIDELENS,
     :ZOOMLENS,
     [:DEEPSEATOOTH,
      :DEEPSEASCALE],
     [:UPGRADE,
      :DUBIOUSDISC],
     :MAXPOTION],
    # Difficulty 2
    [:BALMMUSHROOM,
     :ROCKYHELMET,
     :BIGPEARL,
     [:OLDAMBER,
      :HELIXFOSSIL,
      :DOMEFOSSIL,
      :ROOTFOSSIL,
      :CLAWFOSSIL,
      :SKULLFOSSIL,
      :ARMORFOSSIL,
      :COVERFOSSIL,
      :PLUMEFOSSIL,
      :SAILFOSSIL,
      :JAWFOSSIL],
     [:FIRESTONE,
      :WATERSTONE,
      :THUNDERSTONE,
      :LEAFSTONE,
      :ICESTONE],
     :AMULETCOIN,
     [:CHOICEBAND,
      :CHOICESCARF,
      :CHOICESPECS],
     :LEFTOVERS,
     :KINGSROCK,
     :FLAMEORB,
     :TOXICORB,
     [:LAXINCENSE,
      :FULLINCENSE,
      :LUCKINCENSE,
      :PUREINCENSE,
      :SEAINCENSE,
      :WAVEINCENSE,
      :ROSEINCENSE,
      :ODDINCENSE,
      :ROCKINCENSE,
      :TROPICALINCENSE],
     :FULLRESTORE,
     :MAXREVIVE,
     :HPUP,
     :PROTEIN,
     :IRON,
     :CALCIUM,
     :ZINC,
     :CARBOS,
     :WHETSTONE,
     :BOTTLECAP,
     :BOTTLECAP],
    # Difficulty 3
    [:NUGGET,
     [:SUNSTONE,
      :MOONSTONE,
      :DUSKSTONE,
      :DAWNSTONE,
      :SHINYSTONE],
     :EVIOLITE,
     :LUCKYEGG,
     :LIFEORB,
     :PPUP,
     :ABILITYCAPSULE,
     :ASSAULTVEST,
     :BOTTLECAP],
    # Difficulty 4
    [:BIGNUGGET,
     :PPMAX,
     :HABILITYCAPSULE,
     :GOLDBOTTLECAP],
    # Difficulty 5
    [:COMETSHARD,
     :MASTERBALL,
     :GOLDBOTTLECAP]
  ][difficulty]
  item = items.shuffle[0]
  while item.is_a?(Array)
    item = items.shuffle[0]
  end
  return item
end

def pbRandomQuestItem(difficulty)
  items = [
    # Difficulty 0
    [:ESCAPEROPE,
     :TINYMUSHROOM,
     :HEARTSCALE,
     :SHOALSHELL],
    # Difficulty 1
    [:HONEY,
     :PEARL,
     :RAREBONE,
     :IRONBALL,
     :METALPOWDER,
     :QUICKPOWDER,
     :BERRYJUICE],
    # Difficulty 2
    [:BIGMUSHROOM,
     :SHELLBELL,
     [:HEATROCK,
      :ICYROCK,
      :SMOOTHROCK,
      :DAMPROCK,
      :VELVETYROCK],
     [:CHARCOAL,
      :MIRACLESEED,
      :MYSTICWATER,
      :PIXIEDUST,
      :SILKSCARF,
      :METALCOAT,
      :HARDSTONE,
      :NEVERMELTICE,
      :BLACKGLASSES,
      :POISONBARB,
      :SILVERPOWDER,
      :MAGNET,
      :BLACKBELT,
      :SOFTSAND,
      :SHARPBEAK,
      :TWISTEDSPOON,
      :SPELLTAG,
      :DRAGONFANG]],
    # Difficulty 3
    [:BALMMUSHROOM,
     :ROCKYHELMET,
     :BIGPEARL,
     :ASSAULTVEST],
    # Difficulty 4
    [:NUGGET],
    # Difficulty 5
    [:BIGNUGGET,
     :TRINITYORB]
  ][difficulty]
  item = items.shuffle[0]
  while item.is_a?(Array)
    item = items.shuffle[0]
  end
  return item
end

def pbLegendaryPokemon
  return [
    :ARTICUNO, :ZAPDOS, :MOLTRES,
    :MEWTWO, :MEW,
    :RAIKOU, :ENTEI, :SUICUNE,
    :LUGIA, :HOOH,
    :CELEBI,
    :ROTOM,
    :REGIROCK, :REGICE, :REGISTEEL,
    :LATIAS, :LATIOS,
    :KYOGRE, :GROUDON, :RAYQUAZA,
    :JIRACHI,
    :DEOXYS,
    :UXIE, :MESPRIT, :AZELF,
    :DIALGA, :PALKIA, :GIRATINA,
    :HEATRAN,
    :REGIGIGAS,
    :CRESSELIA, :DARKRAI,
    :PHIONE, :MANAPHY,
    :SHAYMIN, :ARCEUS,
    :VICTINI,
    :COBALION, :TERRAKION, :VIRIZION,
    :TORNADUS, :THUNDURUS, :LANDORUS,
    :RESHIRAM, :ZEKROM, :KYUREM,
    :KELDEO,
    :MELOETTA,
    :GENESECT,
    :XERNEAS, :YVELTAL, :ZYGARDE,
    :DIANCIE,
    :HOOPA,
    :VOLCANION,
    :TYPENULL, :SILVALLY,
    :TAPUKOKO, :TAPULELE,
    :TAPUBULU, :TAPUFINI,
    :COSMOG, :COSMOEM,
    :SOLGALEO, :LUNALA,
    :NIHILEGO,
    :BUZZWOLE, :PHEROMOSA,
    :XURKITREE,
    :CELESTEELA, :KARTANA,
    :GUZZLORD,
    :NECROZMA,
    :MAGEARNA,
    :MARSHADOW,
    :POIPOLE, :NAGANADEL,
    :STAKATAKA, :BLACEPHALON,
    :ZERAORA
  ]
end

def pbStaticPokemon
  return [
    :ROTOM,
    :ZORUA, :ZOROARK,
    :DEINO, :ZWEILOUS, :HYDREIGON,
    :LARVESTA, :VOLCARONA
  ]
end

def pbRandomTrainerType(gender=nil)
  male=[
    :YOUNGSTER,
    :SCHOOLBOY,
    :PRESCHOOLER_M,
    :PKMNBREEDER_M,
    :PKMNRANGER_M,
    :BACKPACKER_M,
    :FISHERMAN,
    :GUITARIST,
    :PAINTER,
    :RICHBOY,
    :SCIENTIST_M,
    :BLACKBELT,
    :JANITOR,
    :PKMNFAN_M,
    :DOCTOR,
    :HIKER
  ]
  female=[
    :LASS,
    :SCHOOLGIRL,
    :NURSERYAID,
    :PRESCHOOLER_F,
    :PKMNBREEDER_F,
    :PKMNRANGER_F,
    :BACKPACKER_F,
    :BAKER,
    :LIBRARIAN,
    :LADY,
    :SCIENTIST_F,
    :CRUSHGIRL,
    :PKMNFAN_F,
    :NURSE,
    :PARASOLLADY
  ]
  if gender
    if gender==0
      return male.shuffle[0]
    else
      return female.shuffle[0]
    end
  else
    types = male + female
    return types.shuffle[0]
  end
end

def pbRandomName(gender=nil)
  male=[
    'Chong','Wilmer','Matt','Nickolas','Jarrod',
    'Cody','Edgar','Ernesto','Donald','Raymon',
    'Williams','Cesar','Irvin','Eli','Rosendo',
    'Troy','Elbert','Antony','Edgardo','Philip',
    'Dong','Bo','Seymour','Jospeh','Hubert',
    'Elvin','Logan','Marlon','Oswaldo','Eddie',
    'Bret','Alfonso','Ben','Ralph','Tristan',
    'Marlin','Reyes','Andrea','Titus','Carlton',
    'Connie','Ted','Heriberto','Teodoro','Zachary',
    'Gonzalo','Francesco','Kim','Nick','Alec',
    'Foster','Ismael','Brendan','Johnathan','Alan',
    'JC','Rayford','Brenton','Herschel','Fernando',
    'Ira','Humberto','Rico','Ross','Fletcher',
    'Antoine','Robt','Pablo','Mitchel','Harlan',
    'Kendrick','Rodger','Gerry','Jerrold','Matthew',
    'Maximo','Jamaal','Christoper','Darryl','Horacio',
    'Bud','Milford','Isidro','Russ','Fritz',
    'Randall','Pete','Lucius','Rodrick','Adolph',
    'Lowell','Deshawn','Morris','Emmett','Terrance',
    'Gordon','Darnell','Johnny','Lee','Armand'
  ]
  female=[
    'Ciara','Becky','Jeanna','Soledad','Cathy',
    'Maurita','Donette','Tashina','Lucia','Noella',
    'Genny','Albertha','Jodie','Ona','Nicole',
    'Ellan','Sueann','Gisele','Romelia','Paulita',
    'Rowena','Shawna','Kellye','Francisca','Kathryne',
    'Bobette','Kathryn','Alvera','Nora','Esta',
    'Verla','Keesha','Madge','Lanora','Krysten',
    'Romona','Deeanna','Katelyn','Jeri','Blondell',
    'Liza','Mechelle','Beatrice','Junie','Kortney',
    'Annita','Vergie','Loriann','See','Thi',
    'Ligia','Randi','Tonda','Shantay','Dolly',
    'Scarlet','Carie','Leana','Sharita','Carman',
    'Imelda','Arnetta','Shela','Juliane','Masako',
    'Mercedes','Una','Sheba','Eliza','Alaine',
    'Loida','Anitra','Cleta','Marisha','Kristeen',
    'Larita','Ione','Elvina','Jazmin','Domitila',
    'Marcela','Janina','Caitlyn','Shawnda','Classie',
    'Geri','Robena','Kiesha','Ema','Virgina',
    'Margaretta','Norine','Janine','Melba','Erica',
    'Shani','Kiley','Jeffie','Kayleen','Alexandra'
  ]
  if gender
    if gender==0
      return male.shuffle[0]
    else
      return female.shuffle[0]
    end
  else
    genders = male + female
    return genders.shuffle[0]
  end
end




