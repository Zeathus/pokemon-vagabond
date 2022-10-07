# Remember to add new effects to @effects in ParticleEngine

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