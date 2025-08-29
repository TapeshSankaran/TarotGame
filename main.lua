
-- Tapesh Sankaran
-- CMPM 121
-- 6-11-2025

io.stdout:setvbuf("no")

local Config   = require "conf"
local Sys      = require "sys-set"
local Drag     = require "drag"
local Read_CSV = require "rcsv"
local Game     = require "game"
local PyAI     = require "pyAI"
local Sim    = require "sim"
local Menu   = require "menuManager"

local cardBuffer = {}

-- LOAD FUNCTION --
function love.load()
  
  
  
  -- Set Window and Random Seed --
  --     (from sys-set.lua)     --
  System_Set()
  
  -- Menus --
  createMenus()
  
  -- Read CSV --
  cardData = read_csv(FILE_LOCATIONS.CSV)

  -- Create Game --
  game = Game:new()
  
  ai = PyAI:new(game.opponent, game.board)
  
  if isSim then makeSimPlayer() end
end

-- DRAW FUNCTION --
function love.draw()
  
  game:draw()
  
  drawFX()
  
  dragged_card_draw()
  
  drawMenus()
end