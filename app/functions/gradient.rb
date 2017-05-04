class Gradient

  def Gradient.randomColor(days)

    if days > 150
      days = 150
    end

    r = (100 + days/2).to_s(16)
    g = (205 - days).to_s(16)
    b = (0).to_s(16)

    r, g, b = [r, g, b].map { |s| if s.size == 1 then '0' + s else s end }

    color = r + g + b
  end

end