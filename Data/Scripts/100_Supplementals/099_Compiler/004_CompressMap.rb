def pbCompressMap(map_id)
  def print(text, text2=nil)
    if text2
      echo _INTL("{1}: {2}", text, text2) + "\r\n"
    else
      echo _INTL("{1}", text) + "\r\n"
    end
  end

  tile_size = 32
  tileset_width = 8

  file_name = pbMapFile(map_id, false)
  print("File Name", file_name)
  map_data = load_data(file_name)

  tileset_data = $data_tilesets[map_data.tileset_id]
  tileset = Bitmap.new(sprintf("Graphics/Tilesets/%s", tileset_data.tileset_name))
  passages = tileset_data.passages
  priorities = tileset_data.priorities
  terrain_tags = tileset_data.terrain_tags

  new_tileset_data = Marshal.load(Marshal.dump(tileset_data))
  new_tileset_data.id = map_id + 100
  new_tileset_data.name = sprintf("Map%03d", map_id)
  new_tileset_data.tileset_name = sprintf("tileset%03d", map_id)

  triples = []
  event_tiles = []
  priority_tiles = []
  priority_pos = []

  def has_triple(triples, triple)
    for t in triples
      return true if t[0] == triple[0] && t[1] == triple[1] && t[2] == triple[2]
    end
    return false
  end

  def triple_index(triples, triple)
    for t in 0...triples.length
      return t if triples[t][0] == triple[0] && triples[t][1] == triple[1] && triples[t][2] == triple[2]
    end
    return -1
  end

  map = map_data.data

  cur_id = 0

  for y in 0...map.ysize
    for x in 0...map.xsize
      triple = [map[x,y,0], map[x,y,1], map[x,y,2]]
      for i in 0...3
        triple[i] = 0 if !priorities[triple[i]] || priorities[triple[i]] > 0
      end
      if !has_triple(triples, triple)
        passage = passages[triple[0]] | passages[triple[1]] | passages[triple[2]]
        new_tileset_data.passages[384 + cur_id] = passage
        new_tileset_data.terrain_tags[384 + cur_id] = 0
        for i in 0...3 # Keep the upper non-neutral terrain tag
          terrain_tag = terrain_tags[triple[2 - i]]
          if triple[2 - i] != 0 && terrain_tag != 13 && terrain_tag != 0
            new_tileset_data.terrain_tags[384 + cur_id] = terrain_tag
            break
          end
        end
        new_tileset_data.priorities[384 + cur_id] = 0
        triples.push(triple)
        cur_id += 1
      end
    end
  end

  pri_start = cur_id

  for z in 0...3
    for y in 0...map.ysize
      for x in 0...map.xsize
        tile_id = map[x,y,z]
        if priorities[tile_id] && priorities[tile_id] > 0
          idx = priority_tiles.index(tile_id)
          if !idx
            idx = priority_tiles.length
            priority_tiles.push(tile_id)
            new_tileset_data.passages[384 + cur_id] = passages[tile_id]
            new_tileset_data.terrain_tags[384 + cur_id] = terrain_tags[tile_id]
            new_tileset_data.priorities[384 + cur_id] = priorities[tile_id]
            cur_id += 1
          end
          priority_pos.push([x, y, z, 384 + pri_start + idx])
        end
      end
    end
  end

  event_start = cur_id

  for event in map_data.events.values
    for page in event.pages
      tile_id = page.graphic.tile_id
      if tile_id > 0
        idx = event_tiles.index(tile_id)
        if !idx
          idx = event_tiles.length
          new_tileset_data.passages[384 + cur_id] = tileset_data.passages[tile_id]
          new_tileset_data.terrain_tags[384 + cur_id] = terrain_tags[tile_id]
          new_tileset_data.priorities[384 + cur_id] = priorities[tile_id]
          event_tiles.push(tile_id)
          cur_id += 1
        end
        page.graphic.tile_id = 384 + event_start + idx
      end
    end
  end

  print("Unique Triples Found", triples.length)
  print("Unique Priority Tiles Found", priority_tiles.length)
  print("Priority Tiles Total Found", priority_pos.length)
  print("Unique Event Tiles Found", event_tiles.length)

  new_tileset = Bitmap.new(tile_size * tileset_width, tile_size * ((cur_id / tileset_width).ceil + 2))

  bitmap_1 = Bitmap.new(1, 1)
  tmp_bitmap = Bitmap.new(tile_size, tile_size)
  rect_1 = Rect.new(0, 0, 1, 1)
  tile_rect = Rect.new(0, 0, tile_size, tile_size)

  cur_id = 0

  for i in 0...triples.length
    tmp_bitmap.clear
    new_tileset_x = (cur_id & 7) * tile_size
    new_tileset_y = (cur_id >> 3) * tile_size
    for z in 0...3
      id = triples[i][z]
      if id >= 384
        tmp_rect = Rect.new(
          ((id - 384) & 7) * tile_size,
          ((id - 384) >> 3) * tile_size,
          tile_size, tile_size
        )
        for y in 0...tmp_rect.height
          for x in 0...tmp_rect.width
            bitmap_1.clear
            bitmap_1.blt(0, 0, tileset, Rect.new(x + tmp_rect.x, y + tmp_rect.y, 1, 1))
            px = bitmap_1.get_pixel(0, 0)
            if px.alpha >= 0xFF
              #tmp_bitmap.blt(x, y, bitmap_1, rect_1) # Slow but safe for large bitmaps
              tmp_bitmap.set_pixel(x, y, px)
            elsif px.alpha > 0x00
              px2 = tmp_bitmap.get_pixel(x, y)
              px2.red = (px2.red - (px2.red * px.alpha / 0xFF) + (px.red * px.alpha / 0xFF)).floor
              px2.green = (px2.green - (px2.green * px.alpha / 0xFF) + (px.green * px.alpha / 0xFF)).floor
              px2.blue = (px2.blue - (px2.blue * px.alpha / 0xFF) + (px.blue * px.alpha / 0xFF)).floor
              px2.alpha = [px2.alpha + px.alpha, 0xFF].min
              tmp_bitmap.set_pixel(x, y, px2)
            end
          end
        end
      end
    end
    print("Done", sprintf("%d / %d", i + 1, triples.length)) if (i % 100 == 99)
    new_tileset.blt(new_tileset_x, new_tileset_y, tmp_bitmap, tile_rect)
    cur_id += 1
  end

  for i in 0...priority_tiles.length
    tmp_bitmap.clear
    new_tileset_x = (cur_id & 7) * tile_size
    new_tileset_y = (cur_id >> 3) * tile_size
    id = priority_tiles[i]
    if id >= 384
      tmp_rect = Rect.new(
        ((id - 384) & 7) * tile_size,
        ((id - 384) >> 3) * tile_size,
        tile_size, tile_size
      )
      tmp_bitmap.blt(0, 0, tileset, tmp_rect)
      new_tileset.blt(new_tileset_x, new_tileset_y, tmp_bitmap, tile_rect)
    end
    cur_id += 1
  end

  for i in 0...event_tiles.length
    tmp_bitmap.clear
    new_tileset_x = (cur_id & 7) * tile_size
    new_tileset_y = (cur_id >> 3) * tile_size
    id = event_tiles[i]
    if id >= 384
      tmp_rect = Rect.new(
        ((id - 384) & 7) * tile_size,
        ((id - 384) >> 3) * tile_size,
        tile_size, tile_size
      )
      tmp_bitmap.blt(0, 0, tileset, tmp_rect)
      new_tileset.blt(new_tileset_x, new_tileset_y, tmp_bitmap, tile_rect)
    end
    cur_id += 1
  end

  new_tileset.make_png(new_tileset_data.tileset_name, "Graphics/Tilesets/")
  $data_tilesets[new_tileset_data.id] = new_tileset_data
  save_data($data_tilesets, "Data/Tilesets.rxdata")

  print("Saved tileset")

  new_tileset.dispose
  tmp_bitmap.dispose

  for y in 0...map.ysize
    for x in 0...map.xsize
      triple = [map[x,y,0], map[x,y,1], map[x,y,2]]
      for i in 0...3
        triple[i] = 0 if !priorities[triple[i]] || priorities[triple[i]] > 0
      end
      idx = triple_index(triples, triple)
      if idx >= 0
        map[x,y,0] = 384 + idx
        map[x,y,1] = 0
        map[x,y,2] = 0
      end
    end
  end

  for i in priority_pos
    map[i[0], i[1], i[2]] = i[3]
  end

  map_data.tileset_id = new_tileset_data.id

  file_name = pbMapFile(map_id, true)
  save_data(map_data, file_name)
  print("Saved map")
end




module Zlib
  class Png_File < GzipWriter
    def make_png(bitmap, mode = 0)
      @bitmap, @mode = bitmap, mode
      self.write(make_header)
      self.write(make_ihdr)
      self.write(make_idat)
      self.write(make_iend)
    end
    def make_header
      return [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a].pack('C*')
    end
    def make_ihdr
      ih_size               = [13].pack('N')
      ih_sign               = 'IHDR'
      ih_width              = [@bitmap.width].pack('N')
      ih_height             = [@bitmap.height].pack('N')
      ih_bit_depth          = [8].pack('C')
      ih_color_type         = [6].pack('C')
      ih_compression_method = [0].pack('C')
      ih_filter_method      = [0].pack('C')
      ih_interlace_method   = [0].pack('C')
      string = ih_sign + ih_width + ih_height + ih_bit_depth + ih_color_type +
               ih_compression_method + ih_filter_method + ih_interlace_method
      ih_crc = [Zlib.crc32(string)].pack('N')
      return ih_size + string + ih_crc
    end
    def make_idat
      header  = "\x49\x44\x41\x54"
      data    = @mode == 0 ? make_bitmap_data0 : make_bitmap_data1
      data    = Zlib::Deflate.deflate(data, 8)
      crc     = [Zlib.crc32(header + data)].pack('N')
      size    = [data.length].pack('N')
      return size + header + data + crc
    end
    def make_bitmap_data0
      gz = Zlib::GzipWriter.open('png2.tmp')
      t_Fx = 0
      w = @bitmap.width
      h = @bitmap.height
      data = []
      for y in 0...h
        data.push(0)
        for x in 0...w
          t_Fx += 1
          if t_Fx % 10000 == 0
            Graphics.update
            if t_Fx % 100000 == 0
              s = data.pack('C*')
              gz.write(s)
              data.clear
            end
          end
          color = @bitmap.get_pixel(x, y)
          data.push(color.red, color.green, color.blue, color.alpha)
        end
      end
      s = data.pack('C*')
      gz.write(s)
      gz.close   
      data.clear
      gz = Zlib::GzipReader.open('png2.tmp')
      data = gz.read
      gz.close
      File.delete('png2.tmp')
      return data
    end
    def make_bitmap_data1
      w = @bitmap.width
      h = @bitmap.height
      data = []
      for y in 0...h
        data.push(0)
        for x in 0...w
          color = @bitmap.get_pixel(x, y)
          data.push(color.red, color.green, color.blue, color.alpha)
        end
      end
      return data.pack('C*')
    end
    def make_iend
      ie_size = [0].pack('N')
      ie_sign = 'IEND'
      ie_crc  = [Zlib.crc32(ie_sign)].pack('N')
      return ie_size + ie_sign + ie_crc
    end
  end
end

#=============================================================================
# ** Bitmap
#=============================================================================
class Bitmap
  def make_png(name = 'like', path = '', mode = 0)
    Zlib::Png_File.open('png.tmp')   { |gz| gz.make_png(self, mode) }
    Zlib::GzipReader.open('png.tmp') { |gz| $read = gz.read }
    f = File.open(path + name + '.png', 'wb')
    f.write($read)
    f.close
    File.delete('png.tmp')
  end
end 