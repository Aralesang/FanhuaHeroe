local Bag = require "scripts.game.bag"
---@class UiManager 界面管理器
---@field uis ui[] ui集合
local UiManager = {
    uis = {}
}

function UiManager:init()
    self.uis["bag"] = Bag:new()
end

---显示UI
---@param name string ui名称
function UiManager:show(name)
    self.uis[name]:show()
end

return UiManager