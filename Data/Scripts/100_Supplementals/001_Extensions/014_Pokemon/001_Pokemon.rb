class Pokemon

  def el
    ret = {}
    GameData::Stat.each_main do |s|
      level = 0
      for i in 1..Supplementals::MAX_EFFORT_LEVEL
        if @iv[s.id] < Supplementals::EFFORT_LEVEL_IVS[i] ||
           @ev[s.id] < Supplementals::EFFORT_LEVEL_EVS[i]
          break
        end
        level = i
      end
      ret[s.id] = level
    end
    return ret
  end

  def total_el
    els = self.el
    total = 0
    els.each_value { |i|
      total += i
    }
    return total
  end

  def total_counting_els
    els = self.el
    total = 0
    els.each_value { |i|
      if i > Supplementals::IGNORE_TOTAL_EFFORT_LEVELS
        total += i - Supplementals::IGNORE_TOTAL_EFFORT_LEVELS
      end
    }
    return total
  end

  def el=(value)
    GameData::Stat.each_main do |s|
      @iv[s.id] = Supplementals::EFFORT_LEVEL_IVS[value[s.id]]
      @ev[s.id] = Supplementals::EFFORT_LEVEL_EVS[value[s.id]]
    end
  end

  def align_el
    self.el = self.el
  end

end