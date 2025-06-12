
local Vector = require "vector"
local Config = require "conf"
Anim         = require "anim"
local Abilities = require "abilities"


local Card = {}
Card.__index = Card

-- Load all Images --
faceDown  = love.graphics.newImage(FILE_LOCATIONS.BACK)
emptyCard = love.graphics.newImage(FILE_LOCATIONS.EMPTY)
endButton = love.graphics.newImage(FILE_LOCATIONS.END)
background = love.graphics.newImage(FILE_LOCATIONS.BG)
ghostImg = love.graphics.newImage(FILE_LOCATIONS.GHOST)
beamImg = love.graphics.newImage(FILE_LOCATIONS.BEAM)
fireImg = love.graphics.newImage(FILE_LOCATIONS.FIRE)
pointsImg = love.graphics.newImage(FILE_LOCATIONS.POINTS)



name_font = love.graphics.newFont(FILE_LOCATIONS.FONT1, 14)
title_font = love.graphics.newFont(FILE_LOCATIONS.FONT1, 28)
detail_font = love.graphics.newFont(FILE_LOCATIONS.FONT2, 8)

-- Load all Audio --
   -- (empty) --

-- Edit Audio --
   -- (empty) --

-- CREATE NEW CARD --
function Card:new(data, faceUp, owner, x, y)
  local metatable = {__index = Card}
  local name, cost, power, ability = unpack(data)
  local card = {
    name = name,
    cost = cost,
    power = power,
    sprite = love.graphics.newImage("Sprites/" .. string.lower(name) .. ".png"),
    ability = ability,
    faceUp = faceUp,
    field = nil,
    owner = (owner == "Player" or owner == game.player) and game.player or game.opponent,
    position = Vector(x, y),
    isDragging = false,
    offsetX = 0,
    offsetY = 0,
    anchor = Vector(x, y),
    draggable = true,
    anim = Anim:new(fireImg, 32, 32, 15, 1.25, 1.75, 3.14/1.75, true)
  }
  setmetatable(card, metatable)
  return card
end

-- FORMAT CARD INTO PRINTABLE STATE --
function Card:toString()
  return self.name .. ": " .. "(" .. self.cost .. ", " .. self.power .. ")"
end

-- FLIP CARD --
function Card:flip()
  self.faceUp = not self.faceUp
end

function Card:trigger(trigger)
  if ABILITIES[self.name] and ABILITIES[self.name][trigger] then
    ABILITIES[self.name][trigger](self)
  end
end

-- DRAW CARD --
function Card:draw(dynamic_scale)
  dynamic_scale = dynamic_scale or scale
  local cardWidth  = img_width * dynamic_scale
  local cardHeight = img_height * dynamic_scale
  local mouseOver = self:isMouseOver(love.mouse.getX(), love.mouse.getY())
  local isPlayerCard = self.owner == game.player or self.owner == "Player"
  local d_scale = 1
  local g_color = COLORS.WHITE
  
  if isPlayerCard and tonumber(self.cost) > tonumber(game.player.mana) and self.field == nil then
    d_scale = 0.5
  end
  
  if self.faceUp and draggableCard == nil and mouseOver and game.state == "player_turn" and isPlayerCard then
    g_color = COLORS.LIGHT_GOLD
  end
  
  love.graphics.setColor(((COLORS.WHITE * g_color) * d_scale):rgb())
  if self.faceUp == true then
    love.graphics.draw(emptyCard, self.position.x, self.position.y, 0, dynamic_scale, dynamic_scale)
    love.graphics.draw(self.sprite, self.position.x+cardWidth/2, self.position.y+cardHeight*0.15, 0, 2.2*0.05, 2.2*0.05, self.sprite:getWidth()/2)
    
    love.graphics.setColor(((COLORS.PURPLE * 2.5 * g_color) * d_scale):rgb())
    love.graphics.setFont(name_font)
    love.graphics.printf(self.name, self.position.x, self.position.y, cardWidth, "center")
    
    love.graphics.setColor(((COLORS.BLUE * g_color) * d_scale):rgb())
    love.graphics.printf(self.cost, self.position.x+cardWidth*0.1, self.position.y+cardHeight*0.47, cardWidth, "left")
    
    local opacity = self.field and (self.power - 5)/5 or 0
    local x = tonumber(self.power) < 10 and 0.88 or 0.85
    love.graphics.setColor((COLORS.BLUE * Color(1, 1, 1, opacity)):rgb())
    self.anim:draw(self.position.x+cardWidth*x, self.position.y+cardHeight*0.47)
    
    love.graphics.setColor(((COLORS.DARK_RED * g_color) * d_scale):rgb())
    love.graphics.printf(self.power, self.position.x, self.position.y+cardHeight*0.47, cardWidth*0.92, "right")
    
    
    
    love.graphics.setColor(((COLORS.PURPLE*2 * g_color) * d_scale):rgb())
    love.graphics.setFont(detail_font)
    love.graphics.printf(self.ability, self.position.x+cardWidth*0.075, self.position.y+cardHeight*0.62, cardWidth*0.9, "center")
  else
    love.graphics.draw(faceDown, self.position.x, self.position.y, 0, dynamic_scale, dynamic_scale)
  end
  love.graphics.setColor(COLORS.WHITE:rgb())
end

-- START DRAGGING CARD --
function Card:startDrag(mouseX, mouseY)
  if game.state ~= "player_turn" then
    return
  end
  
  self.isDragging = true
  self.offsetX = mouseX - self.position.x
  self.offsetY = mouseY - self.position.y
  self.anchor = Vector(self.position.x, self.position.y)
end

-- TRANSFER PILE TO ANOTHER --
function Card:transfer(pile, prev_card_hidden)
  
  prev_card_hidden = prev_card_hidden or false
  local prev_shown = false
  
  -- If card is top if its pile...
  if self.pile.cards[#self.pile.cards] == self then
    
    -- Set prev_shown to whether previous card in pile is face up if there is a previous card --
    if #self.pile.cards > 1 then
      prev_shown = self.pile.cards[#self.pile.cards-1].faceUp
    end
    
    -- Set prev_shown to false if pile is waste pile --
    if self.pile == board.cardWaste then
      prev_shown = false
    end
    
    -- Transfer card --
    self.pile:remove()
    pile:add(self, prev_card_hidden)
    self.isDragging = false
  
  -- If card is not the top card in deck --
  else
  
    -- Remove cards from pile, check prev card in pile's face state --
    local cT, prev_shown = self.pile:removeI(self)
    
    -- Move all cards to pile. If previous card is hidden(and  -- 
    -- technically is an undo action), set it to hidden again. --
    for i,c in ipairs(cT) do
      if i == 1 and prev_card_hidden then
        pile:add(c, prev_card_hidden)
      else
        pile:add(c)
      end
    end
    self.isDragging = false
  end
  
  -- Play audio and return opposite of prev_shown --
  -- (if previous card is shown, when undoing, no action is needed. --
  --        action is needed when previous card is not shown)       --
  move_SFX:play()
  return not prev_shown
end
  
-- STOP DRAGGING CARD --
function Card:stopDrag(mouseX, mouseY)
    
    for i, field in ipairs(game.board.fields) do
      if field:isOver(mouseX, mouseY) then
        local index = indexOf(game.player.hand, self)
        if index == nil then break end
        
        local card = game.player:playCard(index)
        
        if card == nil then break end
        
        field:addCard(game.player, self)
      
        local c, onPlay = field:hasTrigger("onPlay", "both")
        if onPlay then
          onPlay(c, self)
        end
        table.insert(game.action, self)
        return
      end
    end
    
    -- Return card to original position if any condition did not pass or no pile was found --
    self.position = Vector(self.anchor.x, self.anchor.y)
    self.isDragging = false
end

-- UPDATE CARD POSITION WHEN DRAGGING --
function Card:update(dt, mouseX, mouseY)
  if self.isDragging and self.faceUp then
      
      self.position.x = mouseX - self.offsetX
      self.position.y = mouseY - self.offsetY
  end
end

function Card:animUpdate(dt)
  self.anim:update(dt)
end
-- CHECKS WHEN MOUSE IS OVER CARD --
function Card:isMouseOver(mouseX, mouseY)
    local width = img_width * scale
    local height = img_height * scale
    --local height = self.sprite:getHeight() * scale
    return mouseX > self.position.x and mouseX < self.position.x + width and
           mouseY > self.position.y and mouseY < self.position.y + height
end

return Card
