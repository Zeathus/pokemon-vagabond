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
    #      shadow,underline,strikeout,font,fontSize,?,graphicRect,outline]
    #      9      10        11        12   13         15          16
    if $game_system && $game_system.message_effect && $game_system.message_effect.is_a?(Array)
      numchars=@numtextchars
      numchars=[@curchar,@numtextchars].min if self.letterbyletter

      effect = $game_system.message_effect
      @ef_frame = 0 if !@ef_frame
      @ef_frame += 1
      if @ef_frame % 2 == 0
        speed = effect[3] ? (effect[3] * 1.0) : 6.0
        if effect[0]=="wave" || effect[0]=="wavebow"
          if effect.length == 1
            self.contents.clear
            for i in 0..numchars
              next if i>=@fmtchars.length
              if !self.letterbyletter
                next if @fmtchars[i][1]>=maxX
                next if @fmtchars[i][2]>=maxY
              end
              old_y = @fmtchars[i][2]
              add = Math.sin(i/2.0 + @ef_frame/speed)*3.0
              add = add.floor if add > 0
              add = add.ceil if add < 0
              if effect[0]=="wavebow"
                if i==0
                  @firstcolors = []
                  @firstcolors = [@fmtchars[0][8],@fmtchars[0][9]]
                end
                if @fmtchars[i+1]
                  @fmtchars[i][8] = @fmtchars[i+1][8]
                  @fmtchars[i][9] = @fmtchars[i+1][9]
                else
                  @fmtchars[i][8] = @firstcolors[0]
                  @fmtchars[i][9] = @firstcolors[1]
                end
              end
              @fmtchars[i][2] += add
              drawSingleFormattedChar(self.contents,@fmtchars[i])
              @fmtchars[i][2] = old_y
              @lastDrawnChar=i
            end
          elsif effect.length > 1
            e_start = effect[1] ? effect[1] : 0
            e_start = 0 if e_start < 0
            e_end = effect[2] ? effect[2] : numchars
            e_end = numchars if effect[2] && (numchars < effect[2] || effect[2] <= 0)
            for i in e_start..e_end
              next if i>=@fmtchars.length
              if !self.letterbyletter
                next if @fmtchars[i][1]>=maxX
                next if @fmtchars[i][2]>=maxY
              end
              self.contents.fill_rect(
                @fmtchars[i][1],@fmtchars[i][2],
                @fmtchars[i][3]-2,@fmtchars[i][4],
                Color.new(0,0,0,0))
              old_y = @fmtchars[i][2]
              add = Math.sin(i/2.0 + @ef_frame/speed)*3.0
              add = add.floor if add > 0
              add = add.ceil if add < 0
              @fmtchars[i][2] += add
              drawSingleFormattedChar(self.contents,@fmtchars[i])
              @fmtchars[i][2] = old_y
              @lastDrawnChar=i
            end
          end
        elsif effect[0] == "shake"
          if effect.length == 1
            self.contents.clear
            for i in 0..numchars
              next if i>=@fmtchars.length
              if !self.letterbyletter
                next if @fmtchars[i][1]>=maxX
                next if @fmtchars[i][2]>=maxY
              end
              old_x = @fmtchars[i][1]
              old_y = @fmtchars[i][2]
              addx = Math.sin(@ef_frame*12.0/speed)*1.0 + 1
              addx = addx.floor if addx > 0
              addx = addx.ceil if addx < 0
              addy = Math.cos(@ef_frame*9.0/speed)*1.0 + 1
              addy = addy.floor if addy > 0
              addy = addy.ceil if addy < 0
              @fmtchars[i][1] += addx
              @fmtchars[i][2] += addy
              drawSingleFormattedChar(self.contents,@fmtchars[i])
              @fmtchars[i][1] = old_x
              @fmtchars[i][2] = old_y
              @lastDrawnChar=i
            end
          elsif effect.length > 1
            e_start = effect[1] ? effect[1] : 0
            e_start = 0 if e_start < 0
            e_end = effect[2] ? effect[2] : numchars
            e_end = numchars if effect[2] && (numchars < effect[2] || effect[2] <= 0)
            for i in e_start..e_end
              next if i>=@fmtchars.length
              if !self.letterbyletter
                next if @fmtchars[i][1]>=maxX
                next if @fmtchars[i][2]>=maxY
              end
              self.contents.fill_rect(
                @fmtchars[i][1],@fmtchars[i][2],
                @fmtchars[i][3]-2,@fmtchars[i][4],
                Color.new(0,0,0,0))
              old_x = @fmtchars[i][1]
              old_y = @fmtchars[i][2]
              addx = Math.sin(@ef_frame*12.0/speed)*1.0 + 1
              addx = addx.floor if addx > 0
              addx = addx.ceil if addx < 0
              addy = Math.cos(@ef_frame*9.0/speed)*1.0 + 1
              addy = addy.floor if addy > 0
              addy = addy.ceil if addy < 0
              @fmtchars[i][1] += addx
              @fmtchars[i][2] += addy
              drawSingleFormattedChar(self.contents,@fmtchars[i])
              @fmtchars[i][1] = old_x
              @fmtchars[i][2] = old_y
              @lastDrawnChar=i
            end
          end
        end
      end
    end

  end

end