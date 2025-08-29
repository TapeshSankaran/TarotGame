
Player = require "player"

AI = {}
AI.__index = AI

function AI:new(player, board)
  local ai = {
    player = player,
    board = board,
    action = {}
  }
  setmetatable(ai, AI)
  return ai
end

function AI:takeTurn()
  local turn = {}
  local used = {}
  local hand = self.player.hand
  local availableMana = self.player.mana
    
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
  local bestMoves = {}

  -- Evaluate all possible moves
  for _, card in ipairs(hand) do
    if tonumber(card.cost) <= availableMana then
      for locIndex, field in ipairs(self.board.fields) do
        local slotsOpen = self:findOpenSlot(field, self.player)
        if slotsOpen > 0 then
          local score = self:scoreCardPlay(card, field, slotsOpen)
          table.insert(bestMoves, {
            card = card,
            field = locIndex,
            slot = slotsOpen,
            score = score
          })
        end
      end
    end
  end

  -- Sort by descending score
  table.sort(bestMoves, function(a, b)
    return a.score > b.score
  end)

  -- Play best cards until mana runs out
  for _, move in ipairs(bestMoves) do
    local card = move.card
    if tonumber(card.cost) <= availableMana and not self:isCardUsed(card, used) then
      local field = self.board.fields[move.field]
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


function AI:findOpenSlot(field, player)
  local side = player == game.player and field.player_slots or field.opponent_slots
  return 4 - #side
end

function AI:selectWeakestEnemyField()
  local bestLoc, minPower = 1, math.huge
  for i, field in ipairs(self.board.fields) do
    local enemyPower = field:getPower(self.player)
    if enemyPower < minPower then
      bestLoc, minPower = i, enemyPower
    end
  end
  return bestLoc
end

function AI:scoreCardPlay(card, field, slot)
  local enemyPower = field:getPower(self.player) or 0
  local baseScore = (tonumber(card.power) or 1) / (tonumber(card.cost) or 1)

  -- Prefer fields with weak enemies
  local pressureFactor = 1 / (1 + enemyPower)

  -- Optional: Give bonus if slot is early (e.g., edge lanes)
  local laneBonus = (slot == 1 or slot == 4) and 0.2 or 0

  return baseScore * pressureFactor + laneBonus
end

function AI:isCardUsed(card, usedList)
  for _, used in ipairs(usedList) do
    if used == card then return true end
  end
  return false
end

function AI:encodeAbilities(card)
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



return AI
