################################################################################
# "Mining" mini-game
# By Maruno
#-------------------------------------------------------------------------------
# Run with:      pbMiningGame
################################################################################
class MiningGameCounter < BitmapSprite
  attr_accessor :hits
  attr_accessor :durability_mod

  def initialize(x, y)
    @viewport = Viewport.new(x, y, 544, 60)
    @viewport.z = 99999
    super(544, 60, @viewport)
    @hits = 0
    @durability_mod = 1.5
    @image = AnimatedBitmap.new("Graphics/Pictures/Mining/cracks")
    update
  end

  def update
    self.bitmap.clear
    value = (@hits / @durability_mod).floor
    startx = 544 - 48
    bitmapx = 0
    while value > 6
      self.bitmap.blt(startx, 0, @image.bitmap, Rect.new(bitmapx, 0, 48, 52))
      startx -= 48
      value -= 6
    end
    startx -= 48
    if value > 0
      self.bitmap.blt(startx, 0, @image.bitmap, Rect.new(0, value * 52, 96, 52))
    end
  end
end



class MiningGameTile < BitmapSprite
  attr_reader :layer

  def initialize(x, y, viewport=nil)
    need_viewport = viewport.nil?
    viewport = Viewport.new(x, y, 32, 32) if need_viewport
    @viewport = viewport
    @viewport.z = 99999
    super(32, 32, @viewport)
    r = rand(100)
    if r < 10
      @layer = 2   # 10%
    elsif r < 25
      @layer = 3   # 15%
    elsif r < 60
      @layer = 4   # 35%
    elsif r < 85
      @layer = 5   # 25%
    else
      @layer = 6   # 15%
    end
    @image = AnimatedBitmap.new("Graphics/Pictures/Mining/tiles")
    if !need_viewport
      self.x = x
      self.y = y
    end
    self.z = 99
    update
  end

  def layer=(value)
    @layer = value
    @layer = 0 if @layer < 0
  end

  def update
    self.bitmap.clear
    if @layer > 0
      self.bitmap.blt(0, 0, @image.bitmap, Rect.new(0, 32 * (@layer - 1), 32, 32))
    end
  end
end



class MiningGameCursor < BitmapSprite
  attr_accessor :mode
  attr_accessor :position
  attr_accessor :hit
  attr_accessor :counter

  TOOL_POSITIONS = [[1, 0], [1, 1], [1, 1], [0, 0], [0, 0],
                    [0, 2], [0, 2], [0, 0], [0, 0], [0, 2], [0, 2]]   # Graphic, position

  def initialize(position = 0, mode = 0)   # mode: 0=pick, 1=hammer
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    super(Graphics.width, Graphics.height, @viewport)
    @position = position
    @mode     = mode
    @hit      = 0   # 0=regular, 1=hit item, 2=hit iron
    @counter  = 0
    @cursorbitmap = AnimatedBitmap.new("Graphics/Pictures/Mining/cursor")
    @toolbitmap   = AnimatedBitmap.new("Graphics/Pictures/Mining/tools")
    @hitsbitmap   = AnimatedBitmap.new("Graphics/Pictures/Mining/hits")
    update
  end

  def isAnimating?
    return @counter > 0
  end

  def animate(hit)
    @counter = 22
    @hit     = hit
  end

  def update
    self.bitmap.clear
    x = 32 * (@position % MiningGameScene::BOARD_WIDTH)
    y = 32 * (@position / MiningGameScene::BOARD_WIDTH)
    if @counter > 0
      @counter -= 1
      toolx = x
      tooly = y
      i = 10 - (@counter / 2).floor
      case TOOL_POSITIONS[i][1]
      when 1
        toolx -= 8
        tooly += 8
      when 2
        toolx += 6
      end
      self.bitmap.blt(toolx + 112, tooly, @toolbitmap.bitmap,
                      Rect.new(96 * TOOL_POSITIONS[i][0], 96 * @mode, 96, 96))
      if i < 5 && i.even?
        if @hit == 2
          self.bitmap.blt(x - 64 + 112, y, @hitsbitmap.bitmap, Rect.new(160 * 4, 0, 160, 160))
        else
          self.bitmap.blt(x - 64 + 112, y, @hitsbitmap.bitmap, Rect.new(160 * @mode, 0, 160, 160))
        end
      end
      if @hit == 1 && i < 3
        self.bitmap.blt(x - 64 + 112, y, @hitsbitmap.bitmap, Rect.new(160 * i, 160, 160, 160))
      end
      if @hit == 3 && i < 3
        self.bitmap.blt(x - 64 + 112, y, @hitsbitmap.bitmap, Rect.new(160 * i, 160 * 2, 160, 160))
      end
    else
      self.bitmap.blt(x + 112, y + 64, @cursorbitmap.bitmap, Rect.new(32 * @mode, 0, 32, 32))
    end
  end
end



class MiningGameScene
  BOARD_WIDTH  = 17
  BOARD_HEIGHT = 14
  DEFAULT_ITEMS = [   # Item, probability, graphic x, graphic y, width, height, pattern
    [:DOMEFOSSIL, 20, 0, 3, 5, 4, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0]],
    [:HELIXFOSSIL, 5, 5, 3, 4, 4, [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0]],
    [:HELIXFOSSIL, 5, 9, 3, 4, 4, [1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1]],
    [:HELIXFOSSIL, 5, 13, 3, 4, 4, [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0]],
    [:HELIXFOSSIL, 5, 17, 3, 4, 4, [1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1]],
    [:OLDAMBER, 10, 21, 3, 4, 4, [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0]],
    [:OLDAMBER, 10, 25, 3, 4, 4, [1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1]],
    [:ROOTFOSSIL, 5, 0, 7, 5, 5, [1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0]],
    [:ROOTFOSSIL, 5, 5, 7, 5, 5, [0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0]],
    [:ROOTFOSSIL, 5, 10, 7, 5, 5, [0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1]],
    [:ROOTFOSSIL, 5, 15, 7, 5, 5, [0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0]],
    [:SKULLFOSSIL, 20, 20, 7, 4, 4, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0]],
    [:ARMORFOSSIL, 20, 24, 7, 5, 4, [0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0]],
    [:CLAWFOSSIL, 5, 0, 12, 4, 5, [0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0]],
    [:CLAWFOSSIL, 5, 4, 12, 5, 4, [1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1]],
    [:CLAWFOSSIL, 5, 9, 12, 4, 5, [0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0]],
    [:CLAWFOSSIL, 5, 13, 12, 5, 4, [1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1]],
    [:FIRESTONE, 20, 20, 11, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:WATERSTONE, 20, 23, 11, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 0]],
    [:THUNDERSTONE, 20, 26, 11, 3, 3, [0, 1, 1, 1, 1, 1, 1, 1, 0]],
    [:LEAFSTONE, 10, 18, 14, 3, 4, [0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0]],
    [:LEAFSTONE, 10, 21, 14, 4, 3, [0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0]],
    [:MOONSTONE, 10, 25, 14, 4, 2, [0, 1, 1, 1, 1, 1, 1, 0]],
    [:MOONSTONE, 10, 27, 16, 2, 4, [1, 0, 1, 1, 1, 1, 0, 1]],
    [:SUNSTONE, 20, 21, 17, 3, 3, [0, 1, 0, 1, 1, 1, 1, 1, 1]],
    [:OVALSTONE, 150, 24, 17, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:EVERSTONE, 150, 21, 20, 4, 2, [1, 1, 1, 1, 1, 1, 1, 1]],
    [:STARPIECE, 100, 0, 17, 3, 3, [0, 1, 0, 1, 1, 1, 0, 1, 0]],
    [:REVIVE, 100, 0, 20, 3, 3, [0, 1, 0, 1, 1, 1, 0, 1, 0]],
    [:MAXREVIVE, 50, 0, 23, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:RAREBONE, 50, 3, 17, 6, 3, [1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1]],
    [:RAREBONE, 50, 3, 20, 3, 6, [1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1]],
    [:LIGHTCLAY, 100, 6, 20, 4, 4, [1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1]],
    [:HARDSTONE, 200, 6, 24, 2, 2, [1, 1, 1, 1]],
    [:HEARTSCALE, 200, 8, 24, 2, 2, [1, 0, 1, 1]],
    [:IRONBALL, 100, 9, 17, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:ODDKEYSTONE, 100, 10, 20, 4, 4, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:HEATROCK, 50, 12, 17, 4, 3, [1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:DAMPROCK, 50, 14, 20, 3, 3, [1, 1, 1, 1, 1, 1, 1, 0, 1]],
    [:SMOOTHROCK, 50, 17, 18, 4, 4, [0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0]],
    [:ICYROCK, 50, 17, 22, 4, 4, [0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1]],
    [:VELVETYROCK, 50, 25, 31, 4, 4, [0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0]],
    [:REDSHARD, 100, 21, 22, 3, 3, [1, 1, 1, 1, 1, 0, 1, 1, 1]],
    [:GREENSHARD, 100, 25, 20, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1]],
    [:YELLOWSHARD, 100, 25, 23, 4, 3, [1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1]],
    [:BLUESHARD, 100, 26, 26, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 0]]
    #[:INSECTPLATE, 10, 0, 26, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:DREADPLATE, 10, 4, 26, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:DRACOPLATE, 10, 8, 26, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:ZAPPLATE, 10, 12, 26, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:FISTPLATE, 10, 16, 26, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:FLAMEPLATE, 10, 20, 26, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:MEADOWPLATE, 10, 0, 29, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:EARTHPLATE, 10, 4, 29, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:ICICLEPLATE, 10, 8, 29, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:TOXICPLATE, 10, 12, 29, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:MINDPLATE, 10, 16, 29, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:STONEPLATE, 10, 20, 29, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:SKYPLATE, 10, 0, 32, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:SPOOKYPLATE, 10, 4, 32, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:IRONPLATE, 10, 8, 32, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:SPLASHPLATE, 10, 12, 32, 4, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
  ]
  IRON = [   # Graphic x, graphic y, width, height, pattern
    [0, 0, 1, 4, [1, 1, 1, 1]],
    [1, 0, 2, 4, [1, 1, 1, 1, 1, 1, 1, 1]],
    [3, 0, 4, 2, [1, 1, 1, 1, 1, 1, 1, 1]],
    [3, 2, 4, 1, [1, 1, 1, 1]],
    [7, 0, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [0, 5, 3, 2, [1, 1, 0, 0, 1, 1]],
    [0, 7, 3, 2, [0, 1, 0, 1, 1, 1]],
    [3, 5, 3, 2, [0, 1, 1, 1, 1, 0]],
    [3, 7, 3, 2, [1, 1, 1, 0, 1, 0]],
    [6, 3, 2, 3, [1, 0, 1, 1, 0, 1]],
    [8, 3, 2, 3, [0, 1, 1, 1, 1, 0]],
    [6, 6, 2, 3, [1, 0, 1, 1, 1, 0]],
    [8, 6, 2, 3, [0, 1, 1, 1, 0, 1]]
  ]
  NON_ITEMS = [:CRACK1, :CRACK2, :CRACK3, :CRACK4, :CRACK5]

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(items = nil)
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    addBackgroundPlane(@sprites, "bg", "Mining/miningbg", @viewport)
    @sprites["itemlayer"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @itembitmap = AnimatedBitmap.new("Graphics/Pictures/Mining/items")
    @ironbitmap = AnimatedBitmap.new("Graphics/Pictures/Mining/irons")
    @all_items = items.nil? ? DEFAULT_ITEMS : items
    @items = []
    @itemswon = []
    @iron = []
    pbDistributeItems
    pbDistributeIron
    BOARD_HEIGHT.times do |i|
      BOARD_WIDTH.times do |j|
        @sprites["tile#{j + (i * BOARD_WIDTH)}"] = MiningGameTile.new(112 + 32 * j, 64 + (32 * i), @viewport)
        #@sprites["tile#{j + (i * BOARD_WIDTH)}"].visible = false
      end
    end
    @tool_count = 2
    if pbJob("Miner").level >= 2
      @tool_count += 1
    end
    if pbJob("Miner").level >= 4
      @tool_count += 1
    end
    @tool_ypos = 92 + 112 * (4 - @tool_count) / 2
    for i in 0...@tool_count
      @sprites[_INTL("toolbg_{1}", i)] = IconSprite.new(Graphics.width - 86, @tool_ypos + ((i + @tool_count - 2) % @tool_count) * 112, @viewport)
      @sprites[_INTL("toolbg_{1}", i)].setBitmap(sprintf("Graphics/Pictures/Mining/toolicons"))
      @sprites[_INTL("toolbg_{1}", i)].src_rect.set(68 * i, 100, 68, 100)
    end
    @sprites["crack"] = MiningGameCounter.new(112, 4)
    @sprites["cursor"] = MiningGameCursor.new(110, (@tool_count > 2) ? 2 : 0)   # central position, pick
    @sprites["tool"] = IconSprite.new(Graphics.width - 86, @tool_ypos, @viewport)
    @sprites["tool"].setBitmap(sprintf("Graphics/Pictures/Mining/toolicons"))
    @sprites["tool"].src_rect.set(68 * @sprites["cursor"].mode, 0, 68, 100)
    unique_items = []
    @all_items.each do |item|
      unique_items.push(item[0]) if !NON_ITEMS.include?(item[0]) && !unique_items.include?(item[0])
    end
    item_preview_x = 28
    item_preview_y = 160
    for i in 0...unique_items.length
      @sprites[_INTL("item_preview_{1}", i)] = ItemIconSprite.new(item_preview_x, item_preview_y, unique_items[i], @viewport)
      @sprites[_INTL("item_preview_{1}", i)].z = 99
      if i % 2 == 0
        item_preview_x += 48
      else
        item_preview_x -= 48
        item_preview_y += 48
      end
    end
    @sprites["text"] = Sprite.new(@viewport)
    @sprites["text"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSmallFont(@sprites["text"].bitmap)
    pbDrawTextPositions(@sprites["text"].bitmap, [
        ["Possible", 8, 90, 0, MessageConfig::LIGHT_TEXT_MAIN_COLOR, MessageConfig::DARK_TEXT_MAIN_COLOR, true],
        ["Items:", 8, 114, 0, MessageConfig::LIGHT_TEXT_MAIN_COLOR, MessageConfig::DARK_TEXT_MAIN_COLOR, true]
      ]
    )
    update
    pbFadeInAndShow(@sprites)
  end

  def pbDistributeItems
    # Set items to be buried (index in @all_items, x coord, y coord)
    ptotal = 0
    numitems = rand(4..6)
    @all_items.length.times do |i|
      ptotal += @all_items[i][1]
      if @all_items[i][1] == 0
        added = false
        until added
          provx = rand(BOARD_WIDTH - @all_items[i][4] + 1)
          provy = rand(BOARD_HEIGHT - @all_items[i][5] + 1)
          if pbCheckOverlaps(false, provx, provy, @all_items[i][4], @all_items[i][5], @all_items[i][6])
            @items.push([i, provx, provy])
            numitems -= 1
            added = true
          end
        end
      end
    end
    tries = 0
    while numitems > 0
      rnd = rand(ptotal)
      added = false
      @all_items.length.times do |i|
        rnd -= @all_items[i][1]
        if rnd < 0
          if pbNoDuplicateItems(@all_items[i][0])
            until added
              provx = rand(BOARD_WIDTH - @all_items[i][4] + 1)
              provy = rand(BOARD_HEIGHT - @all_items[i][5] + 1)
              if pbCheckOverlaps(false, provx, provy, @all_items[i][4], @all_items[i][5], @all_items[i][6])
                @items.push([i, provx, provy])
                numitems -= 1
                added = true
              end
            end
          else
            break
          end
        end
        break if added
      end
      tries += 1
      break if tries >= 500
    end
    # Draw items on item layer
    layer = @sprites["itemlayer"].bitmap
    @items.each do |i|
      ox = @all_items[i[0]][2]
      oy = @all_items[i[0]][3]
      rectx = @all_items[i[0]][4]
      recty = @all_items[i[0]][5]
      layer.blt(112 + 32 * i[1], 64 + (32 * i[2]), @itembitmap.bitmap, Rect.new(32 * ox, 32 * oy, 32 * rectx, 32 * recty))
    end
  end

  def pbDistributeIron
    # Set iron to be buried (index in IRON, x coord, y coord)
    numitems = rand(4..6)
    tries = 0
    while numitems > 0
      rnd = rand(IRON.length)
      provx = rand(BOARD_WIDTH - IRON[rnd][2] + 1)
      provy = rand(BOARD_HEIGHT - IRON[rnd][3] + 1)
      if pbCheckOverlaps(true, provx, provy, IRON[rnd][2], IRON[rnd][3], IRON[rnd][4])
        @iron.push([rnd, provx, provy])
        numitems -= 1
      end
      tries += 1
      break if tries >= 500
    end
    # Draw items on item layer
    layer = @sprites["itemlayer"].bitmap
    @iron.each do |i|
      ox = IRON[i[0]][0]
      oy = IRON[i[0]][1]
      rectx = IRON[i[0]][2]
      recty = IRON[i[0]][3]
      layer.blt(112 + 32 * i[1], 64 + (32 * i[2]), @ironbitmap.bitmap, Rect.new(32 * ox, 32 * oy, 32 * rectx, 32 * recty))
    end
  end

  def pbNoDuplicateItems(newitem)
    return true if newitem == :HEARTSCALE   # Allow multiple Heart Scales
    shards = [:REDSHARD, :BLUESHARD, :GREENSHARD, :YELLOWSHARD]
    return true if shards.include?(newitem)
    fossils = [:DOMEFOSSIL, :HELIXFOSSIL, :OLDAMBER, :ROOTFOSSIL,
               :SKULLFOSSIL, :ARMORFOSSIL, :CLAWFOSSIL]
    plates = [:INSECTPLATE, :DREADPLATE, :DRACOPLATE, :ZAPPLATE, :FISTPLATE,
              :FLAMEPLATE, :MEADOWPLATE, :EARTHPLATE, :ICICLEPLATE, :TOXICPLATE,
              :MINDPLATE, :STONEPLATE, :SKYPLATE, :SPOOKYPLATE, :IRONPLATE, :SPLASHPLATE]
    @items.each do |i|
      preitem = @all_items[i[0]][0]
      return false if preitem == newitem   # No duplicate items
      return false if fossils.include?(preitem) && fossils.include?(newitem)
      return false if plates.include?(preitem) && plates.include?(newitem)
    end
    return true
  end

  def pbCheckOverlaps(checkiron, provx, provy, provwidth, provheight, provpattern)
    @items.each do |i|
      prex = i[1]
      prey = i[2]
      prewidth = @all_items[i[0]][4]
      preheight = @all_items[i[0]][5]
      prepattern = @all_items[i[0]][6]
      next if provx + provwidth <= prex || provx >= prex + prewidth ||
              provy + provheight <= prey || provy >= prey + preheight
      prepattern.length.times do |j|
        next if prepattern[j] == 0
        xco = prex + (j % prewidth)
        yco = prey + (j / prewidth).floor
        next if provx + provwidth <= xco || provx > xco ||
                provy + provheight <= yco || provy > yco
        return false if provpattern[xco - provx + ((yco - provy) * provwidth)] == 1
      end
    end
    if checkiron   # Check other irons as well
      @iron.each do |i|
        prex = i[1]
        prey = i[2]
        prewidth = IRON[i[0]][2]
        preheight = IRON[i[0]][3]
        prepattern = IRON[i[0]][4]
        next if provx + provwidth <= prex || provx >= prex + prewidth ||
                provy + provheight <= prey || provy >= prey + preheight
        prepattern.length.times do |j|
          next if prepattern[j] == 0
          xco = prex + (j % prewidth)
          yco = prey + (j / prewidth).floor
          next if provx + provwidth <= xco || provx > xco ||
                  provy + provheight <= yco || provy > yco
          return false if provpattern[xco - provx + ((yco - provy) * provwidth)] == 1
        end
      end
    end
    return true
  end

  def pbHit
    hittype = 0
    position = @sprites["cursor"].position
    if @sprites["cursor"].mode == 1   # Hammer
      pattern = [1, 2, 1,
                 2, 2, 2,
                 1, 2, 1]
      @sprites["crack"].hits += 3 if !($DEBUG && Input.press?(Input::CTRL))
    elsif @sprites["cursor"].mode == 2
      pattern = [0, 0, 0,
                 0, 1, 0,
                 0, 0, 0]
      @sprites["crack"].hits += 1 if !($DEBUG && Input.press?(Input::CTRL))
    elsif @sprites["cursor"].mode == 3
      pattern = [0, 0, 0,
                 0, 1, 0,
                 0, 0, 0]
      @sprites["crack"].hits += 4 if !($DEBUG && Input.press?(Input::CTRL))
    else                            # Pick
      pattern = [0, 1, 0,
                 1, 2, 1,
                 0, 1, 0]
      @sprites["crack"].hits += 2 if !($DEBUG && Input.press?(Input::CTRL))
    end
    if @sprites["tile#{position}"].layer <= pattern[4] && pbIsIronThere?(position)
      @sprites["tile#{position}"].layer -= pattern[4]
      pbSEPlay("Mining iron")
      hittype = 2
    else
      3.times do |i|
        ytile = i - 1 + (position / BOARD_WIDTH)
        next if ytile < 0 || ytile >= BOARD_HEIGHT
        3.times do |j|
          xtile = j - 1 + (position % BOARD_WIDTH)
          next if xtile < 0 || xtile >= BOARD_WIDTH
          @sprites["tile#{xtile + (ytile * BOARD_WIDTH)}"].layer -= pattern[j + (i * 3)]
        end
      end
      if @sprites["cursor"].mode == 1   # Hammer
        pbSEPlay("Mining hammer")
      elsif @sprites["cursor"].mode == 2 || @sprites["cursor"].mode == 3
        if pbIsItemThere?(position)
          pbSEPlay("Mining spelunk")
        else
          pbSEPlay("Mining pick")
        end
      else
        pbSEPlay("Mining pick")
      end
    end
    update
    Graphics.update
    hititem = (@sprites["tile#{position}"].layer == 0 && pbIsItemThere?(position))
    hittype = 3 if @sprites["cursor"].mode == 2 && pbIsItemThere?(position)
    hittype = 1 if hititem
    @sprites["cursor"].animate(hittype)
    revealed = pbCheckRevealed
    if revealed.length > 0
      pbSEPlay("Mining reveal full")
      pbFlashItems(revealed)
    elsif hititem
      pbSEPlay("Mining reveal")
    end
    if @sprites["cursor"].mode == 3
      hititem = pbIsItemThere?(position)
      pbOutlineItems([hititem]) if hititem
    end
  end

  def pbIsItemThere?(position)
    posx = position % BOARD_WIDTH
    posy = position / BOARD_WIDTH
    @items.length.times do |i|
      item = @items[i]
      index = item[0]
      width = @all_items[index][4]
      height = @all_items[index][5]
      pattern = @all_items[index][6]
      next if posx < item[1] || posx >= (item[1] + width)
      next if posy < item[2] || posy >= (item[2] + height)
      dx = posx - item[1]
      dy = posy - item[2]
      return i if pattern[dx + (dy * width)] > 0
    end
    return false
  end

  def pbIsIronThere?(position)
    posx = position % BOARD_WIDTH
    posy = position / BOARD_WIDTH
    @iron.each do |i|
      index = i[0]
      width = IRON[index][2]
      height = IRON[index][3]
      pattern = IRON[index][4]
      next if posx < i[1] || posx >= (i[1] + width)
      next if posy < i[2] || posy >= (i[2] + height)
      dx = posx - i[1]
      dy = posy - i[2]
      return true if pattern[dx + (dy * width)] > 0
    end
    return false
  end

  def pbCheckRevealed
    ret = []
    @items.length.times do |i|
      next if @items[i][3]
      revealed = true
      index = @items[i][0]
      width = @all_items[index][4]
      height = @all_items[index][5]
      pattern = @all_items[index][6]
      height.times do |j|
        width.times do |k|
          layer = @sprites["tile#{@items[i][1] + k + ((@items[i][2] + j) * BOARD_WIDTH)}"].layer
          revealed = false if layer > 0 && pattern[k + (j * width)] > 0
          break if !revealed
        end
        break if !revealed
      end
      ret.push(i) if revealed
    end
    return ret
  end

  def pbFlashItems(revealed)
    return if revealed.length <= 0
    revealeditems = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    halfFlashTime = Graphics.frame_rate / 8
    alphaDiff = (255.0 / halfFlashTime).ceil
    (1..halfFlashTime * 2).each do |i|
      revealed.each do |index|
        burieditem = @items[index]
        revealeditems.bitmap.blt(112 + 32 * burieditem[1], 64 + (32 * burieditem[2]),
                                 @itembitmap.bitmap,
                                 Rect.new(32 * @all_items[burieditem[0]][2], 32 * @all_items[burieditem[0]][3],
                                          32 * @all_items[burieditem[0]][4], 32 * @all_items[burieditem[0]][5]))
        if i > halfFlashTime
          revealeditems.color = Color.new(255, 255, 255, ((halfFlashTime * 2) - i) * alphaDiff)
        else
          revealeditems.color = Color.new(255, 255, 255, i * alphaDiff)
        end
      end
      update
      Graphics.update
    end
    revealeditems.dispose
    revealed.each do |index|
      @items[index][3] = true
      item = @all_items[@items[index][0]][0]
      @itemswon.push(item)
    end
  end

  def pbOutlineItems(revealed)
    return if revealed.length <= 0
    revealeditems = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    fadeTime = Graphics.frame_rate / 2
    startFadeTime = Graphics.frame_rate / 2
    revealeditems.color = Color.new(0, 0, 0)
    revealeditems.z = 99999
    alphaDiff = (128.0 / fadeTime).ceil
    revealeditems.opacity = alphaDiff * fadeTime
    (1..(startFadeTime + fadeTime)).each do |i|
      revealed.each do |index|
        burieditem = @items[index]
        revealeditems.bitmap.blt(112 + 32 * burieditem[1], 64 + (32 * burieditem[2]),
                                 @itembitmap.bitmap,
                                 Rect.new(32 * @all_items[burieditem[0]][2], 32 * @all_items[burieditem[0]][3],
                                          32 * @all_items[burieditem[0]][4], 32 * @all_items[burieditem[0]][5]))
        if i > startFadeTime
          revealeditems.opacity = (fadeTime + startFadeTime - i) * alphaDiff
        end
      end
      update
      Graphics.update
    end
    revealeditems.dispose
  end

  def pbMain
    pbSEPlay("Mining ping")
    pbMessage(_INTL("Something pinged in the wall!\n{1} confirmed!", @items.length))
    loop do
      update
      Graphics.update
      Input.update
      next if @sprites["cursor"].isAnimating?
      # Check end conditions
      if @sprites["crack"].hits >= 108
        @sprites["cursor"].visible = false
        pbSEPlay("Mining collapse")
        collapseviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        collapseviewport.z = 99999
        @sprites["collapse"] = BitmapSprite.new(Graphics.width, Graphics.height, collapseviewport)
        collapseTime = Graphics.frame_rate * 8 / 10
        collapseFraction = (Graphics.height.to_f / collapseTime).ceil
        (1..collapseTime).each do |i|
          @sprites["collapse"].bitmap.fill_rect(0, collapseFraction * (i - 1),
                                                Graphics.width, collapseFraction * i, Color.new(0, 0, 0))
          Graphics.update
        end
        pbMessage(_INTL("The wall collapsed!"))
        break
      end
      foundall = true
      @items.each do |i|
        foundall = false if !i[3]
        break if !foundall
      end
      if foundall
        @sprites["cursor"].visible = false
        pbWait(Graphics.frame_rate * 3 / 4)
        pbSEPlay("Mining found all")
        pbMessage(_INTL("Everything was dug up!"))
        break
      end
      # Input
      if Input.trigger?(Input::UP) || Input.repeat?(Input::UP)
        if @sprites["cursor"].position >= BOARD_WIDTH
          pbSEPlay("Mining cursor")
          @sprites["cursor"].position -= BOARD_WIDTH
        end
      elsif Input.trigger?(Input::DOWN) || Input.repeat?(Input::DOWN)
        if @sprites["cursor"].position < (BOARD_WIDTH * (BOARD_HEIGHT - 1))
          pbSEPlay("Mining cursor")
          @sprites["cursor"].position += BOARD_WIDTH
        end
      elsif Input.trigger?(Input::LEFT) || Input.repeat?(Input::LEFT)
        if @sprites["cursor"].position % BOARD_WIDTH > 0
          pbSEPlay("Mining cursor")
          @sprites["cursor"].position -= 1
        end
      elsif Input.trigger?(Input::RIGHT) || Input.repeat?(Input::RIGHT)
        if @sprites["cursor"].position % BOARD_WIDTH < (BOARD_WIDTH - 1)
          pbSEPlay("Mining cursor")
          @sprites["cursor"].position += 1
        end
      elsif Input.trigger?(Input::ACTION)   # Change tool mode
        pbSEPlay("Mining tool change")
        newmode = (@sprites["cursor"].mode + 1) % @tool_count
        @sprites["cursor"].mode = newmode
        @sprites["tool"].src_rect.set(newmode * 68, 0, 68, 100)
        @sprites["tool"].y = @tool_ypos + (112 * ((newmode + @tool_count - 2) % @tool_count))
      elsif Input.trigger?(Input::USE)   # Hit
        pbHit
      elsif Input.trigger?(Input::BACK)   # Quit
        msgwindow = pbCreateMessageWindow(nil, nil)
        msgwindow.z += 3
        command = pbMessageDisplay(msgwindow, _INTL("Are you sure you want to give up?"), true,
                    proc { |msgwindow|
                      next Kernel.pbShowCommands(msgwindow, ["Yes", "No"], -1, 0)
                    })
        pbDisposeMessageWindow(msgwindow)
        break if command == 0
      end
    end
    pbGiveItems
  end

  def pbGiveItems
    if @itemswon.length > 0
      @itemswon.each do |i|
        pbJob("Miner").register(i)
        next if NON_ITEMS.include?(i)
        if $bag.add(i)
          pbMessage(_INTL("One {1} was obtained.\\se[Mining item get]\\wtnp[30]",
                          GameData::Item.get(i).name))
        else
          pbMessage(_INTL("One {1} was found, but you have no room for it.",
                          GameData::Item.get(i).name))
        end
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class MiningGame
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(items = nil)
    @scene.pbStartScene(items)
    @scene.pbMain
    @scene.pbEndScene
  end
end



def pbMiningGame(items = nil)
  pbFadeOutIn {
    scene = MiningGameScene.new
    screen = MiningGame.new(scene)
    screen.pbStartScreen(items)
  }
end


def pbMineQuarry(color = "none", tier = 0)
  if $bag.quantity(:MINERKIT) == 0
    pbMessage(_INTL("You spot {1} objects in the wall, but lack the tools needed to excavate them.", color.downcase))
    return
  end
  if pbConfirmMessage(_INTL("You spot {1} objects in the wall.\\wt[4]\nDo you want to mine here?", color.downcase))
    items = pbMiningColorItems(color, tier)
    pbMiningGame(items)
  end
end


def pbMiningColorItems(color = "none", tier = 0)
  items = []

  case color.downcase
  when "red"
    items.push([:REDSHARD, 200, 21, 22, 3, 2, [1, 1, 1, 1, 1, 0]])
    items.push([:REDSHARD, 200, 21, 24, 3, 2, [1, 1, 0, 1, 1, 1]])
    items.push([:REDSHARD, 200, 15, 23, 2, 3, [1, 1, 1, 0, 1, 1]])
    items.push([:FIRESTONE, 80, 20, 11, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]])
    items.push([:HEATROCK, 100, 12, 17, 4, 3, [1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1]])
  when "green"
    items.push([:GREENSHARD, 100, 25, 20, 2, 3, [1, 1, 1, 1, 1, 0]])
    items.push([:GREENSHARD, 100, 27, 20, 2, 3, [1, 1, 1, 1, 0, 1]])
    items.push([:GREENSHARD, 100, 13, 24, 2, 2, [1, 1, 1, 1]])
    items.push([:LEAFSTONE, 40, 18, 14, 3, 4, [0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0]])
    items.push([:LEAFSTONE, 40, 21, 14, 4, 3, [0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0]])
    items.push([:VELVETYROCK, 100, 25, 31, 4, 4, [0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0]])
  when "yellow"
    items.push([:YELLOWSHARD, 100, 24, 23, 3, 2, [1, 0, 1, 1, 1, 1]])
    items.push([:YELLOWSHARD, 100, 27, 23, 2, 3, [1, 0, 1, 0, 1, 1]])
    items.push([:YELLOWSHARD, 100, 24, 25, 2, 3, [1, 0, 1, 1, 1, 1]])
    items.push([:THUNDERSTONE, 80, 26, 11, 3, 3, [0, 1, 1, 1, 1, 1, 1, 1, 0]])
    items.push([:SMOOTHROCK, 100, 17, 18, 4, 4, [0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0]])
  when "blue"
    items.push([:BLUESHARD, 100, 26, 26, 3, 2, [1, 1, 1, 1, 1, 1]])
    items.push([:BLUESHARD, 100, 25, 28, 2, 3, [1, 1, 1, 1, 1, 0]])
    items.push([:BLUESHARD, 100, 27, 28, 2, 3, [1, 1, 1, 1, 1, 1]])
    items.push([:WATERSTONE, 80, 23, 11, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 0]])
    # Ice Stone
    items.push([:DAMPROCK, 100, 14, 20, 3, 3, [1, 1, 1, 1, 1, 1, 1, 0, 1]])
    items.push([:ICYROCK, 100, 17, 22, 4, 4, [0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1]])
  when "dark"
    items.push([:MOONSTONE, 40, 25, 14, 4, 2, [0, 1, 1, 1, 1, 1, 1, 0]])
    items.push([:MOONSTONE, 40, 27, 16, 2, 4, [1, 0, 1, 1, 1, 1, 0, 1]])
    # Dusk Stone
  when "bright"
    items.push([:SUNSTONE, 80, 21, 17, 3, 3, [0, 1, 0, 1, 1, 1, 1, 1, 1]])
    # Dawn Stone
    # Shiny Stone
  when "fossil"
    items.push([:DOMEFOSSIL, 20, 0, 3, 5, 4, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0]])
    items.push([:HELIXFOSSIL, 5, 5, 3, 4, 4, [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0]])
    items.push([:HELIXFOSSIL, 5, 9, 3, 4, 4, [1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1]])
    items.push([:HELIXFOSSIL, 5, 13, 3, 4, 4, [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0]])
    items.push([:HELIXFOSSIL, 5, 17, 3, 4, 4, [1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1]])
    items.push([:OLDAMBER, 10, 21, 3, 4, 4, [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0]])
    items.push([:OLDAMBER, 10, 25, 3, 4, 4, [1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1]])
    items.push([:ROOTFOSSIL, 5, 0, 7, 5, 5, [1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0]])
    items.push([:ROOTFOSSIL, 5, 5, 7, 5, 5, [0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0]])
    items.push([:ROOTFOSSIL, 5, 10, 7, 5, 5, [0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1]])
    items.push([:ROOTFOSSIL, 5, 15, 7, 5, 5, [0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0]])
    items.push([:SKULLFOSSIL, 20, 20, 7, 4, 4, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0]])
    items.push([:ARMORFOSSIL, 20, 24, 7, 5, 4, [0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0]])
    items.push([:CLAWFOSSIL, 5, 0, 12, 4, 5, [0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0]])
    items.push([:CLAWFOSSIL, 5, 4, 12, 5, 4, [1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1]])
    items.push([:CLAWFOSSIL, 5, 9, 12, 4, 5, [0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0]])
    items.push([:CLAWFOSSIL, 5, 13, 12, 5, 4, [1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1]])
    # Sail Fossil
    # Jaw Fossil
  end

  items += [
    [:OVALSTONE, 50, 24, 17, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:EVERSTONE, 150, 21, 20, 4, 2, [1, 1, 1, 1, 1, 1, 1, 1]],
    [:STARPIECE, 100, 0, 17, 3, 3, [0, 1, 0, 1, 1, 1, 0, 1, 0]],
    [:REVIVE, 100, 0, 20, 3, 3, [0, 1, 0, 1, 1, 1, 0, 1, 0]],
    #[:MAXREVIVE, 50, 0, 23, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]],
    [:RAREBONE, 50, 3, 17, 6, 3, [1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1]],
    [:RAREBONE, 50, 3, 20, 3, 6, [1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 1, 1]],
    [:LIGHTCLAY, 100, 6, 20, 4, 4, [1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1]],
    [:HARDSTONE, 150, 6, 24, 2, 2, [1, 1, 1, 1]],
    [:HEARTSCALE, 150, 8, 24, 2, 2, [1, 0, 1, 1]],
    [:IRONBALL, 100, 9, 17, 3, 3, [1, 1, 1, 1, 1, 1, 1, 1, 1]],
    #[:ODDKEYSTONE, 100, 10, 20, 4, 4, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]],
    # King's Rock
    # Metal Powder
    # Quick Powder
    # Protector ?
  ]

  if tier == 10
    items.push([:CRACK1, 0, 0, 35, 7, 5,
      [1, 1, 1, 1, 1, 1, 0,
       0, 1, 1, 1, 1, 0, 0,
       0, 1, 1, 1, 1, 1, 0,
       1, 1, 1, 0, 1, 1, 1,
       0, 1, 1, 1, 0, 0, 0]])
  end

  return items

end