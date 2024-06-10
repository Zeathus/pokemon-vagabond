def pbMiniQuests
  day = $game_variables[MINIQUESTDAY]
  count = $game_variables[MINIQUESTCOUNT]

  if pbGetTimeNow.day != day || !$game_variables[MINIQUESTLIST].is_a?(Array)
    quests = []
    max = 3
    max += 1 if count >= 1
    max += 1 if count >= 2
    max += 1 if count >= 6
    max += 1 if count >= 12
    max += 1 if count >= 20
    for i in 0...max
      if count==0
        dif=0
      elsif count==1
        dif=0
        dif=1 if i > 3
      elsif count < 6
        dif=rand(2)+rand(2)
      elsif count < 12
        dif=rand(2)+rand(2)+rand(2)
      elsif count < 20
        dif=rand(2)+rand(3)
      elsif count < 30
        dif=rand(2)+rand(4)
      else
        dif=rand(3)+rand(3)
        dif+=1 if dif==4 && rand(3)==0
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
      count = $game_variables[MINIQUESTCOUNT]
      if count==0
        dif=0
      elsif count==1
        dif=0
        dif=1 if i > 3
      elsif count < 6
        dif=rand(2)+rand(2)
      elsif count < 12
        dif=rand(2)+rand(2)+rand(2)
      elsif count < 20
        dif=rand(2)+rand(3)
      elsif count < 30
        dif=rand(2)+rand(4)
      else
        dif=rand(3)+rand(3)
        dif+=1 if dif==4 && rand(3)==0
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

  sprites["searchtitle"]=Window_AdvancedTextPokemon.newWithSize("",2,-16,Graphics.width,64,viewport)
  sprites["searchtitle"].windowskin=nil
  sprites["searchtitle"].baseColor=Color.new(248,248,248)
  sprites["searchtitle"].shadowColor=Color.new(0,0,0)
  sprites["searchtitle"].text=_ISPRINTF("<b><outln2><ac>Tasks</ac><outln><b>")
  sprites["searchlist"]=Window_ComplexCommandPokemon.newEmpty(-6,32,258,352,viewport)
  sprites["searchlist"].baseColor=Color.new(88,88,80)
  sprites["searchlist"].shadowColor=Color.new(168,184,184)
  sprites["searchlist"].commands=[
    "Quests",
    names + ["Cancel"]
  ]
  sprites["auxlist"]=Window_UnformattedTextPokemon.newWithSize("",254,32,264,194,viewport)
  sprites["auxlist"].baseColor=Color.new(88,88,80)
  sprites["auxlist"].shadowColor=Color.new(168,184,184)
  sprites["messagebox"]=Window_UnformattedTextPokemon.newWithSize("",254,226,264,158,viewport)
  sprites["messagebox"].baseColor=Color.new(88,88,80)
  sprites["messagebox"].shadowColor=Color.new(168,184,184)
  sprites["messagebox"].letterbyletter=false

  sprites["difficulty"]=IconSprite.new(384,342,viewport)
  sprites["difficulty"].setBitmap("Graphics/UI/Stadium/difficulty")
  sprites["difficulty"].src_rect = Rect.new(0,0,120,22)
  sprites["difficulty"].z=999

  sprites["searchlist"].index=1
  searchlist=sprites["searchlist"]
  sprites["messagebox"].visible=true
  sprites["auxlist"].visible=true
  sprites["searchlist"].visible=true
  sprites["searchtitle"].visible=true
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
  difficulty=sprites["difficulty"]
  index = searchlist.index-1
  if quests[index]
    quest = quests[index]
    auxlist.text = quest.description
    messagebox.text = sprintf(
      "%s\nMoney: $%d\nItem: %s\nDifficulty: ",
      quest.trainer,quest.rewardMoney,PBItems.getName(quest.rewardItem))
    difficulty.src_rect.width = 20 * (quest.difficulty + 1)
  else
    auxlist.text=""
    messagebox.text=""
    difficulty.src_rect.width=0
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