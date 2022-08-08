class Interpreter

  alias sup_pbSetSelfSwitch pbSetSelfSwitch

  def pbSetSelfSwitch(eventid, switch_name, value, mapid = -1)
    case eventid
    when Numeric
      sup_pbSetSelfSwitch(eventid, switch_name, value, mapid)
    when String
      if mapid != -1
        echo "pbSetSelfSwitch with String does not support mapid parameter"
      else
        $game_map.events.each_value do |event|
          if event.name == eventid
            sup_pbSetSelfSwitch(event.id, switch_name, value, mapid)
          end
        end
      end
    when Array
      for i in eventid
        sup_pbSetSelfSwitch(i, switch_name, value, mapid)
      end
    end
  end

end