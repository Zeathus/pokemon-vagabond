def pbNumericUpDown(text, min = 1, max = 100, init = 1, cancel = -1)
  params=ChooseNumberParams.new
  params.setRange(min, max)
  params.setInitialValue(init)
  params.setCancelValue(cancel)
  ret = pbMessageChooseNumber(text, params)
  return ret
end