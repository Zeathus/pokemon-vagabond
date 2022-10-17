class Window_AdvancedTextPokemon < SpriteWindow_Base

  alias sup_dispose dispose
  alias sup_update update

  def dispose
    @arrow&.dispose
    @arrow = nil
    sup_dispose
  end

  def update
    sup_update
    if @arrow
      @arrow.x  = self.x + self.width / 2
      @arrow.y  = self.y + self.height
    end
  end

  def setArrow(arrow_skin)
    if @arrow
      @arrow.dispose
      @arrow = nil
    end
    if arrow_skin
      @arrow = IconSprite.new(0, 0, @viewport)
      @arrow.setBitmap(arrow_skin)
      @arrow.ox = @arrow.bitmap.width / 2
      @arrow.oy = @arrow.bitmap.height
      @arrow.x  = self.x + self.width / 2
      @arrow.y  = self.y + self.height
      @arrow.z  = 100
    end
  end

  def opacity=(value)
    super(value)
    @arrow.opacity = value if @arrow
  end

  def updateEffect
    #@fmtchar elements:
    #      0    1 2 3     4      5       6    7      8
    #ch = [char,x,y,width,height,graphic,bold,italic,color,
    #      shadow,underline,strikeout,font,fontSize,?,graphicRect,outline,
    #      effect] # Added by Supplementals
    #      9      10        11        12   13         15          16
    #      17
    numchars = @numtextchars
    numchars = [@curchar, @numtextchars].min if self.letterbyletter

    return if !(@fmtchars[0...numchars].any? { |c| !(c[17].nil?) })
    clear_all = (@fmtchars[0...numchars].all? { |c| !(c[17].nil?) })
    text_size = $game_temp.textSize ? ($game_temp.textSize / 2) : 1
    drew_previous = false

    @ef_frame = 0 if !@ef_frame
    @ef_frame += 1
    if @ef_frame % 2 == 0
      speed = 6.0
      self.contents.clear if clear_all
      for i in 0...numchars
        break if i >= @fmtchars.length
        if !self.letterbyletter
          next if @fmtchars[i][1]>=maxX
          next if @fmtchars[i][2]>=maxY
        end
        if @fmtchars[i][17].nil?
          if drew_previous
            drawSingleFormattedChar(self.contents, @fmtchars[i])
            drew_previous = false
          end
          next
        end
        drew_previous = true
        if !clear_all
          self.contents.fill_rect(
            @fmtchars[i][1],@fmtchars[i][2],
            @fmtchars[i][3],@fmtchars[i][4]*text_size,
            Color.new(0,0,0,0))
        end
        case @fmtchars[i][17]
        when "wave", "wavebow"
          add = Math.sin(i / 2.0 + @ef_frame / (speed * 2)) * 3.0
          add = add.floor if add > 0
          add = add.ceil if add < 0
          @fmtchars[i][2] += add
          drawSingleFormattedChar(self.contents, @fmtchars[i])
          @fmtchars[i][2] -= add
          @lastDrawnChar = i
        when "shake"
          add_x = Math.sin(@ef_frame * 12.0 / speed) * 1.0 + 1
          add_x = add_x.floor if add_x > 0
          add_x = add_x.ceil if add_x < 0
          add_y = Math.cos(@ef_frame * 9.0 / speed) * 1.0 + 1
          add_y = add_y.floor if add_y > 0
          add_y = add_y.ceil if add_y < 0
          @fmtchars[i][1] += add_x
          @fmtchars[i][2] += add_y
          drawSingleFormattedChar(self.contents, @fmtchars[i])
          @fmtchars[i][1] -= add_x
          @fmtchars[i][2] -= add_y
          @lastDrawnChar = i
        end
        add = Math.sin(i / 2.0 + @ef_frame / speed)
      end
    end

  end

end