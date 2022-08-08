class Scene_Map
  def updateToasts
    queue = $game_temp.toast_queue
    if queue.length > 0
      if queue[0].disposed?
        queue.shift
      elsif queue[0].active
        queue[0].update
      else
        queue[0].active = true
      end
    end
  end
end