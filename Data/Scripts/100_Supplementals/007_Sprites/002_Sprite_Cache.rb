class CachedAnimatedBitmap < AnimatedBitmap
  def dispose; end
end

module Supplementals
  module Cache

    @supplementals_cache = {}

    def self.get(filename)
      if filename.nil?
        filename = "Graphics/Pokemon/Icons/0/000.png"
      end
      cache = @supplementals_cache
      key = filename
      idx = key.index("/")
      while idx
        subcache = key[0...idx]
        cache[subcache] = {} if !cache[subcache]
        cache = cache[subcache]
        key = key[(idx + 1)...key.length]
        idx = key.index("/")
      end
      ret = cache[key]
      if !ret
        echoln _INTL("Failed to find '{1}' in cache", filename)
        self.put(filename)
        ret = cache[key]
      end
      return ret
    end

    def self.put(filename)
      cache = @supplementals_cache
      key = filename
      idx = key.index("/")
      while idx
        subcache = key[0...idx]
        cache[subcache] = {} if !cache[subcache]
        cache = cache[subcache]
        key = key[(idx + 1)...key.length]
        idx = key.index("/")
      end
      cache[key]&.dispose
      #echoln _INTL("Put {1}", filename)
      bitmap = CachedAnimatedBitmap.new(filename)
      cache[key] = bitmap
    end

    def self.prepare
      self.cache_directory("Graphics/Pokemon/Icons")
    end

    def self.cache_directory(dir)
      return if !FileTest.exist?(dir)
      to_cache = []
      Dir.all(dir).each do |f|
        if !FileTest.directory?(f)
          to_cache.push(f)
        end
      end
      to_cache.each do |f|
        self.put(f)
      end
    end
  end
end