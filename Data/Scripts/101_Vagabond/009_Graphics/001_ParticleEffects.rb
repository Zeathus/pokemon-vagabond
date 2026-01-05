__END__

# Remember to add new effects to @effects in ParticleEngine

# Particle Engine, Peter O., 2007-11-03
# Based on version 2 by Near Fantastica, 04.01.06
# In turn based on the Particle Engine designed by PinkMan
class Particle_Engine
  def initialize(viewport=nil,map=nil)
    @map       = (map) ? map : $game_map
    @viewport  = viewport
    @effect    = []
    @disposed  = false
    @firsttime = true
    @effects   = {
       # By Zeathus
       "darkportal"   => Particle_Engine::DarkPortal
    }
  end

  def dispose
    return if disposed?
    for particle in @effect
      next if particle.nil?
      particle.dispose
    end
    @effect.clear
    @map = nil
    @disposed = true
  end

  def disposed?
    return @disposed
  end

  def add_effect(event)
    @effect[event.id] = pbParticleEffect(event)
  end

  def remove_effect(event)
    return if @effect[event.id].nil?
    @effect[event.id].dispose
    @effect.delete_at(event.id)
  end

  def realloc_effect(event,particle)
    type = pbEventCommentInput(event, 1, "Particle Engine Type")
    if type.nil?
      particle.dispose if particle
      return nil
    end
    type = type[0].downcase
    cls = @effects[type]
    if cls.nil?
      particle.dispose if particle
      return nil
    end
    if !particle || !particle.is_a?(cls)
      particle.dispose if particle
      particle = cls.new(event,@viewport)
    end
    return particle
  end

  def pbParticleEffect(event)
    return realloc_effect(event,nil)
  end

  def update
    if @firsttime
      @firsttime = false
      for event in @map.events.values
        remove_effect(event)
        add_effect(event)
      end
    end
    for i in 0...@effect.length
      particle = @effect[i]
      next if particle.nil?
      if particle.event.pe_refresh
        event = particle.event
        event.pe_refresh = false
        particle = realloc_effect(event,particle)
        @effect[i] = particle
      end
      particle.update if particle
    end
  end
end

class ParticleEffect
  attr_accessor :x, :y, :z

  def initialize
    @x = 0
    @y = 0
    @z = 0
  end

  def update;  end
  def dispose; end
end



class ParticleSprite
  attr_accessor :x, :y, :z, :ox, :oy, :opacity, :blend_type
  attr_reader :bitmap

  def initialize(viewport)
    @viewport   = viewport
    @sprite     = nil
    @x          = 0
    @y          = 0
    @z          = 0
    @ox         = 0
    @oy         = 0
    @opacity    = 255
    @bitmap     = nil
    @blend_type = 0
    @minleft    = 0
    @mintop     = 0
  end

  def dispose
    @sprite.dispose if @sprite
  end

  def bitmap=(value)
    @bitmap = value
    if value
      @minleft = -value.width
      @mintop  = -value.height
    else
      @minleft = 0
      @mintop  = 0
    end
  end

  def update
    w = Graphics.width
    h = Graphics.height
    if !@sprite && @x>=@minleft && @y>=@mintop && @x<w && @y<h
      @sprite = Sprite.new(@viewport)
    elsif @sprite && (@x<@minleft || @y<@mintop || @x>=w || @y>=h)
      @sprite.dispose
      @sprite = nil
    end
    if @sprite
      @sprite.x          = @x if @sprite.x!=@x
      @sprite.x          -= @ox
      @sprite.y          = @y if @sprite.y!=@y
      @sprite.y          -= @oy
      @sprite.z          = @z if @sprite.z!=@z
      @sprite.opacity    = @opacity if @sprite.opacity!=@opacity
      @sprite.blend_type = @blend_type if @sprite.blend_type!=@blend_type
      @sprite.bitmap     = @bitmap if @sprite.bitmap!=@bitmap
    end
  end
end



class ParticleEffect_Event < ParticleEffect
  attr_accessor :event

  def initialize(event,viewport=nil)
    @event     = event
    @viewport  = viewport
    @particles = []
    @bitmaps   = {}
  end

  def setParameters(params)
    @randomhue,@leftright,@fade,
    @maxparticless,@hue,@slowdown,
    @ytop,@ybottom,@xleft,@xright,
    @xgravity,@ygravity,@xoffset,@yoffset,
    @opacityvar,@originalopacity = params
  end

  def loadBitmap(filename,hue)
    key = [filename,hue]
    bitmap = @bitmaps[key]
    if !bitmap || bitmap.disposed?
      bitmap = AnimatedBitmap.new("Graphics/Fogs/"+filename,hue).deanimate
      @bitmaps[key] = bitmap
    end
    return bitmap
  end

  def initParticles(filename,opacity,zOffset=0,blendtype=1)
    @particles = []
    @particlex = []
    @particley = []
    @opacity   = []
    @startingx = self.x + @xoffset
    @startingy = self.y + @yoffset
    @screen_x  = self.x
    @screen_y  = self.y
    @real_x    = @event.real_x
    @real_y    = @event.real_y
    @filename  = filename
    @zoffset   = zOffset
    @bmwidth   = 32
    @bmheight  = 32
    for i in 0...@maxparticless
      @particlex[i] = -@xoffset
      @particley[i] = -@yoffset
      @particles[i] = ParticleSprite.new(@viewport)
      @particles[i].bitmap = loadBitmap(filename, @hue) if filename
      if i==0 && @particles[i].bitmap
        @bmwidth  = @particles[i].bitmap.width
        @bmheight = @particles[i].bitmap.height
      end
      @particles[i].blend_type = blendtype
      @particles[i].y = @startingy
      @particles[i].x = @startingx
      @particles[i].z = self.z+zOffset
      @opacity[i] = rand(opacity/4)
      @particles[i].opacity = @opacity[i]
      @particles[i].update
    end
  end

  def x; return ScreenPosHelper.pbScreenX(@event); end
  def y; return ScreenPosHelper.pbScreenY(@event); end
  def z; return ScreenPosHelper.pbScreenZ(@event); end

  def update
    if @viewport &&
       (@viewport.rect.x >= Graphics.width ||
       @viewport.rect.y >= Graphics.height)
      return
    end
    selfX = self.x
    selfY = self.y
    selfZ = self.z
    newRealX = @event.real_x
    newRealY = @event.real_y
    @startingx = selfX + @xoffset
    @startingy = selfY + @yoffset
    @__offsetx = (@real_x==newRealX) ? 0 : selfX-@screen_x
    @__offsety = (@real_y==newRealY) ? 0 : selfY-@screen_y
    @screen_x = selfX
    @screen_y = selfY
    @real_x = newRealX
    @real_y = newRealY
    if @opacityvar>0 && @viewport
      opac = 255.0/@opacityvar
      minX = opac*(-@xgravity*1.0 / @slowdown).floor + @startingx
      maxX = opac*(@xgravity*1.0 / @slowdown).floor + @startingx
      minY = opac*(-@ygravity*1.0 / @slowdown).floor + @startingy
      maxY = @startingy
      minX -= @bmwidth
      minY -= @bmheight
      maxX += @bmwidth
      maxY += @bmheight
      if maxX<0 || maxY<0 || minX>=Graphics.width || minY>=Graphics.height
#        echo "skipped"
        return
      end
    end
    particleZ = selfZ+@zoffset
    for i in 0...@maxparticless
      @particles[i].z = particleZ
      if @particles[i].y <= @ytop
        @particles[i].y = @startingy + @yoffset
        @particles[i].x = @startingx + @xoffset
        @particlex[i] = 0.0
        @particley[i] = 0.0
      end
      if @particles[i].x <= @xleft
        @particles[i].y = @startingy + @yoffset
        @particles[i].x = @startingx + @xoffset
        @particlex[i] = 0.0
        @particley[i] = 0.0
      end
      if @particles[i].y >= @ybottom
        @particles[i].y = @startingy + @yoffset
        @particles[i].x = @startingx + @xoffset
        @particlex[i] = 0.0
        @particley[i] = 0.0
      end
      if @particles[i].x >= @xright
        @particles[i].y = @startingy + @yoffset
        @particles[i].x = @startingx + @xoffset
        @particlex[i] = 0.0
        @particley[i] = 0.0
      end
      if @fade == 0
        if @opacity[i] <= 0
          @opacity[i] = @originalopacity
          @particles[i].y = @startingy + @yoffset
          @particles[i].x = @startingx + @xoffset
          @particlex[i] = 0.0
          @particley[i] = 0.0
        end
      else
        if @opacity[i] <= 0
          @opacity[i] = 250
          @particles[i].y = @startingy + @yoffset
          @particles[i].x = @startingx + @xoffset
          @particlex[i] = 0.0
          @particley[i] = 0.0
        end
      end
      calcParticlePos(i)
      if @randomhue == 1
        @hue += 0.5
        @hue = 0 if @hue >= 360
        @particles[i].bitmap = loadBitmap(@filename, @hue) if @filename
      end
      @opacity[i] = @opacity[i] - rand(@opacityvar)
      @particles[i].opacity = @opacity[i]
      @particles[i].update
    end
  end

  def calcParticlePos(i)
    @leftright = rand(2)
    if @leftright == 1
      xo = -@xgravity*1.0 / @slowdown
    else
      xo = @xgravity*1.0 / @slowdown
    end
    yo = -@ygravity*1.0 / @slowdown
    @particlex[i] += xo
    @particley[i] += yo
    @particlex[i] -= @__offsetx
    @particley[i] -= @__offsety
    @particlex[i] = @particlex[i].floor
    @particley[i] = @particley[i].floor
    @particles[i].x = @particlex[i]+@startingx+@xoffset
    @particles[i].y = @particley[i]+@startingy+@yoffset
  end

  def dispose
    for particle in @particles
      particle.dispose
    end
    for bitmap in @bitmaps.values
      bitmap.dispose
    end
    @particles.clear
    @bitmaps.clear
  end
end

class Game_Event < Game_Character
  attr_accessor :pe_refresh

  alias nf_particles_game_map_initialize initialize
  def initialize(map_id,event,map=nil)
    @pe_refresh = false
    begin
      nf_particles_game_map_initialize(map_id, event, map)
    rescue ArgumentError
      nf_particles_game_map_initialize(map_id, event)
    end
  end

  alias nf_particles_game_map_refresh refresh
  def refresh
    nf_particles_game_map_refresh
    @pe_refresh = true
  end
end

class Particle_Engine::DarkPortal < ParticleEffect_Event
  def initialize(event,viewport)
    super
    setParameters([0,0,0,150,0,0.5,-64,
       Graphics.height,-64,Graphics.width,0.8,0.8,-5,-15,10,80])
    initParticles("darkportal",250,0,2)
    @lifetime = []
    @startangle = []
    for i in 0...@maxparticless
      @lifetime[i]=0.0-(i*0.1)
      @startangle[i]=Math::PI*(i%2)#rand(2)
    end
  end

  def calcParticlePos(i)
    @lifetime[i]+=10.0/150
    if @lifetime[i]>=10.0
      @lifetime[i]=-3.0
    end
    factor=@lifetime[i]
    radian=factor+@startangle[i]
    @particlex[i]=8*factor*Math.cos(radian)
    @particley[i]=7*factor*Math.sin(radian)
    @particlex[i]-=@__offsetx
    @particley[i]-=@__offsety
    @particlex[i]=@particlex[i].floor
    @particley[i]=@particley[i].floor
    @particles[i].x=@particlex[i]+@startingx+@xoffset
    @particles[i].y=@particley[i]+@startingy+@yoffset
    if @lifetime[i]>0
      @opacity[i]=255*(10.0-@lifetime[i])
      @particles[i].opacity=@opacity[i]
    else
      @opacity[i]=0
      @particles[i].opacity=@opacity[i]
    end
  end
end