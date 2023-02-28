def pbNextForecast
  if !$game_variables[DAILY_FORECAST].is_a?(Array)
    $game_variables[DAILY_FORECAST] = []
    pbGenerateForecast
  else
    $game_variables[DAILY_FORECAST].shift
    pbGenerateForecast
  end
end

def pbGenerateForecast
  $game_variables[DAILY_FORECAST] = [] if !$game_variables[DAILY_FORECAST].is_a?(Array)

  while $game_variables[DAILY_FORECAST].length < 5
    $game_variables[DAILY_FORECAST].push(pbGenerateSingleForecast)
  end

  pbUpdateWeather
end

def pbGenerateSingleForecast
  areas = [
    [[[10.5, 5],[7, 5]],[:BrecciaPassage,:BrecciaCity,:BrecciaUndergrowth,:DeepBreccia,:BrecciaOutlook]],
    [[[14, 7],[14, 9.5]],[:LazuliRiver,:LazuliDistrict,:LapisDistrict]],
    [[[21, 6]],[:MicaTown,:FeldsparTown,:MtPegmaHillside,:MtPegmaPeak]],
    [[[17.5, 5]],[:QuartzPassing]],
    [[[24.5, 15]],[:CanjonValley]]
  ]

  desert_areas = [
    PBMaps::CanjonValley
  ]

  weathers = [
    :None,
    :Cloudy,
    :Rain,
    :Sun,
    :Winds
  ]

  desert_weathers = [
    :None,
    :None,
    :Cloudy,
    :Sun,
    :Sun,
    :Sandstorm,
    :Sandstorm,
    :Sandstorm,
    :Winds
  ]

  weathers.push(:Sun) if pbGetTimeNow.wday == "Sunday"
  weathers.push(:Rain) if pbGetTimeNow.wday == "Wednesday"
  weathers.push(:Winds) if pbGetTimeNow.wday == "Friday"

  forecast=[]
  forecast[0]=[] # Array for map ids and weather
  forecast[1]=[] # Array for map icons for forecast

  for area in areas
    weather = weathers[rand(weathers.length)]
    if desert_areas.include?(getID(PBMaps,area[1][0]))
      weather = desert_weathers[rand(desert_weathers.length)]
    end
    for map in area[1]
      map = getID(PBMaps,map) if map.is_a?(Symbol)
      forecast[0][map]=weather
    end
    for coords in area[0]
      forecast[1].push([[coords],weather])
    end
  end

  bloodmoon = rand(areas.length*7)
  bloodmoon = rand(areas.length) if pbGetTimeNow.wday == "Friday" && pbGetTimeNow.day % 13 == 0
  if bloodmoon<areas.length && pbGetTimeNow.day > 2
    echoln "Blood Moon Spawned"
    area=areas[bloodmoon]
    for map in area[1]
      map = getID(PBMaps, map) if map.is_a?(Symbol)
      forecast[0][map] = :BloodMoon
    end
    for coords in area[0]
      for i in 0...forecast[1].length
        if forecast[1][i][0][0][0]==coords[0] && forecast[1][i][0][0][1]==coords[1]
          forecast[1][i][1] = :BloodMoon
        end
      end
    end
  end

  return forecast
end

def pbUpdateWeather
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  outdoor_map = map_metadata ? map_metadata.outdoor_map : true
  force_weather = false
  if outdoor_map
    if $game_switches[WEATHER_RAIN]
      if $game_screen.weather_type != PBFieldWeather::Rain
        $game_screen.weather(PBFieldWeather::Rain,9,200)
        force_weather = true
      end
    elsif $game_switches[WEATHER_SUN]
      if $game_screen.weather_type != PBFieldWeather::Sun
        $game_screen.weather(PBFieldWeather::Sun,1,200)
        force_weather = true
      end
    elsif $game_switches[WEATHER_SNOW]
      if $game_screen.weather_type != PBFieldWeather::Snow
        $game_screen.weather(PBFieldWeather::Snow,9,200)
        force_weather = true
      end
    elsif $game_switches[WEATHER_STORM]
      if $game_screen.weather_type != PBFieldWeather::Storm
        $game_screen.weather(PBFieldWeather::Storm,9,200)
        force_weather = true
      end
    end
  end
  if !force_weather
    forecast = pbGetForecast(false, 0)
    new_weather = :None
    if forecast[$game_map.map_id] && outdoor_map
      new_weather = forecast[$game_map.map_id]
      if new_weather == :BloodMoon
        if pbGetTimeNow.hour < 18
          new_weather = :None
        end
      end
    end
    if new_weather != $game_screen.weather_type
      if new_weather == :None
        $game_screen.weather(0,0,0)
      else
        $game_screen.weather(new_weather, 5, 200)
      end
    end
  end
  pbUpdateVFX
end

EventHandlers.add(:on_enter_map, :update_weather,
  proc { |_old_map_id|
    pbUpdateWeather
  }
)

def pbGetForecast(map_data = false, index = 0)
  pbGenerateForecast if !$game_variables[DAILY_FORECAST].is_a?(Array) || !$game_variables[DAILY_FORECAST][index]
  return $game_variables[DAILY_FORECAST][index][map_data ? 1 : 0]
end





