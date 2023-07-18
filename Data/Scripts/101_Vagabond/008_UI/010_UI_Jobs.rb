#===============================================================================
#
#===============================================================================

class Window_Jobs < Window_DrawableCommand
  def initialize(items,x,y,width,height,viewport=nil)
    @items = items
    super(x, y, width, height, viewport)
    @selarrow=AnimatedBitmap.new("Graphics/Pictures/Trainer Card/cursor")
    @baseColor=Color.new(88,88,80)
    @shadowColor=Color.new(168,184,184)
    self.windowskin=nil
  end

  def itemCount
    return @items.length
  end

  def item
    return self.index >= @items.length ? 0 : @items[self.index]
  end

  def drawItem(index,count,rect)
    textpos=[]
    rect=drawCursor(index,rect)
    ypos=rect.y
    itemname=@items[index]
    if !["Trainer", "General Stats", "Battle Stats"].include?(itemname)
      itemname = pbJob(itemname).name
    end
    textpos.push([itemname,rect.x,ypos+2,false,self.baseColor,self.shadowColor])
    pbDrawTextPositions(self.contents,textpos)
  end
end


class PokemonJobs_Scene
  def pbStartScene
    @index = 0
    @debug_count = 0
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    addBackgroundPlane(@sprites,"bg","Trainer Card/bg",@viewport)
    cardexists = pbResolveBitmap(sprintf("Graphics/Pictures/Trainer Card/card_f"))
    @jobs = ["Trainer"]
    pbAllJobs.each do |job|
      @jobs.push(job) if pbHasJob(job)
    end
    @jobs.push("General Stats", "Battle Stats")
    @sprites["listbg"] = IconSprite.new(0,48,@viewport)
    @sprites["listbg"].setBitmap("Graphics/Pictures/Trainer Card/list")
    @sprites["itemlist"]=Window_Jobs.new(@jobs, -12, 54, 264, Graphics.height - 56)
    @sprites["itemlist"].viewport = @viewport
    @sprites["itemlist"].index = @index
    @sprites["itemlist"].baseColor = Color.new(252, 252, 252)
    @sprites["itemlist"].shadowColor = Color.new(0, 0, 0)
    @sprites["itemlist"].refresh
    spacing = 0
    for i in 0...([@jobs.length, 5].min)
      pos_y = 128 - spacing
      spacing += 48 - i * 12
      @sprites[_INTL("card_{1}", i)] = IconSprite.new(228,pos_y,@viewport)
      @sprites[_INTL("card_{1}", i)].z = 9 - i * 2
      @sprites[_INTL("overlay_{1}", i)] = BitmapSprite.new(512,384,@viewport)
      @sprites[_INTL("overlay_{1}", i)].x = 228
      @sprites[_INTL("overlay_{1}", i)].y = pos_y
      @sprites[_INTL("overlay_{1}", i)].z = 10 - i * 2
      pbSetSystemFont(@sprites[_INTL("overlay_{1}", i)].bitmap)
    end
    #@sprites["trainer"] = IconSprite.new(336+228,124+96,@viewport)
    #@sprites["trainer"].setBitmap(GameData::TrainerType.player_front_sprite_filename($player.trainer_type))
    #@sprites["trainer"].x -= (@sprites["trainer"].bitmap.width-128)/2
    #@sprites["trainer"].y -= (@sprites["trainer"].bitmap.height-128)
    #@sprites["trainer"].z = 2
    pbRefresh
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    if @index != @sprites["itemlist"].index
      @index = @sprites["itemlist"].index
      pbRefresh
    end
  end

  def pbRefresh
    for i in 0...([@jobs.length, 5].min)
      card = @sprites[_INTL("card_{1}", i)]
      overlay = (i > 1) ? nil : @sprites[_INTL("overlay_{1}", i)]
      job = @jobs[(@index+i) % @sprites["itemlist"].itemCount]
      case job
      when "Trainer"
        pbDrawTrainerCard(card, overlay)
      when "General Stats"
        pbDrawStats(card, overlay, "general")
      when "Battle Stats"
        pbDrawStats(card, overlay, "battle")
      else
        pbDrawJob(job, card, overlay)
      end
    end
  end

  def pbGetQuestProgress
    return [0, 0]
    count = $game_variables[QUEST_ARRAY].length
    complete = 0
    for i in 1..count
      if $game_variables[QUEST_ARRAY][i-1].status == 2
        complete += 1
      end
    end
    return [complete, count]
  end

  def pbDrawTrainerCard(card, overlay)
    if $player.female? && cardexists
      card.setBitmap("Graphics/Pictures/Trainer Card/card_f")
    else
      card.setBitmap("Graphics/Pictures/Trainer Card/card")
    end
    return if !overlay
    #@sprites["trainer"].visible=true
    overlay.bitmap.clear
    baseColor   = Color.new(72,72,72)
    shadowColor = Color.new(160,160,160)
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time = (hour>0) ? _INTL("{1}h {2}m",hour,min) : _INTL("{1}m",min)
    $PokemonGlobal.startTime = pbGetTimeNow if !$PokemonGlobal.startTime
    starttime = _INTL("{1} {2}, {3}",
       pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
       $PokemonGlobal.startTime.day,
       $PokemonGlobal.startTime.year)
    textPositions = [
       [_INTL("Name"),34,70,0,baseColor,shadowColor],
       [$player.name,302,70,1,baseColor,shadowColor],
       [_INTL("ID No."),332,70,0,baseColor,shadowColor],
       [sprintf("%05d",$player.public_ID),468,70,1,baseColor,shadowColor],
       [_INTL("Money"),34,118,0,baseColor,shadowColor],
       [_INTL("${1}",$player.money.to_s_formatted),302,118,1,baseColor,shadowColor],
       [_INTL("Pokédex"),34,166,0,baseColor,shadowColor],
       [sprintf("%d/%d",$player.pokedex.owned_count,$player.pokedex.seen_count),302,166,1,baseColor,shadowColor],
       [_INTL("Time"),34,214,0,baseColor,shadowColor],
       [time,302,214,1,baseColor,shadowColor],
       [_INTL("Started"),34,262,0,baseColor,shadowColor],
       [starttime,302,262,1,baseColor,shadowColor]
    ]
    pbDrawTextPositions(overlay.bitmap,textPositions)
    x = 42
    region = pbGetCurrentRegion(0) # Get the current region
    imagePositions = []
    for i in $player.badges
      imagePositions.push(["Graphics/Pictures/Trainer Card/icon_badges",x,310,i*32,region*32,32,32])
      x += 44
    end
    pbDrawImagePositions(overlay.bitmap,imagePositions)
  end

  def pbDrawStats(card, overlay, section="general")
    card.setBitmap("Graphics/Pictures/Trainer Card/card_2")
    return if !overlay
    #@sprites["trainer"].visible=false
    overlay.bitmap.clear
    baseColor=Color.new(72,72,72)
    shadowColor=Color.new(160,160,160)
    quest = pbGetQuestProgress
    stats = []
    case section
    when "general"
      stats = [
        ["Heals at Poké Centers", $stats.poke_center_count],
        ["Times Evolved", $stats.evolution_count],
        ["Eggs Hatched", $stats.eggs_hatched],
        ["Berries Picked", $stats.berry_plants_picked],
        ["$ Spent at Marts", $stats.money_spent_at_marts],
        ["$ Earned at Marts", $stats.money_earned_at_marts],
        ["Distance Walked", $stats.distance_walked],
        ["Distance Surfed", $stats.distance_surfed]
      ]
    when "battle"
      stats = [
        ["Affinity Boosts", $stats.affinity_boosts || 0],
        ["Trainer Battles Won", $stats.trainer_battles_won],
        ["Trainer Battles Lost", $stats.trainer_battles_lost],
        ["Wild Battles Won", $stats.wild_battles_won],
        ["Wild Battles Lost", $stats.wild_battles_lost],
        ["Total Exp. Gained", $stats.total_exp_gained],
        ["Prize Money Earned", $stats.battle_money_gained],
        ["Times Blacked Out", $stats.blacked_out_count]
      ]
    end
    textPositions = []
    for i in 0...stats.length
      textPositions.push([stats[i][0],84,88 + i * 32,0,baseColor,shadowColor])
      textPositions.push([_INTL("{1}", stats[i][1]),422,88 + i * 32,1,baseColor,shadowColor])
    end
    pbDrawTextPositions(overlay.bitmap,textPositions)
    return
    textPositions=[
       [_INTL("Trainer Battles"),84,88,0,baseColor,shadowColor],
       [_INTL("{1}",$stats.trainer_battles_won + $stats.trainer_battles_lost),422,88,1,baseColor,shadowColor],
       [_INTL("Wins vs. Trainers"),84,120,0,baseColor,shadowColor],
       [_INTL("{1}",$stats.trainer_battles_won),422,120,1,baseColor,shadowColor],
       [_INTL("Wild Encounters"),84,152,0,baseColor,shadowColor],
       [_INTL("{1}",$stats.wild_battles_won + $stats.wild_battles_lost),422,152,1,baseColor,shadowColor],
       [_INTL("Total Exp. Gained"),84,184,0,baseColor,shadowColor],
       [_INTL("{1}",$stats.total_exp_gained),422,184,1,baseColor,shadowColor],
       [_INTL("Eggs Hatched"),84,216,0,baseColor,shadowColor],
       [_INTL("{1}",$stats.eggs_hatched),422,216,1,baseColor,shadowColor],
       [_INTL("Steps Taken"),84,248,0,baseColor,shadowColor],
       [_INTL("{1}",$stats.distance_walked),422,248,1,baseColor,shadowColor],
       [_INTL("Prize Money Earned"),84,280,0,baseColor,shadowColor],
       [_INTL("${1}",$stats.battle_money_gained),422,280,1,baseColor,shadowColor],
       [_INTL("Money Spent"),84,312,0,baseColor,shadowColor],
       [_INTL("${1}",$stats.money_spent_at_marts),422,312,1,baseColor,shadowColor]
    ]
    pbDrawTextPositions(overlay.bitmap,textPositions)
  end

  def pbDrawJob(name, card, overlay)
    job = pbJob(name)
    card.setBitmap(_INTL("Graphics/Pictures/Trainer Card/{1}", job.card_file))
    return if !overlay
    overlay.bitmap.clear
    baseColor    = Color.new(72,72,72)
    shadowColor  = Color.new(160,160,160)
    baseColor2   = Color.new(252,252,252)
    skills = []
    for r in job.rewards
      skills.push(r)
    end
    if job.level < 4
      for i in (job.level + 1)...5
        skills[i] = "???"
      end
    end
    if job.progress > 0
      bar_width = (192 * [job.progress, job.requirement].min / job.requirement) * 2
      overlay.bitmap.fill_rect(64, 312, bar_width, 2, Color.new(0, 144, 0))
      overlay.bitmap.fill_rect(64, 314, bar_width, 24, Color.new(24, 192, 32))
      overlay.bitmap.fill_rect(64, 338, bar_width, 2, Color.new(0, 144, 0))
    end
    textPositions = [
       [job.teacher_title,34,70,0,baseColor,shadowColor],
       [job.teacher,302,70,1,baseColor,shadowColor],
       [job.location,332,70,0,baseColor,shadowColor],
       [job.progress_text,254,314,2,baseColor2,shadowColor,true]
    ]
    for i in 0...skills.length
      textPositions.push([
        skills[i],74,118 + 36*i,0,(job.level <= i) ? baseColor : baseColor2,shadowColor
      ])
    end
    pbDrawTextPositions(overlay.bitmap,textPositions)
    y = 110
    imagePositions = []
    for i in 0...job.level
      imagePositions.push(["Graphics/Pictures/Trainer Card/star",30,y,0,0,32,32])
      y += 36
    end
    pbDrawImagePositions(overlay.bitmap,imagePositions)
  end

  def pbJobsScreen
    pbSEPlay("GUI trainer card open")
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::C)

      elsif Input.trigger?(Input::BACK)
        if @debug_count == 8
          if !$DEBUG
            $DEBUG = true
            Kernel.pbMessage("DEBUG MODE ACTIVATED")
          else
            $DEBUG = false
            Kernel.pbMessage("debug mode deactivated")
          end
        end
        pbPlayCloseMenuSE
        break
      end
      if Input.trigger?(Input::LEFT)
        if @debug_count == 0
          @debug_count = 1
        else
          @debug_count = 0
        end
      end
      if Input.trigger?(Input::UP)
        if @debug_count == 1
          @debug_count = 2
        elsif @debug_count == 4
          @debug_count = 5
        elsif @debug_count == 6
          @debug_count = 7
        else
          @debug_count = 0
        end
      end
      if Input.trigger?(Input::RIGHT)
        if @debug_count == 2
          @debug_count = 3
        else
          @debug_count = 0
        end
      end
      if Input.trigger?(Input::DOWN)
        if @debug_count == 3
          @debug_count = 4
        elsif @debug_count == 5
          @debug_count = 6
        elsif @debug_count == 7
          @debug_count = 8
        else
          @debug_count = 0
        end
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonJobsScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbJobsScreen
    @scene.pbEndScene
  end
end