def pbHueShift(color, hue)

  u = Math.cos(hue * Math::PI / 180)
  w = Math.sin(hue * Math::PI / 180)

  r = (0.299 + 0.701*u + 0.168*w) * color.red +
      (0.587 - 0.587*u + 0.330*w) * color.green +
      (0.114 - 0.114*u - 0.497*w) * color.blue
  g = (0.299 - 0.299*u - 0.328*w) * color.red +
      (0.587 + 0.413*u + 0.035*w) * color.green +
      (0.114 - 0.114*u + 0.292*w) * color.blue
  b = (0.299 - 0.300*u + 1.250*w) * color.red +
      (0.587 - 0.588*u - 1.050*w) * color.green +
      (0.114 + 0.886*u - 0.203*w) * color.blue

  r = clamp(r, 0, 255)
  g = clamp(g, 0, 255)
  b = clamp(b, 0, 255)

  return Color.new(r,g,b)    

end

def clamp(val, min, max)
  return min if val < min
  return max if val > max
  return val
end