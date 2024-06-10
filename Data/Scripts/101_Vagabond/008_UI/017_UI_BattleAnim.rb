#
# May be modified by using $game_variables[CHANGE_BATTLE_INTRO]
# 1 = Finn: Player challenges a youngster
#
def pbQuickBattleAnimation(viewport, bgm, trainers, dialog)

    event = $PokemonGlobal.quickBattleEvent

    if !dialog
        default_dialog = $game_map.name.upcase.gsub(" ", "_").gsub("-", "_") + "_" + trainers[0].name.upcase
        dialog = default_dialog if $GameDialog[default_dialog + "_0"]
    end

    # Take screenshot of game, for use in some animations
    background_bitmap = Graphics.snap_to_bitmap

    trainer_type = trainers[0].trainer_type

    if $game_variables[CHANGE_BATTLE_INTRO] == 1
        trainer_type = :PROTAGONIST 
        dialog = "LAZULI_FINN_CHALLENGE_" + $game_variables[1].to_s
    end

    ball_type = "pokeball"
    if [
        :PROTAGONIST,
        :PSYCHIC_M, :PSYCHIC_F,
        :SCIENTIST_M, :SCIENTIST_F,
        :GENTLEMAN, :SOCIALITE,
        :GAMBLER
        ].include?(trainer_type)
        ball_type = "greatball"
    elsif [
        :ACETRAINER_M, :ACETRAINER_F,
        :VETERAN_M, :VETERAN_F,
        :ZEATHUS,
        :RIVAL, :AMETHYST, :FORETELLER, :NEKANE,
        :LEADER_Raphael, :LEADER_Faunus, :LEADER_Leroy
        ].include?(trainer_type)
        ball_type = "ultraball"
    end

    background = Sprite.new(viewport)
    background.bitmap = background_bitmap
    background.z = 0
    background.ox = Settings::SCREEN_WIDTH / 2
    background.oy = Settings::SCREEN_HEIGHT / 2
    background.x = Settings::SCREEN_WIDTH / 2
    background.y = Settings::SCREEN_HEIGHT / 2
    top = IconSprite.new(-512, -256, viewport)
    top.setBitmap(_INTL("Graphics/UI/Battle/intro_top_{1}", ball_type))
    top.z = 2
    bottom = IconSprite.new(512 - 128, 256, viewport)
    bottom.setBitmap("Graphics/UI/Battle/intro_bottom_pokeball")
    bottom.z = 1
    trainer_sprite = IconSprite.new(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT / 4, viewport)
    trainer_sprite.setBitmap(GameData::TrainerType.front_sprite_filename(trainer_type))
    trainer_sprite.zoom_x = 2.0
    trainer_sprite.zoom_y = 2.0
    trainer_sprite.z = 4
    trainer_sprite2 = nil
    if trainers.length == 2
        trainer_sprite2 = IconSprite.new(Settings::SCREEN_WIDTH + 32, Settings::SCREEN_HEIGHT / 4 - 32, viewport)
        trainer_sprite2.setBitmap(GameData::TrainerType.front_sprite_filename(trainers[1].trainer_type))
        trainer_sprite2.zoom_x = 2.0
        trainer_sprite2.zoom_y = 2.0
        trainer_sprite2.z = 3
        trainer_sprite.x -= 48
    end
    black_fade = Sprite.new(viewport)
    black_fade.bitmap = Bitmap.new(Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT)
    black_fade.bitmap.fill_rect(0, 0, Settings::SCREEN_WIDTH, Settings::SCREEN_HEIGHT, Color.new(0, 0, 0))
    black_fade.opacity = 0
    black_fade.z = 5

    pbSEPlay("Thunder3")

    zoom_frames = [1.0, 1.05, 1.15, 1.35, 1.45, 1.5]
    zoom_frame = 0

    6.times do
        Graphics.update
        Input.update
        viewport.update
        top.x += 48
        top.y += 24
        top.update
        bottom.x -= 48
        bottom.y -= 24
        bottom.update
        trainer_sprite.x -= 42
        trainer_sprite.update
        trainer_sprite2&.x -= 42
        trainer_sprite2&.update
        zoom = zoom_frames[zoom_frame]
        background.zoom_x = zoom
        background.zoom_y = zoom
        if event
            x_diff = event.x - $game_player.x
            y_diff = event.y - $game_player.y - 1.5
            background.x = Settings::SCREEN_WIDTH / 2 - (32 * x_diff) * (zoom - 1.0) * zoom
            background.y = Settings::SCREEN_HEIGHT / 2 - (32 * y_diff) * (zoom - 1.0) * zoom
        end
        zoom_frame += 1
    end

    frames = [32, 24, 16, 12, 8, 4]
    for i in frames
        Graphics.update
        Input.update
        viewport.update
        top.x += i
        top.y += i / 2
        top.update
        bottom.x -= i
        bottom.y -= i / 2
        bottom.update
        trainer_sprite.x -= i / 2
        trainer_sprite.update
        trainer_sprite2&.x -= i / 2
        trainer_sprite2&.update
    end

    pbBGMPlay(bgm)
    if dialog
        pbDialog(dialog)
    else
        32.times do
            Graphics.update
            Input.update
            viewport.update
        end
    end

    frames = [2, 4, 8, 12, 16, 22, 22, 16, 12, 8, 4, 2]
    trainer_frames = [4, 4, 8, 12, 16, 24, 32, 48, 64, 96, 128, 128]
    for i in 0...frames.length
        frame = frames[i]
        Graphics.update
        Input.update
        viewport.update
        top.x += frame
        top.y += frame / 2
        top.update
        bottom.x -= frame
        bottom.y -= frame / 2
        bottom.update
        trainer_sprite.x += trainer_frames[i] / 2
        trainer_sprite.update
        trainer_sprite2&.x += trainer_frames[i] / 2
        trainer_sprite2&.update
        black_fade.opacity += 16 if i > 6
    end

    pbSEPlay("Vs sword")

    60.times do
        Graphics.update
        Input.update
        viewport.update
        black_fade.opacity += 16
    end

    top.dispose
    bottom.dispose
    trainer_sprite.dispose
    trainer_sprite2&.dispose
    black_fade.dispose
    background.dispose

    # Play main animation
    viewport.color = Color.new(0, 0, 0, 255)   # Ensure screen is black

    $game_variables[CHANGE_BATTLE_INTRO] = 0

end