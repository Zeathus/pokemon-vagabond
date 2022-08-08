SaveData.register(:quests) do
  ensure_class :QuestList
  save_value { $quests }
  load_value { |value| $quests = value }
  new_game_value { QuestList.new }
end