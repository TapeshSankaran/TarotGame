
Player = require "player"

pyAI = {}
pyAI.__index = pyAI

function pyAI:new(player)
  local ai = {
    player = player,
    action = {}
  }
  setmetatable(ai, pyAI)
  return ai
end

-- Returns a table of card plays: { {card, fieldIndex, slotIndex}, ... }
function pyAI:takeTurn()
  local turn = {}
  local hand = self.player.hand
  local used = {}
  turn.hand = {}
  for _, card in ipairs(hand) do
    table.insert(turn.hand, self:encodeAbilities(card))
  end
  
  turn.playedCards = {}
  
  
  for i, field in ipairs(game.board.fields) do
    local uSlots = self.player == game.player and field.player_slots or field.opponent_slots
    local oppSlots = self.player == game.player and field.opponent_slots or field.player_slots

    table.insert(turn.playedCards, { myCards = {}, oppCards = {} })
    for _, card in ipairs(uSlots) do
      table.insert(turn.playedCards[i].myCards, self:encodeAbilities(card))
    end
    for _, card in ipairs(oppSlots) do
      table.insert(turn.playedCards[i].oppCards, self:encodeAbilities(card))
    end
  end
  
  turn.actions = {}
  
  local availableMana = self.player.mana
  

  local bestMoves = {}

  -- Evaluate all possible moves
  for _, card in ipairs(hand) do
    if tonumber(card.cost) <= availableMana then
      for locIndex, field in ipairs(game.board.fields) do
        local score = self:scoreCardPlay(card, field, slotsOpen)
        table.insert(bestMoves, {
          card = card,
          field = locIndex,
          score = score
        })
      end
    end
  end

  -- Sort --
  table.sort(bestMoves, function(a, b)
    return a.score > b.score
  end)

  -- Play best cards until mana runs out
  for _, move in ipairs(bestMoves) do
    local card = move.card
    if tonumber(card.cost) <= availableMana and not self:isCardUsed(card, used) then
      local field = game.board.fields[move.field]
      local index = indexOf(self.player.hand, card)

      if index == nil then break end

      local outCard = self.player:playCard(index)
      if outCard == nil then break end

      field:addCard(self.player, outCard)

      -- Trigger any onPlay effect
      local c, onPlay = field:hasTrigger("onPlay", "both")
      if onPlay then
        onPlay(c, card)
      end

      availableMana = availableMana - card.cost
      table.insert(used, card)
      table.insert(game.action, card)
      table.insert(turn.actions, { card = self:encodeAbilities(card), field = move.field })
    end
  end

  self.action = turn
  return turn
end


function pyAI:findOpenSlot(field, player)
  local side = field.opponent_slots  -- assume board field holds { [1] = {}, [2] = {} } for players 
  return 4 - #side
end

function pyAI:selectWeakestEnemyField()
  local bestLoc, minPower = 1, math.huge
  local opp = self.player == game.player and game.opponent or game.player
  for i, field in ipairs(game.board.fields) do
    local enemyPower = field:getPower(opp)
    if enemyPower < minPower then
      bestLoc, minPower = i, enemyPower
    end
  end
  return bestLoc
end

function pyAI:scoreCardPlay(card, field, slot)
  local opp = self.player == game.player and game.opponent or game.player
  local enemyPower = field:getPower(opp) or 0
  local myPower = field:getPower(self.player) or 0
  local abScore = self:scoreAbilities(card) or 1
  local baseScore = ((tonumber(card.power) or 1) + abScore) / (tonumber(card.cost) or 1)

  -- Prefer fields with weak enemies --
  local pressureFactor = 1 / (1 + enemyPower)

  -- Optional: Give bonus if slot is early (e.g., edge lanes) --
  local laneBonus = (myPower + card.power > enemyPower) and 1 or -0.5
  local counterBonus = (card.name == "Justice" and myPower+12 < enemyPower) and 2 or -1

  return baseScore * pressureFactor + laneBonus + counterBonus
end

function pyAI:scoreAbilities(card)
  local score = 0
  local abilities = ABILITIES[card.name] or {}

  for _, key in ipairs(ABILITY_KEYS) do
    if abilities[key] then
      score = score + (ABILITY_WEIGHTS[key] or 0)
    end
  end

  return score
end


function pyAI:isCardUsed(card, usedList)
  for _, used in ipairs(usedList) do
    if used == card then return true end
  end
  return false
end

function pyAI:encodeAbilities(card)
  local result = {}
  local vector = {}
  local ab = ABILITIES[card.name] or {}
  table.insert(vector, tonumber(card.cost))
  table.insert(vector, tonumber(card.power))
  for _, key in ipairs(ABILITY_KEYS) do
    table.insert(vector, ab[key] and 1 or 0)
  end
  result.name = card.name
  result.vector = vector
  return result
end

return pyAI
