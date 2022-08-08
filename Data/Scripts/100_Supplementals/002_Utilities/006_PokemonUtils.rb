def pbStatArrayToHash(arr)
  return {
    :HP => arr[0],
    :ATTACK => arr[1],
    :DEFENSE => arr[2],
    :SPEED => arr[3],
    :SPECIAL_ATTACK => arr[4],
    :SPECIAL_DEFENSE => arr[5]
  }
end