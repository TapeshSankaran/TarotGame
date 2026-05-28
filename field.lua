-- Field class

local Player = require "player"
local Anim   = require "anim"
local NUM_CARDS = 3

Field = {}
Field.__index = Field

function Field:new(id, x, y, w, h)
    return setmetatable({
        placement = id,
        player_slots = {},
        opponent_slots = {},
        position = Vector(x, y),
        dimensions= Vector(w, h)
    }, self)
end

function Field:addCard(player, card)
  local end_pos = self.position + self.dimensions
  local height = player.name == "Player" and end_pos.y - img_height * scale  or self.position.y
  local slots = player.name == "Player" and self.player_slots or self.opponent_slots
  if #slots < 3 then
    table.insert(slots, card)
    
    card.position = Vector(self.position.x + self.dimensions.x*(#slots-1)/3, height)
    card.field = self 
    
    table.insert(anim_manager, {
      anim = Anim:new(beamImg, 48, 48, 20, 2, 4),
      x = card.position.x+img_width * scale/2,
      y = card.position.y+img_height * scale/2
    })
    
    placeSFX:stop()
    placeSFX:play()
    
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
  if #slots > 0 then
    deathSFX:stop()
    deathSFX:play()
    local clone = revealSFX:clone()
    clone:setPitch(1+(initActionSize)*0.14)
    clone:play()
  end
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
  return self:getPower(game.player), self:getPower(game.opponent)
end

function Field:getPower(player)
  local slots = player == game.player and self.player_slots or self.opponent_slots
  local total = 0
  for i = 1, 4 do
    local card = slots[i]
    if card and card.power then
      total = total + tonumber(card.power)
    end
  end
  return total
end

function Field:isOver(mouseX, mouseY)
  local width = self.dimensions.x
  local height = self.dimensions.y
  --local height = self.sprite:getHeight() * scale
  return mouseX > self.position.x and mouseX < self.position.x + width and
        mouseY > self.position.y and mouseY < self.position.y + height
end

function Field:draw(dt)
  local end_pos = self.position + self.dimensions
  local bevel = Vector(0, 0)--Vector(width * 0.003, height * 0.003)

  -- Background Panel --
  love.graphics.setColor(COLORS.DARK_RED:rgb())
  love.graphics.rectangle("fill", 
    self.position.x - bevel.x, self.position.y - bevel.y, 
    self.dimensions.x + bevel.x * 2, self.dimensions.y + bevel.y * 2
  )
  -- outline is yellow if middle field, else white
  local line_color = self.placement == 0 and COLORS.YELLOW or COLORS.ORANGE
  love.graphics.setColor(line_color:rgb())
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", 
    self.position.x - bevel.x, self.position.y - bevel.y, 
    self.dimensions.x + bevel.x * 2, self.dimensions.y + bevel.y * 2
  )

  love.graphics.setColor(COLORS.WHITE:rgb())

  local cardWidth = img_width * scale
  local cardHeight = img_height * scale
  
  -- Slot Size --
  local fair_width = game.board.size.W*0.33
  local slotWidth = ((fair_width - cardWidth) / NUM_CARDS)

  local centerX = (self.dimensions.x - (NUM_CARDS * slotWidth)) / 2
  local x_offset   = img_width * scale * 0.1
  -- Player Slots (bottom) -- 
  for i = 1, NUM_CARDS do
    local x = self.position.x + (i - 1) * slotWidth + (slotWidth - cardWidth) / 2 + centerX + self.placement * x_offset
    local y = end_pos.y - cardHeight * 1.5
    if i == 2 then
      y = y - img_height * scale * 0.25
    end
    if self.player_slots[i] then
      self.player_slots[i]:draw()
    else
      love.graphics.setColor(COLORS.GREY:rgb())
      love.graphics.draw(emptyCard, x, y, 0, scale, scale)
    end
  end

  -- Opponent Slots (top) --
  for i = 1, NUM_CARDS do
    local x = self.position.x + (i - 1) * slotWidth + (slotWidth - cardWidth) / 2 + centerX + self.placement * x_offset
    local y = self.position.y + cardHeight * 0.5
    if i == 2 then
      y = y + cardHeight * 0.25
    end
    if self.opponent_slots[i] then
      self.opponent_slots[i]:draw()
    else
      love.graphics.setColor(COLORS.GREY:rgb())
      love.graphics.draw(emptyCard, x, y, 0, scale, scale)
    end
  end

  love.graphics.setColor(COLORS.WHITE:rgb())
end

return Field
