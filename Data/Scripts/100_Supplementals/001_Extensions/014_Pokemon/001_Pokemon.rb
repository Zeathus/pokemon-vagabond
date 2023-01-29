class Pokemon

  def el
    ret = {}
    GameData::Stat.each_main do |s|
      level = 0
      for i in 1...Supplementals::MAX_EFFORT_LEVEL
        if @iv[s] < Supplementals::EFFORT_LEVEL_IVS[s] ||
           @ev[s] < Supplementals::EFFORT_LEVEL_EVS[s]
          break
        end
        level = i
      end
      ret[s] = level
    end
    return ret
  end

  def el=(value)
    GameData::Stat.each_main do |s|
      @iv[s] = Supplementals::EFFORT_LEVEL_IVS[value[s]]
      @ev[s] = Supplementals::EFFORT_LEVEL_EVS[value[s]]
    end
  end

end