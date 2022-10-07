def pbGenerateForecast
  areas = [
    [[[6.5,12],[4.5,11.5]],[:BrecciaPassage,:BrecciaCity,:BrecciaUndergrowth,:DeepBreccia,:BrecciaOutlook]],
    [[[8,14],[7.5,16]],[:LazuliRiver,:LazuliDistrict,:LapisDistrict]],
    [[[8,11],[8,9]],[:MicaTown,:FeldsparTown,:MtPegmaHillside,:MtPegmaPeak]],
    [[[6,8],[4,9]],[:QuartzPassing,:QuartzFalls,:QuartzGrove]],
    [[[16,15],[18.5,15]],[:WestAndesIsle,:EastAndesIsle]],
    [[[25,12.5]],[:CanjonValley]]
  ]

  desert_areas = [
    PBMaps::CanjonValley
  ]

  weathers = [
    :None,
    :None,
    :Rain,
    :Sun,
    :Winds
  ]

  desert_weathers = [
    :None,
    :None,
    :None,
    :Sun,
    :Sun,
    :Sandstorm,
    :Sandstorm,
    :Sandstorm,
    :Winds
  ]

  weathers.push(:Sun) if pbGetTimeNow.wday=="Sunday"
  weathers.push(:Rain) if pbGetTimeNow.wday=="Wednesday"
  weathers.push(:Winds) if pbGetTimeNow.wday=="Friday"

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
  bloodmoon = rand(areas.length) if pbGetTimeNow.wday=="Friday" && pbGetTimeNow.day % 13 == 0
  if bloodmoon<areas.length && pbGetTimeNow.day>2
    Kernel.pbMessage("Blood Moon spawned") if debug_extra?
    area=areas[bloodmoon]
    for map in area[1]
      map = getID(PBMaps,map) if map.is_a?(Symbol)
      forecast[0][map]=PBFieldWeather::BloodMoon
    end
    for coords in area[0]
      for i in 0...forecast[1].length
        if forecast[1][i][0][0][0]==coords[0] && forecast[1][i][0][0][1]==coords[1]
          forecast[1][i][1]=PBFieldWeather::BloodMoon
        end
      end
    end
  end

  $game_variables[DAILY_FORECAST]=forecast

  pbUpdateWeather
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
    forecast = pbGetForecast
    if forecast[$game_map.map_id] && outdoor_map
      if $game_screen.weather_type != forecast[$game_map.map_id]
        weather=forecast[$game_map.map_id]
        if weather==:None
          $game_screen.weather(0,0,0)
        elsif weather==:Sun
          if pbGetTimeNow.hour<=17 && pbGetTimeNow.hour>=5
            $game_screen.weather(weather,5,200)
          else
            $game_screen.weather(0,0,0)
          end
        elsif weather==:BloodMoon
          if pbGetTimeNow.hour>=18
            $game_screen.weather(weather,5,200)
          else
            $game_screen.weather(0,0,0)
          end
        else
          $game_screen.weather(weather,5,200)
        end
      end
    else
      $game_screen.weather(0,0,0)
    end
  end
  pbUpdateVFX
end

def pbGetForecast(index=0)
  if $game_variables[DAILY_FORECAST].is_a?(Array) && !$game_variables[DAILY_FORECAST][index].is_a?(Array)
    $game_variables[DAILY_FORECAST]=0
  end
  pbGenerateForecast if $game_variables[DAILY_FORECAST]==0
  return $game_variables[DAILY_FORECAST][index]
end





