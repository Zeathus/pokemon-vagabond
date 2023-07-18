class Game_Player < Game_Character

    def on_ladder=(value)
        self.turn_up if value
        @direction_fix = value
        $player.has_running_shoes = !value if $player
    end

end