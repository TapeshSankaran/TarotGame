
local Menu = require "menu"
local Config = require "conf"
local AI = require "ai"
local Game = require "game"
local Slider = require "slider"
local Sim = require "sim"

function createMenus()
  
  local titleMenu = Menu:new("Tarot Game", {
      { type = "slider", slider = Slider:new("Target Points",
        width*0.3, 0, width*0.5, 
        20, 200, 100, 5, function(value) game.targetPoints = value end
      )},
      { type = "button", label = "Play", action = function() game.state = "player_turn" end }
    },
    { titleColor = COLORS.PURPLE * 2 }
  )
  menu_manager.titleMenu = titleMenu
  
  local pauseMenu = Menu:new("Pause Menu", {
      { type = "slider", slider = Slider:new("Master Volume",
        width*0.3, 0, width*0.5, 
        0, 100, 100, 1, function(value) masterVolume = value*0.01 end
      )},
      { type = "slider", slider = Slider:new("Background Sound Volume",
        width*0.3, 0, width*0.5,
        0, 100, 100, 1, function(value) bgMusicVolume = value*0.01 end
      )},
      { type = "slider", slider = Slider:new("Sound Effects Volume",
        width*0.3, 0, width*0.5,
        0, 100, 100, 1, function(value) effectsVolume = value*0.01 end
      )},
      { type = "button", label = "Continue", action = function() isPaused = false end }
    }
  )
  menu_manager.pauseMenu = pauseMenu
  
  local winMenu = Menu:new("Player Won!", {
      { type = "button", label = "Restart", action = restartGame }
    },
    { titleColor = COLORS.BLUE }
  )
  menu_manager.winMenu = winMenu
  
  local loseMenu = Menu:new("Player Lost!", {
      { type = "button", label = "Restart", action = restartGame }
    },
    { titleColor = COLORS.RED }
  )
  menu_manager.loseMenu = loseMenu

  local drawMenu = Menu:new("Player Lost!", {
      { type = "button", label = "Restart", action = restartGame }
    },
    { titleColor = COLORS.PURPLE }
  )
  menu_manager.drawMenu = drawMenu
end

function updateMenus(dt)
  for _, menu in pairs(menu_manager) do
    menu:update(dt)
  end
  menu_manager.titleMenu.isEnabled = game.state == "start"
  menu_manager.pauseMenu.isEnabled = isPaused
  menu_manager.winMenu.isEnabled   = game.state == "win"
  menu_manager.loseMenu.isEnabled  = game.state == "lose"
  menu_manager.drawMenu.isEnabled  = game.state == "draw"

end

function menus_mousepressed(x, y, button)
  for _, menu in pairs(menu_manager) do
    if menu.isEnabled then
      menu:mousepressed(x, y, button)
    end
  end
end

function menus_mousereleased(x, y, button)
  for _, menu in pairs(menu_manager) do
    if menu.isEnabled then
      menu:mousereleased(x, y, button)
    end
  end
end

function drawMenus()
  for _, menu in pairs(menu_manager) do
    if menu.isEnabled then
      menu:draw()
    end
  end
end

-- RESTART GAME --
function restartGame()
  
  
  math.randomseed(os.time())
  
  game = Game:new()
  
  ai = AI:new(game.opponent, game.board)
  if isSim then makeSimPlayer() end
  
  hasWon = false
  cont_over = false
end