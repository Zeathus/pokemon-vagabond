def pbGetChoice(name)
  if !$game_variables[Supplementals::SAVED_CHOICES].is_a?(Hash)
    $game_variables[Supplementals::SAVED_CHOICES] = {}
  end
  return [-1, nil] if !$game_variables[Supplementals::SAVED_CHOICES].key?(name)
  return $game_variables[Supplementals::SAVED_CHOICES][name]
end

def pbGetChoiceIndex(name)
  if !$game_variables[Supplementals::SAVED_CHOICES].is_a?(Hash)
    $game_variables[Supplementals::SAVED_CHOICES] = {}
  end
  return -1 if !$game_variables[Supplementals::SAVED_CHOICES].key?(name)
  return $game_variables[Supplementals::SAVED_CHOICES][name][0]
end

def pbGetChoiceValue(name)
  if !$game_variables[Supplementals::SAVED_CHOICES].is_a?(Hash)
    $game_variables[Supplementals::SAVED_CHOICES] = {}
  end
  return nil if !$game_variables[Supplementals::SAVED_CHOICES].key?(name)
  return $game_variables[Supplementals::SAVED_CHOICES][name][1]
end

def pbHasChoice(name)
  if !$game_variables[Supplementals::SAVED_CHOICES].is_a?(Hash)
    $game_variables[Supplementals::SAVED_CHOICES] = {}
  end
  return $game_variables[Supplementals::SAVED_CHOICES].key?(name)
end

def pbSetChoice(name, index = -1, value = nil)
  if !$game_variables[Supplementals::SAVED_CHOICES].is_a?(Hash)
    $game_variables[Supplementals::SAVED_CHOICES] = {}
  end
  $game_variables[Supplementals::SAVED_CHOICES][name] = [index, value]
end