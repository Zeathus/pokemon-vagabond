PI = Math::PI
PI2 = PI / 2.0
PI3 = 3.0 * PI / 2.0

def pbPlayGloom
  pbSceneStandby {
    pbStartGloom
  }
end

def pbStartGloom

  map = [
    [1,1,1,1,1,1,1,1],
    [1,0,1,0,0,0,0,1],
    [1,0,1,0,0,0,0,1],
    [1,0,1,1,0,0,0,1],
    [1,0,0,0,0,0,0,1],
    [1,0,0,0,0,1,0,1],
    [1,0,0,0,0,0,0,1],
    [1,1,1,1,1,1,1,1]
  ]

  mapX = 8
  mapY = 8

  unit = [512 / mapX, 384 / mapY].min

  viewport = Viewport.new(0, 0, 512, 384)
  viewport.z = 999999
  viewsprite = Sprite.new(viewport)
  view = Bitmap.new(512, 384)
  viewsprite.bitmap = view

  tileset = RPG::Cache.load_bitmap("","Graphics/Tilesets/Ruins3D")
  bg = RPG::Cache.load_bitmap("","Graphics/Panoramas/outlookloop")

  player = GloomPlayer.new(map,mapX,mapY,4.5,4.5)
  hud = GloomHUD.new(viewport,player)

  # Define field of view and one notch of rotation
  degree = (PI / 180.0)
  fov = 60.0 * degree
  notch = fov / 256.0

  while !Input.press?(Input::B)
    pbDrawMap3D(view, player, map, mapX, mapY, unit, fov, notch,tileset, bg)
    pbDrawMap2D(view, player, map, mapX, mapY, unit, true)

    player.update
    hud.update
    viewsprite.update
    viewport.update
    Graphics.update
    Input.update
  end

  tileset.dispose
  bg.dispose
  hud.dispose
  viewsprite.dispose
  viewport.dispose

end

def pbDrawMap3D(view, player, map, mapX, mapY, unit, fov, notch, tileset, bg)

  gray = Color.new(50, 50, 50)
  black = Color.new(0, 0, 0)
  white = Color.new(252, 252, 252)
  red = Color.new(240, 0, 0)
  red2 = Color.new(180, 0, 0)
  green = Color.new(0, 252, 0)
  blue = Color.new(0, 0, 252)
  floor = Color.new(252, 225, 120)

  #view.fill_rect(0, 0, 512, 192, gray)
  view.blt(0, 0, bg, Rect.new(800 * player.angle / (PI * 2), 0, 512, 192))
  view.fill_rect(0, 192, 512, 192, floor)

  ra = player.angle - fov / 2.0

  for r in 0...256
    if ra < 0
      ra += 2 * PI
    elsif ra > 2 * PI
      ra -= 2 * PI
    end
    #### Check for horizontal lines
    hx = player.x
    hy = player.y
    hDist = 100000
    dof = 0
    aTan = -1 / Math.tan(ra)

    if ra > PI # Looking up
      ry = player.y.floor - 0.0001
      rx = (player.y - ry) * aTan + player.x
      yo = -1
      xo = -yo * aTan
    elsif ra < PI # Looking down
      ry = player.y.floor + 1.0
      rx = (player.y - ry) * aTan + player.x
      yo = 1
      xo = -yo * aTan
    end
    if ra == PI || ra == 0
      rx = player.x
      ry = player.y
      dof = 8
    end

    # dof, depth of field, specifies how far to check for collision
    while dof < 8
      mx = rx.floor
      my = ry.floor
      if mx < mapX && mx >= 0 && my < mapY && my >= 0 && map[my][mx] == 1
        hx = rx
        hy = ry
        hDist = (player.x - hx)**2 + (player.y - hy)**2
        dof = 8
      else
        rx += xo
        ry += yo
        dof += 1
      end
    end

    #### Check for vertical lines
    vx = player.x
    vy = player.y
    vDist = 100000
    dof = 0
    nTan = -Math.tan(ra)

    if ra > PI2 && ra < PI3 # Looking left
      rx = player.x.floor - 0.0001
      ry = (player.x - rx) * nTan + player.y
      xo = -1
      yo = -xo * nTan
    elsif ra < PI2 || ra > PI3 # Looking right
      rx = player.x.floor + 1.0
      ry = (player.x - rx) * nTan + player.y
      xo = 1
      yo = -xo * nTan
    end
    if ra == PI2 || ra == PI3
      rx = player.x
      ry = player.y
      dof = 8
    end

    # dof, depth of field, specifies how far to check for collision
    while dof < 8
      mx = rx.floor
      my = ry.floor
      if mx < mapX && mx >= 0 && my < mapY && my >= 0 && map[my][mx] == 1
        vx = rx
        vy = ry
        vDist = (player.x - vx)**2 + (player.y - vy)**2
        dof = 8
      else
        rx += xo
        ry += yo
        dof += 1
      end
    end

    # Decide vertical or horizontal collission
    if hDist > vDist
      rx = vx; ry = vy
      tDist = vDist
      color = red
      tileX = (ry % 1) * 32
    else
      rx = hx; ry = hy
      tDist = hDist
      color = red2
      tileX = (rx % 1) * 32
    end
    tDist = Math.sqrt(tDist)

    # Remove fisheye
    ca = player.angle - ra
    if ca < 0
      ca += 2 * PI
    elsif ca > 2 * PI
      ca -= 2 * PI
    end
    tDist *= Math.cos(ca)

    # 3D View
    lineH = 384 / tDist
    lineH = 384 * 4 if lineH > 384 * 4

    #view.fill_rect(r * 2, 192 - lineH / 2, 2, lineH, color)

    view.stretch_blt(
      Rect.new(r * 2, 192 - lineH / 2, 2, lineH),
      tileset,
      Rect.new(tileX, 0, 1, 32))

    # For 2D view of rays
    #if rx < mapX && rx >= 0 && ry < mapY && ry >= 0
    #  view.fill_rect(rx * unit, ry * unit, 2, 2, green)
    #end

    ra += notch
  end

end

def pbDrawMap2D(view, player, map, mapX, mapY, unit, mini=false)

  gray = Color.new(50, 50, 50)
  black = Color.new(0, 0, 0)
  white = Color.new(252, 252, 252)
  red = Color.new(252, 0, 0)

  view.fill_rect(0, 0, 512, 384, gray) if !mini
  unit = (unit * 0.2).ceil if mini

  for y in 0...mapY
    for x in 0...mapX
      if mini
        view.fill_rect(x * unit, y * unit, unit, unit, map[y][x]==0 ? white : black)
      else
        view.fill_rect(x * unit, y * unit, unit - 1, unit - 1, map[y][x]==0 ? white : black)
      end
    end
  end

  if mini
    view.fill_rect(player.x * unit - 2, player.y * unit - 2, 4, 4, red)
    view.fill_rect(player.x * unit + player.dx * 80 - 1, player.y * unit + player.dy * 80 - 1, 2, 2, red)
  else
    view.fill_rect(player.x * unit - 4, player.y * unit - 4, 8, 8, red)
    view.fill_rect(player.x * unit + player.dx * 200 - 1, player.y * unit + player.dy * 200 - 1, 2, 2, red)
  end

end

class GloomEntity
  attr_accessor :x
  attr_accessor :y
  attr_accessor :dx
  attr_accessor :dy
  attr_accessor :angle
  attr_accessor :size
  attr_accessor :health

  def initialize(map,mapX,mapY,sx,sy)
    @frame = 0
    @map = map
    @mapX = mapX
    @mapY = mapY
    @x = sx
    @y = sy
    @angle = 0
    @size = 0.2
    @health = 0
    @speed = 1
    self.calcDelta
  end

  def calcDelta
    @dx = Math.cos(@angle) * 0.05
    @dy = Math.sin(@angle) * 0.05
  end

  def left
    return @x - @size
  end

  def right
    return @x + @size
  end

  def top
    return @y - @size
  end

  def bottom
    return @y + @size
  end

  def update
    @frame += 1
  end

  def moveForward
    nx = @x + @dx * @speed
    ny = @y + @dy * @speed
    nLeft = nx - @size
    nRight = nx + @size
    nTop = ny - @size
    nBottom = ny + @size
    if nx < @mapX && nx >= 0 && ny < @mapY && ny >= 0
      if @angle > PI # Looking up
        if @map[nTop.floor][self.left.floor] > 0 || @map[nTop.floor][self.right.floor] > 0
          ny = nTop.ceil + @size + 0.0001
        end
      elsif @angle < PI # Looking down
        if @map[nBottom.floor][self.left.floor] > 0 || @map[nBottom.floor][self.right.floor] > 0
          ny = nBottom.floor - @size - 0.0001
        end
      end
      if @angle > PI2 && @angle < PI3 # Looking left
        if @map[self.top.floor][nLeft.floor] > 0 || @map[self.bottom.floor][nLeft.floor] > 0
          nx = nLeft.ceil + @size + 0.0001
        end
      elsif @angle < PI2 || @angle > PI3 # Looking right
        if @map[self.top.floor][nRight.floor] > 0 || @map[self.bottom.floor][nRight.floor] > 0
          nx = nRight.floor - @size - 0.0001
        end
      end
      @x = nx
      @y = ny
    end
  end

  def moveBackward
    nx = @x - @dx * @speed
    ny = @y - @dy * @speed
    nLeft = nx - @size
    nRight = nx + @size
    nTop = ny - @size
    nBottom = ny + @size
    if nx < @mapX && nx >= 0 && ny < @mapY && ny >= 0
      if @angle > PI # Looking up
        if @map[nBottom.floor][self.left.floor] > 0 || @map[nBottom.floor][self.right.floor] > 0
          ny = nBottom.floor - @size - 0.0001
        end
      elsif @angle < PI # Looking down
        if @map[nTop.floor][self.left.floor] > 0 || @map[nTop.floor][self.right.floor] > 0
          ny = nTop.ceil + @size + 0.0001
        end
      end
      if @angle > PI2 && @angle < PI3 # Looking left
        if @map[self.top.floor][nRight.floor] > 0 || @map[self.bottom.floor][nRight.floor] > 0
          nx = nRight.floor - @size - 0.0001
        end
      elsif @angle < PI2 || @angle > PI3 # Looking right
        if @map[self.top.floor][nLeft.floor] > 0 || @map[self.bottom.floor][nLeft.floor] > 0
          nx = nLeft.ceil + @size + 0.0001
        end
      end
      @x = nx
      @y = ny
    end
  end

  def turnLeft
    @angle -= 0.05
    if @angle < 0
      @angle += 2 * PI
    end
    self.calcDelta
  end

  def turnRight
    @angle += 0.05
    if @angle > 2 * PI
      @angle -= 2 * PI
    end
    self.calcDelta
  end

  # Returns whether a line to another entity is obstructed
  def canSee?(entity)
    return false
  end

  # Same as canSee, but for the left side of an entity
  def canSeeLeft?(entity)
    return true
  end

  # Same as canSee, but for the right side of an entity
  def canSeeRight?(entity)
    return true
  end
end

class GloomPlayer < GloomEntity
  attr_accessor :armor
  attr_accessor :ammo
  attr_accessor :weapon
  attr_accessor :weapons
  attr_accessor :keys

  def initialize(map,mapX,mapY,sx,sy)
    super(map,mapX,mapY,sx,sy)
    @health = 100
    @armor = 0
    @ammo = [0,50,0,0]
    @weapon = 1
    @weapons = [true,true,false,false]
    @keys = [false,false,false]
  end

  def update
    super
    updateMove
  end

  def updateMove
    if Input.press?(Input::LEFT)
      self.turnLeft
    end
    if Input.press?(Input::RIGHT)
      self.turnRight
    end
    nx = @x
    ny = @y
    if Input.press?(Input::UP) && !Input.press?(Input::DOWN)
      self.moveForward
    elsif Input.press?(Input::DOWN) && !Input.press?(Input::UP)
      self.moveBackward
    end
  end

end

class GloomEnemy < GloomEntity

  attr_accessor :player
  attr_accessor :focus # Timer for when the enemy is targeting the player
  attr_accessor :bitmap
  attr_accessor :pattern

  def initialize(map,mapX,mapY,sx,sy,player,name)
    super(map,mapX,mapY,sx,sy)
    @player = player
    @focus = 0
    @bitmap = RPG::Cache.load_bitmap("",_INTL("Graphics/Scenes/Gloom/{1}",name))
    @pattern = 0
  end

  def update
    super
    # Update focus
    if @focus > 0
      @focus -= 1
    end
    # Only recheck focus every 10 frames, and if focus is low
    if @focus < 60 && @frame % 10 == 0
      @focus = 180 if self.canSee?(@player)
    end
  end

  def focus?
    return @focus > 0
  end

  def dispose
    @bitmap.dispose if @bitmap && !@bitmap.disposed?
  end

end

class GloomParas < GloomEnemy

  def initialize(map,mapX,mapY,sx,sy,player)
    super(map,mapX,mapY,sx,sy,player,"paras")
  end

end

class GloomEnemySprite < Sprite

  def initialize(viewport,enemy)
    @viewport = viewport
    @enemy = enemy
    self.bitmap = @enemy.bitmap
    self.src_rect = Rect.new(0,0,32,32)
  end

  def dispose
    @enemy.dispose
    super
  end

end

class GloomHUD < Sprite

  attr_accessor :player
  attr_accessor :mustrefresh

  def initialize(viewport,p)
    super(viewport)
    self.player = p
    self.mustrefresh = false
    @hudBitmap = RPG::Cache.load_bitmap("","Graphics/Scenes/Gloom/hud")
    self.bitmap = Bitmap.new(@hudBitmap.width,@hudBitmap.height)
    self.y = 384 - @hudBitmap.height
    self.z = 9999
    pbRefresh
  end

  def pbRefresh
    self.bitmap.blt(0,0,@hudBitmap,Rect.new(0,0,@hudBitmap.width,@hudBitmap.height))
    red1 = Color.new(220,30,30)
    red2 = Color.new(100,0,0)
    gray = Color.new(160,140,140)
    yellow = Color.new(252,252,160)
    textpos = [
      [_INTL("{1}",player.ammo[player.weapon]),62,4,1,red1,red2,1],
      [_INTL("{1}%",player.health),152,4,1,red1,red2,1],
      [_INTL("{1}%",player.armor),354,4,1,red1,red2,1]
    ]
    pbSetSystemFont(self.bitmap)
    pbDrawTextPositions(self.bitmap,textpos)
    textpos = [
      [_INTL("2"),174,4,0,player.weapons[1] ? yellow : gray,red2,0],
      [_INTL("3"),192,4,0,player.weapons[2] ? yellow : gray,red2,0],
      [_INTL("4"),210,4,0,player.weapons[3] ? yellow : gray,red2,0],
      [_INTL("{1} / 200",player.ammo[1]),504,0,1,yellow,red2,0],
      [_INTL("{1} / 400",player.ammo[2]),504,14,1,yellow,red2,0],
      [_INTL("{1} / 100",player.ammo[3]),504,28,1,yellow,red2,0]
    ]
    pbSetSmallestFont(self.bitmap)
    pbDrawTextPositions(self.bitmap,textpos)
  end

  def update
    super
    if mustrefresh
      pbRefresh
    end
  end

  def dispose
    @hudBitmap.dispose
    super
  end

end