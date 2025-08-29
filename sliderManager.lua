
local Slider = require "slider"

function makeSliders()
  
  masterSlider = Slider:new("Master Volume", width*0.5, height*0.7, width*0.4, 0, 100, 100, function(value) masterVolume = value*.01 end)
  table.insert(slider_manager, masterSlider)
  
  bgMusicSlider = Slider:new("Music Volume", width*0.5, height*0.6, width*0.4, 0, 100, 100, function(value) bgMusicVolume = value*.01 end)
  table.insert(slider_manager, bgMusicSlider)
  
  effectsSlider = Slider:new("Sound Effects", width*0.5, height*0.5, width*0.4, 0, 100, 100, function(value) effectsVolume = value*.01 end)
  table.insert(slider_manager, effectsSlider)
  
end

function updateSliders(dt)
  
  for _, slider in ipairs(slider_manager) do
    slider:update(dt)
  end
  
end

function drawSliders()
  
  for _,slider in ipairs(slider_manager) do
    slider:draw()
  end
  
end
