local json = require("dkjson") -- or your JSON lib

function getNextLogIndex()
  local index = 0
  if love.filesystem.getInfo("log_index.txt") then
    local contents = love.filesystem.read("log_index.txt")
    index = tonumber(contents) or 0
  end
  index = index + 1
  love.filesystem.write("log_index.txt", tostring(index))
  return index
end

function saveLog(log)
  local json = require("dkjson")
  local jsonText = json.encode(log, { indent = true })

  local index = getNextLogIndex()
  local filename = "training_log_" .. index .. ".json"

  local success, message = love.filesystem.write(filename, jsonText)
  if not success then
    print("Failed to write log:", message)
  else
    print("Log saved to", love.filesystem.getSaveDirectory() .. "/" .. filename)
  end
end

function clearLogs()
  -- Delete all log files
  local files = love.filesystem.getDirectoryItems("")
  for _, filename in ipairs(files) do
    if filename:match("^training_log_.*%.json$") then
      love.filesystem.remove(filename)
      print("Deleted:", filename)
    end
  end

  -- Reset the log index
  love.filesystem.write("log_index.txt", "0")
  print("Log index reset to 0.")
end



