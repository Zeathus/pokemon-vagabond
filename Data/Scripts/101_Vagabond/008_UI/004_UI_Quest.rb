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

  def initialize(viewport,barbitmap,x,y,quest)
    super(viewport)
    @selected = false
    @quest = quest
    @mustrefresh = true
    @barbitmap = barbitmap
    @spriteX = x
    @spriteY = y
    @crop = 0
    self.x = x
    self.y = y
    self.bitmap = Bitmap.new(@barbitmap.width,@barbitmap.height)
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
        Rect.new(0, @selected ? (@barbitmap.height / 4) : 0, @barbitmap.width - @crop, (@barbitmap.height / 4)))
      textpos = [[@quest.display_name(@quest.status),88,16,0,
        Color.new(250,250,250),Color.new(100,60,50)]]
      pbSetSmallFont(self.bitmap)
      pbDrawTextPositions(self.bitmap,textpos)
      imagepos=[
        ["Graphics/UI/Quests/status",
          50, 8, 0, 30*(@quest.status + 1), 30, 30],
        ["Graphics/UI/Quests/quest_type",
          18, 0, 0, 48*@quest.type, 32, 48]
      ]
      pbDrawImagePositions(self.bitmap,imagepos)
    end
  end

  def shift(value)
    self.x += value
    @crop += value
    @mustrefresh = true
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

class QuestInfoSprite < IconSprite

  def initialize(x, y, viewport)
    super(x, y, viewport)
    @overlay = Sprite.new(viewport)
    @overlay.x = x
    @overlay.y = y
    @itemsprite = ItemIconSprite.new(x + 172, y + 416, :NONE, viewport)
    @itemsprite.zoom_x = 0.5
    @itemsprite.zoom_y = 0.5
  end

  def setBitmap(path)
    super(path)
    @overlay.bitmap&.dispose
    @overlay.bitmap = Bitmap.new(self.bitmap.width, self.bitmap.height)
  end

  def color=(value)
    super(value)
    @overlay.color = value
    @itemsprite.color = value
  end

  def tone=(value)
    super(value)
    @overlay.tone = value
    @itemsprite.tone = value
  end

  def update
    super
    @overlay.update
    @itemsprite.update
  end

  def setQuest(quest)
    @overlay.bitmap.clear
    return if quest.nil?

    white = Color.new(255,255,255)
    shadow = Color.new(185,89,59)
    color = Color.new(236,150,87)

    pbSetSystemFont(@overlay.bitmap)
    pbDrawTextPositions(@overlay.bitmap, [[quest.display_name(quest.status),170,10,2,white,shadow]])

    pbSetSmallFont(@overlay.bitmap)

    type_text = [
      "Side Quest",
      "Unlock Quest",
      "Side Story",
      "Challenge",
      "Main Quest",
      "Botanist",
      "Miner",
      "Crafter",
      "Doctor",
      "Fisher",
      "Breeder",
      "Engineer",
      "Professor",
      "Ranger",
      "Archeologist"
    ][quest.type]
    status_text = [
      "Unavailable",
      "Available",
      "In Progress",
      "Completed"
    ][quest.status + 1]
    textpos = [
      [type_text,46,48,0,white,shadow],
      [status_text,204,48,0,white,shadow],
      [(quest.location == "" ? "???" : quest.location),16,192,0,white,shadow]
    ]    
    imagepos = [
      ["Graphics/UI/Quests/status",
        170, 40, 0, 30*(quest.status + 1), 30, 30],
      ["Graphics/UI/Quests/quest_type",
        12, 32, 0, 48*quest.type, 32, 48]
    ]

    step = quest.step
    if quest.step >= quest.steps.length || quest.status == 2
      step = quest.steps.length - 1
    end
    if quest.status >= 0 || true
      textpos.push([_INTL("${1}", number_with_delimiter(quest.money)),14,408,0,white,shadow]) if quest.money > 0
      textpos.push([_INTL("{1}%",quest.exp),108,408,0,white,shadow]) if quest.exp > 0
      if quest.items.length > 0
        @itemsprite.visible = true
        if quest.hide_items && quest.status < 2
          @itemsprite.item = :NONE
          pbDrawTextPositions(@overlay.bitmap,
            [[_INTL("Find out!"),188,408,0,white,shadow]])
        else
          @itemsprite.item = quest.items[0][0]
          item_text = GameData::Item.get(quest.items[0][0]).name
          if quest.items[0][1] > 1
            item_text = _INTL("{1}x {2}", quest.items[0][1], item_text)
          end
          if item_text.length >= 15
            pbSetSmallestFont(@overlay.bitmap)
          end
          pbDrawTextPositions(@overlay.bitmap,
            [[item_text,188,408,0,white,shadow]])
          pbSetSmallFont(@overlay.bitmap)
        end
      else
        @itemsprite.visible = false
      end
    end
    if quest.status > 0
      tasks = Bitmap.new(self.bitmap.width,self.bitmap.height - 58)
      lines = pbLineBreakText(@overlay.bitmap,quest.description,312)
      for i in 0...lines.length
        s = lines[i]
        textpos.push([s,14,76+i*20,0,white,shadow])
      end
      pbSetSmallFont(tasks)
      task_textpos = []
      task_imagepos = []
      offset = 220
      if quest.status == 2
        lines = pbLineBreakText(tasks,quest.done,308)
        for s in lines
          tasks.fill_rect(12,20+offset,316,24,color)
          tasks.fill_rect(10,22+offset,320,20,color)
          task_textpos.push([s,16,24+offset,0,white,shadow])
          offset += 20
        end
        offset += 10
      end
      for j in 0..step
        i = step - j
        complete = quest.status == 2 || quest.step > i
        lines = pbLineBreakText(tasks,quest.steps[i],
          complete ? 284 : 308)
        if complete
          task_imagepos.push(
            ["Graphics/UI/Quests/status",
             12,10+offset+lines.length*10,0,90,30,30])
        end
        for s in lines
          tasks.fill_rect(12,20+offset,316,24,color)
          tasks.fill_rect(10,22+offset,320,20,color)
          task_textpos.push([s,complete ? 46 : 16,24 + offset,0,white,shadow])
          offset += 20
        end
        offset += 10
        break if offset >= tasks.height
      end
      pbDrawTextPositions(tasks,task_textpos)
      pbDrawImagePositions(tasks,task_imagepos)
      @overlay.bitmap.blt(0, 0, tasks, Rect.new(0, 0, tasks.width, tasks.height))
      tasks.dispose
    else
      text = "The location of this quest is unknown."
      if quest.full_location
        text = _INTL("Find the quest {1}.", quest.full_location)
      end
      lines = pbLineBreakText(@overlay.bitmap, text, 320)
      for i in 0...lines.length
        s = lines[i]
        textpos.push([s,10,76+i*20,0,white,shadow])
      end
    end

    pbDrawTextPositions(@overlay.bitmap,textpos)
    pbDrawImagePositions(@overlay.bitmap,imagepos)
  end

  def dispose
    @overlay.dispose
    @itemsprite.dispose
    super
  end

  def number_with_delimiter(num)
    neg = (num < 0)
    num = num.abs
    str = num.to_s
    ret = ""
    if str.include?(".")
      ret = str[str.index(".")...str.length]
      str = str[0...str.index(".")]
    end
    while str.length > 3
      sub = str[(str.length-3)...str.length]
      str = str[0...(str.length-3)]
      ret = "," + sub + ret
    end
    ret = str + ret
    ret = "-" + ret if neg
    return ret
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
  for i in 0...11
    sprites[_INTL("quest{1}",i)] = QuestBarSprite.new(
      viewport,barbitmap,52,94+i*40,quest_list[i])
    sprites[_INTL("quest{1}",i)].z=4
  end

  sprites["quest0"].selected = true

  sprites["infobox"] = QuestInfoSprite.new(370, 98, viewport)
  sprites["infobox"].setBitmap("Graphics/UI/Quests/details")
  sprites["infobox"].setQuest(quest_list[selected])

  # sprites["scrollbar"]=QuestScrollSprite.new(viewport,686,90)
  # sprites["scrollbar"].z=20
  
  sprites["control_exit"] = KeybindSprite.new(Input::BACK, "Exit", 80, Graphics.height - 36, viewport)
  # sprites["control_details"] = KeybindSprite.new(Input::USE, "Details", 156, Graphics.height - 36, viewport)
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
      scroll += 1 if selected > (scroll+9)
      scroll = [0, [scroll, quest_list.length - 11].min].max
      if selected>quest_list.length-1
        if fast_scroll
          selected = quest_list.length-1
          scroll = quest_list.length-11 if quest_list.length > 10
        else
          pbPlayCursorSE
          selected = 0
          scroll = 0
        end
      else
        pbPlayCursorSE
      end
      fast_scroll = false
      update = true
    elsif Input.trigger?(Input::UP) || scroll_dir=="do_up"
      scroll_timer = 0 if !fast_scroll
      scroll_timer = 25 if fast_scroll
      scroll_dir = "up"
      selected -= 1
      scroll -= 1 if selected - 1 < scroll
      scroll = [0, [scroll, quest_list.length - 11].min].max
      if selected < 0
        if fast_scroll
          selected = 0
          scroll = 0
        else
          pbPlayCursorSE
          selected = quest_list.length-1
          if selected > (scroll+10) && quest_list.length > 10
            scroll = quest_list.length-11
          else
            scroll = 0
          end
        end
      else
        pbPlayCursorSE
      end
      fast_scroll = false
      update = true
    elsif Input.trigger?(Input::LEFT)
      pbPlayCursorSE
      selected = 0 if newtab == 1
      scroll = 0 if newtab == 1
      newtab = 0
      update = true
    elsif Input.trigger?(Input::RIGHT)
      pbPlayCursorSE
      selected = 0 if newtab == 0
      scroll = 0 if newtab == 0
      newtab = 1
      update = true
    elsif Input.trigger?(Input::SPECIAL)
      pbHelp(viewport,pbQuestHints)
    elsif Input.trigger?(Input::BACK)
      break
    elsif Input.trigger?(Input::ACTION)
      methods = ["Status", "Alphabetical", "Location", "Type"]
      method = methods[$game_variables[QUEST_SORTING]]
      help_text = _INTL("What to sort by?\nCurrently: {1}", method)
      choice = pbShowCommandsWithHelp(nil,
        methods + ["Cancel"],
        [help_text, help_text, help_text, help_text, help_text],
        999, $game_variables[QUEST_SORTING])
      if choice <= 3
        $game_variables[QUEST_SORTING] = choice
        pbSortQuests(main_quests)
        pbSortQuests(side_quests)
        update = true
      end
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
      # sprites["scrollbar"].scroll(scroll,quest_list.length,11)
      for i in 0...11
        sprites[_INTL("quest{1}",i)].quest = quest_list[i + scroll]
        sprites[_INTL("quest{1}",i)].selected = (i == selected - scroll)
      end
      sprites["infobox"].setQuest(quest_list[selected])
    end
  end
  barbitmap.dispose
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

  def default_sort(a, b)
    return (a.type<=>b.type) if a.type != b.type
    i=[1,0,2]
    return (a.status<0 ? 3 : i[a.status])<=>(b.status<0 ? 3 : i[b.status]) if a.status != b.status
    return (a.display_name(a.status)<=>b.display_name(b.status))
  end

  case method
  when 0 # Status
    i=[1,0,2]
    list.sort!{|a,b|
      (a.status == b.status ?
        default_sort(a, b) :
        (a.status<0 ? 3 : i[a.status])<=>(b.status<0 ? 3 : i[b.status]))}
  when 1 # Alphabetical
    list.sort!{|a,b|
      a.display_name(a.status)<=>b.display_name(b.status)}
  when 2 # Location
    list.sort!{|a,b|
      a.location == b.location ?
        default_sort(a, b) :
        (a.location<=>b.location)}
  when 3 # Type
    list.sort!{|a,b|
      a.type == b.type ?
        default_sort(a, b) :
        (a.type<=>b.type)}
  end

  return list

end

