local bag = require "scripts.game.bag"
---@class ui_manager 界面管理器
---@field uis ui[] ui集合
local ui_manager = {
    uis = {}
}

function ui_manager:init()
    self.uis["bag"] = bag:new()
end

---显示UI
---@param name string ui名称
function ui_manager:show(name)
    self.uis[name]:show()
end

return ui_manager