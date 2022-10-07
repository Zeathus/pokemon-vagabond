def pbQuestHints
  return [
    Hint.new("This tab contains quests important to your main objective.",
      Rect.new(16,46,248,52),
      [nil,2,nil,1],0),
    Hint.new("This tab contains quests that are not necessary, but grant rewards.",
      Rect.new(248,46,248,52),
      [nil,4,0,nil],0),
    Hint.new("No symbol: You haven't found the quest Square: In progress   |   Checkmark: Done",
      Rect.new(24,94,34,250),
      [0,nil,nil,3],1),
    Hint.new("The names of the quests in your quest log.",
      Rect.new(52,94,214,250),
      [0,nil,2,4],1),
    Hint.new("The locations in which each quest is located.",
      Rect.new(260,94,214,250),
      [1,nil,3,nil],1)
  ]
end

def pbQuestDetailHints
  return [
    Hint.new("The name of the quest currently displayed.",
      Rect.new(52,94,214,34),
      [3,5,1,2],0),
    Hint.new("No symbol: You haven't found the quest Square: In progress   |   Checkmark: Done",
      Rect.new(24,94,34,34),
      [3,5,nil,0],0),
    Hint.new("The location where the quest is located.",
      Rect.new(260,94,214,34),
      [4,7,0,nil],0),
    Hint.new("This tab contains quests important to your main objective.",
      Rect.new(16,46,248,52),
      [nil,0,nil,4],0),
    Hint.new("This tab contains quests that are not necessary, but grant rewards.",
      Rect.new(248,46,248,52),
      [nil,2,3,nil],0),
    Hint.new("A general description of what the quest entails.",
      Rect.new(28,126,204,138),
      [0,6,nil,7],1),
    Hint.new("The money, exp and item rewarded by finishing the quest.",
      Rect.new(28,258,204,88),
      [5,nil,nil,7],1),
    Hint.new("A list what tasks you have done or need to do to complete the quest.",
      Rect.new(226,126,248,220),
      [2,nil,5,nil],1)
  ]
end