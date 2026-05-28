-- Board class

local Field = require "field"
local SIDE_FIELD_W = 0.325
local I_Slot_Pos
Board = {}
Board.__index = Board

function Board:new(sx, sy, ex, ey)
    local w = ex-sx
    local h = ey-sy
    local sfw = SIDE_FIELD_W
    local mid_w  = 1 - sfw * 2
    local cw = img_width  * scale
    local ch = img_height * scale
    I_Slot_Pos = {
      O = {
        L = Vector(sx + sfw*w - cw*0.5, sy + ch * 0.25),
        R = Vector(ex - sfw*w - cw*0.5, sy + ch * 0.25),
      },
      P = {
        L = Vector(sx + sfw*w - cw*0.5, ey - ch * 1.25),
        R = Vector(ex - sfw*w - cw*0.5, ey - ch * 1.25),
      }
    }

    return setmetatable({
        fields = {
          Field:new( -1, sx                    , sy, sfw  *w, h ),
          Field:new(  1, sx + (sfw + mid_w) * w, sy, sfw  *w, h ),
          Field:new(  0, sx +  sfw          * w, sy, mid_w*w, h ),
        },
        immortal = {
          opp    = {
            LEFT = nil,
            RIGHT = nil,
          },
          player = {
            LEFT = nil,
            RIGHT = nil,
          }
        },
        size = {
          W = w,
          H = h
        },
        start_position = Vector(sx, sy),
        end_position = Vector(ex, ey),
    }, self)
end

function Board:stageCards(player, locationIndex, card)
    return self.fields[locationIndex]:addCard(player, card)
end

function Board:evaluateTurn()
  local results = {}
  for i, field in ipairs(self.fields) do
    local pPower, oPower = field:calculatePower()
    
    local scoreDiff = math.abs(pPower - oPower)
    if pPower > oPower then
      field:emptyCardSlots(game.opponent)
      results.player = (results.player or 0) + scoreDiff
    elseif oPower > pPower then
      field:emptyCardSlots(game.player)
      results.opponent = (results.opponent or 0) + scoreDiff
    else
      -- Flip coin for tie
      if math.random() < 0.5 then
          results.player = (results.player or 0) + scoreDiff
      else
          results.opponent = (results.opponent or 0) + scoreDiff
      end
    end
  end
  return results
end

function Board:moveCard(player, card)
  local og_field = card.field
  local fieldOptions = {1, 2, 3}
  table.remove(fieldOptions, indexOf(self.fields, og_field))
  local end_field = self.fields[fieldOptions[math.random(1, 2)]]

  end_field:addCard(player, og_field:removeCard(player, card))
end

function Board:allFaceDown()
  for _, field in ipairs(self.fields) do
    for _, card in ipairs(field.player_slots) do
      card.faceUp = false
    end
  end
end

function Board:draw(dt)
  for i, field in ipairs(self.fields) do
    field:draw(dt)
  end
  local sfw = SIDE_FIELD_W
  local mfw = 1 - sfw * 2
  -- Immortal Slots (Opponent)
  local x = I_Slot_Pos.O.L.x
  local y = I_Slot_Pos.O.L.y
  if self.immortal.opp.LEFT then
      self.immortal.opp.LEFT:draw(dt)
    else
      love.graphics.setColor(COLORS.RED:rgb())
      love.graphics.draw(emptyCard, x, y, 0, scale, scale)
    end

  x = I_Slot_Pos.O.R.x
  if self.immortal.opp.RIGHT then
      self.immortal.opp.RIGHT:draw(dt)
    else
      love.graphics.setColor(COLORS.RED:rgb())
      love.graphics.draw(emptyCard, x, y, 0, scale, scale)
    end
  -- Immortal Slots (Player)
  local x = I_Slot_Pos.P.L.x
  local y = I_Slot_Pos.P.L.y
  if self.immortal.player.LEFT then
      self.immortal.player.LEFT:draw()
    else
      love.graphics.setColor(COLORS.RED:rgb())
      love.graphics.draw(emptyCard, x, y, 0, scale, scale)
    end

  x = I_Slot_Pos.P.R.x
  if self.immortal.player.RIGHT then
      self.immortal.player.RIGHT:draw()
    else
      love.graphics.setColor(COLORS.RED:rgb())
      love.graphics.draw(emptyCard, x, y, 0, scale, scale)
  end

  local s = self.start_position
  local e = self.end_position
  local h = e.y - s.y
  love.graphics.setColor(COLORS.WHITE:rgb())
  love.graphics.line(s.x, s.y+h*0.5, e.x, s.y+h*0.5)

end

return Board
