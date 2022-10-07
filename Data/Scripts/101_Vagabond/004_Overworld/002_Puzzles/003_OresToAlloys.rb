class OreEvent
  attr_accessor :type
  attr_accessor :x
  attr_accessor :y
  attr_accessor :event
  attr_accessor :direction
  attr_accessor :move_route
  attr_accessor :in_furnace
  attr_accessor :in_shute
  attr_accessor :melted

  def initialize(type, event, direction)
      self.type       = type
      self.x          = event.x
      self.y          = event.y
      self.event      = event
      self.direction  = direction
      self.move_route = []
      self.in_furnace = false
      self.in_shute   = false
      self.melted     = false
  end

  def move
      self.move_route.push(self.direction)
      case direction
      when PBMoveRoute::Down
          self.y += 1
      when PBMoveRoute::Left
          self.x -= 1
      when PBMoveRoute::Right
          self.x += 1
      when PBMoveRoute::Up
          self.y -= 1
      end
  end
end

class OreJunction
  attr_accessor :x
  attr_accessor :y
  attr_accessor :direction

  def initialize(event, direction)
      self.x = event.x
      self.y = event.y
      self.direction = direction
  end
end

class OreFurnace
  attr_accessor :x
  attr_accessor :y
  attr_accessor :copper
  attr_accessor :tin
  attr_accessor :contents

  def initialize(event)
      self.x = event.x
      self.y = event.y
      self.copper = 0
      self.tin = 0
      self.contents = []
  end
end

def pbOrePuzzle(max_iterations=500)
  ores = []
  junctions = []
  furnace_entries = []
  furnaces = []
  shutes = []

  for event in $game_map.events.values
      if event.name.include?("copper,") || event.name.include?("tin,")
          values = event.name.split(",")
          direction = {
              "down"  => PBMoveRoute::Down,
              "left"  => PBMoveRoute::Left,
              "right" => PBMoveRoute::Right,
              "up"    => PBMoveRoute::Up
          }[values[1]]
          ores.push(OreEvent.new(
              values[0],
              event,
              direction
          ))
      elsif event.name.include?("junction,")
          values = event.name.split(",")
          if values[1] == "var"
              direction = {
                  2 => PBMoveRoute::Down,
                  4 => PBMoveRoute::Left,
                  6 => PBMoveRoute::Right,
                  8 => PBMoveRoute::Up
              }[event.direction]
              junctions.push(OreJunction.new(
                  event,
                  direction
              ))
          else
              direction = {
                  "down"  => PBMoveRoute::Down,
                  "left"  => PBMoveRoute::Left,
                  "right" => PBMoveRoute::Right,
                  "up"    => PBMoveRoute::Up
              }[values[1]]
              junctions.push(OreJunction.new(
                  event,
                  direction
              ))
          end
      elsif event.name.include?("furnace_entry")
          furnace_entries.push(event)
      elsif event.name.include?("furnace")
          furnaces.push(OreFurnace.new(event))
      elsif event.name.include?("shute")
          shutes.push(event)
      end
  end

  failure = false
  failure_events = []

  for i in 0...max_iterations
      # Move all ores
      for ore in ores
          next if ore.in_shute || ore.in_furnace
          ore.move
          if i == 0
              ore.move_route.push(PBMoveRoute::AlwaysOnTopOn)
          end
      end

      # Check for collissions
      for ore in ores
          for other_ore in ores
              next if ore.in_shute || ore.in_furnace ||
                      other_ore.in_shute || other_ore.in_furnace
              if ore != other_ore && ore.x == other_ore.x && other_ore.y == ore.y
                  failure = true
                  failure_events = [ore, other_ore]
                  break
              end
          end
          break if failure
      end
      break if failure

      # Check for junctions
      for ore in ores
          for junction in junctions
              if ore.x == junction.x && ore.y == junction.y
                  ore.direction = junction.direction
              end
          end
      end

      # Check for furnace entries
      for ore in ores
          for entry in furnace_entries
              if ore.x == entry.x && ore.y == entry.y
                  ore.move_route.push(PBMoveRoute::AlwaysOnTopOff)
              end
          end
      end

      # Check for dispatch shutes
      for ore in ores
          for shute in shutes
              if ore.x == shute.x && ore.y == shute.y
                  ore.in_shute = true
              end
          end
      end

      # Check for furnaces
      for ore in ores
          next if ore.in_shute || ore.in_furnace
          for furnace in furnaces
              if ore.x == furnace.x && ore.y == furnace.y
                  ore.in_furnace = true
                  furnace.contents.push(ore)
                  if ore.type == "copper"
                      furnace.copper += 1
                  elsif ore.type == "tin"
                      furnace.tin += 1
                  end
                  if furnace.tin > 1 || furnace.copper > 1
                      #failure_events = [furnace]
                      failure = true
                      break
                  end
                  if furnace.tin == 1 && furnace.copper == 1
                      furnace.copper = 0
                      furnace.tin = 0
                      furnace.contents[0].melted = true
                      ore = furnace.contents[1]
                      furnace.contents = []
                      ore.in_furnace = false
                      ore.move_route.push(PBMoveRoute::Script,
                          _INTL("self.character_name = 'ingots'"))
                      ore.move_route.push(PBMoveRoute::Wait, 1)
                      ore.move_route.push(PBMoveRoute::Script,
                          _INTL("self.direction = 4"))
                      ore.move_route.push(PBMoveRoute::Wait, 1)
                      ore.move_route.push(PBMoveRoute::Script,
                          _INTL("self.pattern = 0"))
                  end
              end
          end
          break if failure
      end
      break if failure

      success = true
      deadlock = true
      for ore in ores
          if !(ore.in_shute || ore.in_furnace || ore.melted)
              deadlock = false
          end
          if !(ore.in_shute || ore.melted)
              success = false
          end
      end
      if success
          break
      elsif deadlock
          failure = true
          break
      end
  end

  longest_route = ores[0]
  for ore in ores
      if ore.move_route.length > longest_route.move_route.length
          longest_route = ore
      end
  end
  if failure
      longest_route.move_route.push(PBMoveRoute::Script,
          _INTL("pbSEPlay('GUI sel buzzer', 100, 100)"))
      for ore in ores
          if failure_events.include?(ore)
              for i in 0...4
                  ore.move_route.push(PBMoveRoute::Opacity, 0)
                  ore.move_route.push(PBMoveRoute::Wait, 2)
                  ore.move_route.push(PBMoveRoute::Opacity, 255)
                  ore.move_route.push(PBMoveRoute::Wait, 2)
              end
          else
              ore.move_route.push(PBMoveRoute::Wait, 4 * 4)
          end
      end
  else
      longest_route.move_route.push(PBMoveRoute::Script,
          _INTL("pbSEPlay('Mining reveal full', 100, 100)"))
  end

  for ore in ores
      ore.move_route.push(PBMoveRoute::AlwaysOnTopOff)
      ore.move_route.push(PBMoveRoute::Script,
          _INTL("self.character_name = '{1}'", ore.event.character_name))
      ore.move_route.push(PBMoveRoute::Wait, 1)
      ore.move_route.push(PBMoveRoute::Script,
          _INTL("self.direction = {1}", ore.event.direction))
      ore.move_route.push(PBMoveRoute::Wait, 1)
      ore.move_route.push(PBMoveRoute::Script,
          _INTL("self.pattern = {1}", ore.event.pattern))
      ore.move_route.push(PBMoveRoute::Wait, 1)
      ore.move_route.push(PBMoveRoute::Script,
          _INTL("self.moveto({1}, {2})", ore.event.x, ore.event.y))
      ore.move_route.push(PBMoveRoute::Opacity, 255)
  end

  for ore in ores
      pbMoveRoute(ore.event, ore.move_route)
  end

  @move_route_waiting = true

  return !failure
end