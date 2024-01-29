module PBMaps  
  None              = 0
  
  # Routes
  ShalePath         = 6
  LazuliRiver       = 9
  MtPegmaHillside   = 14
  BrecciaTrail      = 62
  QuartzPassing     = 72
  QuartzFalls       = 73
  QuartzGrove       = 74
  CanjonValley      = 106
  LakeCanjon        = 107
  ScoriaDesert      = 132
  ScoriaCanyon      = 216
  SouthGabbroRiver  = 220
  
  # Areas
  Crosswoods        = 7
  HalcyonClearing   = 58
  HalcyonForest     = 61
  DeepBreccia       = 68
  BrecciaOutlook    = 120
  WestAndesIsle     = 25
  EastAndesIsle     = 26
  EvergoneMangrove  = 208
  EvergoneHill      = 209
  EvergoneStairway  = 210
  EvergoneRuins     = 211
  EvergoneCrater    = 70
  SmokeyForest1     = 129
  SmokeyForest2     = 130
  RangerOutpost     = 219
  
  # Caves
  MtPegma1F         = 20
  MtPegma1F_2       = 44
  MtPegma2F         = 45
  MtPegma3F         = 47
  MtPegmaPeak       = 48
  LakeKirrock       = 46
  MicaQuarryB1F     = 92
  MicaQuarryB2F     = 93
  MicaQuarryB3F     = 94
  MicaQuarryB4F     = 95
  MicaQuarryB5F     = 96
  MicaQuarryB6F     = 97
  MicaQuarryB7F     = 98
  MicaQuarryB8F     = 99
  
  # Cities
  ShaleTown         = 3
  LazuliDistrict    = 113
  LapisLazuliPark   = 22
  MicaDistrict      = 12
  MicaQuarry        = 87
  BrecciaCity       = 8
  BrecciaUndergrowth= 11
  FeldsparDistrict  = 21
  LapisDistrict     = 27
  ScoriaCity        = 198
  AmphiTown         = 221
  
  # Housing
  BrecciaCity_H     = 19
  LazuliCity_H      = 50
  
  # Centers
  LapisTown_C       = 28
  
  # Other
  GPO_HQ            = 35
  GPO_Living        = 36
  GPO_Healthcare    = 38
  GPO_Pokecare      = 56
  GPO_Admin         = 57
  Amethysts_Office  = 40
  
  def PBMaps.hasSpikes(map = nil)
    map = $game_map.map_id if !map
    map = getID(PBMaps,map) if map.is_a?(Symbol)
    spike_maps = [
      PBMaps::CanjonValley
    ]
    return true if spike_maps.include?(map)
    return false
  end
  
  def PBMaps.hasLights(map = nil)
    map = $game_map.map_id if !map
    map = getID(PBMaps,map) if map.is_a?(Symbol)
    light_maps = [
      PBMaps::BrecciaCity,
      PBMaps::LazuliDistrict,
      PBMaps::LapisDistrict,
      PBMaps::MicaDistrict,
      PBMaps::FeldsparDistrict
    ]
    return true if light_maps.include?(map)
    return false
  end
  
end







