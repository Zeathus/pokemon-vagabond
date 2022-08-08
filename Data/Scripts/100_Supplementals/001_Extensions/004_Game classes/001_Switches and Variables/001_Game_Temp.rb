class Game_Temp
  attr_accessor :text_bubble_queue
  attr_accessor :toast_queue
  attr_accessor :no_saving

  alias sup_initialize initialize

  def initialize
    sup_initialize
    @text_bubble_queue = []
    @toast_queue       = []
    @no_saving         = false
  end

  def queue_toast(toast)
    @toast_queue.push(toast)
  end

  def clear_notifications
    @toast_queue.each do |toast|
      toast.dispose if !toast.disposed?
    end
  end

  def text_bubble(event_id, text)
    @text_bubble_queue.push(TextBubble.new(event_id, text))
  end

  def partner_text_bubble(pid, text)
    @text_bubble_queue.push(TextBubble.new(pid, text, true))
  end

  def clear_text_bubbles
    if @text_bubble_queue.length > 0
      if @text_bubble_queue[0].active
        @text_bubble_queue[0].dispose
      end
    end
    @text_bubble_queue = []
  end
end