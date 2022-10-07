def pbAmphiWoodsEncounter
  amphi_pos = $game_variables[AMPHIWOODSPOS]
  if amphi_pos < 8
    directions = [:GOLETT,
                  :CUTIEFLY,
                  :SALANDIT,
                  :BRIONNE]
    return directions[pbAmphiWoodsRoute[amphi_pos]]
  end
  return :RATTATA
end

def pbAmphiWoodsRoute
  # 0 = north / earth / golett
  # 1 = east  / air   / cutiefly
  # 2 = south / fire  / salandit
  # 3 = west  / water / brionne
  if !$game_variables[AMPHIWOODSROUTE].is_a?(Array)
    route = []
    first = rand(3)
    route.push(first==1 ? 3: first)
    for i in 0...7
      route.push(rand(4))
    end
    $game_variables[AMPHIWOODSROUTE] = route
  end
  return $game_variables[AMPHIWOODSROUTE]
end

def pbAmphiWoodsCorrect(dir)
  pos = $game_variables[AMPHIWOODSPOS]
  if pbAmphiWoodsRoute[pos]==dir
    return true
  end
  return false
end