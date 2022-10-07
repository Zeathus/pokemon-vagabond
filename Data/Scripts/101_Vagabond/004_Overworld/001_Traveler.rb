class Traveler
  attr_accessor(:id)              # PBTrainer::TRAINERCLASS
  attr_accessor(:name)            # The name of the trainer
  attr_accessor(:areas)           # The IDs of maps the trainer can move to
  attr_accessor(:battled)         # If the trainer has been battled or not (and it was won)
  attr_accessor(:phrases)         # The different phrases the trainer has for each area
  attr_accessor(:switch)          # Switch used for a variety of special scripts
  attr_accessor(:level)           # The last level the trainer had when battled
  attr_accessor(:location)        # What map the trainer is currently at
  attr_accessor(:timer)           # How long the trainer has yet to stay in an area
  attr_accessor(:lock)            # Make the trainer not able to move between maps
  attr_accessor(:call)            # Dialog when called, {1} is replaced with location
  attr_accessor(:number)          # Dialog when giving the player their number
  attr_accessor(:battle)          # Dialog when challenging the player
  attr_accessor(:after)           # In-battle dialog when winning
  attr_accessor(:leave)           # Dialog when leaving the map

  def initialize(id, name, location)
    self.id       = id
    self.name     = name
    self.areas    = [location]
    self.battled  = false
    self.phrases  = []
    self.switch   = false
    self.level    = 0
    self.location = location
    self.timer    = 3
    self.call     = nil
    self.number   = nil
    self.battle   = nil
    self.after    = "I lost..."
    self.leave    = nil
  end

  def move
    previous = self.location
    while previous == self.location
      self.location = self.areas.shuffle[0]
    end
    self.timer = rand(3) + 6
  end

  def talk
    if self.battle != nil && !self.battled
      self.challenge
    else
      pbSpeech(self.name, "neutral", self.phrases[$game_map.map_id])
      pbSpecial(self, $game_map.map_id)
    end
  end

  def challenge
    if !battled
      pbSpeech(self.name, "neutral", self.battle)
    end
    if pbFieldTrainer(self.id,self.name,self.after,false)
      if !battled
        pbSpecial(self, $game_map.map_id, true)
        if self.number != nil && self.call != nil
          pbSpeech(self.name, "neutral", self.number)
          pbRegisterTrainerNumber(self)
        end
        self.battled = true
      end
      if self.leave != nil
        pbSpeech(self.name, "neutral", self.leave)
        self.move
        $game_screen.start_tone_change(Tone.new(-255, -255, -255, 0), 20)
        pbWait(30)
        pbGenerateTrainers
        $game_screen.start_tone_change(Tone.new(0, 0, 0, 0), 20)
        pbWait(30)
      end
    end
  end

  def update
    if battled && !lock
      self.timer -= 1
      if timer < 0
        self.move
      end
    end
  end

end

def pbSpecial(trainer, map_id, after_battle=false)
  town = pbIsTown?(map_id)

  ######################### Hiker Horton #########################
  if trainer.name == "Horton"
    if town || after_battle
      pbSpeech(trainer.name, "neutral",
        "Do ye want to buy something?",false,["Yes", "No"])
      if pbGet(1)==0
        pbPokemonMart([
          :RAREBONE,:HARDSTONE,
          :THICKCLUB,:SMOOTHROCK
          ],
          "Get anything you like. It's all high quality!",
          true)
      else
        pbSpeech(trainer.name, "neutral",
          "You bet I've always got stock for later!")
      end
    else
      pbSpeech(trainer.name, "neutral",
        "Do ye need something?",false,["Trade","Battle","No"])
      if pbGet(1)==0
        pbPokemonMart([
          :RAREBONE,:HARDSTONE,
          :THICKCLUB,:SMOOTHROCK
          ],
          "Get anything you like. It's all high quality!",
          true)
      elsif pbGet(1)==1
        trainer.challenge
      else
        pbSpeech(trainer.name, "neutral",
          "Have a good one fella!")
      end
    end
  end
end

def pbIsTown?(map_id)
  name = pbGetMapNameFromId(map_id)
  if name.include?("Town") || name.include?("City") ||
    name.include?("Village") || name.include?("Center") ||
    name.include?("House")
    return true
  end
  return false
end

def pbTrainer(trainer_name)
  trainer = nil
  for i in $game_variables[TRAINER_ARRAY]
    if i.name == trainer_name
      return i
    end
  end
  return trainer
end