-- Field class

local Player = require "player"
local Anim   = require "anim"

Field = {}
Field.__index = Field

function Field:new(x, y, endX, endY)
    return setmetatable({
        player_slots = {},
        opponent_slots = {},
        position = Vector(x, y),
        dimensions= Vector(endX, endY)
    }, self)
end

function Field:addCard(player, card)
  local end_pos = self.position + self.dimensions
  local height = player.name == "Player" and end_pos.y - img_height * scale  or self.position.y
  local slots = player.name == "Player" and self.player_slots or self.opponent_slots
  if #slots < 4 then
    table.insert(slots, card)
    
    card.position = Vector(self.position.x + self.dimensions.x*(#slots-1)/4, height)
    card.field = self
    
    table.insert(anim_manager, {
      anim = Anim:new(beamImg, 48, 48, 20, 2, 4),
      x = card.position.x+img_width * scale/2,
      y = card.position.y+img_height * scale/2
    })
    
    return true
  end
  return false
end

function Field:removeCard(player, card)
  local slots = player.name == "Player" and self.player_slots or self.opponent_slots
  
  if #slots > 0 then
    local index = indexOf(slots, card)
    table.remove(slots, index)
    table.insert(player.discard_pile, card)
    
    table.insert(anim_manager, {
      anim = Anim:new(ghostImg, 48, 64, 15),
      x = card.position.x+img_width * scale/2,
      y = card.position.y
    })
  
    card.position = Vector(-100, -100)
    self:refreshCards(player)
    
    return card
  end
  return nil
end

function Field:emptyCardSlots(player)
  local slots = player.name == "Player" and self.player_slots or self.opponent_slots
  for i=1,#slots do  
    local card = table.remove(slots)
    
    table.insert(anim_manager, {
        anim = Anim:new(ghostImg, 48, 64, 15),
        x = card.position.x+img_width * scale/2,
        y = card.position.y+img_height * scale/2
    })
    
    table.insert(player.discard_pile, card)
    if ABILITIES[card.name] and ABILITIES[card.name].onDiscard then
      ABILITIES[card.name].onDiscard(card)
    end
    card.position = Vector(-100, -100)
  end
end

function Field:isWinning(player)
  local pPower, oPower = self:calculatePower()
  ownerPower = player.name == "Player" and pPower or oPower
  otherPower = player.name ~= "Player" and pPower or oPower
  return ownerPower > otherPower
end

function Field:refreshCards(player)
  local end_pos = self.position + self.dimensions
  local height = player.name == "Player" and end_pos.y - img_height * scale  or self.position.y
  local slots = player.name == "Player" and self.player_slots or self.opponent_slots
  for i, card in ipairs(slots) do
    card.position = Vector(self.position.x + self.dimensions.x*(i-1)/4, height)
  end
end

function Field:hasTrigger(trigger, target)
  if target == "Player" or target == "both" then
    for _, card in ipairs(self.player_slots) do
      local ability = ABILITIES[card.name]
      if ability and ability[trigger] then
        return card, ability[trigger]
      end
    end
  end
  if target == "Opponent" or target == "both" then
    for _, card in ipairs(self.opponent_slots) do
      local ability = ABILITIES[card.name]
      if ability and ability[trigger] then
        return card, ability[trigger]
      end
    end
  end
  return nil, nil
end

function Field:hasTriggers(trigger, target)
  local cards, abilities = {}, {}
  if target == "Player" or target == "both" then
    for _, card in ipairs(self.player_slots) do
      local ability = ABILITIES[card.name]
      if ability and ability[trigger] then
        table.insert(cards, card)
        table.insert(abilities, ability[trigger])
      end
    end
  end
  if target == "Opponent" or target == "both" then
    for _, card in ipairs(self.opponent_slots) do
      local ability = ABILITIES[card.name]
      if ability and ability[trigger] then
        table.insert(cards, card)
        table.insert(abilities, ability[trigger])
      end
    end
  end
  return cards ~= {} and cards or nil, abilities ~= {} and abilities or nil
end

function Field:calculatePower()
  local function sumPower(cards)
    local total = 0
    for _, c in ipairs(cards) do total = total + c.power end
    return total
  end
  return sumPower(self.player_slots), sumPower(self.opponent_slots)
end

function Field:isOver(mouseX, mouseY)
  local width = self.dimensions.x
  local height = self.dimensions.y
  --local height = self.sprite:getHeight() * scale
  return mouseX > self.position.x and mouseX < self.position.x + width and
        mouseY > self.position.y and mouseY < self.position.y + height
end

function Field:draw()
  local end_pos = self.position + self.dimensions
  local bevel = Vector(width * 0.003, height * 0.003)

  -- Background Panel --
  love.graphics.setColor((COLORS.BLACK * 0.5):rgb())
  love.graphics.rectangle("fill", 
    self.position.x - bevel.x, self.position.y - bevel.y, 
    self.dimensions.x + bevel.x * 2, self.dimensions.y + bevel.y * 2
  )

  love.graphics.setColor(COLORS.WHITE:rgb())

  -- Slot Size --
  local slotWidth = self.dimensions.x / 4
  local slotScaleX = scale
  local cardWidth = emptyCard:getWidth() * scale

  -- Player Slots (bottom) -- 
  for i = 1, 4 do
    local x = self.position.x + (i - 1) * slotWidth + (slotWidth - cardWidth) / 2
    local y = end_pos.y - img_height * scale
    if self.player_slots[i] then
      self.player_slots[i]:draw()
    else
      love.graphics.setColor(COLORS.PURPLE:rgb())
      love.graphics.draw(emptyCard, x, y, 0, scale, scale)
    end
  end

  -- Opponent Slots (top) --
  for i = 1, 4 do
    local x = self.position.x + (i - 1) * slotWidth + (slotWidth - cardWidth) / 2
    local y = self.position.y
    if self.opponent_slots[i] then
      self.opponent_slots[i]:draw()
    else
      love.graphics.setColor(COLORS.PURPLE:rgb())
      love.graphics.draw(emptyCard, x, y, 0, scale, scale)
    end
  end

  love.graphics.setColor(COLORS.WHITE:rgb())
end

return Field
