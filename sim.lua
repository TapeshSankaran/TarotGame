local Config = require "conf"
local PyAI   = require "pyAI"
local AI     = require "AI"

playerSim = {}
log = {turns = {}, winner = {}}


function makeSimPlayer()
  playerSim = AI:new(game.player, game.board)
  log = {turns = {}, winner = {}}
end

function simulateGame()
  if game.state == "player_turn" then
    table.insert(log.turns, playerSim:takeTurn())
    game.state = "ai_turn"
  end
end

function logEnemyTurn(turn)
  table.insert(log.turns, turn)
end

function logWinner(result)
  local winner = {}
  if result == "win" then
    winner = game.player
  elseif result == "lose" then
    winner = game.opponent
  else
    log.winner = "draw"
    return
  end
  log.winner = winner.name
end
