class CenterCommandSprite < BitmapSprite

  def initialize(viewport, command, width)
      super(width + 48, 48, viewport)
      @command = command
      @width = width
      @selected = false
      @choice_bitmap = AnimatedBitmap.new("Graphics/Windowskins/choice vb")
      @selected_bitmap = AnimatedBitmap.new("Graphics/Windowskins/choice vb selected")
      self.refresh
  end

  def selected=(value)
      if value != @selected
          @selected = value
          self.refresh
      end
  end

  def text=(value)
    @command = value
    self.refresh
  end

  def refresh
      self.bitmap.clear
      bg_bitmap = (@selected ? @selected_bitmap : @choice_bitmap).bitmap
      self.bitmap.blt(0, 0, bg_bitmap, Rect.new(0, 0, 24, 48))
      self.bitmap.blt(self.bitmap.width-24, 0, bg_bitmap, Rect.new(24, 0, 24, 48))
      self.bitmap.stretch_blt(Rect.new(24, 0, self.bitmap.width-48, 48), bg_bitmap, Rect.new(22, 0, 4, 48))
      textpos = [
          #[_INTL(@command),self.bitmap.width / 2,2,2,Color.new(80, 80, 88),Color.new(160, 160, 168)]
          [_INTL(@command),self.bitmap.width / 2, 14, 2, Color.new(252, 252, 252), Color.new(120, 120, 132)]
      ]
      pbSetSystemFont(self.bitmap)
      pbDrawTextPositions(self.bitmap, textpos)
  end

  def dispose
      @choice_bitmap.dispose
      super
  end

end

class CenterCommandListSprite < BitmapSprite

  attr_reader :index

  def initialize(viewport, commands, msgwindow=nil)
      super(2, 2, viewport)
      @index = 0
      @commands = commands
      @commands_shown = [@commands.length, 7].min
      @scroll = 0
      @msgwindow = msgwindow
      pbSetSystemFont(self.bitmap)
      @max_width = 48
      for command in @commands
          text_width = self.bitmap.text_size(command).width
          @max_width = text_width if @max_width < text_width
      end
      @sprites = []
      for i in 0...@commands_shown
          command = @commands[i + @scroll]
          sprite = CenterCommandSprite.new(viewport, command, @max_width)
          sprite.z = 1
          sprite.x = Graphics.width / 2 - sprite.bitmap.width / 2
          if $game_system.message_position == 1
              sprite.y = Graphics.height * 2 / 3
          else
              sprite.y = Graphics.height / 2
              if $game_system.message_position == 0
                  sprite.y += 48 if msgwindow
              else
                  sprite.y -= 48 if msgwindow
              end
          end
          sprite.y += (i - @commands_shown / 2.0) * 48
          @sprites.push(sprite)
      end
      if @commands_shown < @commands.length

      end
      @rightarrow = AnimatedSprite.new("Graphics/UI/right_arrow",8,40,28,2,viewport)
      @rightarrow.z = 2
      @rightarrow.play
      @leftarrow = AnimatedSprite.new("Graphics/UI/right_arrow",8,40,28,2,viewport)
      @leftarrow.z = 2
      @leftarrow.zoom_x = -1
      @leftarrow.play
      if @commands_shown < @commands.length
        @downarrow = AnimatedSprite.new("Graphics/UI/down_arrow",8,28,40,2,viewport)
        @downarrow.x = Graphics.width / 2 - 14
        @downarrow.y = Graphics.height - 176
        @downarrow.z = 5
        @downarrow.play
        @uparrow = AnimatedSprite.new("Graphics/UI/up_arrow",8,28,40,2,viewport)
        @uparrow.x = Graphics.width / 2 - 14
        @uparrow.y = 40
        @uparrow.z = 2
        @uparrow.play
      end
      self.update_scroll
      self.update
  end

  def refresh
    for i in 0...@commands_shown
        command = @commands[i + @scroll]
        @sprites[i].text = command
    end
  end

  def index=(value)
      @index = value
      if @index >= @commands.length
        echoln "Warning: cancelCmd index was out of bounds"
        @index = @commands.length - 1
      end
      self.update_scroll
      self.update
  end

  def update_scroll
    old_scroll = @scroll
    while @index >= @commands_shown + @scroll
      @scroll += 1
    end
    while @index < @scroll
      @scroll -= 1
    end
    if @index == @scroll && @scroll > 0
      @scroll -= 1
    elsif @index == @scroll + @commands_shown - 1 && @scroll < @commands.length - @commands_shown
      @scroll += 1
    end
    if @downarrow && @uparrow
      @uparrow.visible = @scroll > 0
      @downarrow.visible = @scroll < @commands.length - @commands_shown
    end
    self.refresh if old_scroll != @scroll
  end

  def z=(value)
      super(value)
      for sprite in @sprites
          sprite.z = value + 1
      end
      @rightarrow.z = value + 2
      @leftarrow.z = value + 2
  end

  def update(input=true)
      if input
          old_scroll = @scroll
          old_index = @index
          @index += 1 if Input.trigger?(Input::DOWN) || (Input.repeat?(Input::DOWN) && @index < @commands.length - 1)
          @index -= 1 if Input.trigger?(Input::UP) || (Input.repeat?(Input::UP) && @index > 0)
          @index = 0 if @index >= @commands.length
          @index = @commands.length - 1 if @index < 0
          self.update_scroll
          pbPlayCursorSE() if old_index != @index
      end
      sprite = @sprites[@index - @scroll]
      @rightarrow.x = sprite.x - @rightarrow.bitmap.width + 16
      @rightarrow.y = sprite.y + 10
      @leftarrow.x = sprite.x + sprite.bitmap.width + @leftarrow.bitmap.width - 16
      @leftarrow.y = sprite.y + 10
      @rightarrow.update
      @leftarrow.update
      @uparrow&.update
      @downarrow&.update
      for i in 0...@sprites.length
          sprite = @sprites[i]
          sprite.selected = (i == @index - @scroll)
          sprite.update
      end
      super()
  end

  def opacity=(value)
      super(value)
      for sprite in @sprites
          sprite.opacity = value
      end
      @rightarrow.opacity = value
      @leftarrow.opacity = value
  end

  def dispose
      @rightarrow.dispose
      @leftarrow.dispose
      for sprite in @sprites
          sprite.dispose
      end
      super
  end

end

def pbCenterCommands(msgwindow, commands=nil,cmdIfCancel=0,defaultCmd=0)
  background_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  background_viewport.z = (msgwindow ? (msgwindow.z - 1) : 99998)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = (msgwindow ? (msgwindow.z + 1) : 99999)
  darken = Sprite.new(background_viewport)
  darken.bitmap = Bitmap.new(Graphics.width, Graphics.height)
  darken.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
  darken.opacity = 0
  darken.z = -1
  cmdwindow=CenterCommandListSprite.new(viewport, commands, msgwindow)
  cmdwindow.opacity = 0
  cmdwindow.index = defaultCmd
  20.times do
      Graphics.update
      Input.update
      cmdwindow.update
      msgwindow.update if msgwindow
      darken.opacity += 6
      cmdwindow.opacity += 16
      pbUpdateSceneMap
  end
  command=0
  loop do
    Graphics.update
    Input.update
    cmdwindow.update
    msgwindow.update if msgwindow
    yield if block_given?
    if Input.trigger?(Input::BACK)
          if cmdIfCancel>0
              command=cmdIfCancel-1
              cmdwindow.index=command
              break
          elsif cmdIfCancel<0
              command=cmdIfCancel
              cmdwindow.index=command
              break
          end
    end
      if Input.trigger?(Input::USE)
          command=cmdwindow.index
          break
      end
      pbUpdateSceneMap
  end
  ret=command
  if command == cmdIfCancel - 1
      pbPlayCancelSE()
  else
      pbPlayDecisionSE()
  end
  40.times do
      Graphics.update
      Input.update
      cmdwindow.update(false)
      msgwindow.update if msgwindow
      darken.opacity -= 3
      cmdwindow.opacity -= 16
      pbUpdateSceneMap
  end
  darken.dispose
  cmdwindow.dispose
  Input.update
  background_viewport.dispose
  viewport.dispose
  return ret
end