def drawSmallTextEx(bitmap,x,y,width,numlines,text,baseColor,shadowColor)
  boxheight=numlines*22
  pbSetSmallFont(bitmap)
  normtext=getLineBrokenChunks(bitmap,text,width,nil,true)
  lines=getNormTextLines(normtext)
  perfectlySpacedLines(bitmap,normtext,boxheight,lines,numlines)
  renderLineBrokenChunksWithShadow(bitmap,x,y,normtext,numlines*32,
      baseColor,shadowColor)
end

def getNormTextLines(normtext)
  lines=0
  last_y=-1
  for word in normtext
    if word[2] != last_y
      lines+=1
      last_y = word[2]
    end
  end
  return lines
end

def perfectlySpacedLines(bitmap,normtext,boxheight,lines,maxlines)
  return if lines == 0 || normtext.length <= 0
  lines = maxlines - 1 if lines < maxlines - 1
  lineheight = boxheight / lines
  min_y = normtext[0][2]
  ycoords = []
  for word in normtext
    min_y = word[2] if word[2] < min_y
    ycoords.push(word[2]) if !ycoords.include?(word[2])
  end
  ycoords.sort! {|a,b| a<=>b}
  for word in normtext
    index = 0
    for i in 0...ycoords.length
      if word[2]==ycoords[i]
        index = i
        break
      end
    end
    word[2] = min_y + lineheight * index
    if lines == 2 && maxlines == 2 && bitmap.font.name=="Small"
      word[2]+=2
    elsif lines == 3 && maxlines == 3 && bitmap.font.name=="Smallest"
      word[2]-=2
    elsif lines == 2 && maxlines == 3 && bitmap.font.name=="Smallest"
      word[2] = min_y + (lineheight - 4) * index + 4
    end
  end
end

def pbSetScreenOrigin(sprites, ox, oy)
  sprites = [sprites] if !sprites.is_a?(Array)
  for s in sprites
    s.ox = ox - s.x
    s.x = ox
    s.oy = oy - s.y
    s.y = oy
  end
end