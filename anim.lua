-- Animation.lua
local Animation = {}
Animation.__index = Animation

function Animation:new(image, frameWidth, frameHeight, fps, sx, sy, r, isLoop)
  local anim = setmetatable({}, Animation)

  anim.image = image
  anim.frameWidth = frameWidth
  anim.frameHeight = frameHeight
  anim.fps = fps or 12
  anim.timer = 0
  anim.frames = {}
  anim.done = false
  anim.sx   = sx and sx or 2.2
  anim.sy   = sy and sy or 2.2
  anim.rot  = r  and r  or 0
  anim.loop = isLoop or false


  local cols = image:getWidth() / frameWidth
  local rows = image:getHeight() / frameHeight
  for y = 0, rows - 1 do
    for x = 0, cols - 1 do
      table.insert(anim.frames, love.graphics.newQuad(
        x * frameWidth, y * frameHeight,
        frameWidth, frameHeight,
        image:getDimensions()
      ))
    end
  end

  anim.totalFrames = #anim.frames
  anim.currentFrame = 1

  return anim
end

function Animation:update(dt)
  if self.done then return end
  
  self.timer = self.timer + dt
  local frameIndex = math.floor(self.timer * self.fps) + 1
  
  if frameIndex > self.totalFrames then
    if self.loop then
      self.timer = 0
      frameIndex = 1
    else
      self.done = true
      frameIndex = self.totalFrames
    end
  end
  self.currentFrame = frameIndex
end

function Animation:draw(x, y)
  if not self.done then
    love.graphics.draw(
      self.image,
      self.frames[self.currentFrame],
      x, y,
      self.rot,
      self.sx,
      self.sy,
      self.frameWidth/2,
      self.frameHeight/2
    )
  end
end

function Animation:isLooping()
  return self.loop
end

function Animation:setLoop(value)
  self.loop = value
end

function Animation:isDone()
  return self.done
end

function Animation:reset()
  self.timer = 0
  self.currentFrame = 1
  self.done = false
end

return Animation
