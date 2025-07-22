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
    if type==0
      blacklist = [
        :ARCHEBLAST,
        :TROPICOPIA,
        :LAPRANESSE,
        :SANDOLIN,
        :TYPENULL,
        :SILVALLY
      ]
      dex_list = pbLoadRegionalDexes[0]
      species_data = self.generate_pokemon(difficulty)
      species = species_data.species
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

  def self.generate_pokemon(difficulty)
    # Currently ends at regional dex #287
    return GameData::Species.get([
      [ # Difficulty 1
        :ZIGZAGOON,
        :PIDGEY,
        :HOPPIP,
        :SKIPLOOM,
        :CATERPIE,
        :METAPOD,
        :WEEDLE,
        :KAKUNA,
        :SEEDOT,
        :NICKIT,
        :NATU,
        :EEVEE,
        :MAGIKARP,
        :WOOPER,
        :POLIWAG,
        :SNIVY,
        :ODDISH,
        :TAILLOW,
        :COMBEE,
        :CUTIEFLY,
        :FLABEBE,
        :CHERUBI,
        :SWABLU,
        :GOSSIFLEUR,
        :SEWADDLE,
        :MINCCINO,
        :NINCADA,
        :ROWLET,
        :TIMBURR,
        :STUFFUL,
        :MAREEP,
        :MUDBRAY,
        :AZURILL,
        :MARILL,
        :PAWMI,
        :BUDEW,
        :PSYDUCK,
        :SHINX,
        :SPOINK,
        :SNUBBULL,
        :DUCKLETT,
        :WINGULL,
        :TRUBBISH,
        :MEOWTH,
        :SKITTY,
        :CHINGLING,
        :MUNCHLAX,
        :DRIFLOON,
        :MIMEJR,
        :BONSLY,
        :VULPIX,
        :FLETCHLING,
        :NIDORANfE,
        :NIDORANmA,
        :SALANDIT,
        :NUMEL,
        :GROWLITHE,
        :ROCKRUFF,
        :GEODUDE,
        :DIGLETT,
        :ARON,
        :TINKATINK,
        :MAGBY,
        :TYROGUE,
        :SPEAROW,
        :MAKUHITA,
        :SKIDDO,
        :MACHOP,
        :MUDKIP,
        :KRABBY,
        :MORELULL,
        :MURKROW,
        :PUMPKABOO,
        :RALTS,
        :DEWPIDER,
        :WIMPOD,
        :SLUGMA,
        :SCRAGGY,
        :DODUO,
        :HELIOPTILE,
        :SCORBUNNY,
        :FERROSEED,
        :CHARCADET,
        :FENNEKIN,
        :CACNEA,
        :BRAMBLIN,
        :SANDILE,
        :HIPPOPOTAS,
        :TRAPINCH,
        :ROGGENROLA,
        :NACLI,
        :SANDSHREW,
        :DARUMAKA,
        :ARCHEN,
        :TENTACOOL,
        :FINIZEN,
        :STARYU,
        :CLAUNCHER,
        :HORSEA,
        :WAILMER,
        :SHELLOS,
        :CLOBBOPUS,
        :SLOWPOKE,
        :MANTYKE
      ],
      [ # Difficulty 2
        :LINOONE,
        :PIDGEOTTO,
        :JUMPLUFF,
        :BUTTERFREE,
        :BEEDRILL,
        :NUZLEAF,
        :THIEVUL,
        :XATU,
        :CLODSIRE,
        :POLIWHIRL,
        :SERVINE,
        :GLOOM,
        :SWELLOW,
        :FLOETTE,
        :CHERRIM,
        :ELDEGOSS,
        :SWADLOON,
        :NINJASK,
        :DARTRIX,
        :GURDURR,
        :PACHIRISU,
        :FLAAFFY,
        :MILTANK,
        :HAPPINY,
        :AZUMARILL,
        :PAWMO,
        :ROSELIA,
        :GOLDUCK,
        :LUXIO,
        :GRUMPIG,
        :GRANBULL,
        :SWANNA,
        :INDEEDEE,
        :PELIPPER,
        :PERSIAN,
        :MRMIME,
        #:ROTOM,
        :FLETCHINDER,
        :NIDORINA,
        :NIDORINO,
        :CAMERUPT,
        #:LYCANROC,
        :GRAVELER,
        :DUGTRIO,
        :TINKATUFF,
        :MAGMAR,
        :ONIX,
        :FEAROW,
        :GOGOAT,
        :MACHOKE,
        :MARSHTOMP,
        :SHIINOTIC,
        :GOURGEIST,
        :KIRLIA,
        :CARNIVINE,
        :ABSOL,
        :DURANT,
        :MAGCARGO,
        :CARBINK,
        :HEATMOR,
        :TORKOAL,
        :RHYHORN,
        :DODRIO,
        :RABOOT,
        :SKARMORY,
        :BRAIXEN,
        :CACTURNE,
        :KROKOROK,
        :MARACTUS,
        :VIBRAVA,
        :BOLDORE,
        :NACLSTACK,
        :SANDSLASH,
        :TIRTOUGA,
        :TENTACRUEL,
        :QWILFISH,
        :SHUCKLE,
        :SEADRA,
        :CORSOLA,
        :GASTRODON,
        :MANTINE
      ],
      [ # Difficulty 3
        :PALMINO,
        :BOOMINE,
        :LAZU,
        :PIDGEOT,
        :VAPOREON,
        :JOLTEON,
        :FLAREON,
        :LEAFEON,
        :GLACEON,
        :GYARADOS,
        :POLIWRATH,
        :SERPERIOR,
        :VILEPLUME,
        :RIBOMBEE,
        :ALTARIA,
        :CINCCINO,
        :SHEDINJA,
        :DECIDUEYE,
        :BEWEAR,
        :AMPHAROS,
        :CHANSEY,
        :MUDSDALE,
        :LUXRAY,
        :GARBODOR,
        :DELCATTY,
        :CHIMECHO,
        :SNORLAX,
        :DRIFBLIM,
        :SUDOWOODO,
        :NINETALES,
        :TALONFLAME,
        :ARCANINE,
        :LAIRON,
        :TINKATON,
        :HITMONCHAN,
        :HITMONLEE,
        :HITMONTOP,
        :HARIYAMA,
        :SWAMPERT,
        :KINGLER,
        :GARDEVOIR,
        :ARAQUANID,
        :GOLISOPOD,
        :SCRAFTY,
        :RHYDON,
        :HELIOLISK,
        :CINDERACE,
        :FERROTHORN,
        :ARMAROUGE,
        :CERULEDGE,
        :DELPHOX,
        :BRAMBLEGHAST,
        :KROOKODILE,
        :HIPPOWDON,
        :FLYGON,
        :GARGANACL,
        :DARMANITAN,
        :ARCHEOPS,
        :CARRACOSTA,
        :PALAFIN,
        :OVERQWIL,
        :STARMIE,
        :CLAWITZER,
        :WAILORD,
        :GRAPPLOCT,
        :SLOWBRO,
        :SLOWKING
      ],
      [ # Difficulty 4
        :SHIFTRY,
        :ESPEON,
        :UMBREON,
        :SYLVEON,
        :POLITOED,
        :BELLOSSOM,
        :VESPIQUEN,
        :FLORGES,
        :LEAVANNY,
        :CONKELDURR,
        :BLISSEY,
        :PAWMOT,
        :ROSERADE,
        :NIDOQUEEN,
        :NIDOKING,
        :SALAZZLE,
        :GOLEM,
        :AGGRON,
        :MAGMORTAR,
        :STEELIX,
        :MACHAMP,
        :HONCHKROW,
        :GALLADE,
        :RHYPERIOR,
        :GIGALITH,
        :KINGDRA
      ],
      [ # Difficulty 5
        :DITTO
      ]
    ][difficulty].shuffle[0])
  end

  def name
    vocals = ['A','E','I','O','U','Y']
    if @type==0
      species = GameData::Species.get(requirements[0]).name
      if vocals.include?(species[0..0])
        return _INTL("Catch an {1}",species)
      else
        return _INTL("Catch a {1}",species)
      end
    elsif @type==1
      return "Category"
    elsif @type==2
      item = GameData::Item.get(requirements[0]).name
      if vocals.include?(item[0..0])
        return _INTL("Find an {1}",item)
      else
        return _INTL("Find a {1}",item)
      end
    end
    return "N/A"
  end

  def display_name(status=0)
    return self.name
  end

  def location
    return "???"
  end

  def trainer
    typename = GameData::TrainerType.get(@trainertype).name
    if typename.length > 11 && typename.include?(" ")
      typename = typename[(typename.index(" ")+1)..typename.length]
    end
    return _INTL("{1} {2}",typename,@trainername)
  end

  def description
    ret = self.name + " and return it to HQ.\n\n"
    return ret
  end

  def money
    return @rewards[0]
  end

  def items
    return [[@rewards[1], 1]]
  end

  def exp
    return 0
  end

  def steps
    return [pbGetStepDescription]
  end

  def pbGetStepDescription
    ret = "G.P.O. Task:\n"
    ret += self.name + " and return it to HQ.\n\n"
    ret += "Requested by:\n" + self.trainer
    return ret
  end

  def hide_items
    return false
  end

  def give_items
    return false
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

  def type
    return 15
  end

  def canComplete?
    if @type==0 # Catching
      species = requirements[0]
      return true if pbHasInParty?(species)
    elsif @type==1 # Category Catching
      return false
    elsif @type==2 # Item Fetching
      item = requirements[0]
      return true if $bag.quantity(item)>0
    end
    return false
  end

  def complete
    if @type==0 # Catching
      species = GameData::Species.get(requirements[0])
      pbSet(2, species)
      if !pbDialog("GPO_COMPLETE_TASK", 1)
        return false
      end
    elsif @type==1 # Category Catching
      return
    elsif @type==2 # Item Fetching
      item = GameData::Item.get(requirements[0])
      pbSet(2, item)
      if !pbDialog("GPO_COMPLETE_TASK", 2)
        return false
      end
      $bag.remove(requirements[0],1)
    end
    pbSet(2, @rewards[0])
    pbSet(3, GameData::Item.get(@rewards[1]).name)
    pbDialog("GPO_TASK_REWARD", 0)
    pbReceiveItem(@rewards[1])
    pbRemoveMiniQuestFromList($game_variables[CURRENTMINIQUEST])
    $game_variables[CURRENTMINIQUEST] = 0
    $game_variables[MINIQUESTCOUNT] += 1
    if pbJob("G.P.O.").level <= @difficulty + 1 && pbJob("G.P.O.").level < 5
      pbJob("G.P.O.").add_progress
    end
    pbMiniQuestPromotion($game_variables[MINIQUESTCOUNT])
    pbDialog("GPO_TASK_END")
    return true
  end

end

def pbMiniQuestPromotion(count)
  refresh=false
  if count == 1 # Small reward for first job
    pbDialog("GPO_PROMOTION", 0)
    pbReceiveItem(:POKEBALL,10)
  elsif pbJob("G.P.O.").progress >= pbJob("G.P.O.").requirement
    pbDialog("GPO_PROMOTION", pbJob("G.P.O.").level)
    case pbJob("G.P.O.").level
    when 1
      pbReceiveItem(:GREATBALL,10)
    when 2
      pbReceiveItem(:ULTRABALL,10)
    when 3
      pbReceiveItem(:ABILITYPATCH,1)
    when 4
      pbReceiveItem(:MASTERBALL,1)
    end
    pbJob("G.P.O.").level += 1
    pbJob("G.P.O.").reset_progress
    # Reset the list of tasks
    $game_variables[MINIQUESTLIST] = 0
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
     :HEALTHWING,
     :MUSCLEWING,
     :RESISTWING,
     :GENIUSWING,
     :CLEVERWING,
     :SWIFTWING,
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
     :FROSTORB,
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
     :CARBOS],
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
     :ASSAULTVEST],
    # Difficulty 4
    [:BIGNUGGET,
     :PPMAX,
     :ABILITYPATCH],
    # Difficulty 5
    [:COMETSHARD,
     :MASTERBALL]
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
    [:TINYMUSHROOM,
     :HEARTSCALE,
     :EVERSTONE,
     :ENERGYPOWDER],
    # Difficulty 1
    [:HONEY,
     :PEARL,
     :RAREBONE,
     :IRONBALL,
     :OVALSTONE],
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




