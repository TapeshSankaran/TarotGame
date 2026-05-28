Color = {}

function Color:rgb()
  return self.r, self.g, self.b, self.a
end

local color_mt = {
  __add = function(a, b)
    return Color((a.r + b.r)/2, (a.g + b.g)/2, (a.b + b.b)/2, (a.a + b.a)/2)
  end,

  __mul = function(a, b)
    if type(a) == "number" then return Color(a * b.r, a * b.g, a * b.b, b.a)
    elseif type(b) == "number" then return Color(b * a.r, b * a.g, b * a.b, a.a) end
    return Color(a.r * b.r, a.g * b.g, a.b * b.b, a.a * b.a)
  end,

  __index = Color
}

setmetatable(Color, {
  __call = function(_, r, g, b, a)
    a = a and a or 1
    if r > 1 or g > 1 or b > 1 then
      r = r / 255
      g = g / 255
      b = b / 255
    end
    local color = { r = r, g = g, b = b, a = a }
    setmetatable(color, color_mt)
    return color
  end
})

return Color
