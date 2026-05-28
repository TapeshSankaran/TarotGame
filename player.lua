-- Player class

Deck   = require "deck"
Anim   = require "anim"
Player = {}
Player.__index = Player

theta = 0

function Player:new(name, x, y)
    
    local deck  = Deck:new(cardData, name, width*0.025, height*0.78)
    deck:shuffle()
  
    local hand = {}
    for _ = 1, 4 do
      local card = deck:deal()
      if name == "Opponent" then
        card:flip()
      end
      card.owner = name
      table.insert(hand, card)
    end
    
    local cardWidth = img_width*scale+10
    for i, card in ipairs(hand) do
      card.position = Vector(
        x+cardWidth*#hand*0.5-cardWidth*i,
        y
      )
    end
    
    return setmetatable({
        name = name,
        deck = deck,
        hand = hand,
        discard_pile = {},
        points = 0,
        mana = 1,
        extra = 0,
        position = Vector(x, y),
        lastPlayedCard = {},
        power_anim = Anim:new(fireImg, 32, 32, 15, 3, 3, 3.14/1.75, true)
    }, self)
end

function Player:drawCard()
  
  -- If hand is at limit or deck is empty, leave --
  if #self.hand >= 7 or #self.deck.cards <= 0 then
    return
  end

  -- Transfer top card to hand --
  table.insert(self.hand, self.deck:deal())

  -- Flip face down if enemy --
  if self.name == "Opponent" then
    self.hand[#self.hand]:flip()
    
  end
  
  self:respaceCards()
end

function Player:addCard(card)
  
  -- If hand is at limit or deck is empty, leave --
  if #self.hand >= 7 or card == nil then
    return
  end

  -- Transfer top card to hand --
  table.insert(self.hand, card)

  -- Flip face down if enemy --
  if self.name == "Opponent" then
    self.hand[#self.hand]:flip()
    
  end
  
  self:respaceCards()
end

function Player:playCard(index)
    local card = self.hand[index]
    if card and tonumber(card.cost) <= self.mana then
        self.mana = self.mana - card.cost
        table.remove(self.hand, index)
        self:respaceCards()
        return card
    end
    return nil
end

function Player:removeCard(index)
    local card = self.hand[index]
    if card then
        table.remove(self.hand, index)
        self:respaceCards()
        return card
    end
    return nil
end

function Player:respaceCards()
  -- Cardwidth + permittedd distance between cards --
  local cardWidth = img_width*scale+180/(4*#self.hand)
  
  -- Space cards apart properly --
  for i, card in ipairs(self.hand) do
    card.owner = self
    card.position = Vector(
      self.position.x+cardWidth*#self.hand*0.5-cardWidth*i,
      self.position.y
    )
  end
end

function Player:draw(dt)
  if self.name ~= "Opponent" then
    for _, card in ipairs(self.hand) do
      card:draw()
    end
    self.deck:draw()
  end

  theta = theta + dt * 0.1

  local is_opp = self.name == "Opponent"
  local main_color = is_opp and COLORS.RED or COLORS.PURPLE
  local glass_color = main_color * Color(1, 1, 1, 0.7)
  local smoke_color = main_color * Color(1, 1, 1, 0.5)
  
  local bg_color = COLORS.BLACK
  local avatar = is_opp and "O" or "P"
  
  local y = is_opp and height*0.01 or height*0.99
  local r = 0
  local bevel = 0.02
  local w = 1 - bevel * 2
  
  local anchor = orbImg:getWidth() / 2

  -- Avatar Bubble
  love.graphics.setColor(bg_color:rgb())
  love.graphics.circle("fill", width * 0.01, y, width * 0.103)
  
  local outline_color = is_opp and COLORS.GREY or COLORS.WHITE
  love.graphics.setColor(outline_color:rgb())
  love.graphics.circle("line", width * 0.01, y, width * 0.103)
  
  local offset = is_opp and 0 or 80
  love.graphics.setFont(title_font)
  love.graphics.printf(avatar, width * bevel, y - offset, width * w, "left", 0, 2, 2)

  love.graphics.setColor(glass_color:rgb())
  love.graphics.draw(orbImg, width * 0.01, y, r, 0.5, 0.5, anchor, anchor)

  love.graphics.setColor(smoke_color:rgb())
  love.graphics.draw(smokeImg, width * 0.01, y, r - theta, 0.5, 0.5, anchor, anchor)
  love.graphics.draw(smokeImg, width * 0.01, y, r + 90 + theta, 0.5, 0.5, anchor, anchor)  

  -- Power Bubble
  bg_color = COLORS.YELLOW
  smoke_color = ((main_color * 1.66) + (COLORS.ORANGE * 0.33)) * Color(1, 1, 1, 0.5)

  love.graphics.setColor(bg_color:rgb())
  love.graphics.circle("fill", width * 0.99, y, width * 0.103)
  
  local outline_color = is_opp and COLORS.GREY or COLORS.WHITE
  love.graphics.setColor(outline_color:rgb())
  love.graphics.circle("line", width * 0.99, y, width * 0.103)
  
  local offset = is_opp and 0 or 80
  love.graphics.setFont(title_font)
  love.graphics.printf(avatar, width * bevel, y - offset, width * w, "right", 0, 2, 2)

  love.graphics.setColor(smoke_color:rgb())
  love.graphics.draw(smokeImg, width * 0.99, y, r-90 + theta, 0.5, 0.5, anchor, anchor)
  love.graphics.draw(smokeImg, width * 0.99, y, r - theta, 0.5, 0.5, anchor, anchor)

  love.graphics.setColor(glass_color:rgb())
  love.graphics.draw(orbImg, width * 0.99, y, r, 0.5, 0.5, anchor, anchor)



  love.graphics.setColor(COLORS.BLUE:rgb())
  love.graphics.setFont(name_font)
  love.graphics.printf("Mana: " .. self.mana, self.position.x-width*0.1, self.position.y+y, 64, "right", 0, 1, 1, name_font:getWidth("Mana: " .. self.mana))
  love.graphics.setColor(COLORS.DARK_GOLD:rgb())
  love.graphics.printf("Points: " .. self.points, self.position.x+width*0.075, self.position.y+y, 64*2, "left")
end

return Player

