#===============================================================================
# ** Game_Player
#-------------------------------------------------------------------------------
#  This class handles the player. Its functions include event starting
#  determinants and map scrolling. Refer to "$game_player" for the one
#  instance of this class.
#===============================================================================
class Game_Player < Game_Character
  attr_accessor :charsetData
  attr_accessor :encounter_count

  SCREEN_CENTER_X = ((Settings::SCREEN_WIDTH / 2) - (Game_Map::TILE_WIDTH / 2)) * Game_Map::X_SUBPIXELS
  SCREEN_CENTER_Y = ((Settings::SCREEN_HEIGHT / 2) - (Game_Map::TILE_HEIGHT / 2)) * Game_Map::Y_SUBPIXELS
  # Time in seconds for one cycle of bobbing (playing 4 charset frames) while
  # surfing or diving.
  SURF_BOB_DURATION = 1.5

  def initialize(*arg)
    super(*arg)
    @lastdir = 0
    @lastdirframe = 0
  end

  def map
    @map = nil
    return $game_map
  end

  def map_id
    return $game_map.map_id
  end

  def screen_z(height = 0)
    ret = super
    return ret + 1
  end

  def has_follower?
    return $PokemonGlobal.followers.length > 0
  end

  def can_map_transfer_with_follower?
    return $PokemonGlobal.followers.length == 0
  end

  def can_ride_vehicle_with_follower?
    return $PokemonGlobal.followers.length == 0
  end

  def sprinting
    return @sprinting || 0
  end

  def sprinting=(value)
    @sprinting = value
  end

  def start_sprinting
    return @start_sprinting || false
  end

  def start_sprinting=(direction)
    @start_sprinting = true
    @sprinting = direction
  end

  #-----------------------------------------------------------------------------

  def can_run?(ignore_interpreter = false)
    return @move_speed > 3 if @move_route_forcing
    return false if @bumping
    return true if $game_switches && $game_switches[FORCED_RUNNING]
    return false if !ignore_interpreter && ($game_temp.in_menu || $game_temp.in_battle ||
                    $game_temp.message_window_showing || pbMapInterpreterRunning?)
    return false if !$player.has_running_shoes && !$PokemonGlobal.diving &&
                    !$PokemonGlobal.surfing && !$PokemonGlobal.bicycle
    return false if jumping?
    return false if pbTerrainTag.must_walk && $game_map.terrain_tag(@move_initial_x, @move_initial_y).must_walk
    return ($PokemonSystem.runstyle == 1) ^ Input.press?(Input::BACK)
  end

  def set_movement_type(type)
    meta = GameData::PlayerMetadata.get($player&.character_ID || 1)
    new_charset = nil
    case type
    when :fishing
      new_charset = pbGetPlayerCharset(meta.fish_charset)
    when :surf_fishing
      new_charset = pbGetPlayerCharset(meta.surf_fish_charset)
    when :diving, :diving_fast, :diving_jumping, :diving_stopped
      self.move_speed = 3 if !@move_route_forcing
      new_charset = pbGetPlayerCharset(meta.dive_charset)
    when :surfing, :surfing_fast, :surfing_jumping, :surfing_stopped
      if !@move_route_forcing
        self.move_speed = (type == :surfing_jumping) ? 3 : 4
      end
      new_charset = pbGetPlayerCharset(type == :surfing_jumping ? meta.walk_charset : meta.surf_charset)
    when :descending_waterfall, :ascending_waterfall
      self.move_speed = 2 if !@move_route_forcing
      new_charset = pbGetPlayerCharset(meta.surf_charset)
    when :cycling, :cycling_fast, :cycling_jumping, :cycling_stopped
      if !@move_route_forcing
        self.move_speed = (type == :cycling_jumping) ? 3 : 5
      end
      new_charset = pbGetPlayerCharset(meta.cycle_charset)
    when :sprinting
      self.move_speed = 6 if !@move_route_forcing
      new_charset = pbGetPlayerCharset(meta.run_charset)
    when :running
      self.move_speed = 4 if !@move_route_forcing
      new_charset = pbGetPlayerCharset(meta.run_charset)
    when :ice_sliding
      self.move_speed = 4 if !@move_route_forcing
      new_charset = pbGetPlayerCharset(meta.walk_charset)
    #when :stair_up
    #  self.move_speed = 2
    #  new_charset = pbGetPlayerCharset(meta.walk_charset)
    else   # :walking, :jumping, :walking_stopped
      self.move_speed = 3 if !@move_route_forcing
      new_charset = pbGetPlayerCharset(meta.walk_charset)
    end
    if @direction == 8 && $game_map && @y >= 0 && $game_map.stairsUp?(@x, @y + 1)
      self.move_speed -= 1
    elsif @direction == 2 && $game_map && @y < $game_map.height - 1 && $game_map.stairsUp?(@x, @y)
      self.move_speed -= 1
    end
    self.move_speed += $game_variables[MOVE_SPEED_MOD]
    self.move_speed = 3 if @bumping
    @character_name = new_charset if new_charset
  end

  # Called when the player's character or outfit changes. Assumes the player
  # isn't moving.
  def refresh_charset
    meta = GameData::PlayerMetadata.get($player&.character_ID || 1)
    new_charset = nil
    if $PokemonGlobal&.diving
      new_charset = pbGetPlayerCharset(meta.dive_charset)
    elsif $PokemonGlobal&.surfing
      new_charset = pbGetPlayerCharset(meta.surf_charset)
    elsif $PokemonGlobal&.bicycle
      new_charset = pbGetPlayerCharset(meta.cycle_charset)
    else
      new_charset = pbGetPlayerCharset(meta.walk_charset)
    end
    @character_name = new_charset if new_charset
  end

  #-----------------------------------------------------------------------------

  def bump_into_object
    pbSEPlay("Player bump") if !@move_route_forcing
    $stats.bump_count += 1
    @move_initial_x = @x
    @move_initial_y = @y
    @move_timer = 0.0
    @bumping = true
    @sprinting = false
  end

  def add_move_distance_to_stats(distance = 1)
    if $PokemonGlobal&.diving || $PokemonGlobal&.surfing
      $stats.distance_surfed += distance
    elsif $PokemonGlobal&.bicycle
      $stats.distance_cycled += distance
    else
      $stats.distance_walked += distance
    end
    $stats.distance_slid_on_ice += distance if $PokemonGlobal.ice_sliding
  end

  def move_generic(dir, turn_enabled = true)
    turn_generic(dir, true) if turn_enabled
    if !$game_temp.encounter_triggered
      x_offset = (dir == 4) ? -1 : (dir == 6) ? 1 : 0
      y_offset = (dir == 8) ? -1 : (dir == 2) ? 1 : 0
      if pbStairs(x_offset, y_offset)
        check_event_trigger_touch(dir)
        return
      end
      return if pbEndSurf(x_offset, y_offset)
      if can_move_in_direction?(dir)
        x_offset = (dir == 4) ? -1 : (dir == 6) ? 1 : 0
        y_offset = (dir == 8) ? -1 : (dir == 2) ? 1 : 0
        # Jump over ledges
        if pbFacingTerrainTag.ledge
          if jumpForward(2)
            pbSEPlay("Player jump")
            increase_steps
          end
          return
        elsif pbFacingTerrainTag.waterfall_crest && dir == 2
          $PokemonGlobal.descending_waterfall = true
          $game_player.through = true
          $stats.waterfalls_descended += 1
        end
        # General movement
        turn_generic(dir, true)
        if !$game_temp.encounter_triggered
          @move_initial_x = @x
          @move_initial_y = @y
          @x += x_offset
          @y += y_offset
          @move_timer = 0.0
          add_move_distance_to_stats(x_offset.abs + y_offset.abs)
          increase_steps
        end
      elsif !check_event_trigger_touch(dir)
        return if $PokemonSystem.auto_surf && pbStartSurf(false)
        bump_into_object
      end
    end
    $game_temp.encounter_triggered = false
  end

  def turn_generic(dir, keep_enc_indicator = false)
    old_direction = @direction
    super(dir)
    if @direction != old_direction && !@move_route_forcing && !pbMapInterpreterRunning?
      EventHandlers.trigger(:on_player_change_direction)
      $game_temp.encounter_triggered = false if !keep_enc_indicator
    end
  end

  def jump(x_plus, y_plus, direction = 0)
    old_x = @x
    old_y = @y
    super
    add_move_distance_to_stats(x_plus.abs + y_plus.abs) if @x != old_x || @y != old_y
  end

  #-----------------------------------------------------------------------------

  def pbTerrainTag(countBridge = false)
    return $map_factory.getTerrainTagFromCoords(self.map.map_id, @x, @y, countBridge) if $map_factory
    return $game_map.terrain_tag(@x, @y, countBridge)
  end

  def pbFacingEvent(ignoreInterpreter = false)
    return nil if $game_system.map_interpreter.running? && !ignoreInterpreter
    # Check the tile in front of the player for events
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    return nil if !$game_map.valid?(new_x, new_y)
    $game_map.events.each_value do |event|
      next if !event.at_coordinate?(new_x, new_y)
      next if event.jumping? || event.over_trigger?
      return event
    end
    # If the tile in front is a counter, check one tile beyond that for events
    if $game_map.counter?(new_x, new_y)
      new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
      new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
      $game_map.events.each_value do |event|
        next if !event.at_coordinate?(new_x, new_y)
        next if event.jumping? || event.over_trigger?
        return event
      end
    end
    return nil
  end

  def pbFacingTerrainTag(dir = nil)
    dir = self.direction if !dir
    return $map_factory.getFacingTerrainTag(dir, self) if $map_factory
    facing = pbFacingTile(dir, self)
    return $game_map.terrain_tag(facing[1], facing[2])
  end

  # Passable Determinants
  #     x : x-coordinate
  #     y : y-coordinate
  #     d : direction (0, 2, 4, 6, 8)
  #         * 0 = Determines if all directions are impassable (for jumping)
  def passable?(x, y, d, strict = false)
    # Get new coordinates
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # If coordinates are outside of map
    return false if !$game_map.validLax?(new_x, new_y)
    if !$game_map.valid?(new_x, new_y)
      return false if !$map_factory
      return $map_factory.isPassableFromEdge?(new_x, new_y)
    end
    # If debug mode is ON and Ctrl key was pressed
    return true if $DEBUG && Input.press?(Input::CTRL)
    return super
  end

  # Set Map Display Position to Center of Screen
  def center(x, y)
    self.map.display_x = (x * Game_Map::REAL_RES_X) - SCREEN_CENTER_X
    self.map.display_y = (y * Game_Map::REAL_RES_Y) - SCREEN_CENTER_Y
  end

  # Move to Designated Position
  #     x : x-coordinate
  #     y : y-coordinate
  def moveto(x, y)
    super
    center(x, y)
    make_encounter_count
  end

  # Make Encounter Count
  def make_encounter_count
    # Image of two dice rolling
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = rand(n) + rand(n) + 1
    end
  end

  def refresh
    @opacity    = 255
    @blend_type = 0
  end

  #-----------------------------------------------------------------------------

  def pbTriggeredTrainerEvents(triggers, checkIfRunning = true, trainer_only = false)
    result = []
    # If event is running
    return result if checkIfRunning && $game_system.map_interpreter.running?
    # All event loops
    $game_map.events.each_value do |event|
      next if !triggers.include?(event.trigger)
      next if !event.name[/trainer\((\d+)\)/i] && (trainer_only || !event.name[/sight\((\d+)\)/i])
      distance = $~[1].to_i
      next if !pbEventCanReachPlayer?(event, self, distance)
      next if event.jumping? || event.over_trigger?
      result.push(event)
    end
    return result
  end

  def pbTriggeredCounterEvents(triggers, checkIfRunning = true)
    result = []
    # If event is running
    return result if checkIfRunning && $game_system.map_interpreter.running?
    # All event loops
    $game_map.events.each_value do |event|
      next if !triggers.include?(event.trigger)
      next if !event.name[/counter\((\d+)\)/i]
      distance = $~[1].to_i
      next if !pbEventFacesPlayer?(event, self, distance)
      next if event.jumping? || event.over_trigger?
      result.push(event)
    end
    return result
  end

  def check_event_trigger_after_turning; end

  def pbCheckEventTriggerFromDistance(triggers)
    events = pbTriggeredTrainerEvents(triggers)
    events.concat(pbTriggeredCounterEvents(triggers))
    return false if events.length == 0
    ret = false
    events.each do |event|
      event.start
      ret = true if event.starting
    end
    return ret
  end

  # Trigger event(s) at the same coordinates as self with the appropriate
  # trigger(s) that can be triggered
  def check_event_trigger_here(triggers)
    result = false
    # If event is running
    return result if $game_system.map_interpreter.running?
    # All event loops
    $game_map.events.each_value do |event|
      # If event coordinates and triggers are consistent
      next if !event.at_coordinate?(@x, @y)
      next if !triggers.include?(event.trigger)
      # If starting determinant is same position event (other than jumping)
      next if event.jumping? || !event.over_trigger?
      event.start
      result = true if event.starting
    end
    return result
  end

  # Front Event Starting Determinant
  def check_event_trigger_there(triggers)
    result = false
    # If event is running
    return result if $game_system.map_interpreter.running?
    # Calculate front event coordinates
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    return false if !$game_map.valid?(new_x, new_y)
    # All event loops
    $game_map.events.each_value do |event|
      next if !triggers.include?(event.trigger)
      # If event coordinates and triggers are consistent
      next if !event.at_coordinate?(new_x, new_y)
      # If starting determinant is front event (other than jumping)
      next if event.jumping? || event.over_trigger?
      event.start
      result = true if event.starting
    end
    # If fitting event is not found
    if result == false && $game_map.counter?(new_x, new_y)
      # Calculate coordinates of 1 tile further away
      new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
      new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
      return false if !$game_map.valid?(new_x, new_y)
      # All event loops
      $game_map.events.each_value do |event|
        next if !triggers.include?(event.trigger)
        # If event coordinates and triggers are consistent
        next if !event.at_coordinate?(new_x, new_y)
        # If starting determinant is front event (other than jumping)
        next if event.jumping? || event.over_trigger?
        event.start
        result = true if event.starting
      end
    end
    return result
  end

  # Touch Event Starting Determinant
  def check_event_trigger_touch(dir)
    result = false
    return result if $game_system.map_interpreter.running?
    # All event loops
    x_offset = (dir == 4) ? -1 : (dir == 6) ? 1 : 0
    y_offset = (dir == 8) ? -1 : (dir == 2) ? 1 : 0
    $game_map.events.each_value do |event|
      next if ![1, 2].include?(event.trigger)   # Player touch, event touch
      # If event coordinates and triggers are consistent
      next if !event.at_coordinate?(@x + x_offset, @y + y_offset)
      if event.name[/(?:sight|trainer)\((\d+)\)/i]
        distance = $~[1].to_i
        next if !pbEventCanReachPlayer?(event, self, distance)
      elsif event.name[/counter\((\d+)\)/i]
        distance = $~[1].to_i
        next if !pbEventFacesPlayer?(event, self, distance)
      end
      # If starting determinant is front event (other than jumping)
      next if event.jumping? || event.over_trigger?
      event.start
      result = true if event.starting
    end
    return result
  end

  #-----------------------------------------------------------------------------

  def update
    @last_real_x = @real_x
    @last_real_y = @real_y
    @last_terrain_tag = pbTerrainTag
    if self.sprinting != 0
      if self.start_sprinting
        if !@sprint_timer || System.uptime - @sprint_timer > 0.25
          @sprint_timer = System.uptime
          pbSEPlay("Sprint", 80, 100)
        end
      else
        if !@sprint_timer || System.uptime - @sprint_timer > 0.2
          @sprint_timer = System.uptime
          pbSEPlay("Sprint", 80, 125)
        end
        if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
          @sprinting = 0
        else
          dir = Input.dir4
          self.sprinting = dir if dir != 0
        end
      end
    end
    super
    update_stop if $game_temp.in_menu && @stopped_last_frame
    update_screen_position(@last_real_x, @last_real_y)
    # Update dependent events
    if (!@moved_last_frame || @stopped_last_frame) && (moving? || jumping?) && !@bumping
      $game_temp.followers.move_followers
    end
    $game_temp.followers.update
    update_event_triggering
  end

  def update_command_new
    dir = Input.dir4
    if $PokemonGlobal.forced_movement?
      move_forward
    elsif !pbMapInterpreterRunning? && !$game_temp.message_window_showing &&
          !$game_temp.in_mini_update && !$game_temp.in_menu
      if self.sprinting != 0
        @start_sprinting = false
        if dir == 0
          dir = self.sprinting
        else
          self.sprinting = dir
        end
        case dir
        when 2 then move_down
        when 4 then move_left
        when 6 then move_right
        when 8 then move_up
        end
      else
        # Move player in the direction the directional button is being pressed
        if @moved_last_frame ||
          (dir > 0 && dir == @lastdir && System.uptime - @lastdirframe >= 0.075)
          case dir
          when 2 then move_down
          when 4 then move_left
          when 6 then move_right
          when 8 then move_up
          end
        elsif dir != @lastdir
          case dir
          when 2 then turn_down
          when 4 then turn_left
          when 6 then turn_right
          when 8 then turn_up
          end
        end
      end
      # Record last direction input
      @lastdirframe = System.uptime if dir != @lastdir
      @lastdir = dir
    elsif !self.start_sprinting
      @sprinting = 0
    end
  end

  def update_move
    if !@moved_last_frame || @stopped_last_frame   # Started a new step
      if $PokemonGlobal.ice_sliding || @last_terrain_tag.ice
        set_movement_type(:ice_sliding)
      elsif $PokemonGlobal.descending_waterfall
        set_movement_type(:descending_waterfall)
      elsif $PokemonGlobal.ascending_waterfall
        set_movement_type(:ascending_waterfall)
      else
        faster = can_run?
        if $PokemonGlobal&.diving
          set_movement_type((faster) ? :diving_fast : :diving)
        elsif $PokemonGlobal&.surfing
          set_movement_type((faster) ? :surfing_fast : :surfing)
        elsif $PokemonGlobal&.bicycle
          set_movement_type((faster) ? :cycling_fast : :cycling)
        elsif self.sprinting != 0
          set_movement_type(:sprinting)
        else
          set_movement_type((faster) ? :running : :walking)
        end
      end
      if jumping?
        if $PokemonGlobal&.diving
          set_movement_type(:diving_jumping)
        elsif $PokemonGlobal&.surfing
          set_movement_type(:surfing_jumping)
        elsif $PokemonGlobal&.bicycle
          set_movement_type(:cycling_jumping)
        else
          set_movement_type(:jumping)   # Walking speed/charset while jumping
        end
      end
    end
    was_jumping = jumping?
    super
    if was_jumping && !jumping? && !@transparent && (@tile_id > 0 || @character_name != "")
      if !$PokemonGlobal.surfing || $game_temp.ending_surf
        spriteset = $scene.spriteset(map_id)
        angle = ($game_variables && $game_variables[PLAYER_ROTATION]) ? $game_variables[PLAYER_ROTATION] : 0
        spriteset&.addUserAnimation(Settings::DUST_ANIMATION_ID, self.x, self.y, true, 1, angle)
      end
    end
  end

  def update_stop
    if @stopped_last_frame
      if $PokemonGlobal&.diving
        set_movement_type(:diving_stopped)
      elsif $PokemonGlobal&.surfing
        set_movement_type(:surfing_stopped)
      elsif $PokemonGlobal&.bicycle
        set_movement_type(:cycling_stopped)
      else
        set_movement_type(:walking_stopped)
      end
    end
    super
  end

  def update_pattern
    if $PokemonGlobal&.surfing || $PokemonGlobal&.diving
      bob_pattern = (4 * System.uptime / SURF_BOB_DURATION).to_i % 4
      @pattern = bob_pattern if !@lock_pattern
      @pattern = 1 if jumping?
      @pattern_surf = bob_pattern
      @bob_height = (bob_pattern >= 2) ? 2 : 0
      @anime_count = 0
    elsif jumping?
      @pattern = 1
      @anime_count = 0
    else
      @bob_height = 0
      super
    end
  end

  # Track the player on-screen as they move.
  def update_screen_position(last_real_x, last_real_y)
    return if self.map.scrolling? || !(@moved_last_frame || @moved_this_frame)
    if (@real_x < last_real_x && @real_x < $game_map.display_x + SCREEN_CENTER_X) ||
       (@real_x > last_real_x && @real_x > $game_map.display_x + SCREEN_CENTER_X)
      self.map.display_x += @real_x - last_real_x
    end
    if (@real_y < last_real_y && @real_y < $game_map.display_y + SCREEN_CENTER_Y) ||
       (@real_y > last_real_y && @real_y > $game_map.display_y + SCREEN_CENTER_Y)
      self.map.display_y += @real_y - last_real_y
    end
  end

  def update_event_triggering
    return if moving? || jumping? || $PokemonGlobal.forced_movement?
    # Try triggering events upon walking into them/in front of them
    if @moved_this_frame
      $game_temp.followers.turn_followers
      result = pbCheckEventTriggerFromDistance([2])
      # Event determinant is via touch of same position event
      result |= check_event_trigger_here([1, 2])
      # No events triggered, try other event triggers upon finishing a step
      pbOnStepTaken(result)
    end
  end
end

#===============================================================================
#
#===============================================================================
def pbGetPlayerCharset(charset, trainer = nil, force = false, follower = false)
  trainer = $player if !trainer
  outfit = (trainer) ? trainer.outfit : 0
  member_id = getPartyActiveSprite(follower ? 1 : 0)
  charsets = ["walk", "run", "surf"]
  return nil if !force && $game_player&.charsetData &&
                $game_player.charsetData[0] == trainer.character_ID &&
                $game_player.charsetData[1] == charset &&
                $game_player.charsetData[2] == outfit &&
                $game_player.charsetData[3] == member_id
  $game_player.charsetData = [trainer.character_ID, charset, outfit, member_id] if $game_player
  ret = "member" + member_id.to_s + "_" + charset
  if pbResolveBitmap("Graphics/Characters/" + ret + "_" + outfit.to_s)
    ret = ret + "_" + outfit.to_s
  end
  return ret
end

def pbUpdateVehicle
  if $PokemonGlobal&.diving
    $game_player.set_movement_type(:diving_stopped)
  elsif $PokemonGlobal&.surfing
    $game_player.set_movement_type(:surfing_stopped)
  elsif $PokemonGlobal&.bicycle
    $game_player.set_movement_type(:cycling_stopped)
  else
    $game_player.set_movement_type(:walking_stopped)
  end
end

def pbCancelVehicles(destination = nil, cancel_swimming = true)
  $PokemonGlobal.surfing = false if cancel_swimming
  $PokemonGlobal.diving  = false if cancel_swimming
  $PokemonGlobal.bicycle = false if !destination || !pbCanUseBike?(destination)
  $game_player.sprinting = false
  pbUpdateVehicle
end

def pbCanUseBike?(map_id)
  map_metadata = GameData::MapMetadata.try_get(map_id)
  return false if !map_metadata
  return map_metadata.always_bicycle || map_metadata.can_bicycle || map_metadata.outdoor_map
end

def pbMountBike
  return if $PokemonGlobal.bicycle
  $PokemonGlobal.bicycle = true
  $stats.cycle_count += 1
  pbUpdateVehicle
  bike_bgm = GameData::Metadata.get.bicycle_BGM
  pbCueBGM(bike_bgm, 0.4) if bike_bgm
  pbSEPlay("Bicycle")
  pbPokeRadarCancel
end

def pbDismountBike
  return if !$PokemonGlobal.bicycle
  $PokemonGlobal.bicycle = false
  pbUpdateVehicle
  $game_map.autoplayAsCue
end
