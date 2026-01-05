class CharacterCustomization
  # Add the path to any sprites that should be replaced by a custom one here
  # pointing to the name of the custom sprite.
  @@sprite_names = {
    # "Graphics/Characters/member0_walk" => "member0_walk"
  }
  @@sprites = {}
  @@customization = {
    "masc" => {
      "palettes" => {
        "skin" => ["Tone 1", "Tone 2", "Tone 3", "Tone 4", "Tone 5"],
        "eyes" => [],
        "hair" => []
      },
      "layers" => {
        "body"    => ["Base"],
        "hair"    => ["Long"],
        "eyes"    => ["Confident"],
        "mouth"   => ["Smirk"],
        "clothes" => ["None", "Cloak 1", "Cloak 2"]
      }
    },
    "fem" => {
      "body" => [],
      "hair" => [],
      "face" => []
    },
    "non" => {
      "body" => [],
      "hair" => [],
      "face" => []
    }
  }

  def self.get(file)
    name = @@sprite_names[file]
    return nil if name.nil?
    self.reload(name) if @@sprites[name].nil?
    return @@sprites[name].copy
  end

  def self.reload(name)
    @@sprite_names.each do |key, value|
      @@sprites[value]&.dispose
      split_file = key.split(/[\\\/]/)
      filename = split_file.pop
      path = split_file.join("/") + "/"
      sprite = GifBitmap.new("Graphics/Characters/", "member0_walk", 0)
      @@sprites[value] = sprite
      echoln "Write"
      sprite.bitmap.toFile(System.data_directory + "/test.dat")
      sprite.bitmap = BitmapWrapper.fromFile(System.data_directory + "/test.dat")
    end
  end

  def self.reload_all
    @@sprite_names.each do |key, value|
      self.reload(value)
    end
  end
end

class CharacterBitmap < AnimatedBitmap
  def initialize(file, hue = 0)
    custom_sprite = CharacterCustomization.get(file)
    if custom_sprite.nil?
      super(file, hue)
    else
      @bitmap = custom_sprite
    end
  end
end