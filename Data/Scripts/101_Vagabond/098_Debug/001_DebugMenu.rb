MenuHandlers.add(:debug_menu, :vagabond, {
  "parent"      => :main,
  "name"        => _INTL("Vagabond Options..."),
  "description" => _INTL("Anything new added by Vagabond.")
})

MenuHandlers.add(:debug_menu, :party_members, {
  "parent"      => :vagabond,
  "name"        => _INTL("Party Members"),
  "description" => _INTL("Toggle whether party members are with you."),
  "effect"      => proc {
      pbDebugPartyMembers
  }
})

MenuHandlers.add(:debug_menu, :all_numbers, {
  "parent"      => :vagabond,
  "name"        => _INTL("Get All Trainer Phones"),
  "description" => _INTL("Gets the phone numbers of all wandering trainers."),
  "effect"      => proc {
      for i in $game_variables[TRAINER_ARRAY]
        phonenum=[]
        phonenum.push(true)
        phonenum.push(i.id)
        phonenum.push(PBTrainers.getName(i.id) + " " + i.name)
        phonenum.push(i.name)
        phonenum.push(0)
        $PokemonGlobal.phoneNumbers.push(phonenum)
      end
      pbMessage("All numbers added")
  }
})

MenuHandlers.add(:debug_menu, :reset_quests, {
  "parent"      => :vagabond,
  "name"        => _INTL("Reset Quests"),
  "description" => _INTL("Sets all quests to their initial state."),
  "effect"      => proc {
      pbMessage(_INTL("Side Quests re-initialized."))
      $quests = QuestList.new
  }
})

MenuHandlers.add(:debug_menu, :unlock_quests, {
  "parent"      => :vagabond,
  "name"        => _INTL("Unlock All Quests"),
  "description" => _INTL("Sets all quests as available."),
  "effect"      => proc {
      $quests.each { |quest|
        if quest.type != PBQuestType::Main
          quest.status = 0 if quest.status < 0
        end
      }
      pbMessage(_INTL("Unlocked All Quests"))
  }
})

MenuHandlers.add(:debug_menu, :reset_travelers, {
  "parent"      => :vagabond,
  "name"        => _INTL("Reset Travelers"),
  "description" => _INTL("Resets all traveling trainers to their initial state."),
  "effect"      => proc {
      Kernel.pbMessage(_INTL("Travelers re-initialized."))
      pbInitTrainers
  }
})

#===============================================================================
# Debug Variables screen
#===============================================================================
class SpriteWindow_DebugPartyMembers < Window_DrawableCommand
  def initialize(viewport)
    super(0,0,Graphics.width,Graphics.height,viewport)
  end

  def itemCount
    return PBParty.len
  end

  def shadowtext(x,y,w,h,t,align=0,colors=0)
    width = self.contents.text_size(t).width
    if align==1 # Right aligned
      x += (w-width)
    elsif align==2 # Centre aligned
      x += (w/2)-(width/2)
    end
    base = Color.new(12*8,12*8,12*8)
    if colors==1 # Red
      base = Color.new(168,48,56)
    elsif colors==2 # Green
      base = Color.new(0,144,0)
    end
    pbDrawShadowText(self.contents,x,y,[width,w].max,h,t,base,Color.new(26*8,26*8,25*8))
  end

  def drawItem(index,_count,rect)
    pbSetNarrowFont(self.contents)
    colors = 0; codeswitch = false
    name = PBParty.getName(index)
    val = hasPartyMember(index)
    if val.nil?
      status = "[-]"
      colors = 0
      codeswitch = true
    elsif val   # true
      status = "[ON]"
      colors = 2
    else   # false
      status = "[OFF]"
      colors = 1
    end
    name = '' if name==nil
    id_text = sprintf("%04d:",index)
    rect = drawCursor(index,rect)
    totalWidth = rect.width
    idWidth     = totalWidth*15/100
    nameWidth   = totalWidth*65/100
    statusWidth = totalWidth*20/100
    self.shadowtext(rect.x,rect.y,idWidth,rect.height,id_text)
    self.shadowtext(rect.x+idWidth,rect.y,nameWidth,rect.height,name,0,(codeswitch) ? 1 : 0)
    self.shadowtext(rect.x+idWidth+nameWidth,rect.y,statusWidth,rect.height,status,1,colors)
  end
end

def pbDebugPartyMembers
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  viewport.z = 99999
  sprites = {}
  sprites["right_window"] = SpriteWindow_DebugPartyMembers.new(viewport)
  right_window = sprites["right_window"]
  right_window.active   = true
  loop do
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    if Input.trigger?(Input::BACK)
      pbPlayCancelSE
      break
    end
    current_id = right_window.index
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE
      if hasPartyMember(current_id)
        removePartyMember(current_id)
      else
        addPartyMember(current_id)
      end
      right_window.refresh
    end
  end
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end