#===============================================================================
# Data box for regular battles
#===============================================================================
class Battle::Scene::PokemonDataBox < Sprite
  attr_reader   :battler
  attr_accessor :selected

  # Time in seconds to fully fill the Exp bar (from empty).
  EXP_BAR_FILL_TIME = 1.75
  # Time in seconds for this data box to flash when the Exp fully fills.
  EXP_FULL_FLASH_DURATION = 0.2
  # Maximum time in seconds to make a change to the HP bar.
  HP_BAR_CHANGE_TIME = 1.0
  # Time (in seconds) for one complete sprite bob cycle (up and down) while
  # choosing a command for this battler or when this battler is being chosen as
  # a target. Set to nil to prevent bobbing.
  BOBBING_DURATION = 0.6
  # Height in pixels of a status icon
  STATUS_ICON_HEIGHT = 16
  # Text colors
  NAME_BASE_COLOR         = Color.new(72, 72, 72)
  NAME_SHADOW_COLOR       = Color.new(184, 184, 184)
  MALE_BASE_COLOR         = Color.new(48, 96, 216)
  MALE_SHADOW_COLOR       = NAME_SHADOW_COLOR
  FEMALE_BASE_COLOR       = Color.new(248, 88, 40)
  FEMALE_SHADOW_COLOR     = NAME_SHADOW_COLOR

  def initialize(battler, sideSize, viewport = nil)
    super(viewport)
    @battler         = battler
    @sprites         = {}
    @spriteX         = 0
    @spriteY         = 0
    @spriteBaseX     = 0
    @selected        = 0
    @show_hp_numbers = false
    @show_exp_bar    = false
    initializeDataBoxGraphic(sideSize)
    initializeOtherGraphics(viewport)
    refresh
  end

  def onPlayerSide
    return (@battler.index % 2 == 0)
  end

  def initializeDataBoxGraphic(sideSize)
    onPlayerSide = @battler.index.even?
    # Get the data box graphic and set whether the HP numbers/Exp bar are shown
    if sideSize == 1   # One Pokémon on side, use the regular dara box BG
      bgFilename = [_INTL("Graphics/UI/Battle/databox_normal"),
                    _INTL("Graphics/UI/Battle/databox_normal_foe")][@battler.index % 2]
      if onPlayerSide
        @show_hp_numbers = true
        @show_exp_bar    = true
      end
    else   # Multiple Pokémon on side, use the thin dara box BG
      bgFilename = [_INTL("Graphics/UI/Battle/databox_thin"),
                    _INTL("Graphics/UI/Battle/databox_thin_foe")][@battler.index % 2]
    end
    @databoxBitmap&.dispose
    @databoxBitmap = AnimatedBitmap.new(bgFilename)
    # Determine the co-ordinates of the data box and the left edge padding width
    if onPlayerSide
      @spriteX = self.viewport.rect.width - 244
      @spriteY = self.viewport.rect.height - 192
      @spriteBaseX = 34
    else
      @spriteX = -16
      @spriteY = 36
      @spriteBaseX = 16
    end
    case sideSize
    when 1
      if @battler.index == 1
        offset = 0
        for gauge in pbBoss.gauges
          if gauge.type == PBGauge::Half
            offset += 6
          else
            offset += 12
          end
        end
        @spriteY -= [offset, 40].min
      end
    when 2
      @spriteX += [-12,  12,  0,  0][@battler.index]
      @spriteY += [-20, -34, 34, 20][@battler.index]
    when 3
      @spriteX += [-12,  12, -6,  6,  0,  0][@battler.index]
      @spriteY += [-42, -46,  4,  0, 50, 46][@battler.index]
    end
  end

  def initializeOtherGraphics(viewport)
    # Create other bitmaps
    @numbersBitmap = AnimatedBitmap.new("Graphics/UI/Battle/icon_numbers")
    @hpBarBitmap   = AnimatedBitmap.new("Graphics/UI/Battle/overlay_hp")
    @hpBarExBitmap = AnimatedBitmap.new("Graphics/UI/Battle/overlay_hp_extra")
    @expBarBitmap  = AnimatedBitmap.new("Graphics/UI/Battle/overlay_exp")
    @numbersWhiteBitmap = AnimatedBitmap.new("Graphics/UI/Battle/icon_numbers_white")
    # Create sprite to draw HP numbers on
    @hpNumbers = BitmapSprite.new(124, 16, viewport)
#    pbSetSmallFont(@hpNumbers.bitmap)
    @sprites["hpNumbers"] = @hpNumbers
    # Create sprite wrapper that displays HP bar
    @hpBar = Sprite.new(viewport)
    @hpBar.bitmap = @hpBarBitmap.bitmap
    @hpBar.src_rect.height = @hpBarBitmap.height / 3
    @hpBarEx = Sprite.new(viewport)
    @hpBarEx.bitmap = @hpBarExBitmap.bitmap
    @hpBarEx.src_rect.height = @hpBarExBitmap.height / 8
    @hpBarEx.src_rect.width = 0
    @hpBarEx2 = Sprite.new(viewport)
    @hpBarEx2.bitmap = @hpBarExBitmap.bitmap
    @hpBarEx2.src_rect.height = @hpBarExBitmap.height / 8
    @hpBarEx2.src_rect.width = 0
    @sprites["hpBar"] = @hpBar
    @sprites["hpBarEx"] = @hpBarEx
    @sprites["hpBarEx2"] = @hpBarEx2
    # Create sprite wrapper that displays Exp bar
    @expBar = Sprite.new(viewport)
    @expBar.bitmap = @expBarBitmap.bitmap
    @sprites["expBar"] = @expBar
    # Create sprite wrapper that displays everything except the above
    @contents = Bitmap.new(@databoxBitmap.width, @databoxBitmap.height + 256)
    self.bitmap  = @contents
    self.visible = false
    self.z       = 150 + ((@battler.index / 2) * 5)
    pbSetSystemFont(self.bitmap)
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @databoxBitmap.dispose
    @numbersBitmap.dispose
    @hpBarBitmap.dispose
    @hpBarExBitmap.dispose
    @expBarBitmap.dispose
    @contents.dispose
    super
  end

  def x=(value)
    super
    @hpBar.x     = value + @spriteBaseX + 102
    @hpBarEx.x   = @hpBar.x
    @hpBarEx2.x  = @hpBar.x
    @expBar.x    = value + @spriteBaseX + 6
    @hpNumbers.x = value + @spriteBaseX + (@showHP ? 80 : 98)
  end

  def y=(value)
    super
    @hpBar.y     = value + 40
    @hpBarEx.y   = @hpBar.y
    @hpBarEx2.y  = @hpBar.y
    @expBar.y    = value + 74
    @hpNumbers.y = value + (@showHP ? 52 : 34)
  end

  def z=(value)
    super
    @hpBar.z     = value + 1
    @hpBarEx.z   = @hpBar.z
    @hpBarEx2.z  = @hpBar.z
    @expBar.z    = value + 1
    @hpNumbers.z = value + 2
  end

  def opacity=(value)
    super
    @sprites.each do |i|
      i[1].opacity = value if !i[1].disposed?
    end
  end

  def visible=(value)
    super
    @sprites.each do |i|
      i[1].visible = value if !i[1].disposed?
    end
    @expBar.visible = (value && @show_exp_bar)
  end

  def color=(value)
    super
    @sprites.each do |i|
      i[1].color = value if !i[1].disposed?
    end
  end

  def battler=(b)
    @battler = b
    self.visible = (@battler && !@battler.fainted?)
  end

  def hp
    return (animating_hp?) ? @anim_hp_current : @battler.hp
  end

  def exp_fraction
    if animating_exp?
      return 0.0 if @anim_exp_range == 0
      return @anim_exp_current.to_f / @anim_exp_range
    end
    return @battler.pokemon.exp_fraction
  end

  # NOTE: A change in HP takes the same amount of time to animate, no matter how
  #       big a change it is.
  def animate_hp(old_val, new_val)
    return if old_val == new_val
    @anim_hp_start = old_val
    @anim_hp_end = new_val
    @anim_hp_current = old_val
    @anim_hp_timer_start = System.uptime
  end

  def animating_hp?
    return @anim_hp_timer_start != nil
  end

  # NOTE: Filling the Exp bar from empty to full takes EXP_BAR_FILL_TIME seconds
  #       no matter what. Filling half of it takes half as long, etc.
  def animate_exp(old_val, new_val, range)
    return if old_val == new_val || range == 0 || !@show_exp_bar
    @anim_exp_start = old_val
    @anim_exp_end = new_val
    @anim_exp_range = range
    @anim_exp_duration_mult = (new_val - old_val).abs / range.to_f
    @anim_exp_current = old_val
    @anim_exp_timer_start = System.uptime
    pbSEPlay("Pkmn exp gain") if @show_exp_bar
  end

  def animating_exp?
    return @anim_exp_timer_start != nil
  end

  def pbDrawNumber(number, btmp, startX, startY, align = :left, white = false)
    # -1 means draw the / character
    n = (number == -1) ? [10] : number.to_i.digits.reverse
    n.push(11) if number.to_s.include?("%")
    charWidth  = @numbersBitmap.width / 12
    charHeight = @numbersBitmap.height
    startX -= charWidth * n.length if align == :right
    startX -= (charWidth * n.length) / 2 if align == :center
    n.each do |i|
      btmp.blt(startX, startY, white ? @numbersWhiteBitmap.bitmap : @numbersBitmap.bitmap, Rect.new(i * charWidth, 0, charWidth, charHeight))
      startX += charWidth
    end
  end

  def draw_background
    self.bitmap.blt(0, 0, @databoxBitmap.bitmap, Rect.new(0, 0, @databoxBitmap.width, @databoxBitmap.height))
  end

  def draw_name
    nameWidth = self.bitmap.text_size(@battler.name).width
    nameOffset = 0
    nameOffset = nameWidth - 116 if nameWidth > 116
    pbDrawTextPositions(self.bitmap, [[@battler.name, @spriteBaseX + 8 - nameOffset, 12, :left,
                                       NAME_BASE_COLOR, NAME_SHADOW_COLOR]]
    )
  end

  def draw_level
    # "Lv" graphic
    pbDrawImagePositions(self.bitmap, [[_INTL("Graphics/UI/Battle/overlay_lv"), @spriteBaseX + 140, 16]])
    # Level number
    pbDrawNumber(@battler.level, self.bitmap, @spriteBaseX + 162, 16)
  end

  def draw_gender
    gender = @battler.displayGender
    return if ![0, 1].include?(gender)
    gender_text  = (gender == 0) ? _INTL("♂") : _INTL("♀")
    base_color   = (gender == 0) ? MALE_BASE_COLOR : FEMALE_BASE_COLOR
    shadow_color = (gender == 0) ? MALE_SHADOW_COLOR : FEMALE_SHADOW_COLOR
    pbDrawTextPositions(self.bitmap, [[gender_text, @spriteBaseX + 126, 12, :left, base_color, shadow_color]])
  end

  def draw_status
    return if @battler.status == :NONE
    if @battler.status == :POISON && @battler.statusCount < 0   # Badly poisoned
      s = GameData::Status.count - 1
    else
      s = GameData::Status.get(@battler.status).icon_position
    end
    return if s < 0
    pbDrawImagePositions(self.bitmap, [[_INTL("Graphics/UI/Battle/icon_statuses"), @spriteBaseX + 24, 36,
                                        0, s * STATUS_ICON_HEIGHT, -1, STATUS_ICON_HEIGHT]])
  end

  def draw_shiny_icon
    return if !@battler.shiny?
    shiny_x = (@battler.opposes?(0)) ? 206 : -6   # Foe's/player's
    pbDrawImagePositions(self.bitmap, [["Graphics/UI/shiny", @spriteBaseX + shiny_x, 36]])
  end

  def draw_special_form_icon
    # Mega Evolution/Primal Reversion icon
    if @battler.mega?
      pbDrawImagePositions(self.bitmap, [["Graphics/UI/Battle/icon_mega", @spriteBaseX + 8, 34]])
    elsif @battler.primal?
      filename = nil
      if @battler.isSpecies?(:GROUDON)
        filename = "Graphics/UI/Battle/icon_primal_Groudon"
      elsif @battler.isSpecies?(:KYOGRE)
        filename = "Graphics/UI/Battle/icon_primal_Kyogre"
      end
      primalX = (@battler.opposes?) ? 208 : -28   # Foe's/player's
      pbDrawImagePositions(self.bitmap, [[filename, @spriteBaseX + primalX, 4]]) if filename
    end
  end

  def draw_owned_icon
    return if !@battler.owned? || !@battler.opposes?(0)   # Draw for foe Pokémon only
    pbDrawImagePositions(self.bitmap, [["Graphics/UI/Battle/icon_own", @spriteBaseX + 8, 36]])
  end

  def refresh
    self.bitmap.clear
    return if !@battler.pokemon
    draw_background
    draw_name
    draw_level
    draw_gender
    draw_status
    draw_shiny_icon
    draw_special_form_icon
    draw_owned_icon
    refresh_hp
    refresh_exp
  end

  def refresh_hp
    @hpNumbers.bitmap.clear
    return if !@battler.pokemon
    # Show HP numbers
    if @show_hp_numbers
      pbDrawNumber(self.hp, @hpNumbers.bitmap, 54, 2, :right)
      pbDrawNumber(-1, @hpNumbers.bitmap, 54, 2)   # / char
      pbDrawNumber(@battler.totalhp, @hpNumbers.bitmap, 70, 2)
    elsif Supplementals::SHOW_OPPOSING_HP_PERCENT
      hpPercent = [(self.hp * 100.0 / @battler.totalhp), 0.1].max
      hpPercent = 0.1 if self.hp == 1
      hpText = self.hp >= @battler.totalhp ? sprintf("%d%%", hpPercent.round) : sprintf("%.1f%%", hpPercent)
      pbDrawNumber(hpText, @hpNumbers.bitmap, 54, 2, :center, true)
    end
    # Resize HP bar
    w = 0
    if self.hp > 0
      w = @hpBarBitmap.width.to_f * self.hp / @battler.totalhp
      w = 1 if w < 1
      # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
      #       fit in with the rest of the graphics which are doubled in size.
      w = ((w / 2.0).round) * 2
    end
    @hpBar.src_rect.width = w
    hpColor = 0                                      # Green bar
    hpColor = 1 if self.hp <= @battler.totalhp / 2   # Yellow bar
    hpColor = 2 if self.hp <= @battler.totalhp / 4   # Red bar
    @hpBar.src_rect.y = hpColor * @hpBarBitmap.height / 3
    if self.hp > @battler.totalhp
      top_layer = ((self.hp - 1) / @battler.totalhp).floor - 1
      if top_layer < 0
        @hpBarEx.src_rect.width = 0
        @hpBarEx2.src_rect.width = 0
      else
        # Resize HP bar
        w = @hpBarBitmap.width.to_f * (self.hp - (@battler.totalhp * (top_layer + 1))) / @battler.totalhp
        w = 1 if w < 1
        # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
        #       fit in with the rest of the graphics which are doubled in size.
        w = ((w / 2.0).round) * 2
        @hpBarEx2.src_rect.width = w
        @hpBarEx2.src_rect.y = (top_layer % 8) * @hpBarExBitmap.height / 8
        if top_layer == 0
          @hpBarEx.src_rect.width = 0
        else
          @hpBarEx.src_rect.y = ((top_layer - 1) % 8) * @hpBarExBitmap.height / 8
          @hpBarEx.src_rect.width = @hpBarExBitmap.width
        end
      end
    else
      @hpBarEx.src_rect.width = 0
      @hpBarEx2.src_rect.width = 0
    end
  end

  def refresh_exp
    return if !@show_exp_bar
    w = exp_fraction * @expBarBitmap.width
    # NOTE: The line below snaps the bar's width to the nearest 2 pixels, to
    #       fit in with the rest of the graphics which are doubled in size.
    w = ((w / 2).round) * 2
    @expBar.src_rect.width = w
  end

  def update_hp_animation
    return if !animating_hp?
    @anim_hp_current = lerp(@anim_hp_start, @anim_hp_end, HP_BAR_CHANGE_TIME,
                            @anim_hp_timer_start, System.uptime)
    # Refresh the HP bar/numbers
    refresh_hp
    # End the HP bar filling animation
    if @anim_hp_current == @anim_hp_end
      @anim_hp_start = nil
      @anim_hp_end = nil
      @anim_hp_timer_start = nil
      @anim_hp_current = nil
    end
  end

  def update_exp_animation
    return if !animating_exp?
    if !@show_exp_bar   # Not showing the Exp bar, no need to waste time animating it
      @anim_exp_timer_start = nil
      return
    end
    duration = EXP_BAR_FILL_TIME * @anim_exp_duration_mult
    @anim_exp_current = lerp(@anim_exp_start, @anim_exp_end, duration,
                             @anim_exp_timer_start, System.uptime)
    # Refresh the Exp bar
    refresh_exp
    return if @anim_exp_current != @anim_exp_end   # Exp bar still has more to animate
    # End the Exp bar filling animation
    if @anim_exp_current >= @anim_exp_range
      if @anim_exp_flash_timer_start
        # Waiting for Exp full flash to finish
        return if System.uptime - @anim_exp_flash_timer_start < EXP_FULL_FLASH_DURATION
      else
        # Show the Exp full flash
        @anim_exp_flash_timer_start = System.uptime
        pbSEStop
        pbSEPlay("Pkmn exp full")
        flash_duration = EXP_FULL_FLASH_DURATION * Graphics.frame_rate   # Must be in frames, not seconds
        self.flash(Color.new(64, 200, 248, 192), flash_duration)
        @sprites.each do |i|
          i[1].flash(Color.new(64, 200, 248, 192), flash_duration) if !i[1].disposed?
        end
        return
      end
    end
    pbSEStop if !@anim_exp_flash_timer_start
    @anim_exp_start = nil
    @anim_exp_end = nil
    @anim_exp_duration_mult = nil
    @anim_exp_current = nil
    @anim_exp_timer_start = nil
    @anim_exp_flash_timer_start = nil
  end

  def refreshBossGauges
    return if @battler.index != 1 || @sideSize > 1

    x_offset = @spriteBaseX
    y_offset = 48

    base = Color.new(248,248,248)
    shadow = Color.new(15,15,15)

    for gauge in pbBoss.gauges
      next if !gauge.enabled

      imagepos = []
      textpos = []

      case gauge.type
      when PBGauge::Full
        imagepos.push(["Graphics/UI/Battle/boss_gauge.png",x_offset,y_offset,0,0,180,24])
        textpos.push([gauge.name,x_offset + 90,y_offset - 12,2,base,shadow])
      when PBGauge::Half
        imagepos.push(["Graphics/UI/Battle/boss_gauge.png",x_offset,y_offset,0,24,92,24])
        textpos.push([gauge.name,x_offset + 45,y_offset - 12,2,base,shadow])
      when PBGauge::Long
        imagepos.push(["Graphics/UI/Battle/boss_gauge.png",x_offset,y_offset,0,48,180,16])
        textpos.push([gauge.name,x_offset + 8,y_offset - 12,0,base,shadow])
      end
      pbDrawImagePositions(self.bitmap,imagepos)
      pbSetSmallestFont(self.bitmap)
      pbDrawTextPositions(self.bitmap,textpos)

      colors = gauge.get_colors

      case gauge.type
      when PBGauge::Full
        self.bitmap.fill_rect(
          x_offset+4,y_offset+16,
          172 * gauge.value / gauge.max, 6, colors[1])
        self.bitmap.fill_rect(
          x_offset+4,y_offset+18,
          172 * gauge.value / gauge.max, 2, colors[0])
        y_offset += 24
      when PBGauge::Half
        self.bitmap.fill_rect(
          x_offset+4,y_offset+16,
          84 * gauge.value / gauge.max, 6, colors[1])
        self.bitmap.fill_rect(
          x_offset+4,y_offset+18,
          84 * gauge.value / gauge.max, 2, colors[0])
        x_offset += 88
        if x_offset > @spriteBaseX + 88
          x_offset = @spriteBaseX
          y_offset += 24
        end
      when PBGauge::Long
        x_start = 12 + self.bitmap.text_size(gauge.name).width
        self.bitmap.fill_rect(x_offset+x_start,y_offset+2,178-x_start,12,shadow)
        self.bitmap.fill_rect(
          x_start+x_offset+2,y_offset+4,
          174-x_start, 8, Color.new(71,58,58))
        self.bitmap.fill_rect(
          x_start+x_offset+2,y_offset+6,
          174-x_start, 4, Color.new(61,50,50))
        self.bitmap.fill_rect(
          x_start+x_offset+2,y_offset+4,
          (174-x_start) * gauge.value / gauge.max, 8, colors[1])
        self.bitmap.fill_rect(
          x_start+x_offset+2,y_offset+6,
          (174-x_start) * gauge.value / gauge.max, 4, colors[0])
        y_offset += 14
      end
    end
  end

  QUARTER_ANIM_PERIOD = Graphics.frame_rate * 3 / 20

  def update_positions
    self.x = @spriteX
    self.y = @spriteY
    # Data box bobbing while Pokémon is selected
    if (@selected == 1 || @selected == 2) && BOBBING_DURATION   # Choosing commands/targeted
      bob_delta = System.uptime % BOBBING_DURATION   # 0-BOBBING_DURATION
      bob_frame = (4 * bob_delta / BOBBING_DURATION).floor
      case bob_frame
      when 1 then self.y = @spriteY - 2
      when 3 then self.y = @spriteY + 2
      end
    end
  end

  def update
    super
    # Animate HP bar
    update_hp_animation
    # Animate Exp bar
    update_exp_animation
    # Update coordinates of the data box
    update_positions
    pbUpdateSpriteHash(@sprites)
  end
end

#===============================================================================
# Splash bar to announce a triggered ability
#===============================================================================
class Battle::Scene::AbilitySplashBar < Sprite
  attr_reader :battler

  TEXT_BASE_COLOR   = Color.new(0, 0, 0)
  TEXT_SHADOW_COLOR = Color.new(248, 248, 248)

  def initialize(side, viewport = nil)
    super(viewport)
    @side    = side
    @battler = nil
    # Create sprite wrapper that displays background graphic
    @bgBitmap = AnimatedBitmap.new("Graphics/UI/Battle/ability_bar")
    @bgSprite = Sprite.new(viewport)
    @bgSprite.bitmap = @bgBitmap.bitmap
    @bgSprite.src_rect.y      = (side == 0) ? 0 : @bgBitmap.height / 2
    @bgSprite.src_rect.height = @bgBitmap.height / 2
    # Create bitmap that displays the text
    @contents = Bitmap.new(@bgBitmap.width, @bgBitmap.height / 2)
    self.bitmap = @contents
    pbSetSystemFont(self.bitmap)
    # Position the bar
    self.x       = (side == 0) ? -viewport.rect.width / 2 : viewport.rect.width
    self.y       = (side == 0) ? 180 : 80
    self.z       = 120
    self.visible = false
  end

  def dispose
    @bgSprite.dispose
    @bgBitmap.dispose
    @contents.dispose
    super
  end

  def x=(value)
    super
    @bgSprite.x = value
  end

  def y=(value)
    super
    @bgSprite.y = value
  end

  def z=(value)
    super
    @bgSprite.z = value - 1
  end

  def opacity=(value)
    super
    @bgSprite.opacity = value
  end

  def visible=(value)
    super
    @bgSprite.visible = value
  end

  def color=(value)
    super
    @bgSprite.color = value
  end

  def battler=(value)
    @battler = value
    refresh
  end

  def refresh
    self.bitmap.clear
    return if !@battler
    textPos = []
    textX = (@side == 0) ? 10 : self.bitmap.width - 8
    align = (@side == 0) ? :left : :right
    # Draw Pokémon's name
    textPos.push([_INTL("{1}'s", @battler.name), textX, 8, align,
                  TEXT_BASE_COLOR, TEXT_SHADOW_COLOR, :outline])
    # Draw Pokémon's ability
    textPos.push([@battler.abilityName, textX, 38, align,
                  TEXT_BASE_COLOR, TEXT_SHADOW_COLOR, :outline])
    pbDrawTextPositions(self.bitmap, textPos)
  end

  def update
    super
    @bgSprite.update
  end
end

#===============================================================================
# Pokémon sprite (used in battle)
#===============================================================================
class Battle::Scene::BattlerSprite < RPG::Sprite
  attr_reader   :pkmn
  attr_accessor :index
  attr_accessor :selected
  attr_reader   :sideSize

  # Time (in seconds) for one complete sprite bob cycle (up and down) while
  # choosing a command for this battler. Set to nil to prevent bobbing.
  COMMAND_BOBBING_DURATION = 0.6
  # Time (in seconds) for one complete blinking cycle while this battler is
  # being chosen as a target. Set to nil to prevent blinking.
  TARGET_BLINKING_DURATION = 0.3

  def initialize(viewport, sideSize, index, battleAnimations)
    super(viewport)
    @pkmn             = nil
    @sideSize         = sideSize
    @index            = index
    @battleAnimations = battleAnimations
    # @selected: 0 = not selected, 1 = choosing action bobbing for this Pokémon,
    #            2 = flashing when targeted
    @selected         = 0
    @updating         = false
    @spriteX          = 0   # Actual x coordinate
    @spriteY          = 0   # Actual y coordinate
    @spriteXExtra     = 0   # Offset due to "bobbing" animation
    @spriteYExtra     = 0   # Offset due to "bobbing" animation
    @critSplashSprite = IconSprite.new(0, 0, viewport)
    @critSplashSprite.setBitmap("Graphics/UI/Battle/splash_critical")
    @critSplashSprite.src_rect = Rect.new(0, 0, @critSplashSprite.bitmap.width, @critSplashSprite.bitmap.height / 2)
    @critSplashSprite.ox = @critSplashSprite.src_rect.width / 2
    @critSplashSprite.oy = @critSplashSprite.src_rect.height / 2
    @critSplashSprite.visible = false
    @weakSplashSprite = IconSprite.new(0, 0, viewport)
    @weakSplashSprite.setBitmap("Graphics/UI/Battle/splash_weakness")
    @weakSplashSprite.src_rect = Rect.new(0, 0, @weakSplashSprite.bitmap.width, @weakSplashSprite.bitmap.height / 19)
    @weakSplashSprite.ox = @weakSplashSprite.src_rect.width / 2
    @weakSplashSprite.oy = @weakSplashSprite.src_rect.height / 2
    @weakSplashSprite.visible = false
    @splashTimer      = 0
    @_iconBitmap      = nil
    self.visible      = false
  end

  def dispose
    @critSplashSprite.dispose
    @weakSplashSprite.dispose
    @_iconBitmap&.dispose
    @_iconBitmap = nil
    self.bitmap = nil if !self.disposed?
    super
  end

  def x; return @spriteX; end
  def y; return @spriteY; end

  def x=(value)
    @spriteX = value
    super(value + @spriteXExtra)
    @weakSplashSprite.x = @spriteX + @spriteXExtra
    @critSplashSprite.x = @spriteX + @spriteXExtra
  end

  def y=(value)
    @spriteY = value
    super(value + @spriteYExtra)
    @weakSplashSprite.y = @spriteY + @spriteYExtra - self.height / 2
    @critSplashSprite.y = @spriteY + @spriteYExtra - self.height / 2
  end

  def z=(value)
    super(value)
    @weakSplashSprite.z = value + 1
    @critSplashSprite.z = value + 1
  end

  def color=(value)
    super(value)
    @weakSplashSprite.color = value
    @critSplashSprite.color = value
  end

  def width;  return (self.bitmap) ? self.bitmap.width : 0;  end
  def height; return (self.bitmap) ? self.bitmap.height : 0; end

  def visible=(value)
    @spriteVisible = value if !@updating   # For selection/targeting flashing
    super
  end

  # Set sprite's origin to bottom middle
  def pbSetOrigin
    return if !@_iconBitmap
    self.ox = @_iconBitmap.width / 2
    self.oy = @_iconBitmap.height
  end

  def pbSetPosition
    return if !@_iconBitmap
    zoom = ((@index & 1  == 0) ? 1.5 : 1.0)
    self.zoom_x = zoom
    self.zoom_y = zoom
    pbSetOrigin
    if @index.even?
      self.z = 50 + (5 * @index / 2)
    else
      self.z = 50 - (5 * (@index + 1) / 2)
    end
    # Set original position
    p = Battle::Scene.pbBattlerPosition(@index, @sideSize)
    @spriteX = p[0]
    @spriteY = p[1]
    # Apply metrics
    @pkmn.species_data.apply_metrics_to_sprite(self, @index)
  end

  def setPokemonBitmap(pkmn, back = false)
    @pkmn = pkmn
    @_iconBitmap&.dispose
    @_iconBitmap = GameData::Species.sprite_bitmap_from_pokemon(@pkmn, back)
    self.bitmap = (@_iconBitmap) ? @_iconBitmap.bitmap : nil
    pbSetPosition
  end

  # This method plays the battle entrance animation of a Pokémon. By default
  # this is just playing the Pokémon's cry, but you can expand on it. The
  # recommendation is to create a PictureEx animation and push it into
  # the @battleAnimations array.
  def pbPlayIntroAnimation(pictureEx = nil)
    @pkmn&.play_cry
  end

  def update
    return if !@_iconBitmap
    @updating = true
    # Update bitmap
    @_iconBitmap.update
    self.bitmap = @_iconBitmap.bitmap
    # Pokémon sprite bobbing while Pokémon is selected
    @spriteYExtra = 0
    if @selected == 1 && COMMAND_BOBBING_DURATION    # When choosing commands for this Pokémon
      bob_delta = System.uptime % COMMAND_BOBBING_DURATION   # 0-COMMAND_BOBBING_DURATION
      bob_frame = (4 * bob_delta / COMMAND_BOBBING_DURATION).floor
      case bob_frame
      when 1 then @spriteYExtra = 2
      when 3 then @spriteYExtra = -2
      end
    end
    self.x       = self.x
    self.y       = self.y
    self.visible = @spriteVisible
    if @splashTimer > 0
      @splashTimer -= 1
      zoom = [1.0, 2.0 - (60 - @splashTimer) / 8.0].max
      zoom *= 1.5 if @index % 2 == 0
      @critSplashSprite.zoom_x = zoom
      @critSplashSprite.zoom_y = zoom
      @weakSplashSprite.zoom_x = zoom
      @weakSplashSprite.zoom_y = zoom
      if @splashTimer > 60 - 8
        @critSplashSprite.opacity += 32
        @weakSplashSprite.opacity += 32
      end
      if @splashTimer <= 32
        @critSplashSprite.opacity = 8 * @splashTimer
        @weakSplashSprite.opacity = 8 * @splashTimer
      end
      if @splashTimer == 0
        @critSplashSprite.visible = false
        @weakSplashSprite.visible = false
      end
    end
    # Pokémon sprite blinking when targeted
    if @selected == 2 && @spriteVisible && TARGET_BLINKING_DURATION
      blink_delta = System.uptime % TARGET_BLINKING_DURATION   # 0-TARGET_BLINKING_DURATION
      blink_frame = (3 * blink_delta / TARGET_BLINKING_DURATION).floor
      self.visible = (blink_frame != 0)
    end
    @updating = false
  end

  def pbWeaknessSplash(type)
    @splashTimer = 60
    @weakSplashSprite.visible = true
    @weakSplashSprite.opacity = 0
    @weakSplashSprite.src_rect.y = @weakSplashSprite.src_rect.height * GameData::Type.get(type).icon_position
  end

  def pbCriticalSplash(category)
    @splashTimer = 60
    @critSplashSprite.visible = true
    @critSplashSprite.opacity = 0
    @critSplashSprite.src_rect.y = @critSplashSprite.src_rect.height * category
  end
end

#===============================================================================
# Shadow sprite for Pokémon (used in battle)
#===============================================================================
class Battle::Scene::BattlerShadowSprite < RPG::Sprite
  attr_reader   :pkmn
  attr_accessor :index
  attr_accessor :selected

  def initialize(viewport, sideSize, index)
    super(viewport)
    @pkmn        = nil
    @sideSize    = sideSize
    @index       = index
    @_iconBitmap = nil
    self.visible = false
  end

  def dispose
    @_iconBitmap&.dispose
    @_iconBitmap = nil
    self.bitmap = nil if !self.disposed?
    super
  end

  def width;  return (self.bitmap) ? self.bitmap.width : 0;  end
  def height; return (self.bitmap) ? self.bitmap.height : 0; end

  # Set sprite's origin to centre
  def pbSetOrigin
    return if !@_iconBitmap
    self.ox = @_iconBitmap.width / 2
    self.oy = @_iconBitmap.height / 2
  end

  def pbSetPosition
    return if !@_iconBitmap
    pbSetOrigin
    self.z = 3
    # Set original position
    p = Battle::Scene.pbBattlerPosition(@index, @sideSize)
    self.x = p[0]
    self.y = p[1]
    # Apply metrics
    @pkmn.species_data.apply_metrics_to_sprite(self, @index, true)
  end

  def setPokemonBitmap(pkmn)
    @pkmn = pkmn
    @_iconBitmap&.dispose
    @_iconBitmap = GameData::Species.shadow_bitmap_from_pokemon(@pkmn, @index % 2 == 0)
    self.bitmap = (@_iconBitmap) ? @_iconBitmap.bitmap : nil
    pbSetPosition
  end

  def update
    return if !@_iconBitmap
    # Update bitmap
    @_iconBitmap.update
    self.bitmap = @_iconBitmap.bitmap
  end
end
