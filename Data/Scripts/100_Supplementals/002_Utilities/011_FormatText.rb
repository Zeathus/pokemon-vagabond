def _format(text)
  text = text + ""
  while text.include?('{') && text.include?('}')
    index1 = text.index('{')
    index2 = text.index('}')
    code = eval(text[(index1+1)...index2])
    text = _INTL(
      "{1}{2}{3}",
      text[0...index1],
      code,
      text[(index2+1)...text.length]
    )
  end
  return text
end

alias _f _format