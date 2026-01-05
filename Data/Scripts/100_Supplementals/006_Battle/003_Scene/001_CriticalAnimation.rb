class CriticalSprite < BitmapSprite

  attr_accessor :type
  attr_accessor :opponent

  def initialize(user, viewport)
    super(512 * 3, 256, viewport)
    @simple = user.is_a?(Numeric)
    @type = @simple ? 1 : user.types[0]
    @opponent = @simple ? true : ((user.index % 2) == 1)
    @src_bitmap = RPG::Cache.load_bitmap("",
      _INTL("Graphics/UI/Battle/critical_{1}",type.to_s))
    self.x = -256
    self.y = viewport.rect.height / 2
    self.oy = 64
    self.zoom_y = 0.0
    @startTime = System.uptime
    refresh
    update
  end

  def update
    time = System.uptime - @startTime
    self.zoom_y = 1.0
    if time < 0.15
      self.zoom_y = [time * 7.5, 1].min
    end
    if time > 1.85
      self.zoom_y = [1 - (time - 1.85) * 7.5, 0].max
    end
    if @opponent
      self.x = -256 - time * 1024
      while self.x <= -512
        self.x += 256
      end
    else
      self.x = -256 + time * 1024
      while self.x >= 0
        self.x -= 256
      end
    end
  end

  def refresh
    for i in 0...3
      self.bitmap.blt(512 * i, 0, @src_bitmap, Rect.new(0, 0, @src_bitmap.width, @src_bitmap.height))
    end
  end

  def dispose
    @src_bitmap.dispose
    super
  end

end

class CriticalSpritePokemon < PokemonSprite

  attr_accessor :species
  attr_accessor :opponent
  attr_accessor :xframes

  def initialize(user, viewport)
    super(viewport)
    @simple = user.is_a?(Numeric)
    @species = @simple ? user : user.species
    @simple ? setSpeciesBitmap(@species) : setPokemonBitmap(user.pokemon)
    @opponent = @simple ? true : ((user.index % 2) == 1)
    pbSetDisplay(
      [
        @opponent ? Graphics.width : -self.bitmap.width,
        viewport.rect.height / 2,
        256,
        128,
      ],
      nil,
      false,
      true
    )
    self.mirror = !@opponent
    @initialX = self.x
    @startTime = System.uptime
    @timePassed = 0
    pbFrameUpdate
  end

  def pbFrameUpdate
    timePassedNow = (System.uptime - @startTime)
    factor = timePassedNow * 30
    if @opponent
      self.x = @initialX - (0.04 * factor**3 - 2.57 * factor**2 + 50 * factor)
    else
      self.x = @initialX + (0.04 * factor**3 - 2.57 * factor**2 + 50 * factor)
    end
    if @timePassed < 0.35 && timePassedNow >= 0.35
      GameData::Species.play_cry(@species, 100)
    end
    @timePassed = timePassedNow
    self.update
  end

  def dispose
    super
  end

end

class Battle::Scene

  def pbCriticalAnimation(user)
    @sprites["crit_bar"]=CriticalSprite.new(user, @viewport)
    @sprites["crit_bar"].z = 10000
    @sprites["crit_pkmn"]=CriticalSpritePokemon.new(user, @viewport)
    @sprites["crit_pkmn"].z = 10001

    pbSEPlay("Thunder3")
    startTime = System.uptime
    while System.uptime - startTime < 2
      pbGraphicsUpdate
      pbFrameUpdate
      Input.update
      @sprites["crit_bar"].update
      @sprites["crit_pkmn"].pbFrameUpdate
    end

    @sprites["crit_bar"].dispose
    @sprites["crit_pkmn"].dispose
    @sprites["crit_bar"] = nil
    @sprites["crit_pkmn"] = nil
  end

end 