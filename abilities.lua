
-- Abilities --

local Config = require "conf"

ABILITIES = {
  
  ["Four of Cups"] = nil,
  ["Three of Wands"]    = nil,
  ["Two of Swords"]   = nil,
  ["Ace of Pentacles"]      = nil,
  
  ["The Heirophant"] = {
    onReveal = function(card)
      if card == nil then return end
      local player = card.owner == game.player and game.opponent or game.player
      for _, c in ipairs(player.hand) do
        c.power = c.power - 1
      end
    end
  },

  ["The Emperor"] = {
    onReveal = function(card)
      if card == nil then return end
      if card.field ~= nil then
        local slots = card.owner == game.player and card.field.opponent_slots or card.field.player_slots
        card.power = card.power + #slots * 2
      end
    end,
    buff = true
  },

  ["The Hanged Man"] = {
    onPlay = function(card, c)
      if card == nil then return end
      c.power = (tonumber(c.power) > 0 and c ~= card) and c.power - 1 or c.power
    end,
    curse = true
  },

  ["The Moon"] = {
    onReveal = function(card)
      if card == nil then return end
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      local toRemove = {}
      for _, c in ipairs(slots) do
        if c ~= card then
          table.insert(toRemove, c)
          card.power = card.power + 2
        end
      end
      for _, c in ipairs(toRemove) do
        card.field:removeCard(card.owner, c)
      end
    end,
    buff = true,
    sacrifice = true
  },

  ["The Devil"] = {
    onReveal = function(card)
      if card == nil then return end
      local enemy_slots = card.owner == game.player and card.field.opponent_slots or card.field.player_slots
      local weakest, index = nil, nil
      local enemy = card.owner == game.player and game.opponent or game.player
      for i, c in ipairs(enemy_slots) do
        if not weakest or tonumber(c.power) < tonumber(weakest.power) then
          weakest = c
          index = i
        end
      end
      if weakest then
        game.board:moveCard(weakest.owner, weakest)
      end
    end,
    move = true
  },

  ["The Hermit"] = {

    onReveal = function(card)
      if card == nil then return end
      local enemy_slots = card.owner == game.player and card.field.opponent_slots or card.field.player_slots
      if #enemy_slots == 1 then
        card.power = card.power + 5
      end
    end,
    buff = true
  },

  ["The Empress"] = {
    onReveal = function(card)
      if card == nil then return end
      for _, c in ipairs(card.owner.hand) do
        c.power = c.power + 1
      end
    end,
    buff = true
  },

  ["The Fool"] = {
    onReveal = function(card)
      if card == nil then return end
      card.owner:drawCard()
      game.opponent:drawCard()
    end,
    copy = true
  },

  ["Death"] = {
    onReveal = function(card)
      if card == nil then return end
      card.power = card.power + #card.owner.discard_pile*2
    end,
    buff = true
  },

  ["Strength"] = {
    onReveal = function(card)
      if card == nil then return end
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      local strongest = card
      for _, c in ipairs(slots) do
        if tonumber(c.power) > tonumber(strongest.power) then return end
      end
      if strongest == card then
        card.power = card.power * 2
      end
    end,
    buff = true
  },

  ["The Sun"] = {
    onReveal = function(card)
      if card == nil then return end
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      card.power = card.power + (#slots - 1) * 2
    end,
    buff = true
  },

  ["The Chariot"] = {
    onReveal = function(card)
      if card == nil then return end
      game.board:moveCard(card.owner, card)
    end,
    move = true
  },

  ["The World"] = {
    onReveal = function(card)
      if card == nil then return end
      for _, card in ipairs(game.action) do
        if card ~= nil then
          card:flip()
        end 
      end
      game.action = {}
    end,
    curse = true
  },

  ["Wheel of Fortune"] = {
    onReveal = function(card)
      if card == nil then return end
      local wheel_of_fortune = cardData[18]
      wheel_of_fortune = game:createCard(wheel_of_fortune, true)
      wheel_of_fortune.owner = card.owner
      wheel_of_fortune.power = wheel_of_fortune.power + 1
      card.owner:addCard(wheen_of_fortune)
    end,
    copy = true,
    buff = true
  },

  ["Temperance"] = {
    onEoT = function(card)
      if card == nil then return end
      if card.field:isWinning(card.owner) and tonumber(card.power) < 16 then
        card.power = card.power * 2
      end
    end,
    buff = true
  },

  ["Justice"] = {
    onReveal = function(card)
      if card == nil then return end
      local all = {}
      for _, c in ipairs(card.field.player_slots) do table.insert(all, c) end
      for _, c in ipairs(card.field.opponent_slots) do table.insert(all, c) end
      for _, c in ipairs(all) do
        c.power = 3
      end
    end
  },

  ["The Lovers"] = {
    onReveal = function(card)
      if card == nil then return end
      local enemy_slots = card.owner == game.player and card.field.opponent_slots or card.field.player_slots
      for _, c in ipairs(enemy_slots) do
        c.power = c.power - 1
      end
    end,
    curse = true
  },

  ["The Magician"] = {
    onPlay = function(card, c)
      if card == nil then return end
      if c ~= card and card.owner == c.owner then
        card.power = card.power + 1
      end
    end,
    buff = true
  },

  ["The Star"] = {
    onReveal = function(card)
      if card == nil then return end
      card.owner.extra = card.owner.extra + 1
    end,
    buff = true
  },

  ["The Alchemist"] = {
    onReveal = function(card)
      if card == nil then return end
      for i=1,2 do
        local c = card.owner.hand[math.ceil(math.random(#card.owner.hand))]
        c.cost = c.cost - 1
      end
    end,
    buff = true
  },

  ["The Void"] = {
    onReveal = function(card)
      if card == nil then return end
      local weakest = card.owner.hand[1]
      local index = 1
      for i, c in ipairs(card.owner.hand) do
        if not weakest or tonumber(c.power) < tonumber(weakest.power) then
          weakest = c
          index = i
        end
      end
      if weakest then
        local c = card.owner:removeCard(index)
        if c and c == weakest then 
          c.position = Vector(-100, -100)
          table.insert(card.owner.discard_pile, c)
        else
          print("WTF")
        end
      end
    end
  },

  ["The Seer"] = {
    onReveal = function(card)
      if card == nil then return end
      local enemy = card.owner == game.player and game.opponent or game.player
      local stolen = enemy.deck:deal()
      if stolen then card.owner:addCard(stolen) end
      stolen.owner = card.owner
    end,
    copy = true
  },

  ["The Tower"] = {
    onReveal = function(card)
      if card == nil then return end
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      if #slots == 1 then
        card.power = card.power - 5
      end
    end,
    curse = true
  },

  ["The Flame"] = {
    onEoT = function(card)
      if card == nil then return end
      card.power = card.power + 1
      if card.power > 7 then
        card.field:removeCard(card.owner, card)
        game:playDeath()
      end
    end,
    buff = true
  },

  ["The High Priestess"] = {
    onEoT = function(card)
      if card == nil then return end
      for _, field in ipairs(game.board.fields) do
        local slotList = card.owner == game.player and field.player_slots or field.opponent_slots
        for _, c in ipairs(slotList) do
          if c ~= card and ABILITIES[c.name] ~= nil then
            c.power = c.power + 1
          end
        end
      end
    end,
    buff = true
  },

  ["The Shadow"] = {
    onReveal = function(card)
      if card == nil then return end
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      local toRemove = {}
      for _, c in ipairs(slots) do
        if c ~= card then
          card.power = c.power + card.power
          table.insert(toRemove, c)
        end
      end
      for _, c in ipairs(toRemove) do
        card.field:removeCard(card.owner, c)
      end
    end,
    buff = true,
    sacrifice = true
  },

  ["Ten of Wands"] = {
    onEoT = function(card)
      if card == nil then return end
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      if #slots >= 4 then
        card.power = card.power - 1
      end
    end,
    curse = true
  },

  ["The Architect"] = {
    onReveal = function(card)
      if card == nil then return end
      for _, field in ipairs(game.board.fields) do
        local wooden_cow = cardData[1]
        wooden_cow_card = game:createCard(wooden_cow, true)
        wooden_cow_card.owner = card.owner
        field:addCard(card.owner, wooden_cow_card)
      end
    end,
    copy = true
  },

  ["The Eclipse"] = {
    onEoT = function(card)
      if card == nil then return end
      card.field:removeCard(card.owner, card)
      deathSFX:stop()
      deathSFX:play()
    end,
    sacrifice = true
  },

  ["The Mind"] = {
    onReveal = function(card)
      if card == nil then return end
      local lastPlayed = card.owner.lastPlayedCard
      if lastPlayed then
        card.owner:addCard(lastPlayed.name)
      end
    end,
    copy = true
  },
}
