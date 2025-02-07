def pbPlayGuessPokemon
  game = Game_Guess_Pokemon.new
  result = game.start
  return result
end

class Game_Guess_Pokemon

  def initialize
    @bitmaps = []
    @sprites = {}
    @lives = 5
    @lives_lost_this_round = 0
    @round = 1
    @prizes = []
    for i in -2...3
      @prizes.push(self.round_prize(@round + i))
    end
    @all_in = 0
  end

  def round_prize(round)
    return nil if round < 0
    return 0 if round == 0
    return 200 if round == 1
    return 250000 if round == 50
    return 1000000 if round == 100
    return nil if round > 100
    prize = (round > 50) ? 500000 : 200
    for r in ((round > 50) ? 51 : 2)..round
      prize = prize + r * 200
      prize += 300 * r if r % 5 == 0
      prize += 400 * r if r % 10 == 0
      prize += 500 * r if r % 20 == 0
      prize += 1000 * r if r % 50 == 0
    end
    return prize / 2
  end

  def get_species_bitmap(species,back=false)
    battlername=sprintf("Graphics/Pokemon/%s/%s/%s",
      back ? "Back" : "Front", species.to_s[0..0], species.to_s)
    bitmap=pbResolveBitmap(battlername)
    if bitmap
      bitmap = RPG::Cache.load_bitmap("", battlername)
      new_bitmap = Bitmap.new(bitmap.width, bitmap.height)
      new_bitmap.blt(0, 0, bitmap, Rect.new(0, 0, bitmap.width, bitmap.height))
      bitmap.dispose
      return new_bitmap
    else
      raise _INTL("Bitmap for %s of %s does not exist",
        back ? "Back" : "Front", species.to_s)
    end
  end

  def create_silhouette(bitmap)
    new_bitmap = Bitmap.new(bitmap.width, bitmap.height)
    black = Color.new(0, 0, 0)
    for y in 0...bitmap.height
      for x in 0...bitmap.width
        if bitmap.get_pixel(x, y).alpha > 100
          new_bitmap.set_pixel(x, y, black)
        else
          new_bitmap.set_pixel(x, y, bitmap.get_pixel(x, y))
        end
      end
    end
    return new_bitmap
  end

  def rotate_90_cw(bitmap)
    new_bitmap = Bitmap.new(bitmap.height, bitmap.width)
    black = Color.new(0, 0, 0)
    for y in 0...bitmap.height
      for x in 0...bitmap.width
        new_bitmap.set_pixel(
          bitmap.height - y, x,
          bitmap.get_pixel(x, y))
      end
    end
    return new_bitmap
  end

  def rotate_90_ccw(bitmap)
    new_bitmap = Bitmap.new(bitmap.height, bitmap.width)
    black = Color.new(0, 0, 0)
    for y in 0...bitmap.height
      for x in 0...bitmap.width
        new_bitmap.set_pixel(
          y, bitmap.width - x,
          bitmap.get_pixel(x, y))
      end
    end
    return new_bitmap
  end

  def rotate_180(bitmap)
    new_bitmap = Bitmap.new(bitmap.width, bitmap.height)
    black = Color.new(0, 0, 0)
    for y in 0...bitmap.height
      for x in 0...bitmap.width
        new_bitmap.set_pixel(
          bitmap.width - x, bitmap.height - y,
          bitmap.get_pixel(x, y))
      end
    end
    return new_bitmap
  end

  def mirror_x(bitmap)
    new_bitmap = Bitmap.new(bitmap.width, bitmap.height)
    black = Color.new(0, 0, 0)
    for y in 0...bitmap.height
      for x in 0...bitmap.width
        new_bitmap.set_pixel(
          bitmap.width - x, y,
          bitmap.get_pixel(x, y))
      end
    end
    return new_bitmap
  end

  def mirror_y(bitmap)
    new_bitmap = Bitmap.new(bitmap.width, bitmap.height)
    black = Color.new(0, 0, 0)
    for y in 0...bitmap.height
      for x in 0...bitmap.width
        new_bitmap.set_pixel(
          x, bitmap.height - y,
          bitmap.get_pixel(x, y))
      end
    end
    return new_bitmap
  end

  def jumble_2x2(bitmap, rotate=false, grid=true)
    new_bitmap = Bitmap.new(bitmap.width, bitmap.height)
    positions = [[0, 0], [1, 0],
                 [0, 1], [1, 1]]
    color1 = Color.new(100, 0, 0, 50)
    color2 = Color.new(0, 100, 0, 50)
    shuffled = false
    while !shuffled
      pieces = positions.shuffle
      for p in 0...pieces.length
        if pieces[p][0] != positions[p][0] && pieces[p][1] != positions[p][1]
          shuffled = true
          break
        end
      end
    end
    for p in 0...pieces.length
      s_x = (pieces[p][0]==0) ? 0 : (bitmap.width / 2.0).floor
      s_y = (pieces[p][1]==0) ? 0 : (bitmap.height / 2.0).floor
      e_x = (pieces[p][0]==0) ? (bitmap.width / 2.0).ceil : (bitmap.width)
      e_y = (pieces[p][1]==0) ? (bitmap.height / 2.0).ceil : (bitmap.height)
      x = (positions[p][0]==0) ? 0 : (bitmap.width / 2.0).floor
      y = (positions[p][1]==0) ? 0 : (bitmap.height / 2.0).floor
      if grid
        color = ((((p % 2) + ((p / 2) % 2)) % 2) == 0) ? color1 : color2
        new_bitmap.fill_rect(x, y, (x + e_x - s_x), (y + e_y - s_y), color)
      end
      if rotate
        tmp_bitmap = Bitmap.new(e_x - s_x, e_y - s_y)
        tmp_bitmap.blt(0, 0, bitmap, Rect.new(s_x, s_y, e_x, e_y))
        rng = rand(4)
        if rng == 3
          tmp_bitmap2 = rotate_180(tmp_bitmap)
          tmp_bitmap.dispose
          tmp_bitmap = tmp_bitmap2
        elsif rng == 2
          tmp_bitmap2 = mirror_y(tmp_bitmap)
          tmp_bitmap.dispose
          tmp_bitmap = tmp_bitmap2
        elsif rng == 1
          tmp_bitmap2 = mirror_x(tmp_bitmap)
          tmp_bitmap.dispose
          tmp_bitmap = tmp_bitmap2
        else
          tmp_bitmap2 = tmp_bitmap
        end
        new_bitmap.blt(x, y, tmp_bitmap, Rect.new(0, 0, tmp_bitmap.width, tmp_bitmap.height))
        tmp_bitmap.dispose
      else
        new_bitmap.blt(x, y, bitmap, Rect.new(s_x, s_y, e_x, e_y))
      end
    end
    return new_bitmap
  end

  def jumble_3x3(bitmap, rotate=false, grid=true)
    new_bitmap = Bitmap.new(bitmap.width, bitmap.height)
    positions = [[0, 0], [1, 0], [2, 0],
                 [0, 1], [1, 1], [2, 1],
                 [0, 2], [1, 2], [2, 2]]
    color1 = Color.new(200, 0, 0, 50)
    color2 = Color.new(0, 200, 0, 50)
    shuffled = false
    while !shuffled
      pieces = positions.shuffle
      for p in 0...pieces.length
        if pieces[p][0] != positions[p][0] && pieces[p][1] != positions[p][1]
          shuffled = true
          break
        end
      end
    end
    xs = [0, (bitmap.width / 3.0).floor, (bitmap.width * 2.0 / 3.0).floor, bitmap.width]
    ys = [0, (bitmap.height / 3.0).floor, (bitmap.height * 2.0 / 3.0).floor, bitmap.height]
    xs2 = [0, (bitmap.width / 3.0).ceil, (bitmap.width * 2.0 / 3.0).ceil, bitmap.width]
    ys2 = [0, (bitmap.height / 3.0).ceil, (bitmap.height * 2.0 / 3.0).ceil, bitmap.height]
    for p in 0...pieces.length
      s_x = xs[pieces[p][0]]
      s_y = ys[pieces[p][1]]
      e_x = xs2[pieces[p][0]+1]
      e_y = ys2[pieces[p][1]+1]
      x = xs[positions[p][0]]
      y = ys[positions[p][1]]
      if grid
        color = ((((p % 3) + ((p / 3) % 2)) % 2) == 0) ? color1 : color2
        new_bitmap.fill_rect(x, y, (x + e_x - s_x), (y + e_y - s_y), color)
      end
      if rotate
        tmp_bitmap = Bitmap.new(e_x - s_x, e_y - s_y)
        tmp_bitmap.blt(0, 0, bitmap, Rect.new(s_x, s_y, e_x, e_y))
        rng = rand(4)
        if rng == 3
          tmp_bitmap2 = rotate_180(tmp_bitmap)
          tmp_bitmap.dispose
          tmp_bitmap = tmp_bitmap2
        elsif rng == 2
          tmp_bitmap2 = mirror_y(tmp_bitmap)
          tmp_bitmap.dispose
          tmp_bitmap = tmp_bitmap2
        elsif rng == 1
          tmp_bitmap2 = mirror_x(tmp_bitmap)
          tmp_bitmap.dispose
          tmp_bitmap = tmp_bitmap2
        else
          tmp_bitmap2 = tmp_bitmap
        end
        new_bitmap.blt(x, y, tmp_bitmap, Rect.new(0, 0, tmp_bitmap.width, tmp_bitmap.height))
        tmp_bitmap.dispose
      else
        new_bitmap.blt(x, y, bitmap, Rect.new(s_x, s_y, e_x, e_y))
      end
    end
    return new_bitmap
  end

  def current_pokemon_bitmap
    bitmap = @bitmaps[@bitmaps.length - 1]
  end

  def refresh_pokemon_sprite
    bitmap = self.current_pokemon_bitmap
    @sprites["pokemon"].bitmap = bitmap
    @sprites["pokemon"].ox = bitmap.width / 2
    @sprites["pokemon"].oy = bitmap.height / 2
  end

  def refresh_pokemon2_sprite
    bitmap = @bitmaps[@bitmaps.length - 2]
    @sprites["pokemon2"].bitmap = bitmap
    @sprites["pokemon2"].ox = bitmap.width / 2
    @sprites["pokemon2"].oy = bitmap.height / 2
  end

  def refresh_hud
    bitmap = @sprites["hud"].bitmap
    bitmap.clear
    base = Color.new(255, 255, 255)
    shadow1 = Color.new(80, 110, 150)
    shadow2 = Color.new(180, 100, 100)
    shadow3 = Color.new(70, 150, 90)
    shadow4 = Color.new(100, 190, 120)
    textpos = [
      ["ROUND",Graphics.width/2 + 191,68,2,base,shadow1,true],
      ["LIVES",Graphics.width/2 + 191,164,2,base,shadow2,true],
      [@round.to_s,Graphics.width/2 + 191,98,2,base,shadow1,true],
      [@lives.to_s,Graphics.width/2 + 191,194,2,base,shadow2,true],
      ["PRIZE",Graphics.width/2 - 193,68,2,base,shadow3,true]
    ]
    prizepos = []
    i = 0
    for p in @prizes
      str = p ? self.number_with_delimiter(p) : "-"
      str = "> " + str + " <" if i == 1
      shadow = (i == 1) ? shadow3 : shadow4
      prizepos.push([str,Graphics.width/2 - 193,194 - i * 24,2,base,shadow,true])
      i += 1
    end
    pbSetSystemFont(bitmap)
    pbDrawTextPositions(bitmap, textpos)
    pbSetSmallFont(bitmap)
    pbDrawTextPositions(bitmap, prizepos)
  end

  def update
    Graphics.update
    Input.update
    pbUpdateSpriteHash(@sprites)
    @viewport.update
  end

  def random_rotation
    case rand(5)
    when 0
      @bitmaps.push(self.mirror_x(self.current_pokemon_bitmap))
    when 1
      @bitmaps.push(self.mirror_y(self.current_pokemon_bitmap))
    when 2
      @bitmaps.push(self.rotate_90_cw(self.current_pokemon_bitmap))
    when 3
      @bitmaps.push(self.rotate_90_ccw(self.current_pokemon_bitmap))
    when 4
      @bitmaps.push(self.rotate_180(self.current_pokemon_bitmap))
    end
  end

  def create_round(round)
    dex_list = pbLoadRegionalDexes[0]
    species_data = GameData::Species.get(dex_list[rand(511)])
    while true
      begin
        while species_data.form != 0 || [:ARCHEBLAST,:TROPICOPIA,:LAPRANESSE,:SANDOLIN].include?(species_data.species)
          species_data = GameData::Species.get(dex_list[rand(511)])
        end
        species = species_data.species

        @bitmaps.push(self.get_species_bitmap(species))
        break
      rescue
        msg = "Failed to get bitmap for " + species.to_s
        echoln msg
        species_data = GameData::Species.get(dex_list[rand(511)])
      end
    end

    # First few round show off each transformation
    if round == 2
      @bitmaps.push(self.mirror_y(self.current_pokemon_bitmap))
    elsif round == 3
      @bitmaps.push(self.rotate_90_cw(self.current_pokemon_bitmap))
    elsif round == 4
      @bitmaps.push(self.jumble_2x2(self.current_pokemon_bitmap))
    elsif round == 5
      @bitmaps.push(self.jumble_3x3(self.current_pokemon_bitmap, true))
    end

    if round == 100
      @bitmaps.push(self.jumble_2x2(self.current_pokemon_bitmap, true, false))
      @bitmaps.push(self.jumble_3x3(self.current_pokemon_bitmap, true, false))
      self.random_rotation
    elsif round >= 90
      @bitmaps.push(self.jumble_2x2(self.current_pokemon_bitmap, false, false))
      @bitmaps.push(self.jumble_3x3(self.current_pokemon_bitmap, false, false))
    elsif round >= 70
      @bitmaps.push(self.jumble_3x3(self.current_pokemon_bitmap, true, false))
    elsif round >= 50
      @bitmaps.push(self.jumble_3x3(self.current_pokemon_bitmap, true))
      self.random_rotation
    elsif round >= 45
      @bitmaps.push(self.jumble_3x3(self.current_pokemon_bitmap, true))
    elsif round >= 40
      @bitmaps.push(self.jumble_2x2(self.current_pokemon_bitmap, true))
      self.random_rotation
    elsif round >= 35
      @bitmaps.push(self.jumble_2x2(self.current_pokemon_bitmap, true))
    elsif round >= 30
      @bitmaps.push(self.jumble_2x2(self.current_pokemon_bitmap))
      self.random_rotation
    elsif round >= 25
      @bitmaps.push(self.jumble_3x3(self.current_pokemon_bitmap))
    elsif round >= 20
      @bitmaps.push(self.jumble_2x2(self.current_pokemon_bitmap))
    elsif round >= 10
      self.random_rotation
    end

    if round > 5
      # All pokemon past round 5 are silhouettes
      @bitmaps.push(self.create_silhouette(self.current_pokemon_bitmap))
    end

    return species

  end

  def guess_pokemon(species)
    while true
      if @round > 20 && @lives > 1
        if @all_in == 0
          loop do
            pbMessage("Are you ready to guess?\\ch[1,0,Yes,Go All In]")
            if $game_variables[1] == 1
              if @lives <= 1
                pbMessage("You can't Go All In with just one life left.")
              else
                pbMessage("Are you sure you want to Go All In?\\ch[1,0,Yes,No]")
                if $game_variables[1] == 0
                  pbMessage("It's all or nothing, good luck.")
                  @all_in = 1
                  break
                end
              end
            else
              break
            end
          end
        end
        guess = pbEnterText("Who's that Pokémon?", 1, 12).downcase
        species_data = GameData::Species.get(species)
        for s in species_keys = GameData::Species::DATA.keys
          sd = GameData::Species.get(s)
          if guess == sd.name.downcase || guess == s.to_s.downcase
            if guess == species_data.name.downcase || guess == species.to_s.downcase
              return true
            else
              return false
            end
          end
        end
        pbMessage("I do not believe there is a Pokemon with that name. Please try another.")
      else
        pbMessage("Are you ready to guess?\\ch[1,0,Yes]")
        guess = pbEnterText("Who's that Pokémon?", 1, 12).downcase
        species_data = GameData::Species.get(species)
        for s in species_keys = GameData::Species::DATA.keys
          sd = GameData::Species.get(s)
          if guess == sd.name.downcase || guess == s.to_s.downcase
            if guess == species_data.name.downcase || guess == species.to_s.downcase
              return true
            else
              return false
            end
          end
        end
        pbMessage("I do not believe there is a Pokemon with that name. Please try another.")
      end
    end
    return false
  end

  def update
    Graphics.update
    Input.update
    pbUpdateSpriteHash(@sprites)
    @viewport.update
  end

  def wait(frames)
    frames.times do
      self.update
    end
  end

  def unveil
    while @bitmaps.length > 1
      self.wait(10)
      self.refresh_pokemon2_sprite
      for i in 0...64
        @sprites["pokemon2"].opacity = i * 4
        @sprites["pokemon"].opacity = 256 - i * 4
        self.update
      end
      @bitmaps.pop.dispose
      self.refresh_pokemon_sprite
      @sprites["pokemon2"].bitmap = nil
      @sprites["pokemon2"].opacity = 0
      @sprites["pokemon"].opacity = 255
      self.wait(10)
    end
  end

  def start
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)

    @sprites["pokemon"] = Sprite.new(@viewport)
    @sprites["pokemon"].x = Graphics.width / 2
    @sprites["pokemon"].y = Graphics.height / 4 - 18
    @sprites["pokemon2"] = Sprite.new(@viewport)
    @sprites["pokemon2"].x = Graphics.width / 2
    @sprites["pokemon2"].y = Graphics.height / 4 - 18
    @sprites["pokemon2"].opacity = 0

    @sprites["hud"] = Sprite.new(@viewport)
    @sprites["hud"].bitmap = Bitmap.new(Graphics.width, Graphics.height)

    pbMessage("Welcome to...")
    pbMessage("WHO'S! THAT! POKEMON!")
    pbMessage("The first five rounds we will show different ways the image can be distorted. Then we go to the real thing!")
    while @round <= 100
      @lives_lost_this_round = 0
      @all_in = 0
      if @round > 20 && @lives == 1
        pbMessage("You're at only 1 life...\\nOn your last legs, you will receive another life if you answer this correctly!")
        @all_in = 1
      end
      species = self.create_round(@round)
      self.refresh_hud
      self.refresh_pokemon_sprite
      for i in 0...64
        @sprites["pokemon"].opacity = i * 4
        self.update
      end

      if @round == 1
        pbMessage("This is a Pokemon without any distortions.")
      elsif @round == 2
        pbMessage("This Pokemon has been flipped vertically.\nThey can also be flipped horizontally.")
      elsif @round == 3
        pbMessage("This Pokemon has been rotated 90 degress. They can be rotated 90, 180 or 270 degrees.")
      elsif @round == 4
        pbMessage("This Pokemon has been jumbled into 4 different squares.")
        pbMessage("Each square is shown with a background color to be easily distinguishable.")
      elsif @round == 5
        pbMessage("This Pokemon has been jumbled into 9 different squares, but each square has been randomly flipped individually.")
        pbMessage("You won't see this distortion until the later rounds.")
      elsif @round == 6
        pbMessage("Now begins the real part of the show.\nAll Pokemon from here on are silhouettes!")
        pbMessage("The following Pokemon are without any distortions.")
      elsif @round == 10
        pbMessage("The following Pokemon will be rotated or flipped randomly.")
      elsif @round == 20
        pbMessage("The following Pokemon will be jumbled into 4 squares.")
      elsif @round == 25
        pbMessage("The following Pokemon will be jumbled into 9 squares.")
      elsif @round == 30
        pbMessage("The following Pokemon will be jumbled into 4 squares, then rotated or flipped.")
      elsif @round == 35
        pbMessage("The following Pokemon will be jumbled into 4 squares, but each square can be flipped individually.")
      elsif @round == 40
        pbMessage("The following Pokemon will be jumbled into 4 invididually flipped squares, then rotated or flipped.")
      elsif @round == 45
        pbMessage("The following Pokemon will be jumbled into 9 individually flipped squares.")
      elsif @round == 50
        pbMessage("The following Pokemon will be jumbled into 9 individually flipped squares, then rotated or flipped.")
      elsif @round == 70
        pbMessage("The following Pokemon will be jumbled into 9 individually flipped squares, but with no square colors.")
      elsif @round == 90
        pbMessage("The following Pokemon will be jumbled into 4 squares, then the new image is jumbled into 9 squares.")
      elsif @round == 100
        pbMessage("It's the final round! I have never seen anyone get this far, and neither did I think anyone would!")
        pbMessage("This final Pokemon is jumbled into 4 flipped squares, then 9 flipped squares, and finally rotated or flipped.")
      else
        pbMessage("Here is the next Pokémon.")
      end

      while !guess_pokemon(species)
        pbMessage("Wrong...")
        @lives_lost_this_round += 1
        @lives -= 1
        if @all_in > 0 && @lives > 0
          pbMessage("You went all in, and this is where you confidence got you...")
          @lives = 0
        end
        self.refresh_hud
        if @lives <= 0
          pbMessage("You lose!")
          self.unveil
          self.wait(20)
          pbMessage(_INTL("It's {1}!", GameData::Species.get(species).name))
          pbMessage("That concludes this game of Who's That Pokemon!")
          pbMessage(_INTL("Our lucky contestant mananged to get away with a prize of ${1}!", self.round_prize(@round - 1)))
          $player.money += self.round_prize(@round - 1)
          self.dispose
          return 0
        elsif @lives_lost_this_round >= 3
          pbMessage(_INTL("You have guessed wrong {1} times.\\nDo you want a new Pokémon?\\ch[1,0,Yes,No]",
            @lives_lost_this_round))
          if $game_variables[1] == 0
            self.unveil
            self.wait(20)
            pbMessage(_INTL("It's {1}!", GameData::Species.get(species).name))
            @bitmaps[0].dispose
            @bitmaps = []
            species = self.create_round(@round)
            self.refresh_pokemon_sprite
            @lives_lost_this_round = 0
          else
            # Guess again
          end
        end
      end
      pbMessage("CORRECT!")
      if @all_in > 0
        if @lives == 1
          pbMessage(_INTL("You hang in there and gain {1} {2}!", @all_in, (@all_in == 1) ? "life" : "lives"))
        else
          pbMessage(_INTL("You went all in and gained {1} {2}!", @all_in, (@all_in == 1) ? "life" : "lives"))
        end
        @lives += @all_in
        self.refresh_hud
      end
      @prizes.shift
      @prizes.push(self.round_prize(@round + 3))
      if @bitmaps.length > 1
        self.unveil
        self.wait(20)
      end
      pbMessage(_INTL("It's {1}!", GameData::Species.get(species).name))
      for i in 0...64
        @sprites["pokemon"].opacity = 256 - i * 4
        self.update
      end
      @bitmaps[0].dispose
      @bitmaps = []
      @round += 1
      if @round == 21
        pbMessage("Congratulations on passing round 20!\\wt[10]\\n...But the fun has just begun!")
        pbMessage("You may now put all your lives on the line and Go All In on your guesses.")
        pbMessage("If you guess correctly after going all in,\\nyou gain a life!")
        pbMessage("But if you guess incorrectly...\nYou lose all the lives you have!")
        pbMessage("Mind that you can only Go All In when you have multiple lives remaining.")
      end
    end

    if @round > 100
      pbMessage("I can't believe it...")
      pbMessage("Someone beat all 100 levels of Who's That Pokémon!")
      pbMessage("Congratulations on this momentous achievement.\nYou will walk away with a whole $1,000,000!")
      $player.money += 1000000
      self.dispose
    end

  end

  def dispose
    @viewport.dispose
  end

  def number_with_delimiter(num)
    neg = (num < 0)
    num = num.abs
    str = num.to_s
    ret = ""
    if str.include?(".")
      ret = str[str.index(".")...str.length]
      str = str[0...str.index(".")]
    end
    while str.length > 3
      sub = str[(str.length-3)...str.length]
      str = str[0...(str.length-3)]
      ret = "," + sub + ret
    end
    ret = str + ret
    ret = "-" + ret if neg
    return ret
  end

end