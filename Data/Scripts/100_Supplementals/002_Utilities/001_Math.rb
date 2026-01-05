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

def levenshtein_distance(s, t)
  m = s.length
  n = t.length
  return m if n == 0
  return n if m == 0
  d = Array.new(m+1) {Array.new(n+1)}

  (0..m).each {|i| d[i][0] = i}
  (0..n).each {|j| d[0][j] = j}
  (1..n).each do |j|
    (1..m).each do |i|
      d[i][j] = if s[i-1] == t[j-1]  # adjust index into string
                  d[i-1][j-1]       # no operation required
                else
                  [ d[i-1][j]+1,    # deletion
                    d[i][j-1]+1,    # insertion
                    d[i-1][j-1]+1,  # substitution
                  ].min
                end
    end
  end
  d[m][n]
end