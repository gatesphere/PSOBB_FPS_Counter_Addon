-- Imports
local core_mainmenu = require("core_mainmenu")

-- Storage
local last_time = 0
local last_framecount = 0
local last_time_1s = 0
local last_framecount_1s = 0
local last_fps_1s = 0
local last_time_10s = 0
local last_framecount_10s = 0
local last_fps_10s = 0

-- Draw the window?
local window_open = true

-- Do all the stuff
local function fps_window()
  -- grab current lifetime time and frames
  cur_time = imgui.GetTime()
  cur_framecount = imgui.GetFrameCount()
  
  -- get instantaneous FPS
  delta_fc = cur_framecount - last_framecount
  delta_time = cur_time - last_time
  immediate_fps = delta_fc / delta_time
  
  -- get 1s average
  delta_time_1s = cur_time - last_time_1s
  if delta_time_1s >= 1 then
    delta_fc_1s = cur_framecount - last_framecount_1s
    delta_time_1s = cur_time - last_time_1s
    last_fps_1s = delta_fc_1s / delta_time_1s
    last_time_1s = cur_time
    last_framecount_1s = cur_framecount
  end
  
  -- get 10s average
  delta_time_10s = cur_time - last_time_10s
  if delta_time_10s >= 10 then
    delta_fc_10s = cur_framecount - last_framecount_10s
    delta_time_10s = cur_time - last_time_10s
    last_fps_10s = delta_fc_10s / delta_time_10s
    last_time_10s = cur_time
    last_framecount_10s = cur_framecount
  end
  
  -- store vars
  average_fps_1s = last_fps_1s
  average_fps_10s = last_fps_10s
  last_time = cur_time
  last_framecount = cur_framecount
  
  -- draw the window
  if window_open then
    imgui.Begin("FPS Counter", nil, {"NoTitleBar", "AlwaysAutoResize"})
    imgui.Text(string.format("Current FPS: %.2f", immediate_fps))
    imgui.Text(string.format("Average FPS (1s): %.2f", average_fps_1s))
    imgui.Text(string.format("Average FPS (10s): %.2f", average_fps_10s))
    imgui.End()
  end
end

local function present()
  if window_open then
    fps_window()
  end
end

local function init()
  local function mainMenuButtonHandler()
    window_open = not window_open
  end
  
  core_mainmenu.add_button("FPS Counter", mainMenuButtonHandler)
  
  return {
    name = 'FPS Counter',
    version = '1.0',
    author = 'gatesphere',
    present = present,
  }
end

return {
  __addon = {
    init = init,
  }
}
