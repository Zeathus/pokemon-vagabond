class TextBubble
  attr_accessor :event_id
  attr_accessor :text
  attr_accessor :partner
  attr_accessor :active
  attr_accessor :statis

  def initialize(event_id, text, partner=false)
      text = text.gsub("\n", "")
      @event_id = event_id
      @text = text
      @partner = partner
      @time = 0
      @sprite = nil
      @active = false
      @statis = false
  end

  def get_character
      if @partner
          if getPartyActive(0) == @event_id
              return $game_player.sprite rescue nil
          elsif getPartyActive(1) == @event_id
              return $game_player.sprite.partner rescue nil
          end
          return nil
      else
          event = $game_map.events[@event_id]
          return event.sprite if event
          return nil
      end
  end

  def start
      character = self.get_character
      if !character
          return false
      end
      @active = true
      @statis = false
      if !@sprite
          @time = 0
          @sprite = Window_AdvancedTextPokemon.new("", 1)
          @sprite.setSkin("Graphics/Windowskins/mini_msg", false)
          @sprite.setArrow("Graphics/Windowskins/mini_msg_arrow")
          @sprite.text = ""
          @sprite.resizeToFit(text, Graphics.width * 2 / 5)
          @sprite.x = character.x - @sprite.width / 2
          @sprite.y = character.y - @sprite.height - character.bitmap.height / 4
          @sprite.letterbyletter = true
          @sprite.textspeed = 4
          @sprite.text = text
          @sprite.contents.font.name = "Small"
          @sprite.resume
          @sprite.waitcount = 40
          @sprite.opacity = 0
      end
      character.set_text_bubble(self)
      return true
  end

  def update
      character = self.get_character
      return if character.nil?
      if @time < 180 && @sprite.busy?
          @time += 1
          @sprite.opacity = @time * 16
          @time = 180 if @sprite.opacity >= 255
      elsif !@sprite.busy?
          @time -= 1
          @sprite.opacity = @time * 16
      end
      @sprite.x = character.x - @sprite.width / 2
      @sprite.y = character.y - @sprite.height - character.bitmap.height / 4
      @sprite.update
      if @time == 0
          self.dispose
      end
  end

  def on_event_dispose
      @statis = true
  end

  def dispose
      @sprite.dispose
  end

  def disposed?
      return @sprite.disposed?
  end

end

def pbUpdateTextBubbles
  if $scene.is_a?(Scene_Map)
      if $game_temp.text_bubble_queue.length > 0
          next_bubble = $game_temp.text_bubble_queue[0]
          if !next_bubble.active
              if !next_bubble.start
                  echo "Failed to start text bubble\n"
                  $game_temp.text_bubble_queue.delete_at(0)
              end
          elsif next_bubble.statis
              if !next_bubble.start
                  next_bubble.dispose
                  echo "Failed to restart text bubble\n"
                  $game_temp.text_bubble_queue.delete_at(0)
              end
          elsif next_bubble.disposed?
              $game_temp.text_bubble_queue.delete_at(0)
          end
      end
  end
end 