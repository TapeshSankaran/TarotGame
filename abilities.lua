
-- Abilities --

local Config = require "conf"

ABILITIES = {
  
  ["Four of Cups"] = nil,
  ["Three of Wands"]    = nil,
  ["Two of Swords"]   = nil,
  ["Ace of Pentacles"]      = nil,
  
  ["The Heirophant"] = {
    onReveal = function(card)
      local player = card.owner == game.player and game.opponent or game.player
      for _, c in ipairs(player.hand) do
        c.power = c.power - 1
      end
    end
  },

  ["The Emperor"] = {
    onReveal = function(card)
      if card.field ~= nil then
        local slots = card.owner == game.player and card.field.opponent_slots or card.field.player_slots
        card.power = card.power + #slots * 2
      end
    end
  },

  ["The Hanged Man"] = {
    onPlay = function(card, c)
      print("hello")
      c.power = (tonumber(c.power) > 0 and c ~= card) and c.power - 1 or c.power
    end
  },

  ["The Moon"] = {
    onReveal = function(card)
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
    end
  },

  ["The Devil"] = {
    onReveal = function(card)
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
    end
  },

  ["The Hermit"] = {
    onReveal = function(card)
      local enemy_slots = card.owner == game.player and card.field.opponent_slots or card.field.player_slots
      if #enemy_slots == 1 then
        card.power = card.power + 5
      end
    end
  },

  ["The Empress"] = {
    onReveal = function(card)
      for _, c in ipairs(card.owner.hand) do
        c.power = c.power + 1
      end
    end
  },

  ["The Fool"] = {
    onReveal = function(card)
      card.owner:drawCard()
      game.opponent:drawCard()
    end
  },

  ["Death"] = {
    onReveal = function(card)
      card.power = card.power + #card.owner.discard_pile*2
    end
  },

  ["Strength"] = {
    onReveal = function(card)
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      local strongest = card
      for _, c in ipairs(slots) do
        if tonumber(c.power) > tonumber(strongest.power) then return end
      end
      if strongest == card then
        card.power = card.power * 2
      end
    end
  },

  ["The Sun"] = {
    onReveal = function(card)
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      card.power = card.power + (#slots - 1) * 2
    end
  },

  ["The Chariot"] = {
    onReveal = function(card)
      game.board:moveCard(card.owner, card)
    end
  },

  ["The World"] = {
    onReveal = function(card)
      for _, card in ipairs(game.action) do
        if card ~= nil then
          card:flip()
        end 
      end
      game.action = {}
    end
  },

  ["Wheel of Fortune"] = {
    onReveal = function(card)
      local wheel_of_fortune = cardData[18]
      wheel_of_fortune = game:createCard(wheel_of_fortune, true)
      wheel_of_fortune.owner = card.owner
      wheel_of_fortune.power = wheel_of_fortune.power + 1
      card.owner:addCard(ship_of_theseus)
    end
  },

  ["Temperance"] = {
    onEoT = function(card)
      if card.field:isWinning(card.owner) and tonumber(card.power) < 16 then
        card.power = card.power * 2
      end
    end
  },

  ["Justice"] = {
    onReveal = function(card)
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
      local enemy_slots = card.owner == game.player and card.field.opponent_slots or card.field.player_slots
      for _, c in ipairs(enemy_slots) do
        c.power = c.power - 1
      end
    end
  },

  ["The Magician"] = {
    onPlay = function(card, c)
      if c ~= card and card.owner == c.owner then
        card.power = card.power + 1
      end
    end
  },

  ["The Star"] = {
    onReveal = function(card)
      card.owner.extra = card.owner.extra + 1
    end
  },

  ["The Alchemist"] = {
    onReveal = function(card)
      for i=1,2 do
        local c = card.owner.hand[math.ceil(math.random(#card.owner.hand))]
        c.cost = c.cost - 1
      end
    end
  },

  ["The Void"] = {
    onReveal = function(card)
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
        if c then 
          c.position = Vector(-100, -100)
          table.insert(card.owner.discard_pile, c)
        end
      end
    end
  },

  ["The Seer"] = {
    onReveal = function(card)
      local enemy = card.owner == game.player and game.opponent or game.player
      local stolen = enemy.deck:deal()
      if stolen then card.owner:addCard(stolen) end
      stolen.owner = card.owner
    end
  },

  ["The Tower"] = {
    onReveal = function(card)
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      if #slots == 1 then
        card.power = card.power - 5
      end
    end
  },

  ["The Flame"] = {
    onEoT = function(card)
      card.power = card.power + 1
      if card.power > 7 then
        card.field:removeCard(card.owner, card)
        game:playDeath()
      end
    end
  },

  ["The High Priestess"] = {
    onEoT = function(card)
      for _, field in ipairs(game.board.fields) do
        local slotList = card.owner == game.player and field.player_slots or field.opponent_slots
        for _, c in ipairs(slotList) do
          if c ~= card and ABILITIES[c.name] ~= nil then
            c.power = c.power + 1
          end
        end
      end
    end
  },

  ["The Shadow"] = {
    onReveal = function(card)
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
    end
  },

  ["Ten of Wands"] = {
    onEoT = function(card)
      local slots = card.owner == game.player and card.field.player_slots or card.field.opponent_slots
      if #slots >= 4 then
        card.power = card.power - 1
      end
    end
  },

  ["The Architect"] = {
    onReveal = function(card)
      for _, field in ipairs(game.board.fields) do
        local wooden_cow = cardData[1]
        field:addCard(card.owner, game:createCard(wooden_cow, true))
      end
    end
  },

  ["The Eclipse"] = {
    onEoT = function(card)
      card.field:removeCard(card.owner, card)
      deathSFX:play()
    end
  },

  ["The Mind"] = {
    onReveal = function(card)
      local lastPlayed = card.owner.lastPlayedCard
      if lastPlayed then
        card.owner:addCard(lastPlayed.name)
      end
    end
  },
}
