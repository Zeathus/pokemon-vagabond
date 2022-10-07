class QuestHeaderSprite < Sprite

  def initialize(viewport,x,y,text)
    super(viewport)
    @text = text
    self.x = x
    self.y = y
    @buttonBitmap = RPG::Cache.load_bitmap("","Graphics/Pictures/Quests/header")
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
    textpos = [[@text,118,4,2,
      Color.new(250,250,250),Color.new(100,60,50)]]
    pbSetSystemFont(self.bitmap)
    pbDrawTextPositions(self.bitmap,textpos,false)
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
    self.bitmap = Bitmap.new(464,340)
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
        Rect.new(0,@selected ? 38 : 0,464 - @crop,38))
      textpos = [[@quest.display_name,50,6,0,
        Color.new(250,250,250),Color.new(100,60,50)],
                 [@quest.location,458,6,1,
        Color.new(250,250,250),Color.new(100,60,50)]]
      pbSetSmallFont(self.bitmap)
      pbDrawTextPositions(self.bitmap,textpos,false)
      imagepos=[
        ["Graphics/Pictures/Quests/status",
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

    content = Bitmap.new(446,220)
    content.blt(0,0,@infobitmap,Rect.new(0,0,446,220))
    pbSetSmallestFont(content)

    textpos = []
    imagepos = []
    step = @quest.step
    if @quest.step >= quest.steps.length || @quest.status == 2
      step = @quest.steps.length - 1
    end
    if @quest.status > 0
      lines = pbLineBreakText(content,@quest.description.upcase,192)
      for i in 0...lines.length
        s = lines[i]
        textpos.push([s,10,18+i*14,0,white,shadow])
      end
      textpos.push([@quest.money.to_s,38,152,0,white,shadow])
      textpos.push([_INTL("{1}%",@quest.exp.to_s),148,152,0,white,shadow])
      if @quest.items.length > 0
        if @quest.hide_items
          imagepos.push(
            ["Graphics/Items/000",
             12,184,0,0,48,48,24,24])
          pbDrawTextPositions(content,
            [["SECRET TO EVERYBODY",40,182,0,white,shadow]],false)
        else
          imagepos.push(
            [sprintf("Graphics/Items/%s",@quest.items[0][0].to_s),
             12,184,0,0,48,48,24,24])
          pbDrawTextPositions(content,
            [[GameData::Item.get(@quest.items[0][0]).name.upcase,40,182,0,white,shadow]],false)
        end
      end
      offset = 0
      if @quest.status == 2
        lines = pbLineBreakText(content,@quest.done.upcase,220)
        for s in lines
          content.fill_rect(210,22+offset,228,20,color)
          content.fill_rect(208,24+offset,232,16,color)
          textpos.push([s,214,18+offset,0,white,shadow])
          offset += 14
        end
        offset += 10
      end
      for j in 0..step
        i = step - j
        complete = @quest.status == 2 || @quest.step > i
        lines = pbLineBreakText(content,@quest.steps[i].upcase,
          complete ? 194 : 220)
        if complete
          imagepos.push(
            ["Graphics/Pictures/Quests/status",
             208,10+offset+lines.length*7,0,90,30,30])
        end
        for s in lines
          content.fill_rect(210,22+offset,228,20,color)
          content.fill_rect(208,24+offset,232,16,color)
          textpos.push([s,complete ? 240 : 214,18+offset,0,white,shadow])
          offset += 14
        end
        offset += 10
      end
    else
      text = "The location of this quest is unknown.".upcase
      if @quest.full_location
        text = _INTL("This quest can be found {1}.".upcase, @quest.full_location.upcase)
      end
      lines = pbLineBreakText(content, text, 192)
      for i in 0...lines.length
        s = lines[i]
        textpos.push([s,10,18+i*14,0,white,shadow])
      end
    end

    pbDrawTextPositions(content,textpos,false)
    pbDrawImagePositions(content,imagepos)

    self.z += 10
    self.y = 92
    self.bitmap.blt(18,36,content,Rect.new(0,0,446,220))
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
    @scrollbitmap = RPG::Cache.load_bitmap("","Graphics/Pictures/Quests/scroll")
    @barbitmap = RPG::Cache.load_bitmap("","Graphics/Pictures/Quests/scrollbar")
    @mustrefresh = true
    @scrollpos = 0
    @scrollmax = 254 - @scrollbitmap.height
    self.bitmap = Bitmap.new(12,258)
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
    self.bitmap.blt(0,0,@barbitmap,Rect.new(0,0,12,258))
    self.bitmap.blt(2,2+@scrollpos,@scrollbitmap,Rect.new(0,0,8,30))
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
  viewport.ox = -128
  viewport.oy = -96
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
  sprites["bg"].setBitmap("Graphics/Pictures/Quests/bg")

  sprites["tab1"]=QuestHeaderSprite.new(viewport,22,52,"Main")
  sprites["tab2"]=QuestHeaderSprite.new(viewport,254,52,"Side")
  sprites["tab1"].z=2
  sprites["tab2"].z=2
  questtab == 0 ?
    (sprites["tab1"].selected = true) :
    (sprites["tab2"].selected = true)

  barbitmap = RPG::Cache.load_bitmap("","Graphics/Pictures/Quests/bar")
  infobitmap = RPG::Cache.load_bitmap("","Graphics/Pictures/Quests/details")
  for i in 0...7
    sprites[_INTL("quest{1}",i)] = QuestBarSprite.new(
      viewport,barbitmap,infobitmap,8,92+i*36,quest_list[i])
    sprites[_INTL("quest{1}",i)].z=4
  end

  sprites["quest0"].selected = true

  sprites["scrollbar"]=QuestScrollSprite.new(viewport,472,90)
  sprites["scrollbar"].z=20

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
      scroll += 1 if selected > (scroll+6)
      if selected>quest_list.length-1
        if fast_scroll
          selected = quest_list.length-1
          scroll = quest_list.length-7 if quest_list.length > 6
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
          if selected > (scroll+6) && quest_list.length > 6
            scroll = quest_list.length-7
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
      method=[
        "Status",
        "Alphabetical",
        "Location"][$game_variables[QUEST_SORTING]]
      Kernel.pbMessage(_INTL("What to sort by?\nCurrently: {1}{2}",method,
        "\\ch[1,4,Status,Alphabetical,Location,Cancel]"))
      if pbGet(1)<=2
        $game_variables[QUEST_SORTING]=pbGet(1)
        pbSortQuests(main_quests)
        pbSortQuests(side_quests)
        update = true
      end
    elsif Input.trigger?(Input::USE)
      if quest_list[selected].status < 1 && !$DEBUG
        next
      end
      ret = -1
      while ret != 0
        selquest = sprites[_INTL("quest{1}",selected - scroll)]
        Input.update
        for i in 0...7
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
            scroll += 1 if selected > (scroll+6)
            if selected > quest_list.length-1
              selected = 0
              scroll = 0
            end
            break if quest_list[selected].status > 0 || $DEBUG
          end
        elsif ret == -1
          loop do
            selected -= 1
            scroll -= 1 if selected < scroll 
            if selected < 0
              selected = quest_list.length-1
              if selected > (scroll+6) && quest_list.length > 6
                scroll = quest_list.length-7
              else
                scroll = 0
              end
            end
            break if quest_list[selected].status > 0 || $DEBUG
          end
        end
        for i in 0...7
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
      sprites["scrollbar"].scroll(scroll,quest_list.length,7)
      for i in 0...7
        sprites[_INTL("quest{1}",i)].quest = quest_list[i + scroll]
        sprites[_INTL("quest{1}",i)].selected = (i == selected - scroll)
      end
    end
  end
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
      (a.status<0 ? 3 : i[a.status])<=>(b.status<0 ? 3 : i[b.status])}
  when 1 # Alphabetical
    list.sort!{|a,b|
      a.display_name<=>b.display_name}
  when 2 # Location
    list.sort!{|a,b|
      a.location<=>b.location}
  end

  return list

end

