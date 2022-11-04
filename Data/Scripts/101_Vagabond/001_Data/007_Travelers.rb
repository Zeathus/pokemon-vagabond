# Types
PASSIVE = 0
NEUTRAL = 1
FORCED  = 2

# City
ALL       = 0
CENTER    = 1
NOCENTER  = 2
MART      = 3
NOMART    = 4
GRASS     = 5
PAVEMENT  = 6
#CITY      = 7
TOWN      = 8
SEASIDE   = 9

# In speech, using "PKMN1", "PKMN2", and so on refers to the trainers pokemon.
# "TRN" will mention the area the trainer is in at the moment. 
# "CTY" will refer to the city the trainer is in.
# "MAP" will refer to the name of the map the trainer is in.
# "HOUR" will mention the currect clock hour
# "SKY" will mention the current celestial object (Sun or Moon)

def pbInitTrainers
  if !$game_variables[TRAINER_ARRAY].is_a?(Array)
    $game_variables[TRAINER_ARRAY] = []
  end

  horton = pbTrainer("Horton")
  if !horton
    horton = Traveler.new(:HIKER, "Horton",
      PBMaps::MtPegmaHillside)
    $game_variables[TRAINER_ARRAY].push(horton)
  end
  horton.areas = [
    PBMaps::MtPegmaHillside,
    PBMaps::MicaTown,
    PBMaps::FeldsparTown]
  horton.battle = "Hoi fella!WT I hike around selling stuff, but can ye beat me in battle first?"
  horton.after  = "Yer a strong one!"
  horton.leave  = "I'll be heading off now.WT See ya again sometime!"
  horton.number = "You should have my number!WT Gimme a call if you need something."
  horton.call   = "Hoi!WT If it ain't PLAYER! I'm over {1} right now. Come visit, eh?"
  horton.phrases[PBMaps::MtPegmaHillside] = 
    "Hoi fella!WT Ain't the view of Mt. Pegma while climbing up just great!"
  horton.phrases[PBMaps::MicaTown] =
    "Ain't it nice how Mica Town's a resting point towards Mt. Pegma! A fine town it is!"
  horton.phrases[PBMaps::FeldsparTown] =
    "Towns built on the side of a mountain, music to my ears!"

end

def pbFieldTrainer(trainerid,trainername,endspeech=nil,doublebattle=true,min_lvl=0)
  partyid = 0
  trainers=load_data("Data/trainers.dat")
  for trainer in trainers
    name=trainer[1]
    thistrainerid=trainer[0]
    thispartyid=trainer[4]
    if trainerid==thistrainerid && name==trainername
      if thispartyid>partyid
        lvl_sum = 0
        for poke in trainer[3]
          lvl_sum += poke[TPLEVEL]
        end
        lvl_avg = lvl_sum / trainer[3].length
        if pbTrainerAverageLevel - 2 > lvl_avg || lvl_avg <= min_lvl
          partyid = thispartyid
        end
      end
    end
  end
  return TrainerBattle.start(trainerid, trainername, partyid)
end

def pbGenerateTrainers
  return if !$game_variables[TRAINER_ARRAY].is_a?(Array)
  for trainer in $game_variables[TRAINER_ARRAY]
    trainer.update
  end
  for event in $game_map.events.values
    if event.name.include?("TRAINER")
      name = event.name + ""
      name.gsub!("TRAINER ", "")
      trainer = pbTrainer(name)
      if trainer != nil
        if trainer.location == $game_map.map_id
          $game_self_switches[[$game_map.map_id, event.id, "A"]]=true
          trainer.timer = rand(2) + 5
        else
          $game_self_switches[[$game_map.map_id, event.id, "A"]]=false
        end
        $game_map.need_refresh = true
      end
    end
  end
end

def pbReplaceQuotePieces(speech, trainer)
  quote = "g"
  quote.gsub!("g",speech)
  team = trainer.teams[trainer.stage]
  if quote.include?("PKMN1")
    quote.gsub!("PKMN1",team[0]) if quote.include?("PKMN1")
  end
  if quote.include?("PKMN2")
    quote.gsub!("PKMN2",team[1]) if quote.include?("PKMN2")
  end
  if quote.include?("PKMN3")
    quote.gsub!("PKMN3",team[2]) if quote.include?("PKMN3")
  end
  quote.gsub!("TRN","-not implemented-") if quote.include?("TRN")
  quote.gsub!("MAP",$game_map.name) if quote.include?("MAP")
  if quote.include?("SKY")
    time = pbGetTimeNow
    time = time.hour.to_i
    replace = "sun"
    if time >= 20 && time <= 23
      replace = "moon"
    elsif time >= 0 && time <= 4
      replace = "moon"
    else
      replace = "sun"
    end
    quote.gsub!("SKY",replace)
  end
  if quote.include?("HOUR")
    time = pbGetTimeNow
    time = time.hour.to_i
    replace = time.to_s
    quote.gsub!("HOUR",replace)
  end
  if quote.include?("WILD")
    encounter=$PokemonEncounters.pbEncounteredPokemon(EncounterTypes::Land)
    poke = PokeBattle_Pokemon.new(encounter[0], 1)
    quote.gsub!("WILD",poke.name)
  end
  if quote.include?("CMD")
    quote.gsub!("CMD1","")
    quote.gsub!("CMD2","")
    quote.gsub!("CMD3","")
    quote.gsub!("CMD4","")
    quote.gsub!("CMD5","")
    quote.gsub!("CMD6","")
    quote.gsub!("CMD","")
  end
  return quote
end

def pbTrainerStatus
  level = pbTrainerAverageLevel
  minlevel = level - 1 - ((6*level)/100)
  maxlevel = level + 1 + ((6*level)/100)
  Kernel.pbMessage(_INTL("Current min trainer lvl: {1}\nCurrent max trainer lvl: {2}", minlevel, maxlevel))

  battled = 0
  total = 0

  for trainer in $game_variables[TRAINER_ARRAY]
    total += 1
    if trainer.battled == true
      battled += 1
    end
  end
  Kernel.pbMessage(_INTL("You have battled {1}/{2} trainers.", battled, total))
end

def pbIssueCmd(person, cmd = 1)

  # SCIENTIST TABIL
  if person.name == "Tabil" && (pbGetQuestStatus(A_TRAVELERS_SEARCH)==0 || pbGetQuestStatus(A_TRAVELERS_SEARCH)==1)
    pbSetQuestStatus(A_TRAVELERS_SEARCH, 1) if cmd == 2
    if pbHasSpecies?(:CELEBI)
      pbSpeech(person.name, "none",
      "Oh...WT Could it be, is that really Celebi you have with you?WT May I see it for just moment please?")
      pbWait(10)
      pbSpeech(person.name, "none",
      "...I am deeply grateful to you for giving me the chance to speak with Celebi again.WT When I was in the future with Celebi, we found this, you can have it.WT I will hold on to the memories.")
      person.talk_city = "Seeing Celebi again has given me renewed motivation to find the path to the future we were in.WT I think that is what Celebi wished for when he first met me all those years ago."
      person.talk_city2 = person.talk_city
      Kernel.pbReceiveItem(:MEADOWPLATE)
      pbFinishQuest(A_TRAVELERS_SEARCH)
    end
  end

  if person.name == "Rudiger" and !person.switch
    if pbHasSpecies?(:PORYGON) or pbHasSpecies?(:PORYGON2) or pbHasSpecies?(:PORYGONZ)
      pbSpeech(person.name, "none",
      "That's the one, that's the Pokémon Silph. Co was looking for. Now I can report back to my superiors. Please accept this.")
      Kernel.pbReceiveItem(:COMETSHARD)
      person.talk_city2 = "Now that you have shown me the Porygon, our research will be progressing further!"
      person.switch = true
    end
  end

  if person.name == "Traba" and !person.switch
    if pbHasSpecies?(:EEVEE)
      pbSpeech(person.name, "none",
      "Oh, that's an Eevee you have there isn't it?WT Can I see it please?WT ...Thank you for going through the effort of showing me this.WT Here, you can have these.")
      Kernel.pbReceiveItem(:LIECHIBERRY)
      Kernel.pbReceiveItem(:GANLONBERRY)
      Kernel.pbReceiveItem(:SALACBERRY)
      Kernel.pbReceiveItem(:PETAYABERRY)
      Kernel.pbReceiveItem(:APICOTBERRY)
      person.switch = true
      person.talk_city2 = "Getting to see that Eevee made up for not having one.WT Thank you."
    end
  end
end

def pbRegisterTrainerNumber(trainer)
  phonenum = []
  phonenum.push(true)
  phonenum.push(trainer.id)
  phonenum.push(PBTrainers.getName(trainer.id) + " " + trainer.name)
  phonenum.push(trainer.name)
  phonenum.push(0)
  $PokemonGlobal.phoneNumbers.push(phonenum)
  Kernel.pbMessage(_INTL("Registered {1} in the Pokégear.",trainer.name))
end

def pbCallTravellingTrainer(trainer)
  trainername=trainer[3]
  dummy=trainer[4]
  trainer = pbTrainer(trainername)
  mapname = pbMapMention(trainer.location) if trainer.location >= 1
  trainer.timer = 10
  pbSpeech(trainer.name,"none",_INTL(trainer.call, mapname))
end

