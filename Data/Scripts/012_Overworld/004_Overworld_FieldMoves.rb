#===============================================================================
# Hidden move handlers
#===============================================================================
module HiddenMoveHandlers
  CanUseMove     = MoveHandlerHash.new
  ConfirmUseMove = MoveHandlerHash.new
  UseMove        = MoveHandlerHash.new

  def self.addCanUseMove(item, proc);     CanUseMove.add(item, proc);     end
  def self.addConfirmUseMove(item, proc); ConfirmUseMove.add(item, proc); end
  def self.addUseMove(item, proc);        UseMove.add(item, proc);        end

  def self.hasHandler(item)
    return !CanUseMove[item].nil? && !UseMove[item].nil?
  end

  # Returns whether move can be used
  def self.triggerCanUseMove(item, pokemon, showmsg)
    return false if !CanUseMove[item]
    return CanUseMove.trigger(item, pokemon, showmsg)
  end

  # Returns whether the player confirmed that they want to use the move
  def self.triggerConfirmUseMove(item, pokemon)
    return true if !ConfirmUseMove[item]
    return ConfirmUseMove.trigger(item, pokemon)
  end

  # Returns whether move was used
  def self.triggerUseMove(item, pokemon)
    return false if !UseMove[item]
    return UseMove.trigger(item, pokemon)
  end
end

#===============================================================================
#
#===============================================================================
def pbCanUseHiddenMove?(pkmn, move, showmsg = true)
  return HiddenMoveHandlers.triggerCanUseMove(move, pkmn, showmsg)
end

def pbConfirmUseHiddenMove(pokemon, move)
  return HiddenMoveHandlers.triggerConfirmUseMove(move, pokemon)
end

def pbUseHiddenMove(pokemon, move)
  return HiddenMoveHandlers.triggerUseMove(move, pokemon)
end

# Unused
def pbHiddenMoveEvent
  EventHandlers.trigger(:on_player_interact)
end

def pbCheckHiddenMoveBadge(badge = -1, showmsg = true)
  return true if badge < 0   # No badge requirement
  return true if $DEBUG
  if (Settings::FIELD_MOVES_COUNT_BADGES) ? $player.badge_count >= badge : $player.badges[badge]
    return true
  end
  pbMessage(_INTL("Sorry, a new Badge is required.")) if showmsg
  return false
end

#===============================================================================
# Hidden move animation
#===============================================================================
def pbHiddenMoveAnimation(pokemon)
  return false if !pokemon
  viewport = Viewport.new(0, 0, Graphics.width, 0)
  viewport.z = 99999
  # Set up sprites
  bg = Sprite.new(viewport)
  bg.bitmap = RPG::Cache.ui("Field move/bg")
  sprite = PokemonSprite.new(viewport)
  sprite.setOffset(PictureOrigin::CENTER)
  sprite.setPokemonBitmap(pokemon)
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
        pokemon.play_cry
        timer_start = System.uptime
      end
    when 3   # Wait
      if System.uptime - timer_start >= 1.0
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

#===============================================================================
# Cut
#===============================================================================
def pbCut
  move = :CUT
  movefinder = $player.get_pokemon_with_move(move)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_CUT, false) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("This tree looks like it can be cut down."))
    return false
  end
  if pbConfirmMessage(_INTL("This tree looks like it can be cut down!\nWould you like to cut it?"))
    $stats.cut_count += 1
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    return true
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:CUT, proc { |move, pkmn, showmsg|
  next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_CUT, showmsg)
  facingEvent = $game_player.pbFacingEvent
  if !facingEvent || !facingEvent.name[/cuttree/i]
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:CUT, proc { |move, pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
  end
  $stats.cut_count += 1
  facingEvent = $game_player.pbFacingEvent
  pbSmashEvent(facingEvent) if facingEvent
  next true
})

def pbSmashEvent(event)
  return if !event
  if event.name[/cuttree/i]
    pbSEPlay("Cut")
  elsif event.name[/smashrock/i]
    pbSEPlay("Rock Smash")
  end
  pbMoveRoute(event, [PBMoveRoute::WAIT, 2,
                      PBMoveRoute::TURN_LEFT, PBMoveRoute::WAIT, 2,
                      PBMoveRoute::TURN_RIGHT, PBMoveRoute::WAIT, 2,
                      PBMoveRoute::TURN_UP, PBMoveRoute::WAIT, 2])
  pbWait(0.4)
  event.erase
  $PokemonMap&.addErasedEvent(event.id)
end

#===============================================================================
# Dig
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:DIG, proc { |move, pkmn, showmsg|
  escape = ($PokemonGlobal.escapePoint rescue nil)
  if !escape || escape == []
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  if !$game_player.can_map_transfer_with_follower?
    pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
    next false
  end
  if $game_map.metadata&.has_flag?("DisableFastTravel")
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::ConfirmUseMove.add(:DIG, proc { |move, pkmn|
  escape = ($PokemonGlobal.escapePoint rescue nil)
  next false if !escape || escape == []
  mapname = pbGetMapNameFromId(escape[0])
  next pbConfirmMessage(_INTL("Want to escape from here and return to {1}?", mapname))
})

HiddenMoveHandlers::UseMove.add(:DIG, proc { |move, pokemon|
  escape = ($PokemonGlobal.escapePoint rescue nil)
  if escape
    if !pbHiddenMoveAnimation(pokemon)
      pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
    end
    pbFadeOutIn do
      $game_temp.player_new_map_id    = escape[0]
      $game_temp.player_new_x         = escape[1]
      $game_temp.player_new_y         = escape[2]
      $game_temp.player_new_direction = escape[3]
      pbDismountBike
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
    end
    pbEraseEscapePoint
    next true
  end
  next false
})

#===============================================================================
# Dive
#===============================================================================
def pbDive
  map_metadata = $game_map.metadata
  return false if !map_metadata || !map_metadata.dive_map_id
  move = :DIVE
  movefinder = $player.get_pokemon_with_move(move)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_DIVE, false) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("The sea is deep here. A Pokémon may be able to go underwater."))
    return false
  end
  if pbConfirmMessage(_INTL("The sea is deep here. Would you like to use Dive?"))
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    pbFadeOutIn do
      $game_temp.player_new_map_id    = map_metadata.dive_map_id
      $game_temp.player_new_x         = $game_player.x
      $game_temp.player_new_y         = $game_player.y
      $game_temp.player_new_direction = $game_player.direction
      $PokemonGlobal.surfing = false
      $PokemonGlobal.diving  = true
      $stats.dive_count += 1
      pbUpdateVehicle
      $scene.transfer_player(false)
      $game_map.autoplay
      $game_map.refresh
    end
    return true
  end
  return false
end

def pbSurfacing
  return if !$PokemonGlobal.diving
  surface_map_id = nil
  GameData::MapMetadata.each do |map_data|
    next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
    surface_map_id = map_data.id
    break
  end
  return if !surface_map_id
  move = :DIVE
  movefinder = $player.get_pokemon_with_move(move)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_DIVE, false) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("Light is filtering down from above. A Pokémon may be able to surface here."))
    return false
  end
  if pbConfirmMessage(_INTL("Light is filtering down from above. Would you like to use Dive?"))
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    pbFadeOutIn do
      $game_temp.player_new_map_id    = surface_map_id
      $game_temp.player_new_x         = $game_player.x
      $game_temp.player_new_y         = $game_player.y
      $game_temp.player_new_direction = $game_player.direction
      $PokemonGlobal.surfing = true
      $PokemonGlobal.diving  = false
      pbUpdateVehicle
      $scene.transfer_player(false)
      #surfbgm = GameData::Metadata.get.surf_BGM
      #(surfbgm) ? pbBGMPlay(surfbgm) : $game_map.autoplayAsCue
      $game_map.refresh
    end
    return true
  end
  return false
end

EventHandlers.add(:on_player_interact, :diving,
  proc {
    if $PokemonGlobal.diving
      surface_map_id = nil
      GameData::MapMetadata.each do |map_data|
        next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
        surface_map_id = map_data.id
        break
      end
      if surface_map_id &&
         $map_factory.getTerrainTag(surface_map_id, $game_player.x, $game_player.y).can_dive
        pbSurfacing
      end
    elsif $game_player.terrain_tag.can_dive
      pbDive
    end
  }
)

HiddenMoveHandlers::CanUseMove.add(:DIVE, proc { |move, pkmn, showmsg|
  next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_DIVE, showmsg)
  if $PokemonGlobal.diving
    surface_map_id = nil
    GameData::MapMetadata.each do |map_data|
      next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
      surface_map_id = map_data.id
      break
    end
    if !surface_map_id ||
       !$map_factory.getTerrainTag(surface_map_id, $game_player.x, $game_player.y).can_dive
      pbMessage(_INTL("You can't use that here.")) if showmsg
      next false
    end
  else
    if !$game_map.metadata&.dive_map_id
      pbMessage(_INTL("You can't use that here.")) if showmsg
      next false
    end
    if !$game_player.terrain_tag.can_dive
      pbMessage(_INTL("You can't use that here.")) if showmsg
      next false
    end
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:DIVE, proc { |move, pokemon|
  wasdiving = $PokemonGlobal.diving
  if $PokemonGlobal.diving
    dive_map_id = nil
    GameData::MapMetadata.each do |map_data|
      next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
      dive_map_id = map_data.id
      break
    end
  else
    dive_map_id = $game_map.metadata&.dive_map_id
  end
  next false if !dive_map_id
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
  end
  pbFadeOutIn do
    $game_temp.player_new_map_id    = dive_map_id
    $game_temp.player_new_x         = $game_player.x
    $game_temp.player_new_y         = $game_player.y
    $game_temp.player_new_direction = $game_player.direction
    $PokemonGlobal.surfing = wasdiving
    $PokemonGlobal.diving  = !wasdiving
    pbUpdateVehicle
    $scene.transfer_player(false)
    $game_map.autoplay
    $game_map.refresh
  end
  next true
})

#===============================================================================
# Flash
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:FLASH, proc { |move, pkmn, showmsg|
  next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_FLASH, showmsg)
  if !$game_map.metadata&.dark_map
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  if $PokemonGlobal.flashUsed
    pbMessage(_INTL("Flash is already being used.")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:FLASH, proc { |move, pokemon|
  darkness = $game_temp.darkness_sprite
  next false if !darkness || darkness.disposed?
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
  end
  $PokemonGlobal.flashUsed = true
  $stats.flash_count += 1
  duration = 0.7
  pbWait(duration) do |delta_t|
    darkness.radius = lerp(darkness.radiusMin, darkness.radiusMax, duration, delta_t)
  end
  darkness.radius = darkness.radiusMax
  next true
})

#===============================================================================
# Fly
#===============================================================================
def pbCanFly?(pkmn = nil, show_messages = false)
  return $game_switches[HAS_TELEPORT]
  return false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_FLY, show_messages)
  return false if !$DEBUG && !pkmn && !$player.get_pokemon_with_move(:FLY)
  if !$game_player.can_map_transfer_with_follower?
    pbMessage(_INTL("It can't be used when you have someone with you.")) if show_messages
    return false
  end
  if !$game_map.metadata&.outdoor_map
    pbMessage(_INTL("You can't use that here.")) if show_messages
    return false
  end
  if $game_map.metadata&.has_flag?("DisableFastTravel")
    pbMessage(_INTL("You can't use that here.")) if showmsg
    return false
  end
  return true
end

def pbFlyToNewLocation(pkmn = nil, move = :FLY)
  return false if $game_temp.fly_destination.nil?
  pkmn = $player.get_pokemon_with_move(move) if !pkmn
  if !$DEBUG && !pkmn
    $game_temp.fly_destination = nil
    yield if block_given?
    return false
  end
  $stats.fly_count += 1
  start_time = System.uptime
  time_now = System.uptime
  while (time_now - start_time) * 6 < Math::PI
    scaled_time = (time_now - start_time) * 6
    $game_player.sprite.zoom_x = 1.25 - (Math.cos(scaled_time) + 1) / 8
    $game_player.sprite.zoom_y = 0.5 + (Math.cos(scaled_time) + 1) / 4
    tone = [255, (1 - (Math.cos(scaled_time) + 1) / 2) * 255].min
    $game_player.tone = Tone.new(tone, tone, tone, tone)
    time_now = System.uptime
    pbUpdateSceneMap
    Graphics.update
    Input.update
  end
  pbSEPlay("Wind1")
  start_time = System.uptime
  time_now = System.uptime
  while (time_now - start_time) * 6 < Math::PI
    scaled_time = (time_now - start_time) * 6
    $game_player.sprite.zoom_x = 1.25 - (1 - Math.cos(scaled_time / 2)) * 1.25
    $game_player.sprite.zoom_y = 0.5 + (1 - Math.cos(scaled_time / 2))
    if scaled_time >= Math::PI / 2
      $game_player.y_offset = -((1 - Math.cos(scaled_time - Math::PI / 2)) * 256).floor
    end
    tone = [510, 255 + (1 - (Math.cos(scaled_time) + 1) / 2) * 255].min
    $game_player.tone = Tone.new(tone, tone, tone, tone)
    new_time_now = System.uptime
    if scaled_time < Math::PI * 2 / 3 && (new_time_now - start_time) * 6 >= Math::PI * 2 / 3
      $game_screen.start_tone_change(Tone.new(255, 255, 255, 0), 5.0 * Graphics.frame_rate / 20.0)
    end
    time_now = new_time_now
    pbUpdateSceneMap
    Graphics.update
    Input.update
  end
  $game_player.sprite.zoom_x = 0
  while $game_screen.tone.red < 255
    pbUpdateSceneMap
    Graphics.update
    Input.update
  end
  $game_temp.player_new_map_id    = $game_temp.fly_destination[0]
  $game_temp.player_new_x         = $game_temp.fly_destination[1]
  $game_temp.player_new_y         = $game_temp.fly_destination[2]
  $game_temp.player_new_direction = 2
  $game_temp.fly_destination = nil
  $scene.transfer_player
  $game_map.autoplay
  $game_map.refresh
  $game_player.always_on_top = false
  yield if block_given?
  pbWait(0.25)
  $game_screen.start_tone_change(Tone.new(0, 0, 0, 0), 5.0 * Graphics.frame_rate / 20.0)
  pbWait(0.25)
  pbSEPlay("Wind1", 100, 80)
  start_time = System.uptime
  time_now = System.uptime
  while (time_now - start_time) * 6 < Math::PI
    reverse_time = Math::PI - (time_now - start_time) * 6
    $game_player.sprite.zoom_x = 1.25 - (1 - Math.cos(reverse_time / 2)) * 1.25
    $game_player.sprite.zoom_y = 0.5 + (1 - Math.cos(reverse_time / 2))
    if reverse_time >= Math::PI / 2
      $game_player.y_offset = -((1 - Math.cos(reverse_time - Math::PI / 2)) * 256).floor
    else
      $game_player.y_offset = 0
    end
    tone = [510, 255 + (1 - (Math.cos(reverse_time) + 1) / 2) * 255].min
    $game_player.tone.set(tone, tone, tone, tone)
    time_now = System.uptime
    pbUpdateSceneMap
    Graphics.update
    Input.update
  end
  $game_player.y_offset = 0
  start_time = System.uptime
  time_now = System.uptime
  while (time_now - start_time) * 6 < Math::PI
    reverse_time = Math::PI - (time_now - start_time) * 6
    $game_player.sprite.zoom_x = 1.25 - (Math.cos(reverse_time) + 1) / 8
    $game_player.sprite.zoom_y = 0.5 + (Math.cos(reverse_time) + 1) / 4
    tone = [255, (1 - (Math.cos(reverse_time) + 1) / 2) * 255].min
    $game_player.tone.set(tone, tone, tone, tone)
    time_now = System.uptime
    pbUpdateSceneMap
    Graphics.update
    Input.update
  end
  $game_player.sprite.zoom_x = 1.0
  $game_player.sprite.zoom_y = 1.0
  $game_player.tone.set(0, 0, 0, 0)
  while $game_screen.tone.red > 0
    pbUpdateSceneMap
    Graphics.update
    Input.update
  end
  pbEraseEscapePoint
  $game_temp.fly_destination = nil
  return true
end

HiddenMoveHandlers::CanUseMove.add(:FLY, proc { |move, pkmn, showmsg|
  next pbCanFly?(pkmn, showmsg)
})

HiddenMoveHandlers::UseMove.add(:FLY, proc { |move, pkmn|
  if $game_temp.fly_destination.nil?
    pbMessage(_INTL("You can't use that here."))
    next false
  end
  pbFlyToNewLocation(pkmn)
  next true
})

#===============================================================================
# Headbutt
#===============================================================================
def pbHeadbuttEffect(event = nil)
  pbSEPlay("Headbutt")
  pbWait(1.0)
  event = $game_player.pbFacingEvent(true) if !event
  a = (event.x + (event.x / 24).floor + 1) * (event.y + (event.y / 24).floor + 1)
  a = (a * 2 / 5) % 10   # Even 2x as likely as odd, 0 is 1.5x as likely as odd
  b = $player.public_ID % 10   # Practically equal odds of each value
  chance = 1                 # ~50%
  if a == b                    # 10%
    chance = 8
  elsif a > b && (a - b).abs < 5   # ~30.3%
    chance = 5
  elsif a < b && (a - b).abs > 5   # ~9.7%
    chance = 5
  end
  if rand(10) >= chance
    pbMessage(_INTL("Nope. Nothing..."))
  else
    enctype = (chance == 1) ? :HeadbuttLow : :HeadbuttHigh
    if pbEncounter(enctype)
      $stats.headbutt_battles += 1
    else
      pbMessage(_INTL("Nope. Nothing..."))
    end
  end
end

def pbHeadbutt(event = nil)
  move = :HEADBUTT
  movefinder = $player.get_pokemon_with_move(move)
  if !$DEBUG && !movefinder
    pbMessage(_INTL("A Pokémon could be in this tree. Maybe a Pokémon could shake it."))
    return false
  end
  if pbConfirmMessage(_INTL("A Pokémon could be in this tree. Would you like to use Headbutt?"))
    $stats.headbutt_count += 1
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    pbHeadbuttEffect(event)
    return true
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:HEADBUTT, proc { |move, pkmn, showmsg|
  facingEvent = $game_player.pbFacingEvent
  if !facingEvent || !facingEvent.name[/headbutttree/i]
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:HEADBUTT, proc { |move, pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
  end
  $stats.headbutt_count += 1
  facingEvent = $game_player.pbFacingEvent
  pbHeadbuttEffect(facingEvent)
})

#===============================================================================
# Rock Smash
#===============================================================================
def pbRockSmashRandomEncounter
  if $PokemonEncounters.encounter_triggered?(:RockSmash, false, false)
    $stats.rock_smash_battles += 1
    pbEncounter(:RockSmash)
  end
end

def pbRockSmash
  move = :ROCKSMASH
  movefinder = $player.get_pokemon_with_move(move)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_ROCKSMASH, false) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("It's a rugged rock, but a Pokémon may be able to smash it."))
    return false
  end
  if pbConfirmMessage(_INTL("This rock seems breakable with a hidden move.\nWould you like to use Rock Smash?"))
    $stats.rock_smash_count += 1
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    return true
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:ROCKSMASH, proc { |move, pkmn, showmsg|
  next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_ROCKSMASH, showmsg)
  facingEvent = $game_player.pbFacingEvent
  if !facingEvent || !facingEvent.name[/smashrock/i]
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:ROCKSMASH, proc { |move, pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
  end
  $stats.rock_smash_count += 1
  facingEvent = $game_player.pbFacingEvent
  if facingEvent
    pbSmashEvent(facingEvent)
    pbRockSmashRandomEncounter
  end
  next true
})

#===============================================================================
# Strength
#===============================================================================
def pbStrength(object = "boulder")
  if !(hasPartyMember(:Kira) && $game_switches[HAS_STRENGTH])
    return false
  end
  if $PokemonMap.strengthUsed
    pbMessage(_INTL("Strength made it possible to move {1} around.", object))
    return false
  end
  move = :STRENGTH
  movefinder = Pokemon.new(:SANDOLIN, 5)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_STRENGTH, false) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("It's a big {1}, but a Pokémon may be able to push it aside.", object))
    return false
  end
  speciesname = (movefinder) ? movefinder.name : $player.name
  if pbConfirmMessage(_INTL("The big {1} looks pushable.\nWould you like to call {2}?", object, speciesname))
    pbHiddenMoveAnimation(movefinder)
    pbMessage(_INTL("{1} made it possible to move {2}s around!", speciesname, object))
    $PokemonMap.strengthUsed = true
    return true
  end
  return false
end

EventHandlers.add(:on_player_interact, :strength_event,
  proc {
    facingEvent = $game_player.pbFacingEvent
    pbStrength("boulder") if facingEvent && facingEvent.name[/strengthboulder/i]
    pbStrength("log") if facingEvent && facingEvent.name[/strengthlog/i]
  }
)

HiddenMoveHandlers::CanUseMove.add(:STRENGTH, proc { |move, pkmn, showmsg|
  next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_STRENGTH, showmsg)
  if $PokemonMap.strengthUsed
    pbMessage(_INTL("Strength is already being used.")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:STRENGTH, proc { |move, pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name) + "\1")
  end
  pbMessage(_INTL("Strength made it possible to move boulders around!"))
  $PokemonMap.strengthUsed = true
  next true
})

#===============================================================================
# Surf
#===============================================================================
def pbSurf(confirm = true, target_tile = false)
  return false if !hasPartyMember(PBParty::Amethyst)
  return false if $game_player.pbFacingEvent
  return false if !$game_player.can_ride_vehicle_with_follower?
  if $quests[:UNKNOWNDESTINATION].active?
    if $quests[:UNKNOWNDESTINATION].at_step?(1) && [208,209].include?($game_map.map_id)
      pbDialog("CH1_NO_SURF", 0)
      return false
    end
    if $quests[:UNKNOWNDESTINATION].at_step?(1) && [204, 27, 14].include?($game_map.map_id)
      pbDialog("CH1_NO_SURF", 1)
      return false
    end
    if $quests[:UNKNOWNDESTINATION].at_step?(2) && [204, 14].include?($game_map.map_id)
      pbDialog("CH1_NO_SURF", 2)
      return false
    end
    if $quests[:UNKNOWNDESTINATION].at_step?(2) && [27].include?($game_map.map_id)
      pbDialog("CH1_NO_SURF", 3)
      return false
    end
  end
  if !confirm || pbConfirmMessage(_INTL("The water is a deep blue...\nWould you like to surf on it?"))
    pbMessage(_INTL("Starmie used Surf!")) if confirm
    pbCancelVehicles
    #surfbgm = GameData::Metadata.get.surf_BGM
    #pbCueBGM(surfbgm, 0.5) if surfbgm
    pbStartSurfing(target_tile)
    return true
  end
  return false
end

def pbStartSurfing(target_tile = nil)
  pbCancelVehicles
  $PokemonEncounters.reset_step_count
  $PokemonGlobal.surfing = true
  $stats.surf_count += 1
  pbUpdateVehicle
  if target_tile
    $game_temp.surf_base_coords = [target_tile[0], target_tile[1]]
    pbJump(target_tile[0] - $game_player.x, target_tile[1] - $game_player.y, true)
  else
    $game_temp.surf_base_coords = $map_factory.getFacingCoords($game_player.x, $game_player.y, $game_player.direction)
    pbJumpToward(1, true, false, 0)
  end
  $game_temp.surf_base_coords = nil
  $game_player.check_event_trigger_here([1, 2])
end

def pbEndSurf(_xOffset, _yOffset)
  return false if !$PokemonGlobal.surfing
  #player_terrain = $game_map.terrain_tag($game_player.x, $game_player.y)
  facing_terrain = $game_player.pbFacingTerrainTag
  if !facing_terrain.can_surf || facing_terrain.water_edge
    target_tile = [$game_player.x, $game_player.y]
    # Calculate tile to land on
    target_tile[0] += facing_terrain.water_edge ? 2 : 1 if $game_player.direction == 6
    target_tile[0] -= facing_terrain.water_edge ? 2 : 1 if $game_player.direction == 4
    target_tile[1] += facing_terrain.water_edge ? 2 : 1 if $game_player.direction == 2
    target_tile[1] -= facing_terrain.water_edge ? 2 : 1 if $game_player.direction == 8
    high_edge = false
    # Check if there is water to jump up by one y-coordinate to emulate height sideways
    if ($game_player.direction == 4 || $game_player.direction == 6) && Supplementals::HIGH_WATER_EDGES
      target_terrain = $game_map.terrain_tag(target_tile[0], target_tile[1] - 1)
      if !target_terrain.can_surf && !target_terrain.water_edge && $game_player.passable?(target_tile[0], target_tile[1] - 1, 10 - $game_player.direction)
        target_tile[1] -= 1
        high_edge = true
      end
    end
    # Make sure terrain is walkable
    target_terrain = $game_map.terrain_tag(target_tile[0], target_tile[1])
    if !target_terrain.can_surf && !target_terrain.water_edge && $game_map.passable?(target_tile[0], target_tile[1], 10 - $game_player.direction)
      $game_player.direction_fix = true
      $game_temp.surf_base_coords = [$game_player.x, $game_player.y, true]
      success = false
      if ($game_player.direction == 2 || $game_player.direction == 8)
        if pbJumpToward((target_tile[1] - $game_player.y).abs, true, true)
          success = true
        end
      elsif ($game_player.direction == 4 || $game_player.direction == 6) 
        if pbJumpToward((target_tile[0] - $game_player.x).abs, true, true, target_tile[1] - $game_player.y)
          success = true
        end
      end
      if success
        $game_map.autoplayAsCue
        $game_player.increase_steps
        result = $game_player.check_event_trigger_here([1, 2])
        pbOnStepTaken(result)
        $game_player.sprite.snapPartner(false)
      end
      $game_temp.surf_base_coords = nil
      $game_player.direction_fix = false
      return true
    elsif target_terrain.water_edge
      success = false
      if $game_player.direction == 2
        if !$game_map.terrain_tag(target_tile[0] + 1, target_tile[1]).can_surf && $game_map.passable?(target_tile[0] + 1, target_tile[1], 10 - $game_player.direction)
          target_tile[0] += 1
          success = true
        elsif !$game_map.terrain_tag(target_tile[0] - 1, target_tile[1]).can_surf && $game_map.passable?(target_tile[0] - 1, target_tile[1], 10 - $game_player.direction)
          target_tile[0] -= 1
          success = true
        elsif !$game_map.terrain_tag(target_tile[0], target_tile[1] + 1).can_surf && $game_map.passable?(target_tile[0], target_tile[1] + 1, 10 - $game_player.direction)
          target_tile[1] += 1
          success = true
        end
      elsif $game_player.direction == 4
        if !$game_map.terrain_tag(target_tile[0], target_tile[1] + 1).can_surf && $game_map.passable?(target_tile[0], target_tile[1] + 1, 10 - $game_player.direction)
          target_tile[1] += 1
          success = true
        elsif !$game_map.terrain_tag(target_tile[0], target_tile[1] - 1).can_surf && $game_map.passable?(target_tile[0], target_tile[1] - 1, 10 - $game_player.direction)
          target_tile[1] -= 1
          success = true
        elsif !$game_map.terrain_tag(target_tile[0] - 1, target_tile[1]).can_surf && $game_map.passable?(target_tile[0] - 1, target_tile[1], 10 - $game_player.direction)
          target_tile[0] -= 1
          success = true
        end
      elsif $game_player.direction == 6
        if !$game_map.terrain_tag(target_tile[0], target_tile[1] + 1).can_surf && $game_map.passable?(target_tile[0], target_tile[1] + 1, 10 - $game_player.direction)
          target_tile[1] += 1
          success = true
        elsif !$game_map.terrain_tag(target_tile[0], target_tile[1] - 1).can_surf && $game_map.passable?(target_tile[0], target_tile[1] - 1, 10 - $game_player.direction)
          target_tile[1] -= 1
          success = true
        elsif !$game_map.terrain_tag(target_tile[0] + 1, target_tile[1]).can_surf && $game_map.passable?(target_tile[0] + 1, target_tile[1], 10 - $game_player.direction)
          target_tile[0] += 1
          success = true
        end
      elsif $game_player.direction == 8
        if !$game_map.terrain_tag(target_tile[0] + 1, target_tile[1]).can_surf && $game_map.passable?(target_tile[0] + 1, target_tile[1], 10 - $game_player.direction)
          target_tile[0] += 1
          success = true
        elsif !$game_map.terrain_tag(target_tile[0] - 1, target_tile[1]).can_surf && $game_map.passable?(target_tile[0] - 1, target_tile[1], 10 - $game_player.direction)
          target_tile[0] -= 1
          success = true
        elsif !$game_map.terrain_tag(target_tile[0], target_tile[1] - 1).can_surf && $game_map.passable?(target_tile[0] - 1, target_tile[1], 10 - $game_player.direction)
          target_tile[1] -= 1
          success = true
        end
      end
      if success
        $game_player.direction_fix = true
        $game_temp.surf_base_coords = [$game_player.x, $game_player.y, true]
        success = false
        if pbJump(target_tile[0] - $game_player.x, target_tile[1] - $game_player.y, true, true)
          success = true
        end
        if success
          $game_map.autoplayAsCue
          $game_player.increase_steps
          result = $game_player.check_event_trigger_here([1, 2])
          pbOnStepTaken(result)
          $game_player.sprite.snapPartner(false)
        end
        $game_temp.surf_base_coords = nil
        $game_player.direction_fix = false
        return true
      end
    end
  end
  return false
end

def pbStartSurf(confirm = true)
  return false if $PokemonGlobal.surfing
  facing_terrain = $game_player.pbFacingTerrainTag
  return false if $game_player.can_move_in_direction?($game_player.direction)
  notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction)
  if (facing_terrain.can_surf || facing_terrain.water_edge) && notCliff
    # Calculate tile to land in the water on
    target_tile = [$game_player.x, $game_player.y]
    target_tile[0] += facing_terrain.water_edge ? 2 : 1 if $game_player.direction == 6
    target_tile[0] -= facing_terrain.water_edge ? 2 : 1 if $game_player.direction == 4
    target_tile[1] += facing_terrain.water_edge ? 2 : 1 if $game_player.direction == 2
    target_tile[1] -= facing_terrain.water_edge ? 2 : 1 if $game_player.direction == 8
    high_edge = false
    # Check if there is water to drop down by one y-coordinate to emulate height sideways
    if ($game_player.direction == 4 || $game_player.direction == 6) && !facing_terrain.water_flat_edge && Supplementals::HIGH_WATER_EDGES
      target_terrain = $game_map.terrain_tag(target_tile[0], target_tile[1] + 1)
      if target_terrain.can_surf && !target_terrain.water_edge
        target_tile[1] += 1
        high_edge = true
      end
    end
    # Make sure terrain is surfable
    target_terrain = $game_map.terrain_tag(target_tile[0], target_tile[1])
    if target_terrain.can_surf && !target_terrain.water_edge
      $game_player.direction_fix = true
      pbSurf(confirm, target_tile)
      $game_player.direction_fix = false
      return true
    elsif target_terrain.water_edge
      success = false
      if $game_player.direction == 2
        if $game_map.terrain_tag(target_tile[0] + 1, target_tile[1]).can_surf
          target_tile[0] += 1
          success = true
        elsif $game_map.terrain_tag(target_tile[0] - 1, target_tile[1]).can_surf
          target_tile[0] -= 1
          success = true
        elsif $game_map.terrain_tag(target_tile[0], target_tile[1] + 1).can_surf
          target_tile[1] += 1
          success = true
        end
      elsif $game_player.direction == 4
        if $game_map.terrain_tag(target_tile[0], target_tile[1] + 1).can_surf
          target_tile[1] += 1
          success = true
        elsif $game_map.terrain_tag(target_tile[0], target_tile[1] - 1).can_surf
          target_tile[1] -= 1
          success = true
        elsif $game_map.terrain_tag(target_tile[0] - 1, target_tile[1]).can_surf
          target_tile[0] -= 1
          success = true
        end
      elsif $game_player.direction == 6
        if $game_map.terrain_tag(target_tile[0], target_tile[1] + 1).can_surf
          target_tile[1] += 1
          success = true
        elsif $game_map.terrain_tag(target_tile[0], target_tile[1] - 1).can_surf
          target_tile[1] -= 1
          success = true
        elsif $game_map.terrain_tag(target_tile[0] + 1, target_tile[1]).can_surf
          target_tile[0] += 1
          success = true
        end
      elsif $game_player.direction == 8
        if $game_map.terrain_tag(target_tile[0] + 1, target_tile[1]).can_surf
          target_tile[0] += 1
          success = true
        elsif $game_map.terrain_tag(target_tile[0] - 1, target_tile[1]).can_surf
          target_tile[0] -= 1
          success = true
        elsif $game_map.terrain_tag(target_tile[0], target_tile[1] - 1).can_surf
          target_tile[1] -= 1
          success = true
        end
      end
      if success
        $game_player.direction_fix = true
        pbSurf(confirm, target_tile)
        $game_player.direction_fix = false
        return true
      end
    end
  end
  return false
end

EventHandlers.add(:on_player_interact, :start_surfing,
  proc {
    next if $PokemonGlobal.surfing
    next if $game_map.metadata&.always_bicycle
    #next if !$game_player.pbFacingTerrainTag.can_surf_freely
    next if !$game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
    pbStartSurf(true)
  }
)

# Do things after a jump to start/end surfing.
EventHandlers.add(:on_step_taken, :surf_jump,
  proc { |event|
    next if !$scene.is_a?(Scene_Map) || !event.is_a?(Game_Player)
    next if !$game_temp.surf_base_coords
    # Hide the temporary surf base graphic after jumping onto/off it
    $game_temp.surf_base_coords = nil
    # Finish up dismounting from surfing
    if $game_temp.ending_surf
      pbCancelVehicles
      $PokemonEncounters.reset_step_count
      $game_map.autoplayAsCue   # Play regular map BGM
      $game_temp.ending_surf = false
    end
  }
)

HiddenMoveHandlers::CanUseMove.add(:SURF, proc { |move, pkmn, showmsg|
  next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_SURF, showmsg)
  if $PokemonGlobal.surfing
    pbMessage(_INTL("You're already surfing.")) if showmsg
    next false
  end
  if !$game_player.can_ride_vehicle_with_follower?
    pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
    next false
  end
  if $game_map.metadata&.always_bicycle
    pbMessage(_INTL("Let's enjoy cycling!")) if showmsg
    next false
  end
  if !$game_player.pbFacingTerrainTag.can_surf_freely ||
     !$game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
    pbMessage(_INTL("No surfing here!")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:SURF, proc { |move, pokemon|
  $game_temp.in_menu = false
  pbCancelVehicles
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
  end
  #surfbgm = GameData::Metadata.get.surf_BGM
  #pbCueBGM(surfbgm, 0.5) if surfbgm
  pbStartSurfing
  next true
})

#===============================================================================
# Sweet Scent
#===============================================================================
def pbSweetScent
  if $game_screen.weather_type != :None
    pbMessage(_INTL("The sweet scent faded for some reason..."))
    return
  end
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  viewport.color.red   = 255
  viewport.color.green = 32
  viewport.color.blue  = 32
  viewport.color.alpha -= 10
  pbSEPlay("Sweet Scent")
  start_alpha = viewport.color.alpha
  duration = 2.0
  fade_time = 0.4
  pbWait(duration) do |delta_t|
    if delta_t < duration / 2
      viewport.color.alpha = lerp(start_alpha, start_alpha + 128, fade_time, delta_t)
    else
      viewport.color.alpha = lerp(start_alpha + 128, start_alpha, fade_time, delta_t - duration + fade_time)
    end
  end
  viewport.dispose
  pbSEStop(0.5)
  enctype = $PokemonEncounters.encounter_type
  if !enctype || !$PokemonEncounters.encounter_possible_here? ||
     !pbEncounter(enctype, false)
    pbMessage(_INTL("There appears to be nothing here..."))
  end
end

HiddenMoveHandlers::CanUseMove.add(:SWEETSCENT, proc { |move, pkmn, showmsg|
  next true
})

HiddenMoveHandlers::UseMove.add(:SWEETSCENT, proc { |move, pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
  end
  pbSweetScent
  next true
})

#===============================================================================
# Teleport
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:TELEPORT, proc { |move, pkmn, showmsg|
  if !$game_map.metadata&.outdoor_map
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  healing = $PokemonGlobal.healingSpot
  healing = GameData::PlayerMetadata.get($player.character_ID)&.home if !healing
  healing = GameData::Metadata.get.home if !healing   # Home
  if !healing
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  if !$game_player.can_map_transfer_with_follower?
    pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
    next false
  end
  if $game_map.metadata&.has_flag?("DisableFastTravel")
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::ConfirmUseMove.add(:TELEPORT, proc { |move, pkmn|
  healing = $PokemonGlobal.healingSpot
  healing = GameData::PlayerMetadata.get($player.character_ID)&.home if !healing
  healing = GameData::Metadata.get.home if !healing   # Home
  next false if !healing
  mapname = pbGetMapNameFromId(healing[0])
  next pbConfirmMessage(_INTL("Want to return to the healing spot used last in {1}?", mapname))
})

HiddenMoveHandlers::UseMove.add(:TELEPORT, proc { |move, pokemon|
  healing = $PokemonGlobal.healingSpot
  healing = GameData::PlayerMetadata.get($player.character_ID)&.home if !healing
  healing = GameData::Metadata.get.home if !healing   # Home
  next false if !healing
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
  end
  pbFadeOutIn do
    $game_temp.player_new_map_id    = healing[0]
    $game_temp.player_new_x         = healing[1]
    $game_temp.player_new_y         = healing[2]
    $game_temp.player_new_direction = 2
    pbDismountBike
    $scene.transfer_player
    $game_map.autoplay
    $game_map.refresh
  end
  pbEraseEscapePoint
  next true
})

#===============================================================================
# Waterfall
#===============================================================================
# Starts the ascending of a waterfall.
def pbAscendWaterfall
  return if $game_player.direction != 8   # Can't ascend if not facing up
  terrain = $game_player.pbFacingTerrainTag
  return if !terrain.waterfall && !terrain.waterfall_crest
  $stats.waterfall_count += 1
  $PokemonGlobal.ascending_waterfall = true
  $game_player.through = true
end

# Triggers after finishing each step while ascending/descending a waterfall.
def pbTraverseWaterfall
  if $game_player.direction == 2   # Facing down; descending
    terrain = $game_player.pbTerrainTag
    if ($DEBUG && Input.press?(Input::CTRL)) ||
       (!terrain.waterfall && !terrain.waterfall_crest)
      $PokemonGlobal.descending_waterfall = false
      $game_player.through = false
      return
    end
    $stats.waterfalls_descended += 1 if !$PokemonGlobal.descending_waterfall
    $PokemonGlobal.descending_waterfall = true
    $game_player.through = true
  elsif $PokemonGlobal.ascending_waterfall
    terrain = $game_player.pbTerrainTag
    if ($DEBUG && Input.press?(Input::CTRL)) ||
       (!terrain.waterfall && !terrain.waterfall_crest)
      $PokemonGlobal.ascending_waterfall = false
      $game_player.through = false
      return
    end
    $PokemonGlobal.ascending_waterfall = true
    $game_player.through = true
  end
end

def pbWaterfall
  move = :WATERFALL
  movefinder = $player.get_pokemon_with_move(move)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_WATERFALL, false) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
    return false
  end
  if pbConfirmMessage(_INTL("It's a large waterfall. Would you like to use Waterfall?"))
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    pbAscendWaterfall
    return true
  end
  return false
end

#EventHandlers.add(:on_player_interact, :waterfall,
#  proc {
#    terrain = $game_player.pbFacingTerrainTag
#    if terrain.waterfall
#      pbWaterfall
#    elsif terrain.waterfall_crest
#      pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
#    end
#  }
#)

HiddenMoveHandlers::CanUseMove.add(:WATERFALL, proc { |move, pkmn, showmsg|
  next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_WATERFALL, showmsg)
  if !$game_player.pbFacingTerrainTag.waterfall
    pbMessage(_INTL("You can't use that here.")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:WATERFALL, proc { |move, pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
  end
  pbAscendWaterfall
  next true
})
