local Config = require "conf"

local Slider = {}
Slider.__index = Slider

function Slider:new(name, x, y, width, min, max, value, step, onChange)
    local self = setmetatable({}, Slider)
    self.x = x
    self.y = y
    self.name = name
    self.width = width
    self.height = 20
    self.min = min or 0
    self.max = max or 1
    self.value = value or min or 0
    self.step  = step  or 1
    self.onChange = onChange or function(val) end

    self.knobRadius = 10
    self.dragging = false

    return self
end

function Slider:update(dt)
    if self.dragging then
        local mouseX = love.mouse.getX()
        local percent = (mouseX - self.x) / self.width
        percent = math.max(0, math.min(1, percent))

        local rawValue = self.min + percent * (self.max - self.min)
        local step = self.step
        self.value = math.floor((rawValue - self.min) / step + 0.5) * step + self.min

        self.onChange(self.value)
    end
    return self.value
end

function Slider:draw()
  -- Name
  love.graphics.setColor(COLORS.BLUE:rgb())
  love.graphics.setFont(name_font)
  love.graphics.print(self.name, self.x-name_font:getWidth(self.name)-10, self.y)
  -- Bar
  love.graphics.setColor(COLORS.GREY:rgb())
  love.graphics.rectangle("fill", self.x, self.y + self.height/2 - 2, self.width, 4)

  -- Knob
  local percent = (self.value - self.min) / (self.max - self.min)
  local knobX = self.x + percent * self.width
  love.graphics.setColor(COLORS.WHITE:rgb())
  love.graphics.circle("fill", knobX, self.y + self.height / 2, self.knobRadius)
  
  love.graphics.setColor(COLORS.BLUE:rgb())
  local font = love.graphics.newFont(FILE_LOCATIONS.FONT2, 11)
  love.graphics.setFont(font)
  local fW = font:getWidth(self.value)
  love.graphics.print(self.value, knobX, self.y + self.height/8, 0, 1, 1, fW/2, 0)
end

function Slider:mousepressed(x, y, button)
    if button == 1 then
        local percent = (self.value - self.min) / (self.max - self.min)
        local knobX = self.x + percent * self.width
        local knobY = self.y + self.height / 2
        local dist = math.sqrt((x - knobX)^2 + (y - knobY)^2)
        if dist <= self.knobRadius then
            self.dragging = true
        end
    end
end

function Slider:mousereleased(x, y, button)
    if button == 1 then
        self.dragging = false
    end
end

return Slider
