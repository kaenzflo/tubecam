class Gradient

  def Gradient.randomColor(days)
    # Define thershold value when tubecam is outdated
    threshold = 150

    if days > threshold
      days = threshold
    end

    # Caculate relative value for color range
    vary = (350.0 / threshold * days).round

    # Caculates gradient from green (100,225,0) to red (225,0,0)
    if vary < 125
      g = (225).to_s(16)
      r = (100 + vary).to_s(16)
    else
      r = (225).to_s(16)
      rest = vary - 125
      g = (225 - rest).to_s(16)
    end
    b = (0).to_s(16)

    r, g, b = [r, g, b].map { |s| if s.size == 1 then '0' + s else s end }

    color = r + g + b
  end

end