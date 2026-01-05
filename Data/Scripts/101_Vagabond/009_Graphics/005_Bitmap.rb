class Bitmap
  # Bitmap.new(filepath) does not support non-game directories.
  # These methods are workarounds that dump the raw data to a file instead.
  # Used to save sprites to the save data folder primarily.
  def toFile(filepath)
    File.open(filepath, "wb") do |f|
      Marshal.dump([
        self.width,
        self.height,
        self.raw_data
      ], f)
    end
  end

  def self.fromFile(filepath)
    bitmap = nil
    File.open(filepath, "rb") do |f|
      data = Marshal.load(f)
      bitmap = self.new(data[0], data[1])
      bitmap.raw_data = data[2]
    end
    return bitmap
  end
  # ------------------------------------
end
