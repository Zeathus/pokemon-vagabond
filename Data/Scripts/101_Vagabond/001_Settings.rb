MAX_PARTY_BOX_SIZE   = 6

# ----------------------------------------------------------------------
# Game Switches
# ----------------------------------------------------------------------
GOT_STARTER         = 3
GYM_RAPHAEL         = 4
GYM_FAUNUS          = 5
GYM_LEROY           = 6
NO_TELEPORT         = 51
CUSTOM_WILD         = 53
TAKEN_STEP          = 54
FORCED_RUNNING      = 55
ATTACKS_ONLY_BATTLE = 56
AI_TAKEOVER         = 57
FORCE_VISUAL_LEADER = 58
NO_WILD_POKEMON     = 59
CATCH_BLOCK         = 60
MUDAMUDA            = 61
LETHAL_LOSSES       = 62
MESPRIT_AID         = 63
CANNOT_OPEN_MENUS   = 65
SPIN_PLAYER         = 66
MAP_UPDATE          = 67
HIDE_MARKERS        = 68
LOCK_PAUSE_MENU     = 69
QUEST_TUTORIAL      = 70
HAS_QUEST_LOG       = 71
TEMP_1              = 72
TEMP_2              = 73
TEMP_3              = 74
TEMP_4              = 75
BEING_CHALLENGED    = 76
DISABLE_EXP         = 79
SPEECH_COLOR_MOD    = 80
CAN_SURF            = 81
CHOSEN_POKEMON      = 82
GPO_MEMBER          = 85
HALCYON_ACCESS      = 86
REVERSE_CHASMS      = 87
ROD_UPGRADE         = 96
ANTISAVE            = 101
PERMA_SLEEP         = 102
SOFT_PARALYSIS      = 103
GHOST_ENCOUNTERS    = 104
QMARK_LEVEL         = 105
MINUS1_LEVEL        = 106
NO_TRAINER_CARD     = 108
HAS_HABITAT_DEX     = 109
WEATHER_RAIN        = 110
WEATHER_SUN         = 111
WEATHER_SNOW        = 112
WEATHER_STORM       = 113
SMOKEY_FOREST       = 114
STADIUM_POINT_SHOP  = 115
STADIUM_PARTY_SEL   = 116
HIDE_REFLECTIONS    = 117
INITIALIZED_SHELLOS = 118
MANHOLE_KEY         = 119
SHOW_COLLISION      = 124
DEBUG_EXTRA         = 125
SUMMARY_TUTORIAL    = 126
MOVES_TUTORIAL      = 127
TELEPORT_TUTORIAL   = 128
INACTIVE_PARTY_TUTORIAL = 129
UNSTOPPABLE         = 146
FINAL_BATTLE        = 147
POKEPLAYER          = 151
HAS_TELEPORT        = 152
MET_CERISE          = 153
HIDE_CERISE         = 154
MET_RANGERS         = 155
HAS_AZELF           = 156
HAS_UXIE            = 157
HAS_MESPRIT         = 158
HAS_SECRET_MARKET   = 159
HAS_STRENGTH        = 160
FRIENDOFELEMENTS    = 209

# ----------------------------------------------------------------------
# Game Variables
# ----------------------------------------------------------------------
PARTY_ACTIVE        = 23
PARTY_POKEMON       = 24
PARTY               = 25
VISUAL_PARTY        = 26
SAVED_PARTY         = 27
SAVED_PARTY_ACTIVE  = 28
INACTIVE_POKEMON    = 29
STARTER             = 34
STARTER_ID          = 35
BATTLE_SIM_AI       = 36
PLAYER_ROTATION     = 37
DAILY_MAIL          = 38
DAILY_FORECAST      = 39
BGM_OVERRIDE        = 40
TELEPORT_LIST       = 41
RIDE_PAGER          = 42
RIDE_CURRENT        = 43
RIDE_REGISTERED     = 44
DATA_CHIP_MOVES     = 45
HIGHEST_LEVEL       = 46
PLAYER_EXP          = 47
AVERAGE_LEVEL       = 48
TRAINER_ARRAY       = 49
LAST_QUEST          = 53
LAST_PAGE           = 54
QUEST_SORTING       = 55
LAST_PAUSE_INDEX    = 56
RUINS_DONE          = 57
PREF_LEVEL          = 58
CHOICES             = 59
BATTLE_PARTIES      = 60
DRINK_ACTIVE        = 61
DRINK_TIME          = 62
EXP_MODIFIER        = 63
MOVEMENT_SPEED      = 64
CUSTOM_POKEMON      = 65
RKS_MEMORY_TYPE     = 66
LAST_BATTLE_OPTION  = 67
BATTLE_ORIGINAL_LVL = 68
NEKANE_STATE        = 73
CHARACTER_LOCATIONS = 74
PARTY_STORE         = 76
BAG_STORE           = 77
WILD_MODIFIER       = 80
WILD_AI_LEVEL       = 81
WILD_AI_SKILLCODE   = 82
HOLDING_BACK        = 83
WILD_UNOWN_FORM     = 84
BOSS_BATTLE         = 85
TRAINER_BATTLE      = 86
BOSSES_DEFEATED     = 87
TIME_AND_DAY        = 90
JOBS                = 96
LEAGUE_MAX_PKMN     = 97
LEAGUE_MAX_LVL      = 98
BADGE_COUNT         = 99
DIFFICULTY          = 100
GLOBAL_TIMER        = 101
UI_ARRAY            = 102
OVERRIDE            = 104
AFFECTION           = 105
REELED_IN_POKEMON   = 106
STADIUM_POINTS      = 107
STADIUM_WON_CUPS    = 108
STADIUM_CUP         = 109
SICKZAGOON          = 110
POKEPLAYERID        = 112
LASTBATTLEDTRAINERS = 113
PERSISTENT_EVENTS   = 114
DEBUG_VAR           = 115
AMPHIWOODSPOS       = 128
AMPHIWOODSROUTE     = 129
CERISE_TOTAL        = 130
CERISE_VIRIZION     = 131
CERISE_COBALION     = 132
CERISE_TERRAKION    = 133
CURRENTMINIQUEST    = 144
MINIQUESTCOUNT      = 145
MINIQUESTCOUNT2     = 146
MINIQUESTLIST       = 147
MINIQUESTDAY        = 148
MINIQUESTLIST2      = 149
MINIQUESTDAY2       = 150
GUIDE_LIST          = 151
LAST_GUIDE          = 152
NEW_GUIDE           = 153
CHAIN_SPECIES       = 201
CHAIN_LENGTH        = 202
CUSTOM_POKEMON      = 203
CHANGE_BATTLE_INTRO = 204

# ----------------------------------------------------------------------
# Misc.
# ----------------------------------------------------------------------
MAIN_QUEST_DISPLAY_PRIORITY = [
  :THEFIRSTGYM,
  :BRECCIAGYM,
  :LAPISLAZULIGYM,
  :PEGMAGYM,
  :UNKNOWNDESTINATION,
  :OPERATIONPEGMA,
  :NEKANEGONEMISSING,
  :GUARDIANOFEMOTION
]

def pbPlayerPseudonym
  ret = $player.name[0].upcase
  ret += "2" if "AKN".include?(ret)
  return ret
end