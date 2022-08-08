def pbGetDayMonth(day)
  make_st = [1, 11, 21, 31]
  make_nd = [2, 12, 22]
  make_rd = [3, 13, 23]
  return day.to_s + "st" if make_st.include?(day)
  return day.to_s + "nd" if make_nd.include?(day)
  return day.to_s + "rd" if make_rd.include?(day)
  return day.to_s + "th"
end

def pbMinutesPassed?(start, minutes)
  # Time is in minuted
  timeNow = pbGetTimeNow.to_i_min
  return (start + minutes <= timeNow)
end 