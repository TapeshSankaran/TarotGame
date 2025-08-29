
local Config = "conf"
local Player = "player"
local Anim   = require "anim"
local Slider = require "menuManager"
local Sim    = require "sim"
require "data_export"

-- Checks if mouse is pressed --
local mousePressed = false
-- Card currently being dragged --
local draggableCard = nil
-- Checker for mute state --
local is_muted = false
-- Checker for win state --
local not_won = true
-- Substate for round anim --
local substate = "standby"

-- UPDATE FUNCTION --
function love.update(dt)
  local mouseX, mouseY = love.mouse.getPosition()
  
  updateMenus()
  
  if not BGSFX:isPlaying() then
    BGSFX:play()
  end

  if not whisperSFX:isPlaying() then
    whisperSFX:play()
  end
  
  whisperSFX:setVolume(0.01 * masterVolume * bgMusicVolume)
  BGSFX:setVolume(0.04 * masterVolume * bgMusicVolume)
  revealSFX:setVolume(2 * masterVolume * effectsVolume)
  deathSFX:setVolume(0.8 * masterVolume * effectsVolume)
  placeSFX:setVolume(0.20 * masterVolume * effectsVolume)
  
  -- Update card position of card being dragged --
  if draggableCard then
    draggableCard:update(dt, mouseX, mouseY)
  end
  
  local deltaTime = isPaused and 0 or dt
  
  if game.state == "ai_turn" then
    local turn = game:submitTurn()
    game.state = "wait_for_flip"
    timer = 2
    if isSim then
      logEnemyTurn(turn)
    end
  elseif game.state == "wait_for_flip" then
    timer = timer - deltaTime
    if timer <= 0 then
      substate = "stalled"
      game.state = "waiting"
      timer = 1
    end
  elseif game.state == "flipped" then
    timer = timer - deltaTime
    if timer <= 0 then
      game.state = "next_phase"
    end
  elseif game.state == "next_phase" then
    game:nextTurn()
    if game.state ~= "won" then
      game.state = "player_turn"
    end
  elseif game.state == "won" then
    if isSim then
      logWinner(result)
      saveLog(log)
    end
    timer = 2
    game.state = "winning"
  elseif game.state == "winning" then
    timer = timer - deltaTime
    if timer <= 0 then
      game.state = result
      if isSim then
        restartGame()
        game.state = "player_turn"
      end
    end
  end
  
  if substate == "stall" then
    timer = timer - deltaTime
    if timer <= 0 then
      substate = "stalled"
      game:activateReveal()
    end
  elseif substate == "stalled" then
    timer = 1
    if #game.action > 0 then
      game:revealCard()
      substate = "repeat"
    else
      substate = "standby"
      game.state = "next_phase"
      timer = 1
    end
  elseif substate == "repeat" then
    timer = 1
    substate = "stall"
  end
  
  if isSim then
    simulateGame()
  end

  for _, fx in ipairs(anim_manager) do
    fx.anim:update(dt)
  end
  
  for _, field in ipairs(game.board.fields) do
    for _, card in ipairs(field.player_slots) do
      card:animUpdate(dt)
    end
    for _, card in ipairs(field.opponent_slots) do
      card:animUpdate(dt)
    end
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    isPaused = not isPaused
  end
  if key == "delete" then
    clearLogs()
  end
end

-- WHEN MOUSE PRESSED --
function love.mousepressed(x, y, button, istouch, presses)
  
  menus_mousepressed(x, y, button)
  
  -- If left click and no card already being dragged --
  if button == 1 and draggableCard == nil and game.state == "player_turn" then
    start_drag(x, y)
  end
  
  -- End Turn Button click functionality --
  if button == 1 and end_button_isOver(x, y) and not mousePressed and game.state == "player_turn" then
    game.state = "ai_turn"
  end
  
  mousePressed = false
end

function love.mousereleased(x, y, button, istouch, presses)
  menus_mousereleased(x, y, button)
  if draggableCard then
    stop_drag(x, y)
  end
end

function love.errorhandler(msg)
  local traceback = debug.traceback(msg, 2)
  print("Crash caught:", traceback)
  local simulationLog = log
  if simulationLog then
    local success, err = pcall(function()
      local json = require("dkjson")
      local text = json.encode(simulationLog, { indent = true })
      local time = os.date("%Y-%m-%d_%H-%M-%S")
      local filename = "crash_log_" .. time .. ".json"
      love.filesystem.write(filename, text)
      print("Crash log saved to:", filename)
    end)

    if not success then
      print("Failed to write crash log:", err)
    end
  end

  -- Show the normal Love2D error screen
  return love.errhand(msg)
end


-- START DRAGGING CARD --
function start_drag(x, y)
  for _, card in ipairs(game.player.deck.cardTable) do
    if card.draggable and card.faceUp and card:isMouseOver(x, y) then
      draggableCard = card
      draggableCard:startDrag(x, y)
      break
    end
  end
end

-- WHEN STOP DRAGGING CARD --
function stop_drag(x, y)
    draggableCard:stopDrag(x, y)
    draggableCard = nil  
end

function createAnims()
  
  local ghost = Anim:new(
    spiritImg,
    40, 32,
    15,
    2, 2,
    0,
    false
  )
  table.insert(anim_manager, {
    anim = ghost,
    x = width/2,
    y = height/2
  })
  
  
end

-- CHECK IF OVER END TURN BUTTON -- 
function end_button_isOver(mouseX, mouseY)
  local end_sx = endButton:getWidth() * end_scale
  local end_sy = endButton:getHeight() * end_scale
  
  return mouseX > end_x and mouseX < end_x + end_sx and
           mouseY > end_y and mouseY < end_y + end_sy
end


-- CHECK IF OVER CONTINUE BUTTON -- 
function cont_button_isOver(mouseX, mouseY)
  local cont_sx = title_font:getWidth(game.state == "start" and "Play" or "Continue?")
  local cont_sy = title_font:getHeight()
  local cont_x  = (width - cont_sx) * 0.5
  local cont_y  = height*0.75
  
  return mouseX > cont_x and mouseX < cont_x + cont_sx and
           mouseY > cont_y and mouseY < cont_y + cont_sy
end

-- DRAWING DRAGGED CARD --
function dragged_card_draw() 
  love.graphics.setColor(COLORS.GOLD:rgb())
  if draggableCard ~= nil then
    draggableCard:draw()
  end
  love.graphics.setColor(COLORS.WHITE:rgb())
end

-- DRAWING ANIM --
function drawFX()
  love.graphics.setColor(COLORS.WHITE:rgb())
  for _, fx in ipairs(anim_manager) do
    fx.anim:draw(fx.x, fx.y)
  end
end

