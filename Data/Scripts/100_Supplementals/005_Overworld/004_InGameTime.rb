class CustomTime

  attr_accessor(:sec)
  attr_accessor(:min)
  attr_accessor(:hour)
  attr_accessor(:day)
  attr_accessor(:lasttime)
  attr_accessor(:pause)

  def initialize
    self.sec = 0
    self.min = 0
    self.hour = 12
    self.day = 1
    self.lasttime = Time.now
    self.pause = false
  end

  def wday
    days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ]
    return days[(day-1) % 7]
  end

  def month
    return ((day / 30).floor) % 12
  end

  def mon
    return self.month
  end

  def year
    return (day / 365).floor
  end

  def update
    return false if self.pause
    timenow = Time.now
    if timenow.sec != lasttime.sec
      self.sec += 30
      self.min += 1 if sec >= 60
      self.hour += 1 if min >= 60
      pbUpdateWeather if min >= 60
      pbGenerateForecast if hour >= 24
      self.day += 1 if hour >= 24
      self.sec = 0 if sec >= 60
      self.min = 0 if min >= 60
      self.hour = 0 if hour >= 24
      self.lasttime = timenow
      return true
    end
    self.lasttime = timenow
    return false
  end

  def getDigitalString(showday=false, shortday=false)
    if pbGetLanguage()==2 # English, 12-hour format
      hour_now = self.hour
      suffix = "AM"
      if hour_now >= 12
        suffix = "PM"
        hour_now-=12
      end
      hour_now = 12 if hour_now == 0
      if showday
        return (shortday ? wday[0...3] : wday) + " " + _ISPRINTF("{1:02d}:{2:02d}",hour_now,self.min) + " " + suffix
      end
      return _ISPRINTF("{1:02d}:{2:02d}",hour_now,self.min) + " " + suffix
    else # Other country 24-hour format
      if showday
        return (shortday ? wday[0...3] : wday) + " " + _ISPRINTF("{1:02d}:{2:02d}",self.hour,self.min)
      end
      return _ISPRINTF("{1:02d}:{2:02d}",self.hour,self.min)
    end
  end

  def forwardToTime(h, m)
    self.day += 1
    self.hour = h
    self.min = m
    pbGenerateForecast
    pbUpdateWeather
  end

  def to_i
    ret = self.sec
    ret += self.min * 60
    ret += self.hour * 60 * 60
    ret += self.day * 24 * 60 * 60
    return ret
  end

  def to_i_min
    ret = self.min
    ret += self.hour * 60
    ret += self.day * 24 * 60
    return ret
  end

end

alias sup_pbGetTimeNow pbGetTimeNow

def pbGetTimeNow
  return sup_pbGetTimeNow if !Supplementals::USE_INGAME_TIME
  if $game_variables
    if !$game_variables[Supplementals::TIME_AND_DAY].is_a?(CustomTime)
      $game_variables[Supplementals::TIME_AND_DAY] = CustomTime.new
    end
    return $game_variables[Supplementals::TIME_AND_DAY]
  end
  return Time.now
end

def pbGetDayNow
  if $game_variables
    if !$game_variables[TIME_AND_DAY] || $game_variables[TIME_AND_DAY]==0
      time=Time.now

    end
    return $game_variables[TIME_AND_DAY][1]
  end
  return PBWeekdays::Monday
end

module PBWeekdays
  Monday    = 0
  Tuesday   = 1
  Wednesday = 2
  Thursday  = 3
  Friday    = 4
  Saturday  = 5
  Sunday    = 6
end

module PBDayNight
  def self.getTimeOfDay(time=nil)
    if self.isDay?(time)
      return "day"
    elsif self.isNight?(time)
      return "night"
    elsif self.isMorning?(time)
      return "morning"
    elsif self.isAfternoon?(time)
      return "afternoon"
    elsif self.isEvening?(time)
      return "evening"
    end
    return "day"
  end
end