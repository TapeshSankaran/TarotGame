
require "conf"

function System_Set() 
  -- Set Title of Window --
  love.window.setTitle("Greek Slam")
  
  -- Set Filter for Clearness --
  love.graphics.setDefaultFilter("nearest", "nearest")
  
  -- Set Dimentions for Window --
  love.window.setMode(width, height, {fullscreen = isFull})
  
  -- Set Color --
  love.graphics.setBackgroundColor(COLORS.BLACK:rgb())
  
  -- SET RANDOM SEED --
  math.randomseed(seed)
end
