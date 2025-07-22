def compile_quests(path = "PBS/quests.txt")
  compile_pbs_file_message_start(path)
  GameData::Quest::DATA.clear
  quest_names           = []
  # Read from PBS file
  File.open(path, "rb") { |f|
    FileLineData.file = path   # For error reporting
    # Read a whole section's lines at once, then run through this code.
    # contents is a hash containing all the XXX=YYY lines in that section, where
    # the keys are the XXX and the values are the YYY (as unprocessed strings).
    schema = GameData::Quest.schema
    idx = 0
    pbEachFileSection(f) { |contents, quest_id|
      echo "." if idx % 50 == 0
      idx += 1
      Graphics.update if idx % 250 == 0
      FileLineData.setSection(quest_id, "header", nil)   # For error reporting
      # Raise an error if a quest number is invalid or used twice
      contents["InternalName"] = quest_id
      contents["Steps"] = []
      contents["MapGuides"] = []
      # Go through schema hash of compilable data and compile this section
      for key in schema.keys
        # Skip empty properties, or raise an error if a required property is
        # empty
        if nil_or_empty?(contents[key])
          if ["Name", "InternalName"].include?(key)
            raise _INTL("The entry {1} is required in {2} section {3}.", key, path, quest_id)
          end
          contents[key] = nil
          next
        end
        # Raise an error if a quest internal name is used twice
        FileLineData.setSection(quest_id, key, contents[key])   # For error reporting
        if GameData::Quest::DATA[contents["InternalName"].to_sym]
          raise _INTL("Quest ID '{1}' is used twice.\r\n{2}", contents["InternalName"], FileLineData.linereport)
        end
        # Compile value for key
        value = pbGetCsvRecord(contents[key], key, schema[key])
        value = nil if value.is_a?(Array) && value.length == 0
        contents[key] = value
        # Sanitise data
        case key
        when "Items"
          item_array = []
          for i in 0...value.length
            item_array.push([value[i][0], value[i][1] || 1, i])
          end
          item_array.sort! { |a, b| (a[0] == b[0]) ? a[2] <=> b[2] : a[0] <=> b[0] }
          contents[key] = item_array
        when "RequireMaps", "RequireQuests"
          contents[key] = [contents[key]] if !contents[key].is_a?(Array)
          contents[key].compact!
        when "PartyMembers", "ActiveMembers"
          contents[key] = [contents[key]] if !contents[key].is_a?(Array)
          contents[key].compact!
          for i in 0...contents[key].length
            sym = contents[key][i].to_sym
            if !hasConst?(PBParty,sym)
              raise _INTL("Party Member {1} does not exist.", sym.to_s)
            end
            contents[key][i] = getID(PBParty, sym)
          end
        when "Type"
          sym = contents[key].to_sym
          if !hasConst?(PBQuestType,sym)
            raise _INTL("{1} is not a valid quest type.", sym.to_s)
          end
          contents[key] = getID(PBQuestType, sym)
        end
        for i in 1...GameData::Quest::MAX_STEPS
          if key == _INTL("Step{1}", i)
            contents["Steps"][i-1] = value
          elsif key == _INTL("Map{1}", i)
            contents["MapGuides"][i-1] = [value[0], value[1]]
          end
        end
      end

      if contents["ShowAvailable"].nil?
        if contents["RequireMaps"].nil? && contents["RequireQuests"].nil? &&
           contents["Require"].nil? && contents["PartyMembers"].nil?
          contents["ShowAvailable"] = false
        else
          contents["ShowAvailable"] = true
        end
      end

      # Construct quest hash
      quest_symbol = contents["InternalName"].to_sym
      quest_hash = {
        :id                    => contents["InternalName"].to_sym,
        :name                  => contents["Name"],
        :type                  => contents["Type"],
        :description           => contents["Description"],
        :location              => contents["Location"],
        :full_location         => contents["FullLocation"],
        :done                  => contents["Done"],
        :steps                 => contents["Steps"],
        :map_guides            => contents["MapGuides"],
        :money                 => contents["Money"],
        :exp                   => contents["Exp"],
        :items                 => contents["Items"],
        :hide_items            => contents["HideItems"],
        :give_items            => contents["GiveItems"],
        :hide_name             => contents["HideName"],
        :require_maps          => contents["RequireMaps"],
        :require_quests        => contents["RequireQuests"],
        :require               => contents["Require"],
        :party_members         => contents["PartyMembers"],
        :active_members        => contents["ActiveMembers"],
        :auto_finish           => contents["AutoFinish"],
        :show_available        => contents["ShowAvailable"]
      }
      # Add quest's data to records
      GameData::Quest.register(quest_hash)
      quest_names.push(quest_hash[:name])
    }
  }
  # Save all data
  GameData::Quest.save
  #MessageTypes.setMessages(MessageTypes::Quest, quest_names)
  Graphics.update
  process_pbs_file_message_end
end 