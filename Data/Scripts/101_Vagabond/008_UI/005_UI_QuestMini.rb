def pbMiniQuests
  day = $game_variables[MINIQUESTDAY]
  count = $game_variables[MINIQUESTCOUNT]

  if pbGetTimeNow.day != day || !$game_variables[MINIQUESTLIST].is_a?(Array)
    quests = []
    level = pbJob("G.P.O.").level
    max = 5 + level
    for i in 0...max
      dif = 0
      case level
      when 1
        dif = 0
      when 2
        dif = rand(2)
      when 3
        dif = rand(2)+rand(2)
      when 4
        dif = rand(2)+rand(3)
      when 5
        dif = rand(4)
        # dif+=1 if dif==3 && rand(3)==0 # Master difficulty tasks don't work yet
      end
      quests.push(MiniQuest.generate(dif))
    end
    $game_variables[MINIQUESTDAY] = pbGetTimeNow.day
    $game_variables[MINIQUESTLIST] = quests
  end
  return $game_variables[MINIQUESTLIST]
end

def pbRemoveMiniQuestFromList(quest)
  quests = $game_variables[MINIQUESTLIST]
  for i in 0...quests.length
    if quests[i]==quest
      level = pbJob("G.P.O.").level
      dif = 0
      case level
      when 1
        dif = 0
      when 2
        dif = rand(2)
      when 3
        dif = rand(2)+rand(2)
      when 4
        dif = rand(2)+rand(3)
      when 5
        dif = rand(4)
        # dif+=1 if dif==3 && rand(3)==0 # Master difficulty tasks don't work yet
      end
      quests[i] = MiniQuest.generate(dif)
    end
  end
end

def pbMiniQuestMenu

  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  sprites = {}

  ret = 0

  quests = pbMiniQuests
  names = []
  for q in quests
    names.push(q.name)
  end

  sprites["searchlist"]=Window_ComplexCommandPokemon.newEmpty(90,72,308,422,viewport)
  sprites["searchlist"].baseColor=Color.new(248,248,248)
  sprites["searchlist"].shadowColor=Color.new(88,88,80)
  sprites["searchlist"].commands=[
    "G.P.O. Tasks",
    names + ["Cancel"]
  ]
  sprites["auxlist"]=Window_UnformattedTextPokemon.newWithSize("",400,72,284,224,viewport)
  sprites["auxlist"].baseColor=Color.new(248,248,248)
  sprites["auxlist"].shadowColor=Color.new(88,88,80)
  sprites["messagebox"]=Window_UnformattedTextPokemon.newWithSize("",400,296,284,198,viewport)
  sprites["messagebox"].baseColor=Color.new(248,248,248)
  sprites["messagebox"].shadowColor=Color.new(88,88,80)
  sprites["messagebox"].letterbyletter=false

  sprites["searchlist"].index=1
  searchlist=sprites["searchlist"]
  sprites["messagebox"].visible=true
  sprites["auxlist"].visible=true
  sprites["searchlist"].visible=true
  pbRefreshMiniQuestMenu(sprites,quests)
  pbFadeInAndShow(sprites)
  pbActivateWindow(sprites,"searchlist"){
     loop do
       Graphics.update
       Input.update
       oldindex=searchlist.index
       pbUpdateSpriteHash(sprites)
       if searchlist.index==0
         if oldindex == 1
           searchlist.index = quests.length + 1
         else
           searchlist.index = 1
         end
       end
       if searchlist.index == 1
         searchlist.top_row = 0
         searchlist.index = 1
       end
       if searchlist.index!=oldindex
         pbRefreshMiniQuestMenu(sprites,quests)
       end
       if Input.trigger?(Input::C)
         pbPlayDecisionSE()
         if searchlist.index==quests.length + 1
           break
         else
           index = searchlist.index - 1
           Kernel.pbMessage(_INTL(
             "Do you want to accept \"{1}\"?\\ch[1,2,Yes,No]",
             quests[index].name))
           if $game_variables[1]==0
             ret = quests[index]
             break
           end
         end
       elsif Input.trigger?(Input::B)
         pbPlayCancelSE()
         break
       end
     end
  }
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose
  Input.update
  return ret

end

def pbRefreshMiniQuestMenu(sprites,quests)
  searchlist=sprites["searchlist"]
  messagebox=sprites["messagebox"]
  auxlist=sprites["auxlist"]
  index = searchlist.index-1
  if quests[index]
    quest = quests[index]
    auxlist.text = quest.description
    difficulty = [
      "Rookie",
      "Intermediate",
      "Advanced",
      "Expert",
      "Master"
    ][quest.difficulty]
    messagebox.text = sprintf(
      "%s\nDifficulty: %s\nRewards:\n   Money: $%d\n   Item:   %s",
      quest.trainer,difficulty,quest.money,GameData::Item.get(quest.items[0][0]).name)
  else
    auxlist.text=""
    messagebox.text=""
  end

end

def pbMiniQuestHasWonCup(name)
  if $game_variables[MiniQuest_WON_CUPS].is_a?(Array)
    for cup in $game_variables[MiniQuest_WON_CUPS]
      return true if cup == name
    end
  end
  return false
end

def pbMiniQuestCup
  return $game_variables[MiniQuest_CUP]
end

def pbMiniQuestCupIndex
  cup = pbMiniQuestCup
  return cup[cup.length - 1]
end

def pbMiniQuestCupNextIndex
  cup = pbMiniQuestCup
  cup[cup.length - 1]+=1
end

def pbMiniQuestCupIsDone
  cup = pbMiniQuestCup
  cup[cup.length - 1]>=cup[3].length
end

def pbMiniQuestCupTrainer
  cup = pbMiniQuestCup
  index = pbMiniQuestCupIndex
  return pbTrainerBattle(
    cup[3][index][0],
    cup[3][index][1],
    _I(cup[3][index][3]),
    false,
    cup[3][index][2] ? cup[3][index][2] : 0,
    true,
    nil,
    false)
end

def pbMiniQuestWin(cup)

  if !$game_variables[MiniQuest_WON_CUPS].is_a?(Array)
    $game_variables[MiniQuest_WON_CUPS] = []
  end

  if !$game_variables[MiniQuest_WON_CUPS].include?(cup[0])
    $game_variables[MiniQuest_WON_CUPS].push(cup[0])
    points = (100 * (2**(cup[2][2]-1)))
    $game_variables[MiniQuest_POINTS] += points
    return points
  end

  return false

end