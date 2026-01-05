def pbShowSpeciesPicture(species, dialog = "", playcry = true)
  bitmap = GameData::Species.front_sprite_bitmap(species)
  GameData::Species.play_cry(species, 100, 100) if playcry
  if bitmap # to prevent crashes
    iconwindow=PictureWindow.new(bitmap.bitmap)
    iconwindow.x=(Graphics.width/2)-(iconwindow.width/2)
    iconwindow.y=((Graphics.height-96)/2)-(iconwindow.height/2)
    if dialog.upcase == dialog
      pbDialog(dialog)
    else
      pbMessage("Failed to show pokemon. Please report to developer.")
    end
    iconwindow.dispose
    bitmap.dispose
  end
end