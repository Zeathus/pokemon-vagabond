class HelpSprite < Sprite

  def initialize(viewport)
    super(viewport)
    # Current rect variables
    @rectX = -4
    @rectY = -4
    @rectW = 520
    @rectH = 392
    # Goal rect variables
    @goalX = 0
    @goalY = 0
    @goalW = 0
    @goalH = 0
    @speed = 20
    @color = Color.new(250,0,0)
    self.bitmap = Bitmap.new(512,384)
    update
  end

  def setRect(rect)
    @goalX = rect.x
    @goalY = rect.y
    @goalW = rect.width
    @goalH = rect.height
  end

  def update
    self.bitmap.clear
    self.bitmap.fill_rect(@rectX,@rectY,@rectW,@rectH,@color)
    self.bitmap.clear_rect(@rectX+4,@rectY+4,@rectW-8,@rectH-8)
    rect = [@rectX,@rectY,@rectW,@rectH]
    goal = [@goalX,@goalY,@goalW,@goalH]
    for i in 0...4
      if rect[i] < goal[i]
        rect[i] += @speed
        rect[i] = goal[i] if rect[i] > goal[i]
      elsif rect[i] > goal[i]
        rect[i] -= @speed
        rect[i] = goal[i] if rect[i] < goal[i]
      end
    end
    @rectX,@rectY,@rectW,@rectH = rect[0],rect[1],rect[2],rect[3]
    super
  end

end

class Hint

  attr_accessor(:text)
  attr_accessor(:rect)
  attr_accessor(:adj)
  attr_accessor(:msgpos)

  def initialize(text,rect,adj,msgpos)
    self.text = text
    self.rect = rect
    self.adj = adj
    self.msgpos = msgpos
  end

end

def pbHelp(viewport,hints)

  index = 0
  hint = hints[index]

  sprite = HelpSprite.new(viewport)
  sprite.z = 99999
  sprite.setRect(hint.rect)

  msgwin = Kernel.pbCreateMessageWindow(nil)
  msgwin.letterbyletter = false
  msgwin.text = hint.text
  msgwin.width = msgwin.width
  msgwin.y = hint.msgpos == 0 ? 288 : 0

  Input.update
  loop do
    break if Input.trigger?(Input::BACK) || Input.trigger?(Input::SPECIAL)
    update = false

    if Input.trigger?(Input::UP) && hint.adj[0]
      index = hint.adj[0]
      update = true
    end
    if Input.trigger?(Input::DOWN) && hint.adj[1]
      index = hint.adj[1]
      update = true
    end
    if Input.trigger?(Input::LEFT) && hint.adj[2]
      index = hint.adj[2]
      update = true
    end
    if Input.trigger?(Input::RIGHT) && hint.adj[3]
      index = hint.adj[3]
      update = true
    end

    if update
      update = false
      hint = hints[index]
      sprite.setRect(hint.rect)
      msgwin.text = hint.text
      msgwin.width = msgwin.width
      msgwin.y = hint.msgpos == 0 ? 288 : 0
    end

    Graphics.update
    Input.update
    viewport.update
    sprite.update
    msgwin.update
  end

  sprite.dispose
  Kernel.pbDisposeMessageWindow(msgwin)

end