-- FPS Counter PSOBB Plugin
-- gatesphere
-- init.lua

-- Imports
local core_mainmenu = require("core_mainmenu")
local fps_cfg = require("FPS_Counter.configuration")
local optionsLoaded, options = pcall(require, "FPS_Counter.options")
local optionsFileName = "addons/FPS_Counter/options.lua"

if optionsLoaded then
    -- If options loaded, make sure we have all those we need
    options.configurationEnableWindow = options.configurationEnableWindow == nil and true or options.configurationEnableWindow
    options.enable = options.enable == nil and true or options.enable
    options.graphs = options.graphs == nil and true or options.graphs
    options.show_current = options.show_current == nil and true or options.show_current
    options.show_1s = options.show_1s == nil and true or options.show_1s
    options.show_10s = options.show_10s == nil and true or options.show_10s
else
    options = 
    {
        configurationEnableWindow = true,
        enable = true,
        graphs = true,
        show_current = true,
        show_1s = true,
        show_10s = true
    }
end

local function SaveOptions(options)
    local file = io.open(optionsFileName, "w")
    if file ~= nil then
        io.output(file)

        io.write("return {\n")
        io.write(string.format("    configurationEnableWindow = %s,\n", tostring(options.configurationEnableWindow)))
        io.write(string.format("    enable = %s,\n", tostring(options.enable)))
        io.write("\n")
		io.write(string.format("    graphs = %s,\n", tostring(options.graphs)))
		io.write(string.format("    show_current = %s,\n", tostring(options.show_current)))
		io.write(string.format("    show_1s = %s,\n", tostring(options.show_1s)))
		io.write(string.format("    show_10s = %s,\n", tostring(options.show_10s)))
        io.write("}\n")

        io.close(file)
    end
end


-- Storage
local last_time = 0
local last_framecount = 0
local fps_data = {}
local last_time_1s = 0
local last_framecount_1s = 0
local last_fps_1s = 0
local fps_data_1s = {}
local last_time_10s = 0
local last_framecount_10s = 0
local last_fps_10s = 0
local fps_data_10s = {}

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
  table.remove(fps_data,1)
  table.insert(fps_data, immediate_fps)
  table.remove(fps_data_1s,1)
  table.insert(fps_data_1s, average_fps_1s)
  table.remove(fps_data_10s,1)
  table.insert(fps_data_10s, average_fps_10s)
  
  -- draw the window
  if options.enable then
    imgui.Begin("FPS Counter", nil, {"NoTitleBar", "AlwaysAutoResize"})
    if options.graphs then
      if options.show_current then
        imgui.PlotLines("Current FPS", fps_data, 1800, 0, string.format("%.2f",immediate_fps), 0, 31)
      end
      if options.show_1s then
        imgui.PlotLines("Average FPS (1s)", fps_data_1s, 1800, 0, string.format("%.2f",average_fps_1s), 0, 31)
      end
      if options.show_10s then
        imgui.PlotLines("Average FPS (10s)", fps_data_10s, 1800, 0, string.format("%.2f",average_fps_10s), 0, 31)
      end
    else
      if options.show_current then
        imgui.Text(string.format("Current FPS: %.2f", immediate_fps))
      end
      if options.show_1s then
        imgui.Text(string.format("Average FPS (1s): %.2f", average_fps_1s))
      end
      if options.show_10s then
        imgui.Text(string.format("Average FPS (10s): %.2f", average_fps_10s))
      end
    end
    imgui.End()
  end
end

local function present()
    local changedOptions = false
    -- If the addon has never been used, open the config window
    -- and disable the config window setting
    if options.configurationEnableWindow then
       FPS_Config.open = true
       options.configurationEnableWindow = false
    end

    FPS_Config.Update()
    if FPS_Config.changed then
        changedOptions = true
        FPS_Config.changed = false
        SaveOptions(options)
    end
    
    fps_window()
end

local function init()


  FPS_Config = fps_cfg.ConfigurationWindow(options)

  local function mainMenuButtonHandler()
      FPS_Config.open = not FPS_Config.open
  end
  
  core_mainmenu.add_button("FPS Counter", mainMenuButtonHandler)
  
  for i=1, 1800 do
    table.insert(fps_data, 0)
    table.insert(fps_data_1s, 0)
    table.insert(fps_data_10s, 0)
  end
  
  return {
    name = 'FPS Counter',
    version = '1.2',
    author = 'gatesphere',
    present = present,
  }
end

return {
  __addon = {
    init = init,
  }
}
