
-- Game class

local Player  = require "player"
local Board   = require "board"

Game = {}
Game.__index = Game

function Game:new()
  return setmetatable({
    turn = 1,
    targetPoints = target_points,
    player = Player:new("Player", width/2, height*0.79),
    opponent = Player:new("Opponent", width/2, -height*0.005),
    board = Board:new(width*0.01, height*0.2, width*1.01, height*0.71),
    extra = 0,
    state = "start",
    action = {}
  }, self)
end

function Game:nextTurn()
  local results = self.board:evaluateTurn()
  
  if results.player and results.player > 0 then
    table.insert(anim_manager, {
      anim = Anim:new(pointsImg, 32, 32, 15, 3, 3),
      x = self.player.position.x+width*0.1,
      y = self.player.position.y-height*0.035
    })
  end
  if results.opponent and results.opponent > 0 then
    table.insert(anim_manager, {
      anim = Anim:new(pointsImg, 32, 32, 15, 3, 3),
      x = self.opponent.position.x+width*0.1,
      y = self.opponent.position.y+height*0.075
    })
  end
  
  self.player.points = self.player.points + (results.player or 0)
  self.opponent.points = self.opponent.points + (results.opponent or 0)

  if self.player.points >= self.targetPoints or self.opponent.points >= self.targetPoints then
    if self.player.points > self.opponent.points then
      self.winner = "Player wins!"
      self.state = "won"
      result = "win"
    elseif self.opponent.points > self.player.points then
      self.winner = "Opponent wins!"
      self.state = "won"
      result = "lose"
    else
      self.winner = "It's a draw!"
      self.state = "won"
      result = "draw"
    end
    for _, field in ipairs(self.board.fields) do
      field:emptyCardSlots(self.player)
      field:emptyCardSlots(self.opponent)
    end
    return true
  end
  
  self.turn = self.turn + 1
  self.player.mana = self.turn + self.player.extra
  self.opponent.mana = self.turn + self.opponent.extra
  self.player:drawCard()
  self.opponent:drawCard()
  
  for _, field in ipairs(self.board.fields) do
    local cards, onEoTs = field:hasTriggers("onEoT", "both")
    if onEoTs then
      for i, onEoT in ipairs(onEoTs) do
        onEoT(cards[i])
      end
    end
  end
end

function Game:submitTurn()
  for _, card in ipairs(self.action) do
    card.faceUp = false
  end
  local turn = ai:takeTurn()
  initActionSize = #self.action
  
  local worldIndex = indexOfName(self.action, "The World")
  if worldIndex then
    table.insert(self.action, 1, table.remove(self.action, worldIndex))
  end
  
  return turn
end

function Game:revealCard()
  local card = self.action[1]
  
  local clone = revealSFX:clone()
  clone:setPitch(1+(initActionSize-#self.action)*0.14)
  clone:play()
  
  if card ~= nil then 
    card:flip()
  end
end

function Game:activateReveal()
  local card = table.remove(self.action, 1)
  
  if card ~= nil then
    card:trigger("onReveal")
  end
end

function Game:createCard(cardData, faceUp)
  local card = Card:new(cardData, faceUp, -100, -100)
  return card
end

function Game:playDeath()
  deathSFX:play()
end

function Game:draw()
  love.graphics.setColor((COLORS.WHITE * 0.5):rgb())
  love.graphics.draw(background, 0, 0, 0, width/612, height/408)
    
  self.board:draw()
  self.player:draw()
  self.opponent:draw()
  if game.state == "player_turn" then
    love.graphics.setColor(COLORS.WHITE:rgb())
    love.graphics.draw(endButton, end_x, end_y, 0, end_scale, end_scale)
  end
  love.graphics.setColor(COLORS.BLACK:rgb())
  love.graphics.setFont(name_font)
  love.graphics.printf("Round " .. self.turn, 0, height*0.01, width*0.5, "center", 0, 2, 2)
end

return Game
