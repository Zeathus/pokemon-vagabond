module PBEmote
  Love  = 0
  Heart = 0
  Sigh  = 1
  Sweat = 1
  Angry = 2
  Sad   = 3
  Dots  = 4
  Annoy = 5
  Smile = 6
  Frown = 7
  Idea  = 8

  def PBEmote.getAnimID(emote)
      emote = getID(PBEmote, emote) if emote.is_a?(Symbol)
      return [
          13,
          14,
          15,
          16,
          17,
          18,
          19,
          20,
          21
      ][emote]
  end

  def PBEmote.fromName(emote)
      emote = emote.downcase
      names = [
          ["love", "heart"],
          ["sigh", "sweat"],
          ["angry", "mad"],
          ["sad"],
          ["dots", "dotdotdot", "..."],
          ["annoy", "annoyed"],
          ["smile"],
          ["frown"],
          ["idea", "lightbulb"]
      ]
      for i in 0...names.length
          if names[i].include?(emote)
              return i
          end
      end
      return -1
  end
end

def pbEmote(event,id,tinting=false)
  id = getID(PBEmote, id) if id.is_a?(Symbol)
  pbExclaim(event, PBEmote.getAnimID(id), tinting)
end 