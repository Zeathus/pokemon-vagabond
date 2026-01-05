def pbAmphiWoodsEncounter
  amphi_pos = $game_variables[AMPHIWOODSPOS]
  if amphi_pos < 8
    directions = [:GOLETT,
                  :CUTIEFLY,
                  :SALANDIT,
                  :BRIONNE]
    return directions[pbAmphiWoodsRoute[amphi_pos]]
  end
  return [
    :GOLETT,
    :CUTIEFLY,
    :SALANDIT,
    :BRIONNE
  ].shuffle[0]
end

def pbAmphiWoodsRoute
  # 0 = north / earth / golett
  # 1 = east  / air   / cutiefly
  # 2 = south / fire  / salandit
  # 3 = west  / water / brionne
  if !$game_variables[AMPHIWOODSROUTE].is_a?(Array)
    route = []
    loop do
      route = []
      first = rand(3)
      route.push(first==1 ? 3 : first)
      hits = 0
      for i in 0...5
        # Try until you don't go back where you came
        loop do
          r = rand(4)
          if i == 4 && r == 0
            # Make sure the final exit doesn't go back where you came
            next
          end
          if r != (route[i] + 2) % 4
            route.push(r)
            hits |= 1 << r
            break
          end
        end
      end
      # Second to last is always going back where you came
      route.push((route[route.length - 1] + 2) % 4)
      # Last is always north
      route.push(0)
      break if hits == 15
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