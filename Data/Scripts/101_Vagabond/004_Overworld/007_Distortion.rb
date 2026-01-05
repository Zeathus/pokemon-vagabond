DISTORTION_MAP_IDS = [26, 149, 155, 156, 157, 158, 159, 240, 242, 243, 270, 280]

class UnravelSprite < Sprite
  attr_accessor :ax
  attr_accessor :ay
  attr_reader :time

  def initialize(viewport, x, y, ax, ay)
    super(viewport)
    @time = -1
    @initial_x = x
    @initial_y = y
    self.x = x
    self.y = y
    # Position in sprite array
    @ax = ax
    @ay = ay
    @@current_z = 99999
  end

  def start
    return if @time != -1
    @time = 0
    self.z = @@current_z
    @@current_z -= 1
  end

  def finished
    return @time >= 0 && (
      self.x < 32 ||
      self.y < 32 ||
      self.x > Graphics.width + 32 ||
      self.y > Graphics.height + 32
    )
  end

  def update
    super
    if @time >= 0
      @time += 0.5
      if self.x < Graphics.width / 2
        self.x -= (@time / 2 + @time * (@initial_x - Graphics.width / 2).abs / (Graphics.width / 2)).floor
      elsif self.x > Graphics.width / 2
        self.x += (@time / 2 + @time * (@initial_x - Graphics.width / 2).abs / (Graphics.width / 2)).floor
      end
      self.y += (@time * 2 * (@initial_y.to_f / Graphics.height)).floor
      self.y -= (@time * (1.5 - @initial_y.to_f / Graphics.height) / 3).floor**2
    end
  end

end

def pbWorldHop(new_map_id, new_x, new_y, nekane = true)
  pbBGMFade(3.0)

  pbUpdateSceneMap

  pbNekanePortalAnimation if nekane

  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999

  world_bitmap = Graphics.snap_to_bitmap

  $game_player.opacity = 255

  Graphics.update
  Input.update

  segments = 48

  sprites = []
  for y in 0...segments
    row = []
    for x in 0...segments
      sprite = UnravelSprite.new(
        viewport,
        x * (Graphics.width / segments) + (Graphics.width / segments) / 2,
        y * (Graphics.height / segments) + (Graphics.height / segments) / 2,
        x, y
      )
      sprite.ox = (Graphics.width / segments) / 2
      sprite.oy = (Graphics.height / segments) / 2
      sprite.bitmap = world_bitmap
      sprite.src_rect = Rect.new(
        x * (Graphics.width / segments),
        y * (Graphics.height / segments),
        Graphics.width / segments,
        Graphics.height / segments
      )
      row.push(sprite)
    end
    sprites.push(row)
  end

  # Do the map transfer
  $game_temp.player_new_map_id    = new_map_id
  $game_temp.player_new_x         = new_x
  $game_temp.player_new_y         = new_y
  $game_temp.player_new_direction = $game_player.direction
  pbDismountBike
  $scene.transfer_player(true, false)
  $game_map.refresh

  Graphics.update
  Input.update

  max_distance = 0.0

  pbSEPlay("fog2", 100, 50)

  360.times do |i|
    max_distance += 0.10 + i * 0.001
    finished = true
    sprites.each do |r|
      r.each do |s|
        s.update
        finished = false if finished && !s.finished
        next if s.time >= 0
        distance_sq = (s.ax - segments / 2)**2 + (s.ay - segments / 2)**2
        if max_distance**2 >= distance_sq
          s.start
        elsif (max_distance + 3)**2 >= distance_sq
          if rand((distance_sq - max_distance**2).floor) == 0
            s.start
          end
        end
      end
    end
    pbSEPlay("fog2", 100, 60) if i == 40
    pbSEPlay("fog2", 100, 70) if i == 80
    Graphics.update
    Input.update
    viewport.update
    pbUpdateSceneMap
    break if finished
  end

  $game_map.autoplay

  sprites.each do |r|
    r.each do |s|
      s.dispose
    end
  end
  world_bitmap.dispose
end

#===============================================================================
# Hidden move animation
#===============================================================================
def pbNekanePortalAnimation
  viewport = Viewport.new(0, 0, Graphics.width, 0)
  viewport.z = 99999
  # Set up sprites
  bg = Sprite.new(viewport)
  bg.bitmap = RPG::Cache.ui("Field move/bg")
  sprite = IconSprite.new(0, 0, viewport)
  sprite.setBitmap("Graphics/UI/Field move/nekane_move")
  sprite.ox = sprite.bitmap.width / 2
  sprite.oy = sprite.bitmap.height / 2
  sprite.x = Graphics.width + (sprite.bitmap.width / 2)
  sprite.y = bg.bitmap.height / 2
  sprite.z = 1
  sprite.visible = false
  strobebitmap = AnimatedBitmap.new("Graphics/UI/Field move/strobes")
  strobes = []
  strobes_start_x = []
  strobes_timers = []
  15.times do |i|
    strobe = BitmapSprite.new(52, 16, viewport)
    strobe.bitmap.blt(0, 0, strobebitmap.bitmap, Rect.new(0, (i % 2) * 16, 52, 16))
    strobe.z = (i.even? ? 2 : 0)
    strobe.visible = false
    strobes.push(strobe)
  end
  strobebitmap.dispose
  # Do the animation
  pbSEPlay("Harden")
  phase = 1
  timer_start = System.uptime
  loop do
    Graphics.update
    Input.update
    sprite.update
    case phase
    when 1   # Expand viewport height from zero to full
      viewport.rect.y = lerp(Graphics.height / 2, (Graphics.height - bg.bitmap.height) / 2,
                             0.2, timer_start, System.uptime)
      viewport.rect.height = Graphics.height - (viewport.rect.y * 2)
      bg.oy = (bg.bitmap.height - viewport.rect.height) / 2
      if viewport.rect.y == (Graphics.height - bg.bitmap.height) / 2
        phase = 2
        sprite.visible = true
        timer_start = System.uptime
      end
    when 2   # Slide Pokémon sprite in from right to centre
      sprite.x = lerp(Graphics.width + (sprite.bitmap.width / 2), Graphics.width / 2,
                      0.2, timer_start, System.uptime)
      if sprite.x == Graphics.width / 2
        phase = 3
        timer_start = System.uptime
      end
    when 3   # Wait
      if System.uptime - timer_start >= 1.5
        phase = 4
        timer_start = System.uptime
      end
    when 4   # Slide Pokémon sprite off from centre to left
      sprite.x = lerp(Graphics.width / 2, -(sprite.bitmap.width / 2),
                      0.2, timer_start, System.uptime)
      if sprite.x == -(sprite.bitmap.width / 2)
        phase = 5
        sprite.visible = false
        timer_start = System.uptime
      end
    when 5   # Shrink viewport height from full to zero
      viewport.rect.y = lerp((Graphics.height - bg.bitmap.height) / 2, Graphics.height / 2,
                             0.2, timer_start, System.uptime)
      viewport.rect.height = Graphics.height - (viewport.rect.y * 2)
      bg.oy = (bg.bitmap.height - viewport.rect.height) / 2
      phase = 6 if viewport.rect.y == Graphics.height / 2
    end
    # Constantly stream the strobes across the screen
    strobes.each_with_index do |strobe, i|
      strobe.ox = strobe.viewport.rect.x
      strobe.oy = strobe.viewport.rect.y
      if !strobe.visible   # Initial placement of strobes
        randomY = 16 * (1 + rand((bg.bitmap.height / 16) - 2))
        strobe.y = randomY + ((Graphics.height - bg.bitmap.height) / 2)
        strobe.x = rand(Graphics.width)
        strobe.visible = true
        strobes_start_x[i] = strobe.x
        strobes_timers[i] = System.uptime
      elsif strobe.x < Graphics.width   # Move strobe right
        strobe.x = strobes_start_x[i] + lerp(0, Graphics.width * 2, 0.8, strobes_timers[i], System.uptime)
      else   # Strobe is off the screen, reposition it to the left of the screen
        randomY = 16 * (1 + rand((bg.bitmap.height / 16) - 2))
        strobe.y = randomY + ((Graphics.height - bg.bitmap.height) / 2)
        strobe.x = -strobe.bitmap.width - rand(Graphics.width / 4)
        strobes_start_x[i] = strobe.x
        strobes_timers[i] = System.uptime
      end
    end
    pbUpdateSceneMap
    break if phase == 6
  end
  sprite.dispose
  strobes.each { |strobe| strobe.dispose }
  strobes.clear
  bg.dispose
  viewport.dispose
  return true
end

def pbDisJumpManual(move_x, move_y)
  target = [$game_player.x + move_x, $game_player.y + move_y]
  $game_player.through = true
  pbSEPlay("Player jump", 100, 50)
  $game_player.jump(target[0] - $game_player.x, target[1] - $game_player.y)
  $game_player.sprite.pbHideShadow
  pbWait(0.1)
  $game_player.through = false

  while $game_player.jumping?
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end

  $game_player.sprite.pbShowShadow
end

def pbDisJump(move_x = nil, move_y = nil)
  if move_x && move_y
    pbDisJumpManual(move_x, move_y)
    return
  end
  target = [$game_player.x, $game_player.y]
  case $game_player.direction
  when 2
    target[1] += 3
  when 4
    target[0] -= 3
  when 6
    target[0] += 3
  when 8
    target[1] -= 3
  end
  if $game_map.stairs?($game_player.x, $game_player.y)
    # Currently sideways
    if $game_map.stairs?(target[0], target[1])
      # Staying sideways
      $game_player.through = true
      pbSEPlay("Player jump", 100, 50)
      $game_player.jump(target[0] - $game_player.x, target[1] - $game_player.y)
      $game_player.sprite.pbHideShadow
      pbWait(0.1)
      $game_player.through = false
    elsif !$game_map.stairs?(target[0], target[1] + 1)
      # Going to upright
      target[1] += 1
      $game_player.through = true
      pbSEPlay("Player jump", 100, 50)
      $game_player.jump(target[0] - $game_player.x, target[1] - $game_player.y)
      $game_player.sprite.pbHideShadow
      pbWait(0.1)
      $game_variables[PLAYER_ROTATION] = 0
      $game_player.through = false
    end
  else
    # Currently upright
    if $game_map.stairs?(target[0], target[1] - 1)
      # Going to sideways
      target[1] -= 1
      $game_player.through = true
      pbSEPlay("Player jump", 100, 50)
      $game_player.jump(target[0] - $game_player.x, target[1] - $game_player.y)
      $game_player.sprite.pbHideShadow
      pbWait(0.1)
      if $game_map.stairsLeft?(target[0], target[1])
        $game_variables[PLAYER_ROTATION] = -45
      elsif $game_map.stairsRight?(target[0], target[1])
        $game_variables[PLAYER_ROTATION] = 45
      end
      $game_player.through = false
    else
      # Staying upright
      if $game_map.passable?(target[0], target[1], 0, $game_player)
        $game_player.through = true
        pbSEPlay("Player jump", 100, 50)
        $game_player.jump(target[0] - $game_player.x, target[1] - $game_player.y)
        $game_player.sprite.pbHideShadow
        pbWait(0.1)
        $game_player.through = false
      end
    end
  end
  while $game_player.jumping?
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
  $game_player.sprite.pbShowShadow
end

def pbRideDisPlatform(event_id = nil, max_distance = nil, direction = nil)
  direction = $game_player.direction if !direction
  # Check if there is a platform to jump onto
  if event_id.nil?
    ex = $game_player.x - 1
    ey = $game_player.y + 3
    case direction
    when 2
      ey += 3
    when 4
      ex -= 3
    when 6
      ex += 3
    when 8
      ey -= 3
    end
    event = nil
    $game_map.events.values.each do |e|
      if e.x == ex && e.y == ey && e.name[/Platform/]
        event = e
        break
      end
    end
    return false if event.nil?
  else
    event = get_character(event_id)
  end
  # Jump to the platform
  case direction
  when 2
    pbDisJump(0, 3)
  when 4
    pbDisJump(-3, 0)
  when 6
    pbDisJump(3, 0)
  when 8
    pbDisJump(0, -3)
  end
  if max_distance.nil?
    max_distance = 0
    while true
      nx = event.x + 1
      ny = event.y - 3
      case direction
      when 2
        ny += 3 + max_distance
      when 4
        nx -= 3 + max_distance
      when 6
        nx += 3 + max_distance
      when 8
        ny -= 3 + max_distance
      end
      if ($game_map.data[nx, ny, 0] != 0 ||
          $game_map.data[nx, ny, 1] != 0 ||
          $game_map.data[nx, ny, 2] != 0) &&
         $game_map.passable?(nx, ny, 0)
        break
      end
      max_distance += 1
      break if max_distance > 99
    end
  end
  $game_player.through = true
  event.through = true
  moved = false
  max_distance.times do |i|
    can_move = true
    $game_map.events.values.each do |e|
      if e.name[/Platform/]
        if (direction == 2 && event.x == e.x && event.y == e.y - 3) ||
           (direction == 4 && event.x == e.x + 3 && event.y == e.y) ||
           (direction == 6 && event.x == e.x - 3 && event.y == e.y) ||
           (direction == 8 && event.x == e.x && event.y == e.y + 3)
          can_move = false
          break
        end
      elsif e.name[/Floating Rock/]
        if (direction == 2 && event.x + 1 == e.x && event.y == e.y - 3) ||
           (direction == 4 && event.x + 1 == e.x + 3 && event.y == e.y) ||
           (direction == 6 && event.x + 1 == e.x - 3 && event.y == e.y) ||
           (direction == 8 && event.x + 1 == e.x && event.y == e.y + 3)
          can_move = false
          break
        end
      end
    end
    break if !can_move
    if i == 0
      pbSEPlay("Fire2", 100, 90)
      $game_screen.start_shake(3, 3, 16)
      pbWait(1)
      pbSet(FORCED_MOVE_TYPE, :walking)
      moved = true
    end
    begin
      $game_player.sprite.partner.visibility = false
    rescue
      # Nothing, here just in case
    end
    case direction
    when 2
      pbMoveRoute($game_player,
                  [PBMoveRoute::CHANGE_SPEED, 4,
                   PBMoveRoute::WALK_ANIME_OFF,
                   PBMoveRoute::DOWN,
                   PBMoveRoute::WALK_ANIME_ON])
      event.move_down
    when 4
      pbMoveRoute($game_player,
                  [PBMoveRoute::CHANGE_SPEED, 4,
                   PBMoveRoute::WALK_ANIME_OFF,
                   PBMoveRoute::LEFT,
                   PBMoveRoute::WALK_ANIME_ON])
      event.move_left
    when 6
      pbMoveRoute($game_player,
                  [PBMoveRoute::CHANGE_SPEED, 4,
                   PBMoveRoute::WALK_ANIME_OFF,
                   PBMoveRoute::RIGHT,
                   PBMoveRoute::WALK_ANIME_ON])
      event.move_right
    when 8
      pbMoveRoute($game_player,
                  [PBMoveRoute::CHANGE_SPEED, 4,
                   PBMoveRoute::WALK_ANIME_OFF,
                   PBMoveRoute::UP,
                   PBMoveRoute::WALK_ANIME_ON])
      event.move_up
    end
    pbWait(0.1)
    while $game_player.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  event.through = false
  $game_player.through = false
  if moved
    pbSEPlay("Fire2", 100, 80)
    pbSet(FORCED_MOVE_TYPE, 0)
    $game_screen.start_shake(3, 3, 16)
    pbWait(0.8)
  end
  begin
    $game_player.sprite.snapPartner(false)
    $game_player.sprite.partner.visibility = true
  rescue
    # Nothing, here just in case
  end
  return true
end

def pbLeaveDisPlatform(event)
  return false if !$game_player.at?(event.x + 1, event.y - 3)
  if pbRideDisPlatform
    event.through = true
    return false
  end
  direction = $game_player.direction
  nx = $game_player.x
  ny = $game_player.y
  case direction
  when 2
    ny += 3
  when 4
    nx -= 3
  when 6
    nx += 3
  when 8
    ny -= 3
  end
  if ($game_map.data[nx, ny, 0] == 0 &&
      $game_map.data[nx, ny, 1] == 0 &&
      $game_map.data[nx, ny, 2] == 0) ||
      !$game_map.passable?(nx, ny, 0)
    return false
  end
  $game_map.events.values.each do |e|
    if e.x == nx && e.y == ny && !e.through
      return false
    end
  end
  # Jump to the platform
  case direction
  when 2
    pbDisJump(0, 3)
  when 4
    pbDisJump(-3, 0)
  when 6
    pbDisJump(3, 0)
  when 8
    pbDisJump(0, -3)
  end
  event.through = true
  return true
end

def pbDistortionElevator(direction, new_map_id, new_x, new_y, duration = 8, fade_bgm = false)
  # pbWait(0.1)

  viewport = Spriteset_Map.viewport

  start_time = System.uptime
  pbSEPlay("Fire2", 100, 90)
  $game_screen.start_shake(2, 5, 20)

  # Prepare the map graphics
  current_map = Sprite.new(viewport)
  current_map.bitmap = CarubanMapExporter.getBitmap(
    $game_map.map_id, {:map_events => true, :prevent_lag => true}, viewport
  )
  current_map.x = Graphics.width / 2
  current_map.y = Graphics.height / 2
  current_map.ox = $game_player.x * 32 + 16
  current_map.oy = $game_player.y * 32 + 16
  new_map = $scene.spriteset.backdrop.steal_map
  if new_map.nil?
    new_map = Sprite.new(viewport)
    new_map.bitmap = CarubanMapExporter.getBitmap(
      new_map_id, {:map_events => true, :prevent_lag => true}, viewport
    )
    new_map.z = -99999
  end
  new_map.x = Graphics.width / 2
  new_map.y = Graphics.height / 2
  new_map.ox = new_x * 32 + 16
  new_map.oy = new_y * 32 + 16
  case direction
  when :down
    new_map.zoom_x = 0.5
    new_map.zoom_y = 0.5
    new_map.tone = Tone.new(-32, -32, -32)
    new_map.opacity = 192
    new_map.y = Graphics.height / 2 + 256
    current_map.z = 999
  when :up
    new_map.zoom_x = 3.0
    new_map.zoom_y = 3.0
    new_map.opacity = 0
    new_map.y = Graphics.height / 2 - 1024
    new_map.z = 999
    current_map.z = -999
  when :right
    duration /= 2
    new_map.x = Graphics.width / 2 + 1080
  when :left
    duration /= 2
    new_map.x = Graphics.width / 2 - 1080
  when :north
    duration /= 2
    new_map.y = Graphics.height / 2 - 1080
  when :south
    duration /= 2
    new_map.y = Graphics.height / 2 + 1080
  end

  while System.uptime - start_time < 1.5
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end

  pbBGMFade(3) if fade_bgm

  pbSEPlay("Fire1", 100, 75)

  # Do the temp map transfer
  $game_temp.player_new_map_id    = 270
  $game_temp.player_new_x         = 10
  $game_temp.player_new_y         = 7
  $game_temp.player_new_direction = $game_player.direction
  pbDismountBike
  $scene.transfer_player(true, false)
  $game_map.refresh

  # Animate moving
  start_time = System.uptime
  time_now = start_time
  while time_now - start_time < duration
    case direction
    when :down
      progress = ((time_now - start_time) / duration)**2
      current_map.zoom_x = 1.0 + 2.0 * progress
      current_map.zoom_y = current_map.zoom_x
      current_map.opacity = [255 - 255 * progress * 2, 0].max
      current_map.y = Graphics.height / 2 - 1024 * progress
      new_map.zoom_x = 0.5 + 0.5 * progress
      new_map.zoom_y = new_map.zoom_x
      new_map.opacity = 192 + 64 * progress
      tone = -32 + 32 * progress
      new_map.tone = Tone.new(tone, tone, tone)
      new_map.y = Graphics.height / 2 + 256 - 256 * progress
    when :up
      progress = (1 - ((time_now - start_time) / duration))**2
      new_map.zoom_x = 1.0 + 2.0 * progress
      new_map.zoom_y = new_map.zoom_x
      new_map.opacity = [255 - 255 * progress * 2, 0].max
      new_map.y = Graphics.height / 2 - 1024 * progress
      current_map.zoom_x = 0.5 + 0.5 * progress
      current_map.zoom_y = current_map.zoom_x
      current_map.opacity = 192 + 64 * progress
      tone = -32 + 32 * progress
      current_map.tone = Tone.new(tone, tone, tone)
      current_map.y = Graphics.height / 2 + 256 - 256 * progress
    when :right
      progress = (time_now - start_time) / duration
      current_map.x = Graphics.width / 2 - 1080 * progress
      new_map.x = Graphics.width / 2 + 1080 - 1080 * progress
    when :left
      progress = (time_now - start_time) / duration
      current_map.x = Graphics.width / 2 + 1080 * progress
      new_map.x = Graphics.width / 2 - 1080 + 1080 * progress
    when :north
      progress = (time_now - start_time) / duration
      current_map.y = Graphics.height / 2 + 1080 * progress
      new_map.y = Graphics.height / 2 - 1080 + 1080 * progress
    when :south
      progress = (time_now - start_time) / duration
      current_map.y = Graphics.height / 2 - 1080 * progress
      new_map.y = Graphics.height / 2 + 1080 - 1080 * progress
    end
    Graphics.update
    Input.update
    pbUpdateSceneMap
    time_now = System.uptime
  end

  # Do the final map transfer
  $game_temp.player_new_map_id    = new_map_id
  $game_temp.player_new_x         = new_x
  $game_temp.player_new_y         = new_y
  $game_temp.player_new_direction = $game_player.direction
  pbDismountBike
  $scene.transfer_player(true, false)
  $game_map.refresh
  $game_map.autoplay

  current_map.dispose
  new_map.dispose

  pbSEPlay("Fire2", 100, 80)
  $game_screen.start_shake(2, 5, 20)
  pbWait(1)
end

class DistortionWorldBackdrop < IconSprite

  @@radiuses = [0, 70, 112, 180, 260]
  @@start_angles = []
  for i in 0...5
    @@start_angles[i] = rand(360)
  end

  def initialize(viewport, map_id, battle = false)
    super(0, 0, viewport)
    self.z = 0
    @viewport = viewport
    @battle = battle
    setBitmap("Graphics/Panoramas/distortion")
    @clouds = []
    for i in 0...5
      @clouds[i] = []
      for j in 0...(i + 1)
        cloudY = Graphics.height / 2 + 112 - i * 16
        if @battle
          cloudY += 64 - i * 16
        end
        cloud = IconSprite.new(Graphics.width / 2, cloudY, @viewport)
        cloud.setBitmap("Graphics/Panoramas/distortion_cloud" + i.to_s)
        cloud.z = 1
        cloud.ox = cloud.bitmap.width / 2
        if i == 0
          cloud.zoom_x = 1.25
          cloud.zoom_y = 1.25
        else
          cloud.zoom_x = 1.5
          cloud.zoom_y = 1.5
        end
        @clouds[i].push(cloud)
      end
    end
    @below_map_id = 0
    @below_map_x = 0
    @below_map_y = 0
    if map_id == 26
      @below_map_id = 242
      @below_map_x = 832
      @below_map_y = 1280
    elsif map_id == 156
      @below_map_id = 149
      @below_map_x = 1408
      @below_map_y = 3712
    elsif map_id == 157
      @below_map_id = 149
      @below_map_x = 448
      @below_map_y = 3136
    end
    if @below_map_id != 0
      @below_map = Sprite.new(@viewport)
      @below_map.bitmap = CarubanMapExporter.getBitmap(@below_map_id, {:map_events => true}, @viewport)
      @below_map.x = Graphics.width / 2
      @below_map.y = Graphics.height / 2
      @below_map.ox = @below_map.bitmap.width / 2
      @below_map.oy = @below_map.bitmap.height / 2
      @below_map.zoom_x = 0.5
      @below_map.zoom_y = 0.5
      @below_map.tone = Tone.new(-32, -32, -32)
      @below_map.opacity = 192
      @below_map.z = 10
    end
    update
  end

  def update
    pulse = 8 * (Math.sin(System.uptime) - 1)
    @clouds.each_with_index do |list, i|
      list.each_with_index do |cloud, j|
        cloud.update
        cloud.angle = j * (360 / (i + 1)) - System.uptime * (16 + i * 2) + @@start_angles[i]
        cloud.oy = cloud.bitmap.height / 2
        if i == 0
          cloud.zoom_x = 1.25 + Math.sin(System.uptime) / 12
          cloud.zoom_y = cloud.zoom_x
        else
          cloud.oy += @@radiuses[i] + 4 * Math.sin(System.uptime)
        end
        cloud.opacity = i * 16 + 128 + 64 * Math.sin(System.uptime + @@start_angles[i] + j * Math::PI / 2)
        cloud.tone.set(pulse, pulse, pulse, 0)
      end
    end
    @offset_x = $game_map.display_x / 2
    @offset_y = $game_map.display_y / 2
    #echoln _INTL("{1} {2}", (@offset_x), (@offset_y))
    #echoln _INTL("{1} - {2}", @below_map_y * 32, @offset_y)
    if @below_map_id > 0
      @below_map.x = (@below_map_x - @offset_x) / 2 * @below_map.zoom_x + Graphics.width / 2
      @below_map.y = (@below_map_y - @offset_y) / 2 * @below_map.zoom_y + Graphics.height / 2
    end
    self.tone.set(pulse, pulse, pulse, 0)
    super
  end

  def dispose
    @clouds.each do |i|
      i.each do |j|
        j.dispose
      end
    end
    @below_map&.dispose
    super
  end

  def steal_map
    map = @below_map
    @below_map = nil
    @below_map_id = 0
    return map
  end

end