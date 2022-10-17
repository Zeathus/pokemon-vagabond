class PortraitSprite < IconSprite

  def initialize(msgwindow, viewport)
    super(0, 0, viewport)
    @msgwindow  = msgwindow
    @character  = nil
    @expression = "neutral"
    @position   = 1 # 0 = left, 1 = right, 2 = center, 3 = far left, 4 = far right
    self.refresh
  end

  def set(char, expr)
    if char && char != "none"
      @character = char.downcase
    else
      @character = nil
    end
    if expr
      @expression = expr.downcase
    else
      @expression = "neutral"
    end
    self.refresh(true)
  end

  def character=(value)
    if value && value != "none"
      @character = value.downcase
    else
      @character = nil
    end
    self.refresh(true)
  end

  def expression=(value)
    if value
      @expression = value.downcase
    else
      @expression = "neutral"
    end
    self.refresh(true)
  end

  def position=(value)
    @position = value
    self.refresh
  end

  def refresh(redraw = false)
    self.visible = (!(@character.nil?)) && @msgwindow.visible && (@msgwindow.y >= Graphics.width / 2)
    return if @character.nil?
    if redraw
      self.setBitmap(self.portrait_file)
    end
    if self.bitmap
      self.y = @msgwindow.y - self.bitmap.height + 2
      case @position
      when 0
        self.x = @msgwindow.x + 10
      when 1
        self.x = @msgwindow.x + @msgwindow.width - self.bitmap.width - 10
      when 2
        self.x = @msgwindow.x + (@msgwindow.width / 2) + (self.bitmap.width / 2)
      when 3
        self.x = @msgwindow.x - 32
      when 4
        self.x = @msgwindow.x + @msgwindow.width - self.bitmap.width + 32
      end
    end
  end

  def portrait_file
    files = (@position == 0 || @position == 3) ? [
        _INTL("Graphics/Messages/{1}/left/{2}", @character, @expression),
        _INTL("Graphics/Messages/{1}/left/neutral", @character)
      ] : [
        _INTL("Graphics/Messages/{1}/{2}", @character, @expression),
        _INTL("Graphics/Messages/{1}/neutral", @character)
      ]
    files.each do |file|
      if pbResolveBitmap(file)
        return file
      end
    end
    return nil
  end

end

class NameBoxSprite < IconSprite

  attr_reader :real_name

  def initialize(msgwindow, viewport)
    super(0, 0, viewport)
    @msgwindow  = msgwindow
    @show_name  = nil
    @real_name  = nil
    @hide_name  = false
    @position   = 0 # 0 = left, 1 = right, 2 = center
    self.setBitmap(Dialog::getNameBox(@real_name))
    @overlay    = Sprite.new(viewport)
    @overlay.bitmap = Bitmap.new(self.bitmap.width, self.bitmap.height)
    self.z      = 1
    @overlay.z  = 2
    pbSetSystemFont(@overlay.bitmap)
    self.refresh(true)
  end

  def real_name=(value)
    @real_name = value
    @show_name = nil
    @hide_name = false
    self.refresh(true)
  end

  def name=(value)
    @show_name = value
    @hide_name = false
    self.refresh(true)
  end

  def hide_name=(value)
    @hide_name = value
    self.refresh(true)
  end

  def position=(value)
    @position = value
    self.refresh
  end

  def refresh(redraw = false)
    self.visible = (!(@real_name.nil?)) && @msgwindow.visible
    @overlay.visible = self.visible
    return if @real_name.nil?
    if redraw
      self.setBitmap(Dialog::getNameBox(@real_name))
      @overlay.bitmap.clear
      base   = Dialog::getCharColor(@real_name, 0, true)
      shadow = Dialog::getCharColor(@real_name, 1, true)
      base   = Dialog.defaultTextColor(0, true) if !base
      shadow = Dialog.defaultTextColor(1, true) if !shadow
      textpos = [[
        (@hide_name ? "???" : (@show_name || @real_name)),
        self.bitmap.width / 2, 12, 2, base, shadow
      ]]
      pbDrawTextPositions(@overlay.bitmap, textpos)
    end
    if @msgwindow.y < self.bitmap.height
      self.y = @msgwindow.y + @msgwindow.height - 2
    else
      self.y = @msgwindow.y - self.bitmap.height + 2
    end
    if @position == 0
      self.x = @msgwindow.x + 2
    elsif @position == 1
      self.x = @msgwindow.x + @msgwindow.width - self.bitmap.width - 2
    else
      self.x = @msgwindow.x + (@msgwindow.width / 2) - (self.bitmap.width / 2)
    end
    @overlay.x = self.x
    @overlay.y = self.y
  end

  def dispose
    @overlay.dispose
    super
  end

end

class TalkMessageWindowWrapper

  attr_reader :message_position
  attr_accessor :message_frame
  attr_accessor :text_alignment
  attr_accessor :add_pauses
  attr_accessor :active
  attr_accessor :commands
  attr_accessor :line_count
  attr_accessor :letterbyletter

  def initialize(viewport)
    @viewport = viewport
    @msgwindow = pbCreateMessageWindow(nil, nil)
    @namebox = NameBoxSprite.new(@msgwindow, @viewport)
    @raw_pos = nil
    self.reset(true)
  end

  def reset(full = false)
    @active = false
    @controls = []
    @signWaitCount = 0
    @signWaitTime = Graphics.frame_rate / 2
    @haveSpecialClose = false
    @autoresume = false
    @specialCloseSE = ""
    @startSE = nil
    @text = ""
    @commands = nil
    @atTop = false
    @facewindow&.dispose
    @facewindow = nil
    @goldwindow&.dispose
    @goldwindow = nil
    @coinwindow&.dispose
    @coinwindow = nil
    @battlepointswindow&.dispose
    @battlepointswindow = nil
    if full
      if !@message_position || @message_position <= 2
        if $game_system
          @message_position = $game_system.message_position
          @message_frame = $game_system.message_frame
        else
          @message_position = 2
          @message_frame = 0
        end
      end
      @portraits&.each { |p| p.dispose }
      @portraits = []
      @namebox.real_name = nil
      skin = MessageConfig.pbGetSpeechFrame
      @msgwindow.setSkin(skin)
      @letterbyletter = true
      @add_pauses = true
      @line_count = Supplementals::MESSAGE_WINDOW_LINES
      @text_alignment = 0
      self.visible = false
      self.reposition
    end
  end

  def message_position=(value)
    @message_position = value
    if value == 3 # bottom-left
      @namebox&.position = 1
      self.portrait.position = 3
    elsif value == 4
      self.portrait.position = 4
    end
  end

  def visible
    return @msgwindow.visible
  end

  def visible=(value)
    @msgwindow.visible = value
    @namebox&.refresh
    @portraits.each { |p| p&.refresh }
  end

  def setRawPos(x, y, width, lines)
    @raw_pos = [x, y, width, lines]
  end

  def setSkin(skin)
    if skin
      skin = "Graphics/Windowskins/" + skin
    else
      skin = MessageConfig.pbGetSpeechFrame
    end
    @msgwindow.setSkin(skin)
  end

  def showCommands
    $game_variables[@cmdvariable] = pbShowCommands(@msgwindow, @commands, @cmdIfCancel)
  end

  def prepare_window(text)
    self.reset
    @oldletterbyletter = @msgwindow.letterbyletter
    @msgwindow.letterbyletter = @letterbyletter
    ### Text replacement
    text.gsub!(/\\sign\[([^\]]*)\]/i) {   # \sign[something] gets turned into
      next "\\op\\cl\\ts[]\\w[" + $1 + "]"    # \op\cl\ts[]\w[something]
    }
    text.gsub!(/\\\\/, "\5")
    text.gsub!(/\\1/, "\1")
    if $game_actors
      text.gsub!(/\\n\[([1-8])\]/i) {
        m = $1.to_i
        next $game_actors[m].name
      }
    end
    text.gsub!(/\\pn/i,  $player.name) if $player
    text.gsub!(/\\pm/i,  _INTL("${1}", $player.money.to_s_formatted)) if $player
    text.gsub!(/\\n/i,   "\n")
    text.gsub!(/\\\[([0-9a-f]{8,8})\]/i) { "<c2=" + $1 + ">" }
    text.gsub!(/\\pg/i,  "\\b") if $player&.male?
    text.gsub!(/\\pg/i,  "\\r") if $player&.female?
    text.gsub!(/\\pog/i, "\\r") if $player&.male?
    text.gsub!(/\\pog/i, "\\b") if $player&.female?
    text.gsub!(/\\pg/i,  "")
    text.gsub!(/\\pog/i, "")
    text.gsub!(/\\b/i,   "<c3=3050C8,D0D0C8>")
    text.gsub!(/\\r/i,   "<c3=E00808,D0D0C8>")
    text.gsub!(/\\[Ww]\[([^\]]*)\]/) {
      w = $1.to_s
      if w == ""
        @msgwindow.windowskin = nil
      else
        @msgwindow.setSkin("Graphics/Windowskins/#{w}", false)
      end
      next ""
    }
    isDarkSkin = isDarkWindowskin(@msgwindow.windowskin)
    text.gsub!(/\\c\[([0-9]+)\]/i) {
      m = $1.to_i
      next getSkinColor(@msgwindow.windowskin, m, isDarkSkin)
    }
    loop do
      last_text = text.clone
      text.gsub!(/\\v\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
      break if text == last_text
    end
    loop do
      last_text = text.clone
      text.gsub!(/\\l\[([0-9]+)\]/i) {
        linecount = [1, $1.to_i].max
        next ""
      }
      break if text == last_text
    end
    colortag = ""
    if $game_system && $game_system.message_frame != 0
      colortag = getSkinColor(@msgwindow.windowskin, 0, true)
    else
      colortag = getSkinColor(@msgwindow.windowskin, 0, isDarkSkin)
    end
    text = colortag + text
    ### Controls
    textchunks = []
    while text[/(?:\\(f|ff|ts|cl|me|se|wt|wtnp|ch)\[([^\]]*)\]|\\(g|cn|pt|wd|wm|op|cl|wu|\.|\||\!|\^))/i]
      textchunks.push($~.pre_match)
      if $~[1]
        @controls.push([$~[1].downcase, $~[2], -1])
      else
        @controls.push([$~[3].downcase, "", -1])
      end
      text = $~.post_match
    end
    textchunks.push(text)
    textchunks.each do |chunk|
      chunk.gsub!(/\005/, "\\")
    end
    textlen = 0
    @controls.length.times do |i|
      control = @controls[i][0]
      case control
      when "wt", "wtnp", ".", "|"
        textchunks[i] += "\2"
      when "!"
        textchunks[i] += "\1"
      end
      textlen += toUnformattedText(textchunks[i]).scan(/./m).length
      @controls[i][2] = textlen
    end
    text = textchunks.join
    @controls.length.times do |i|
      control = @controls[i][0]
      param = @controls[i][1]
      case control
      when "op"
        @signWaitCount = @signWaitTime + 1
      when "cl"
        text = text.sub(/\001\z/, "")   # fix: '$' can match end of line as well
        @haveSpecialClose = true
        @specialCloseSE = param
      when "f"
        @facewindow&.dispose
        @facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
      when "ff"
        @facewindow&.dispose
        @facewindow = FaceWindowVX.new(param)
      when "ch"
        cmds = param.clone
        @cmdvariable = pbCsvPosInt!(cmds)
        @cmdIfCancel = pbCsvField!(cmds).to_i
        @commands = []
        while cmds.length > 0
          @commands.push(pbCsvField!(cmds))
        end
      when "wtnp", "^"
        text = text.sub(/\001\z/, "")   # fix: '$' can match end of line as well
      when "se"
        if @controls[i][2] == 0
          @startSE = param
          @controls[i] = nil
        end
      end
    end
    self.reposition
    if @facewindow
      pbPositionNearMsgWindow(@facewindow, @msgwindow, :left)
      @facewindow.viewport = @msgwindow.viewport
      @facewindow.z        = @msgwindow.z
    end
    @atTop = (@msgwindow.y == 0)
    return text
  end

  def start
    self.visible = true
    @active = true
    if @startSE
      pbSEPlay(pbStringToAudioFile(@startSE))
    elsif @signWaitCount == 0 && @letterbyletter
      pbPlayDecisionSE
    end
    @msgwindow.text = @text
    Graphics.frame_reset if Graphics.frame_rate > 40
  end

  def refresh
    if @signWaitCount > 0
      @signWaitCount -= 1
      if @atTop
        @msgwindow.y = -@msgwindow.height * @signWaitCount / @signWaitTime
      else
        @msgwindow.y = Graphics.height - (@msgwindow.height * (@signWaitTime - @signWaitCount) / @signWaitTime)
      end
    end
    @controls.length.times do |i|
      next if !@controls[i]
      next if @controls[i][2] > @msgwindow.position || @msgwindow.waitcount != 0
      control = @controls[i][0]
      param = @controls[i][1]
      case control
      when "f"
        @facewindow&.dispose
        @facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
        pbPositionNearMsgWindow(@facewindow, @msgwindow, :left)
        @facewindow.viewport = @msgwindow.viewport
        @facewindow.z        = @msgwindow.z
      when "ff"
        @facewindow&.dispose
        @facewindow = FaceWindowVX.new(param)
        pbPositionNearMsgWindow(@facewindow, @msgwindow, :left)
        @facewindow.viewport = @msgwindow.viewport
        @facewindow.z        = @msgwindow.z
      when "g"      # Display gold window
        @goldwindow&.dispose
        @goldwindow = pbDisplayGoldWindow(@msgwindow)
      when "cn"     # Display coins window
        @coinwindow&.dispose
        @coinwindow = pbDisplayCoinsWindow(@msgwindow, @goldwindow)
      when "pt"     # Display battle points window
        @battlepointswindow&.dispose
        @battlepointswindow = pbDisplayBattlePointsWindow(@msgwindow)
      when "wu"
        @msgwindow.y = 0
        @atTop = true
        pbPositionNearMsgWindow(@facewindow, @msgwindow, :left)
        @msgwindow.y = -@msgwindow.height * @signWaitCount / @signWaitTime
      when "wm"
        @atTop = false
        @msgwindow.y = (Graphics.height - @msgwindow.height) / 2
        pbPositionNearMsgWindow(@facewindow, @msgwindow, :left)
      when "wd"
        atTop = false
        @msgwindow.y = Graphics.height - @msgwindow.height
        pbPositionNearMsgWindow(@facewindow, @msgwindow, :left)
        @msgwindow.y = Graphics.height - (@msgwindow.height * (@signWaitTime - @signWaitCount) / @signWaitTime)
      when "ts"     # Change text speed
        @msgwindow.textspeed = (param == "") ? -999 : param.to_i
      when "."      # Wait 0.25 seconds
        @msgwindow.waitcount += Graphics.frame_rate / 4
      when "|"      # Wait 1 second
        @msgwindow.waitcount += Graphics.frame_rate
      when "wt"     # Wait X/20 seconds
        param = param.sub(/\A\s+/, "").sub(/\s+\z/, "")
        @msgwindow.waitcount += param.to_i * Graphics.frame_rate / 20
      when "wtnp"   # Wait X/20 seconds, no pause
        param = param.sub(/\A\s+/, "").sub(/\s+\z/, "")
        @msgwindow.waitcount = param.to_i * Graphics.frame_rate / 20
        @autoresume = true
      when "^"      # Wait, no pause
        @autoresume = true
      when "se"     # Play SE
        pbSEPlay(pbStringToAudioFile(param))
      when "me"     # Play ME
        pbMEPlay(pbStringToAudioFile(param))
      end
      @controls[i] = nil
    end
    return true if !@letterbyletter
    @facewindow&.update
    if @autoresume && @msgwindow.waitcount == 0
      @msgwindow.resume if @msgwindow.busy?
      return true if !@msgwindow.busy?
    end
    if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK) ||
       (Supplementals::TEXT_SKIP_WITH_CANCEL && Input.press?(Input::BACK))
      if @msgwindow.busy?
        pbPlayDecisionSE if @msgwindow.pausing?
        @msgwindow.resume
      elsif @signWaitCount == 0
        return true
      end
    end
    self.update
    yield if block_given?
    return true if (!@letterbyletter || @commands) && !@msgwindow.busy?
    return false
  end

  def update
    @msgwindow&.update
    @msgwindow&.updateEffect
    @namebox&.update
    @portaits&.each { |p| p.update }
    @facewindow&.update
    @goldwindow&.update
    @coinwindow&.update
    @battlepointswindow&.update
  end

  def finish
    @active = false
    @msgwindow.letterbyletter = @oldletterbyletter
  end

  def close
    self.reset
    if @haveSpecialClose
      pbSEPlay(pbStringToAudioFile(@specialCloseSE))
      @atTop = (msgwindow.y == 0)
      (0..@signWaitTime).each do |i|
        if @atTop
          @msgwindow.y = -@msgwindow.height * i / @signWaitTime
        else
          @msgwindow.y = Graphics.height - (@msgwindow.height * (@signWaitTime - i) / @signWaitTime)
        end
        Graphics.update
        Input.update
        pbUpdateSceneMap
        @msgwindow.update
      end
    end
  end

  def text=(value)
    value = self.format_text(value)
    value = self.prepare_window(value)
    @text = value
  end

  def format_text(value)
    value = _format(value)

    value.gsub!("\\n", "\n")

    # Insert player information
    if $player
      value.gsub!("<PLAYER>", $player.name)
    end

    # Colors
    for i in ["R", "G", "B", "Y", "P", "O", "W", "RBOW", "RBOW2"]
      value.gsub!(_INTL("[{1}]", i), _INTL("[{1}]", i.downcase))
      value.gsub!(_INTL("[/{1}]", i), "[/]")
      value.gsub!(_INTL("[/{1}]", i.downcase), "[/]")
    end
    value.gsub!("[r]","<c2=043c3aff>")
    value.gsub!("[g]","<c2=06644bd2>")
    value.gsub!("[b]","<c2=65467b14>")
    value.gsub!("[y]","<c2=129B43DF>")
    value.gsub!("[p]","<c2=7C1F7EFF>")
    value.gsub!("[o]","<c2=017F473F>")
    value.gsub!("[w]","<c2=2D497FFF>")
    value.gsub!("[/]","</c2>")

    temp = value + ""
    value = ""
    while temp.include?('[') && temp.include?(']')
      index1 = temp.index('[')
      index2 = temp.index(']')
      name = temp[(index1+1)...index2]
      base = Dialog.getCharColor(name, 0, @message_frame == 0)
      shadow = Dialog.getCharColor(name, 1, @message_frame == 0)
      if base && shadow
        temp = _INTL("{1}<c2={2}{3}>{4}",
          temp[0...index1],
          colorToRgb16(base).to_s,
          colorToRgb16(shadow).to_s,
          temp[(index2+1)...temp.length]
        )
      else
        value += temp[0..temp.index(']')]
        temp = temp[(temp.index(']') + 1)...temp.length]
      end
    end
    value += temp

    if value.include?("[rbow]") && value.include?("[/rbow]")
      start_index = value.index("[rbow]") + 6
      end_index = value.index("[/rbow]")

      color1 = Color.new(255,0,0)
      color2 = Color.new(255,170,170)

      old_str = value[start_index...end_index]
      new_str = ""

      hue_step = (340 / old_str.length).ceil

      for i in 0...old_str.length
        new_str += "<c2="
        new_str += colorToRgb16(pbHueShift(color1,-i*hue_step)).to_s
        new_str += colorToRgb16(pbHueShift(color2,-i*hue_step)).to_s
        new_str += ">"
        new_str += old_str[i..i]
        new_str += "</c2>"
      end

      value.gsub!("[rbow]"+old_str+"[/rbow]",new_str)

    end

    if value.include?("[rbow2]") && value.include?("[/rbow2]")
      start_index = value.index("[rbow2]") + 7
      end_index = value.index("[/rbow2]")

      color1 = Color.new(255,0,0)
      color2 = Color.new(255,170,170)

      old_str = value[start_index...end_index]
      new_str = ""

      hue_step = 360 / 12

      for i in 0...old_str.length
        new_str += "<c2="
        new_str += colorToRgb16(pbHueShift(color1,-i*hue_step)).to_s
        new_str += colorToRgb16(pbHueShift(color2,-i*hue_step)).to_s
        new_str += ">"
        new_str += old_str[i..i]
        new_str += "</c2>"
      end

      value.gsub!("[rbow2]"+old_str+"[/rbow2]",new_str)

    end

    if @namebox&.real_name
      base   = Dialog::getCharColor(@namebox.real_name, 0, @message_frame == 0)
      shadow = Dialog::getCharColor(@namebox.real_name, 1, @message_frame == 0)
      base   = Dialog.defaultTextColor(0, @message_frame == 0) if !base
      shadow = Dialog.defaultTextColor(1, @message_frame == 0) if !shadow
      if base && shadow
        value = _INTL("<c2={1}{2}>{3}</c2>",
          colorToRgb16(base).to_s, colorToRgb16(shadow).to_s, value)
      end
    end

    if @add_pauses
      i = 1
      brackets = 0
      echoln value
      while i < value.length
        if value[i] == "["
          brackets += 1
        elsif value[i] == "]"
          brackets -= 1
        elsif brackets == 0 && value[i - 1] != "\\"
          case value[i]
          when ".", "!", "?"
            add = "\\wt[12]"
            value = (value[0..i] + add + value[(i+1)...value.length])
            i += add.length
          when ",", ":", ";"
            add = "\\wt[8]"
            value = (value[0..i] + add + value[(i+1)...value.length])
            i += add.length
          end
        end
        i += 1
      end
      echoln value
    end

    value = _INTL("\\l[{1}]{2}", @line_count, value) if @line_count != Supplementals::MESSAGE_WINDOW_LINES

    if @text_alignment == 2 # Right
      value = _INTL("<ar>{1}</ar>", value)
    elsif @text_alignment == 1 # Center
      value = _INTL("<ac>{1}</ac>", value)
    end # Default Left

    return value

  end

  def portrait(idx = 0)
    if !@portraits[idx]
      @portraits[idx] = PortraitSprite.new(@msgwindow, @viewport)
      @portraits[idx].position = 0 if idx == 1
      self.message_position = @message_position
    end
    return @portraits[idx]
  end

  def namebox
    return @namebox
  end

  def window_skin=(value)
    value = MessageConfig.pbGetSpeechFrame if value.nil?
    @msgwindow.setSkin(value)
  end

  def font=(value)
    @msgwindow.setFont(value)
  end

  def textspeed
    return @msgwindow.textspeed
  end

  def textspeed=(value)
    @msgwindow.textspeed = value
  end

  def reposition
    if @raw_pos.nil?
      @msgwindow.height = (32 * @line_count) + @msgwindow.borderY
      case @message_position
      when 0  # up
        @msgwindow.y = 0
      when 1  # middle
        @msgwindow.y = (Graphics.height / 2) - (@msgwindow.height / 2)
      when 2..4 # bottom
        @msgwindow.y = (Graphics.height) - (@msgwindow.height)
      end
      case @message_position
      when 0..2
        @msgwindow.width = Supplementals::MESSAGE_WINDOW_WIDTH
        @msgwindow.x = Graphics.width / 2 - Supplementals::MESSAGE_WINDOW_WIDTH / 2
      when 3..4
        @msgwindow.width = Graphics.width / 2
        @msgwindow.x = (@message_position == 3) ? 0 : Graphics.width / 2
      end
    else
      @msgwindow.height = (32 * @raw_pos[3]) + @msgwindow.borderY
      @msgwindow.width = @raw_pos[2]
      @msgwindow.x = @raw_pos[0]
      @msgwindow.y = @raw_pos[1]
    end
    self.visible = (@message_frame != 0)
  end

  def dispose
    pbDisposeMessageWindow(@msgwindow)
    @namebox.dispose
    @portraits.each { |p| p.dispose }
  end

end

class TalkMessageWindows

  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @focus = 0
    @msgwindows = [
      TalkMessageWindowWrapper.new(@viewport)
    ]
    @holding = false # Collect messages to display simultaneously
    @queue = [] # Queue in holding
    @queue_shout = false
    @queue_whisper = false
    @queue_silent = false
  end

  def holding=(value)
    @holding = value
    self.display_queued
  end

  def display_queued
    oldtextspeeds = []
    if @queue_shout
      $game_temp.textSize = 4
      pbSEPlay("Damage1",100,100)
      $game_screen.start_shake(2, 25, 10)
    end
    if @queue_whisper || @queue_silent
      @queue.each { |i|
        i[1].font = (@queue_whisper ? 1 : 2)
      }
    end
    windows = []
    @queue.each { |i|
      window = i[1]
      window.text = i[0]
      window.start
      windows.push(window)
      oldtextspeeds.push(window.textspeed)
    }
    if @queue_shout
      windows.each { |w|
        w.textspeed = -999
      }
    end
    loop do
      break if windows.all? { |w| w.refresh }
      Graphics.update
      Input.update
      pbUpdateSceneMap
      self.update
    end
    windows.each { |w| 
      if w.commands
        w.showCommands()
        $game_map.need_refresh = true if $game_map
      end
    }
    windows.each { |w|
      w.finish
      w.close
    }
    for i in 0...oldtextspeeds.length
      windows[i].textspeed = oldtextspeeds[i]
    end
    @queue = []
    @queue_shout = false
    if @queue_whisper || @queue_silent
      windows.each { |w|
        w.font = 0
      }
      @queue_whisper = false
      @queue_silent = false
    end
    $game_temp.textSize = 2
  end

  def display(text, idx = -1)
    idx = @focus if idx == -1
    window = @msgwindows[idx]
    if @holding
      @queue.push([text, window])
    else
      window.text = text
      window.start
      loop do
        break if window.refresh
        Graphics.update
        Input.update
        pbUpdateSceneMap
        self.update
      end
      if window.commands
        window.showCommands()
        $game_map.need_refresh = true if $game_map
      end
      window.finish
      window.close
    end
  end

  def shout(text, idx = -1)
    idx = @focus if idx == -1
    window = @msgwindows[idx]
    if @holding
      @queue.push([text, window])
      @queue_shout = true
    else
      oldtextspeed = window.textspeed
      window.textspeed = -999
      $game_temp.textSize = 4
      $game_screen.start_shake(2, 25, 10)
      pbSEPlay("Damage1", 100, 100)
      self.display(text, idx)
      $game_temp.textSize = 2
      window.textspeed = oldtextspeed
    end
  end

  def whisper(text, idx = -1)
    idx = @focus if idx == -1
    window = @msgwindows[idx]
    if @holding
      @queue.push([text, window])
      @queue_whisper = true
    else
      window.font = 1
      self.display(text, idx)
      window.font = 0
    end
  end

  def silent(text, idx = -1)
    idx = @focus if idx == -1
    window = @msgwindows[idx]
    if @holding
      @queue.push([text, window])
      @queue_silent = true
    else
      window.font = 2
      self.display(text, idx)
      window.font = 0
    end
  end

  def focus(idx)
    @focus = idx
  end

  def focused
    return @msgwindows[@focus]
  end

  def [](idx)
    return @msgwindows[idx]
  end

  def each
    @msgwindows.each { |w| yield w }
  end

  def length
    return @msgwindows.length
  end

  def dispose
    @msgwindows.each { |w| w.dispose }
    @viewport.dispose
  end

  def update
    @msgwindows.each { |w| w.update }
  end

  def add_window(position)
    msgwindow = TalkMessageWindowWrapper.new(@viewport)
    msgwindow.message_position = position
    msgwindow.reposition
    @msgwindows.push(msgwindow)
  end

  def add_window_manual(x, y, width, lines)
    msgwindow = TalkMessageWindowWrapper.new(@viewport)
    msgwindow.setRawPos(x, y, width, lines)
    msgwindow.reposition
    @msgwindows.push(msgwindow)
  end

end