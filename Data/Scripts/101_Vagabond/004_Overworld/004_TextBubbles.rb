def pbPDialog(member, text)
  member = getID(PBParty, member) if member.is_a?(Symbol)
  $game_temp.partner_text_bubble(member, text)
  return
  if getPartyActive(0) == member
      $game_player.sprite.say(text)
  elsif getPartyActive(1) == member
      $game_player.sprite.partner.say(text)
  end
end