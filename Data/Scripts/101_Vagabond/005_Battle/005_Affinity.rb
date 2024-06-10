class Battle::Battler

  def pbAffinityBoost
    if !opposes?
      $stats.affinity_boosts += 1
    end
    booster = @affinityBooster
    @battle.scene.pbAffinityBoostAnimation(self,booster)
    allies = [self]
    allies.push(booster) if booster && !booster.fainted? && booster != self

    for ally in allies
      if ally.hasActiveAbility?(:MENDINGBOND)
        if @hp != @totalhp && @effects[PBEffects::HealBlock] <= 0
          pbRecoverHP((@totalhp/4.0).ceil,true)
          if ally == self
            @battle.pbDisplay(_INTL("{1}'s Mending Bond restored its HP!", pbThis))
          else
            @battle.pbDisplay(_INTL("{1}'s Mending Bond restored {2}'s HP!", ally.pbThis, pbThis))
          end
        end
      elsif ally.hasActiveAbility?(:FIERCEBOND)
        if pbCanRaiseStatStage?(:ATTACK,self,false)
          pbRaiseStatStageByCause(:ATTACK, 1, ally,
            GameData::Ability.get(:FIERCEBOND).name, true)
        end
      elsif ally.hasActiveAbility?(:GUARDINGBOND)
        if pbCanRaiseStatStage?(:DEFENSE,self,false)
          pbRaiseStatStageByCause(:DEFENSE, 1, ally,
            GameData::Ability.get(:GUARDINGBOND).name, true)
        end
      elsif ally.hasActiveAbility?(:RADIANTBOND)
        if pbCanRaiseStatStage?(:SPECIAL_ATTACK,self,false)
          pbRaiseStatStageByCause(:SPECIAL_ATTACK, 1, ally,
            GameData::Ability.get(:RADIANTBOND).name, true)
        end
      elsif ally.hasActiveAbility?(:SPIRITUALBOND)
        if pbCanRaiseStatStage?(:SPECIAL_DEFENSE,self,false)
          pbRaiseStatStageByCause(:SPECIAL_DEFENSE, 1, ally,
            GameData::Ability.get(:SPIRITUALBOND).name, true)
        end
      elsif ally.hasActiveAbility?(:LIVELYBOND)
        if pbCanRaiseStatStage?(:SPEED,self,false)
          pbRaiseStatStageByCause(:SPEED, 1, ally,
            GameData::Ability.get(:LIVELYBOND).name, true)
        end
      end
    end
  end

end

class Battle::Scene
  def pbAffinityBoostAnimation(attacker,booster)

    if attacker.fainted?
      return
    end

    partner = booster
    partner = false if !partner || partner.fainted?

    opponent = (attacker.index % 2 == 1)

    ### Beam
    sprites = {}
    sprites["beam"] = IconSprite.new(0,112,@viewport)
    sprites["beam"].setBitmap("Graphics/UI/Battle/affinityboost_bg")
    sprites["beam"].src_rect = Rect.new(0,0,512,108)
    sprites["beam"].z = 101
    sprites["beam"].mirror = opponent

    ### Text
    sprites["text"] = IconSprite.new(176,134,@viewport)
    sprites["text"].setBitmap("Graphics/UI/Battle/affinityboost_text")
    sprites["text"].src_rect = Rect.new(0,0,512,108)
    sprites["text"].z = 102
    sprites["text"].opacity = 0
    sprites["text"].x += opponent ? 70 : -70

    start_x = sprites["text"].x

    pbSEPlay("PRSFX- Zpower1")

    21.times do |i|
      if i % 3 == 0
        sprites["beam"].src_rect.y += 108
        if opponent
          sprites["text"].x -= 2 * (8 - i / 3)
        else
          sprites["text"].x += 2 * (8 - i / 3)
        end
      end
      sprites["text"].opacity += 16
      sprites["beam"].update
      sprites["text"].update
      pbGraphicsUpdate
      Input.update
    end

    rand = @battle.pbRandom(100)
    if !partner && rand < 5
      # Cannot do crash animation with one pokemon
      rand = 90
    end

    # Whether the text slides off the screen while fading
    slide = true

    if rand < 60
      sprites["pkmn1"] = PokemonIconSprite.new(attacker.pokemon,@viewport)
      sprites["pkmn1"].z = 104
      sprites["pkmn1"].x = -64 + 32
      sprites["pkmn1"].y = 120 + 32
      sprites["pkmn1"].setOffset(PictureOrigin::CENTER)
      sprites["pkmn1"].mirror = true

      sprites["pkmn2"] = partner ? PokemonIconSprite.new(partner.pokemon,@viewport) : Sprite.new(@viewport)
      sprites["pkmn2"].z = 103
      sprites["pkmn2"].x = 506 + 32
      sprites["pkmn2"].y = 120 + 32
      sprites["pkmn2"].setOffset(PictureOrigin::CENTER) if partner
    end

    if rand < 5
      # 5% chance of crash animation
      14.times do |i|
        sprites["pkmn1"].x += 12 - (i > 10 ? (i - 10) : 0)
        sprites["pkmn2"].x -= 12 - (i > 10 ? (i - 10) : 0)
        sprites["pkmn1"].update
        sprites["pkmn2"].update
        pbGraphicsUpdate
        Input.update
      end

      17.times do |i|
        sprites["pkmn1"].x += 6
        sprites["pkmn2"].x -= 6
        sprites["pkmn1"].y += ((i - 19.0) / 4.0).floor
        sprites["pkmn2"].y += ((i - 19.0) / 4.0).floor
        sprites["pkmn1"].update
        sprites["pkmn2"].update
        pbGraphicsUpdate
        Input.update
      end

      44.times do |i|
        rot = [i * 2, 30].min
        sprites["pkmn1"].x -= 4
        sprites["pkmn2"].x += 4
        sprites["pkmn1"].angle += rot
        sprites["pkmn2"].angle -= rot
        sprites["pkmn1"].y += ((i - 6.0) / 2.0).floor
        sprites["pkmn2"].y += ((i - 6.0) / 2.0).floor
        sprites["pkmn1"].update
        sprites["pkmn2"].update
        pbGraphicsUpdate
        Input.update
      end

      10.times do |i|
        pbGraphicsUpdate
        Input.update
      end

    elsif rand < 15
      # 10% chance of flip animation
      14.times do |i|
        sprites["pkmn1"].x += 12 - (i > 10 ? (i - 10) : 0)
        sprites["pkmn2"].x -= 12 - (i > 10 ? (i - 10) : 0)
        sprites["pkmn1"].update
        sprites["pkmn2"].update
        pbGraphicsUpdate
        Input.update
      end

      rot = 9
      # 1/4 chance for double flip
      rot = 18 if @battle.pbRandom(4)==0

      40.times do |i|
        sprites["pkmn1"].x += 6
        sprites["pkmn2"].x -= 6
        sprites["pkmn1"].angle -= rot
        sprites["pkmn2"].angle += rot
        sprites["pkmn1"].y += ((i - 19.0) / 4.0).floor
        sprites["pkmn2"].y += ((i - 19.0) / 4.0).floor
        sprites["pkmn1"].update
        sprites["pkmn2"].update
        pbGraphicsUpdate
        Input.update
      end

      sprites["pkmn1"].angle = 0
      sprites["pkmn2"].angle = 0

      16.times do |i|
        sprites["pkmn1"].x += 8 + (i < 4 ? i : 4)
        sprites["pkmn2"].x -= 8 + (i < 4 ? i : 4)
        sprites["pkmn1"].update
        sprites["pkmn2"].update
        pbGraphicsUpdate
        Input.update
      end

      10.times do |i|
        pbGraphicsUpdate
        Input.update
      end

    elsif rand < 35
      # 20% chance of joy animation
      slide = false

      20.times do |i|
        sprites["pkmn1"].x += 12 - (i > 8 ? (i - 8) : 0)
        sprites["pkmn2"].x -= 12 - (i > 8 ? (i - 8) : 0)
        sprites["pkmn1"].update
        sprites["pkmn2"].update
        pbGraphicsUpdate
        Input.update
      end

      10.times do |i|
        pbGraphicsUpdate
        Input.update
      end

      frames = [-6, -4, -2, 0, 2, 4, 6, 0, -6, -4, -2, 0, 2, 4, 6]

      30.times do |i|
        if i % 2 == 0
          sprites["pkmn1"].y += frames[i/2]
          sprites["pkmn2"].y += frames[i/2]
        end
        sprites["pkmn1"].update
        sprites["pkmn2"].update
        pbGraphicsUpdate
        Input.update
      end

      10.times do |i|
        pbGraphicsUpdate
        Input.update
      end

    elsif rand < 60
      # 25% chance of jump animation
      14.times do |i|
        sprites["pkmn1"].x += 12 - (i > 10 ? (i - 10) : 0)
        sprites["pkmn2"].x -= 12 - (i > 10 ? (i - 10) : 0)
        sprites["pkmn1"].update
        sprites["pkmn2"].update
        pbGraphicsUpdate
        Input.update
      end

      40.times do |i|
        sprites["pkmn1"].x += 6
        sprites["pkmn2"].x -= 6
        sprites["pkmn1"].y += ((i - 19.0) / 4.0).floor
        sprites["pkmn2"].y += ((i - 19.0) / 4.0).floor
        sprites["pkmn1"].update
        sprites["pkmn2"].update
        pbGraphicsUpdate
        Input.update
      end

      16.times do |i|
        sprites["pkmn1"].x += 8 + (i < 4 ? i : 4)
        sprites["pkmn2"].x -= 8 + (i < 4 ? i : 4)
        sprites["pkmn1"].update
        sprites["pkmn2"].update
        pbGraphicsUpdate
        Input.update
      end

      10.times do |i|
        pbGraphicsUpdate
        Input.update
      end

    else
      # 40% chance of no special animation
      32.times do |i|
        pbGraphicsUpdate
        Input.update
      end

    end

    16.times do |i|
      sprites["beam"].opacity -= 20
      sprites["text"].opacity -= 16
      sprites["pkmn1"].opacity -= 20 if sprites["pkmn1"]
      sprites["pkmn2"].opacity -= 20 if sprites["pkmn2"]
      if slide && i % 3 == 0
        if opponent
          sprites["text"].x -= 2 * (8 - i / 3)
        else
          sprites["text"].x += 2 * (8 - i / 3)
        end
      end
      sprites["beam"].update
      sprites["text"].update
      sprites["pkmn1"].update if sprites["pkmn1"]
      sprites["pkmn2"].update if sprites["pkmn2"]
      pbGraphicsUpdate
      Input.update
    end

    pbDisposeSpriteHash(sprites)

  end
end