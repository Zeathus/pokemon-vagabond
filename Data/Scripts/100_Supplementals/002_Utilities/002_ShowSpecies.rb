def pbShowSpeciesPicture(species, dialog = "", playcry = true)
  battlername=sprintf("Graphics/Pokemon/Front/%s/%s",species.to_s[0..0],species.to_s)
  bitmap=pbResolveBitmap(battlername)
  GameData::Species.play_cry(species, 100, 100) if playcry
  if bitmap # to prevent crashes
    iconwindow=PictureWindow.new(bitmap)
    iconwindow.x=(Graphics.width/2)-(iconwindow.width/2)
    iconwindow.y=((Graphics.height-96)/2)-(iconwindow.height/2)
    if dialog.upcase == dialog
      pbDialog(dialog)
    else
      pbMessage("Failed to show pokemon. Please report to developer.")
    end
    iconwindow.dispose
  end
end