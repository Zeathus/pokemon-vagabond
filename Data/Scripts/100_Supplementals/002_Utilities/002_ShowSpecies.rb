def pbShowSpeciesPicture(species, message = "", playcry = true)
  battlername=sprintf("Graphics/Pokemon/Front/%s",species.to_s)
  bitmap=pbResolveBitmap(battlername)
  GameData::Species.play_cry(species, 100, 100) if playcry
  if bitmap # to prevent crashes
    iconwindow=PictureWindow.new(bitmap)
    iconwindow.x=(Graphics.width/2)-(iconwindow.width/2)
    iconwindow.y=((Graphics.height-96)/2)-(iconwindow.height/2)
    pbMessage(message)
    iconwindow.dispose
  end
end