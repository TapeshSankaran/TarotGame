
local Config = require "conf"

local Menu = {}
Menu.__index = Menu

function Menu:new(title, items, options)
    local self = setmetatable({}, Menu)

    self.title = title or "Menu"
    self.items = items or {} -- can be {type="button", ...} or {type="slider", ...}
    self.options = options or {}
    self.font = self.options.font or love.graphics.newFont(FILE_LOCATIONS.FONT2, 24)
    self.titleFont = self.options.titleFont or love.graphics.newFont(FILE_LOCATIONS.FONT1, 36)
    self.color = self.options.color or COLORS.WHITE
    self.titleColor = self.options.titleColor or COLORS.WHITE
    self.selected = 1
    self.spacing = self.options.spacing or height*0.1
    self.yOffset = self.options.yOffset or height*0.2
    self.centered = self.options.centered ~= false
    self.isEnabled = false
    return self
end

function Menu:update(dt)
  for _, item in ipairs(self.items) do
    if item.type == "slider" then
      item.slider:update(dt)
    end
  end
end

function Menu:draw()
  love.graphics.setColor((COLORS.WHITE + COLORS.BLACK):rgb())
  love.graphics.draw(background, 0, 0, 0, width/612, height/408)
  
  love.graphics.setFont(self.titleFont)
  love.graphics.setColor(self.titleColor:rgb())
  love.graphics.printf(self.title, 0, self.yOffset, width, "center")

  love.graphics.setFont(self.font)
  for i, item in ipairs(self.items) do
    local y = self.yOffset + (i/#self.items * (height - self.yOffset*2))

    if i == self.selected then
      love.graphics.setColor(COLORS.PURPLE:rgb())
    else
      love.graphics.setColor(self.color:rgb())
    end

    if item.type == "button" then
      love.graphics.setFont(self.font)
      love.graphics.printf(item.label, 0, y, width, "center")
    elseif item.type == "slider" then
      item.slider.y = y
      item.slider:draw()
    elseif item.type == "image" then
      local imgH = item.image:getHeight()
      local imgW = item.image:getWidth()
      love.graphics.draw(item.image, width*0.5, y, 0, item.sx or 1, item.sy or 1, imgW*0.5, imgH*0.5)
    end
  end
end

function Menu:keypressed(key)
    local current = self.items[self.selected]

    if key == "up" or key == "w" then
        self.selected = self.selected - 1
        if self.selected < 1 then
            self.selected = #self.items
        end
    elseif key == "down" or key == "s" then
        self.selected = self.selected + 1
        if self.selected > #self.items then
            self.selected = 1
        end
    elseif key == "left" or key == "a" then
        if current.type == "slider" then
            current.value = math.max(current.min, current.value - (current.step or 0.05))
            if current.onChange then current.onChange(current.value) end
        end
    elseif key == "right" or key == "d" then
        if current.type == "slider" then
            current.value = math.min(current.max, current.value + (current.step or 0.05))
            if current.onChange then current.onChange(current.value) end
        end
    elseif key == "return" or key == "space" then
        if current.type == "button" and current.action then
            current.action()
        end
    end
end

function Menu:mousereleased(x, y, button)
  for _, item in ipairs(self.items) do
    if item.type == "slider" then
      item.slider:mousereleased(x, y, button)
    end
  end
end

function Menu:mousepressed(x, y, button)
  if button ~= 1 then return end
  local screenWidth = love.graphics.getWidth()

  for i, item in ipairs(self.items) do
    local itemY = self.yOffset + (i/#self.items * (height - self.yOffset*2))


    if item.type == "button" then
      local textWidth = self.font:getWidth(item.label)
      local textHeight = self.font:getHeight()
      local textX = (screenWidth - textWidth) / 2
      if x >= textX and x <= textX + textWidth and y >= itemY and y <= itemY + textHeight then
          if item.action then item.action() end
      end
    elseif item.type == "slider" then
      item.slider:mousepressed(x, y, button)
    end
  end
end

return Menu
