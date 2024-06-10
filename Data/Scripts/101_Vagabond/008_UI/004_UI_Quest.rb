class QuestHeaderSprite < Sprite

  def initialize(viewport,x,y,text)
    super(viewport)
    @text = text
    self.x = x
    self.y = y
    @buttonBitmap = RPG::Cache.load_bitmap("","Graphics/UI/Quests/header")
    @selected = false
    self.bitmap = Bitmap.new(236,40)
    refresh
  end

  def selected=(value)
    @selected = value
    refresh
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0,0,@buttonBitmap,Rect.new(
      @selected ? 236 : 0, 0, 236, 40))
    textpos = [[@text,118,10,2,
      Color.new(250,250,250),Color.new(100,60,50)]]
    pbSetSystemFont(self.bitmap)
    pbDrawTextPositions(self.bitmap,textpos)
  end

  def dispose
    @buttonBitmap.dispose
    super
  end

end

class QuestBarSprite < Sprite

  def initialize(viewport,barbitmap,infobitmap,x,y,quest)
    super(viewport)
    @selected = false
    @quest = quest
    @mustrefresh = true
    @barbitmap = barbitmap
    @infobitmap = infobitmap
    @spriteX = x
    @spriteY = y
    @crop = 0
    self.x = x
    self.y = y
    self.bitmap = Bitmap.new(@barbitmap.width,@barbitmap.height + @infobitmap.height)
    update
  end

  def selected=(value)
    @selected = value
    @mustrefresh = true
  end

  def quest=(value)
    @quest = value
    @mustrefresh = true
  end

  def quest
    return @quest
  end

  def update
    if @mustrefresh
      @mustrefresh = false
      refresh
    end
    super
  end

  def refresh
    self.bitmap.clear
    if @quest
      self.bitmap.blt(0,0,@barbitmap,
        Rect.new(0,@selected ? 40 : 0,@barbitmap.width - @crop,40))
      textpos = [[@quest.display_name(@quest.status),50,10,0,
        Color.new(250,250,250),Color.new(100,60,50)],
                 [@quest.location,620,10,1,
        Color.new(250,250,250),Color.new(100,60,50)]]
      pbSetSystemFont(self.bitmap)
      pbDrawTextPositions(self.bitmap,textpos)
      #if @quest.location.length > 3
      #  text_width = self.bitmap.text_size(@quest.location).width
      #  pbSetSmallFont(self.bitmap)
      #  textpos = [["Found at", 616 - text_width, 14, 1, Color.new(250,250,250),Color.new(100,60,50)]]
      #  pbDrawTextPositions(self.bitmap, textpos)
      #end
      imagepos=[
        ["Graphics/UI/Quests/status",
         18,4,0,30*(@quest.status+1),30,30]
      ]
      pbDrawImagePositions(self.bitmap,imagepos)
    end
  end

  def shift(value)
    self.x += value
    @crop += value
    @mustrefresh = true
  end

  def showInfo
    spd = 18
    white = Color.new(255,255,255)
    shadow = Color.new(185,89,59)
    color = Color.new(236,150,87)

    content = Bitmap.new(@infobitmap.width,@infobitmap.height)
    content.blt(0,0,@infobitmap,Rect.new(0,0,@infobitmap.width,@infobitmap.height))
    pbSetSmallFont(content)

    textpos = []
    imagepos = []
    step = @quest.step
    if @quest.step >= quest.steps.length || @quest.status == 2
      step = @quest.steps.length - 1
    end
    if @quest.status >= 0
      textpos.push([@quest.money.to_s,40,158 + 186,0,white,shadow])
      textpos.push([_INTL("{1}",@quest.exp.to_s),174,158 + 186,0,white,shadow])
      if @quest.items.length > 0
        if @quest.hide_items
          imagepos.push(
            ["Graphics/Items/000",
             12,184 + 186,0,0,48,48,24,24])
          pbDrawTextPositions(content,
            [["SECRET TO EVERYBODY",40,188 + 186,0,white,shadow]])
        else
          imagepos.push(
            [sprintf("Graphics/Items/%s",@quest.items[0][0].to_s),
             12,190 + 186,0,0,48,48,24,24])
          pbDrawTextPositions(content,
            [[GameData::Item.get(@quest.items[0][0]).name,40,182 + 186,0,white,shadow]])
        end
      end
    end
    if @quest.status > 0
      lines = pbLineBreakText(content,@quest.description,220)
      for i in 0...lines.length
        s = lines[i]
        textpos.push([s,10,26+i*20,0,white,shadow])
      end
      tasks = Bitmap.new(@infobitmap.width,@infobitmap.height - 6)
      pbSetSmallFont(tasks)
      task_textpos = []
      task_imagepos = []
      offset = 4
      if @quest.status == 2
        lines = pbLineBreakText(tasks,@quest.done,348)
        for s in lines
          tasks.fill_rect(244,20+offset,356,24,color)
          tasks.fill_rect(242,22+offset,360,20,color)
          task_textpos.push([s,250,24+offset,0,white,shadow])
          offset += 20
        end
        offset += 10
      end
      for j in 0..step
        i = step - j
        complete = @quest.status == 2 || @quest.step > i
        lines = pbLineBreakText(tasks,@quest.steps[i],
          complete ? 322 : 348)
        if complete
          task_imagepos.push(
            ["Graphics/UI/Quests/status",
             246,10+offset+lines.length*10,0,90,30,30])
        end
        for s in lines
          tasks.fill_rect(244,20+offset,356,24,color)
          tasks.fill_rect(242,22+offset,360,20,color)
          task_textpos.push([s,complete ? 280 : 250,24 + offset,0,white,shadow])
          offset += 20
        end
        offset += 10
      end
      pbDrawTextPositions(tasks,task_textpos)
      pbDrawImagePositions(tasks,task_imagepos)
      content.blt(0, 0, tasks, Rect.new(0, 0, tasks.width, tasks.height))
      tasks.dispose
    else
      text = "The location of this quest is unknown."
      if @quest.full_location
        text = _INTL("This quest can be found {1}.", @quest.full_location)
      end
      lines = pbLineBreakText(content, text, 220)
      for i in 0...lines.length
        s = lines[i]
        textpos.push([s,10,26+i*20,0,white,shadow])
      end
    end

    pbDrawTextPositions(content,textpos)
    pbDrawImagePositions(content,imagepos)

    self.z += 10
    self.y = 92
    self.bitmap.blt(18,34,content,Rect.new(0,0,content.width,content.height))
    ret = 0
    loop do
      break if Input.trigger?(Input::BACK)
      if Input.trigger?(Input::UP)
        ret = -1
        break
      elsif Input.trigger?(Input::DOWN)
        ret = 1
        break
      #elsif Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
      #  ret = 2
      #  break
      elsif Input.trigger?(Input::SPECIAL)
        pbHelp(viewport,pbQuestDetailHints)
      elsif Input.trigger?(Input::ACTION) && $DEBUG
        if Input.press?(Input::CTRL)
          new_status = pbNumericUpDown(
            "Choose new quest status",-1,3,@quest.status)
          @quest.status = new_status == 3 ? -1 : new_status
        else
          new_step = pbNumericUpDown(
            "Choose new quest step", 0, @quest.steps.length-1,@quest.step)
          @quest.step = new_step
        end
        break
      end
      Graphics.update
      Input.update
    end
    refresh
    self.z -= 10
    self.x = @spriteX
    self.y = @spriteY
    content.dispose
    return ret
  end

end

class QuestScrollSprite < Sprite

  def initialize(viewport,x,y)
    super(viewport)
    self.x = x
    self.y = y
    @scrollbitmap = RPG::Cache.load_bitmap("","Graphics/UI/Quests/scroll")
    @barbitmap = RPG::Cache.load_bitmap("","Graphics/UI/Quests/scrollbar")
    @mustrefresh = true
    @scrollpos = 0
    @scrollmax = @barbitmap.height - @scrollbitmap.height - 4
    self.bitmap = Bitmap.new(@barbitmap.width, @barbitmap.height)
    update
  end

  def update
    if @mustrefresh
      @mustrefresh = false
      refresh
    end
    super
  end

  def scroll(scroll,max,items)
    @mustrefresh = true
    if max > items
      @scrollpos = (scroll * @scrollmax / (max - items))
    else
      @scrollpos = 0
    end
  end

  def refresh
    self.bitmap.clear
    self.bitmap.blt(0,0,@barbitmap,Rect.new(0,0,@barbitmap.width,@barbitmap.height))
    self.bitmap.blt(2,2+@scrollpos,@scrollbitmap,Rect.new(0,0,@scrollbitmap.width,@scrollbitmap.height))
  end

  def dispose
    @scrollbitmap.dispose
    @barbitmap.dispose
    super
  end

end

def pbShowQuests(show_quest=nil)
  main_quests=[]
  side_quests=[]
  $quests.each { |quest|
    if quest.status>=0 || $DEBUG
      if quest.type == PBQuestType::Main
        main_quests.push(quest)
      else
        side_quests.push(quest)
      end
    end
  }
  main_quests = pbSortQuests(main_quests)
  side_quests = pbSortQuests(side_quests)
  if $game_variables[CURRENTMINIQUEST].is_a?(MiniQuest)
    side_quests = [$game_variables[CURRENTMINIQUEST]] + side_quests
  end
  no_prev = true

  viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  text_color1 = Color.new(250, 250, 250)
  text_color2 = Color.new(50, 50, 100)
  text_color4 = Color.new(100, 50, 50)#Color.new(144, 80, 80)

  questtab = $game_variables[LAST_PAGE]
  newtab = questtab
  selected = 0
  scroll = 0
  quest_list = main_quests if questtab==0
  quest_list = side_quests if questtab==1

  sprites={}
  sprites["bg"] = IconSprite.new(0,0,viewport)
  sprites["bg"].setBitmap("Graphics/UI/Quests/bg")

  sprites["tab1"]=QuestHeaderSprite.new(viewport,22 + 128,52,"Main")
  sprites["tab2"]=QuestHeaderSprite.new(viewport,254 + 128,52,"Side")
  sprites["tab1"].z=2
  sprites["tab2"].z=2
  questtab == 0 ?
    (sprites["tab1"].selected = true) :
    (sprites["tab2"].selected = true)

  barbitmap = RPG::Cache.load_bitmap("","Graphics/UI/Quests/bar")
  infobitmap = RPG::Cache.load_bitmap("","Graphics/UI/Quests/details")
  for i in 0...11
    sprites[_INTL("quest{1}",i)] = QuestBarSprite.new(
      viewport,barbitmap,infobitmap,56,94+i*40,quest_list[i])
    sprites[_INTL("quest{1}",i)].z=4
  end

  sprites["quest0"].selected = true

  sprites["scrollbar"]=QuestScrollSprite.new(viewport,686,90)
  sprites["scrollbar"].z=20
  
  sprites["control_exit"] = KeybindSprite.new(Input::BACK, "Exit", 80, Graphics.height - 36, viewport)
  sprites["control_details"] = KeybindSprite.new(Input::USE, "Details", 156, Graphics.height - 36, viewport)
  sprites["control_sort"] = KeybindSprite.new(Input::ACTION, "Sort", 258, Graphics.height - 36, viewport)
  sprites["control_select"] = KeybindSprite.new([Input::UP, Input::DOWN], "Select Quest", 338, Graphics.height - 36, viewport)
  sprites["control_page"] = KeybindSprite.new([Input::LEFT, Input::RIGHT], "Change Page", 518, Graphics.height - 36, viewport)

  pbFadeInAndShow(sprites)

  flag_timer = 0
  scroll_timer = 0
  scroll_dir = ""
  fast_scroll = false
  font_size = 10
  loop do
    Graphics.update
    Input.update
    viewport.update
    pbUpdateSpriteHash(sprites)
    update = false
    if Input.press?(Input::DOWN) && scroll_dir=="down"
      scroll_timer+=1
      if scroll_timer>=30
        fast_scroll=true
        scroll_dir = "do_down"
      end
    elsif Input.press?(Input::UP) && scroll_dir=="up"
      scroll_timer+=1
      if scroll_timer>=30
        fast_scroll=true
        scroll_dir = "do_up"
      end
    else
      scroll_timer = 0
    end
    if Input.trigger?(Input::DOWN) || scroll_dir=="do_down"
      scroll_timer = 0 if !fast_scroll
      scroll_timer = 25 if fast_scroll
      scroll_dir = "down"
      selected += 1
      scroll += 1 if selected > (scroll+10)
      if selected>quest_list.length-1
        if fast_scroll
          selected = quest_list.length-1
          scroll = quest_list.length-11 if quest_list.length > 10
        else
          selected = 0
          scroll = 0
        end
      end
      fast_scroll=false
      update = true
    elsif Input.trigger?(Input::UP) || scroll_dir=="do_up"
      scroll_timer = 0 if !fast_scroll
      scroll_timer = 25 if fast_scroll
      scroll_dir = "up"
      selected -= 1
      scroll -= 1 if selected < scroll 
      if selected < 0
        if fast_scroll
          selected = 0
          scroll = 0
        else
          selected = quest_list.length-1
          if selected > (scroll+10) && quest_list.length > 10
            scroll = quest_list.length-11
          else
            scroll = 0
          end
        end
      end
      fast_scroll=false
      update = true
    elsif Input.trigger?(Input::LEFT)
      selected = 0 if newtab == 1
      scroll = 0 if newtab == 1
      newtab = 0
      update = true
    elsif Input.trigger?(Input::RIGHT)
      selected = 0 if newtab == 0
      scroll = 0 if newtab == 0
      newtab = 1
      update = true
    elsif Input.trigger?(Input::SPECIAL)
      pbHelp(viewport,pbQuestHints)
    elsif Input.trigger?(Input::BACK)
      break
    elsif Input.trigger?(Input::ACTION)
      methods = ["Status", "Alphabetical", "Location"]
      method = methods[$game_variables[QUEST_SORTING]]
      help_text = _INTL("What to sort by?\nCurrently: {1}", method)
      choice = pbShowCommandsWithHelp(nil,
        methods + ["Cancel"],
        [help_text, help_text, help_text, help_text],
        999, $game_variables[QUEST_SORTING])
      if choice <= 2
        $game_variables[QUEST_SORTING] = choice
        pbSortQuests(main_quests)
        pbSortQuests(side_quests)
        update = true
      end
    elsif Input.trigger?(Input::USE)
      if quest_list[selected].status < 0 && !$DEBUG
        next
      end
      ret = -1
      while ret != 0
        selquest = sprites[_INTL("quest{1}",selected - scroll)]
        Input.update
        for i in 0...11
          q = sprites[_INTL("quest{1}",i)]
          q.quest = quest_list[i + scroll]
          q.selected = false
          if q != selquest
            q.shift(16)
            q.update
          end
        end
        selquest.selected = true
        selquest.update
        ret = selquest.showInfo
        if ret == 2
          newtab = (questtab == 0) ? 1 : 0
          selected = 0
          scroll = 0
          if newtab == 0
            questtab = newtab
            quest_list = main_quests
          elsif newtab == 1
            questtab = newtab
            quest_list = side_quests
          end
          sprites["tab1"].selected = (questtab == 0)
          sprites["tab2"].selected = (questtab == 1)
        elsif ret == 1
          loop do
            selected += 1
            scroll += 1 if selected > (scroll+10)
            if selected > quest_list.length-1
              selected = 0
              scroll = 0
            end
            break if quest_list[selected].status >= 0 || $DEBUG
          end
        elsif ret == -1
          loop do
            selected -= 1
            scroll -= 1 if selected < scroll 
            if selected < 0
              selected = quest_list.length-1
              if selected > (scroll+6) && quest_list.length > 6
                scroll = quest_list.length-11
              else
                scroll = 0
              end
            end
            break if quest_list[selected].status >= 0 || $DEBUG
          end
        end
        for i in 0...11
          q = sprites[_INTL("quest{1}",i)]
          if q != selquest
            q.shift(-16)
            q.update
          end
        end
      end
      update = true
    end
    if update
      if newtab == 0
        questtab = newtab
        quest_list = main_quests
      elsif newtab == 1
        questtab = newtab
        quest_list = side_quests
      end
      sprites["tab1"].selected = (questtab == 0)
      sprites["tab2"].selected = (questtab == 1)
      sprites["scrollbar"].scroll(scroll,quest_list.length,11)
      for i in 0...11
        sprites[_INTL("quest{1}",i)].quest = quest_list[i + scroll]
        sprites[_INTL("quest{1}",i)].selected = (i == selected - scroll)
      end
    end
  end
  barbitmap.dispose
  infobitmap.dispose
  pbPlayCloseMenuSE
  pbFadeOutAndHide(sprites)
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end

def pbLineBreakText(bitmap, text, max_width)
  ret=[]
  char = ""
  line = 0
  next_string = ""
  text_length = 0
  while text.length > 0
    if text_length > max_width
      char2 = ""
      while char2!=" " && next_string.include?(" ")
        char2=next_string[(next_string.length-1)..(next_string.length-1)]
        text=char2+text
        next_string=next_string[0..(next_string.length-2)]
      end
      text_length = 0
      ret.push(next_string)
      next_string = ""
      line += 1
    end
    char = text[0..0]
    text = text[1..text.length]
    next if char==" " && next_string.length<=0
    if char == "\n"
      text_length = 0
      ret.push(next_string)
      next_string = ""
      line += 1
      next
    else
      text_length += bitmap.text_size(char).width
    end
    next_string += char
  end
  ret.push(next_string)
end

def pbSortQuests(list)

  method = $game_variables[QUEST_SORTING]

  case method
  when 0 # Status
    i=[1,0,2]
    list.sort!{|a,b|
      (a.status == b.status ?
        (a.display_name(a.status)<=>b.display_name(b.status)) :
        (a.status<0 ? 3 : i[a.status])<=>(b.status<0 ? 3 : i[b.status]))}
  when 1 # Alphabetical
    list.sort!{|a,b|
      a.display_name(a.status)<=>b.display_name(b.status)}
  when 2 # Location
    list.sort!{|a,b|
      a.location == b.location ?
        (a.display_name(a.status)<=>b.display_name(b.status)) :
        (a.location<=>b.location)}
  end

  return list

end

