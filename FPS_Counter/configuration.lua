-- FPS Counter PSOBB Plugin
-- gatesphere
-- configuration.lua

local function ConfigurationWindow(configuration)
    local this = 
    {
        title = "FPS Counter - Configuration",
        fontScale = 1.0,
        open = false,
        changed = false,
    }

    local _configuration = configuration

    local _showWindowSettings = function()
        local success
        
        if imgui.Checkbox("Enable", _configuration.enable) then
            _configuration.enable = not _configuration.enable
            this.changed = true
        end
        
        if imgui.Checkbox("Show graphs", _configuration.graphs) then
            _configuration.graphs = not _configuration.graphs
            this.changed = true
        end
        
        if imgui.Checkbox("Show current FPS", _configuration.show_current) then
            _configuration.show_current = not _configuration.show_current
            this.changed = true
        end
        
        if imgui.Checkbox("Show 1s Average FPS", _configuration.show_1s) then
            _configuration.show_1s = not _configuration.show_1s
            this.changed = true
        end
        
        if imgui.Checkbox("Show 10s Average FPS", _configuration.show_10s) then
            _configuration.show_10s = not _configuration.show_10s
            this.changed = true
        end    
    end

    this.Update = function()
        if this.open == false then
            return
        end

        local success

        imgui.SetNextWindowSize(200, 200, 'FirstUseEver')
        success, this.open = imgui.Begin(this.title, this.open)
        imgui.SetWindowFontScale(this.fontScale)

        _showWindowSettings()

        imgui.End()
    end

    return this
end

return 
{
    ConfigurationWindow = ConfigurationWindow,
}
