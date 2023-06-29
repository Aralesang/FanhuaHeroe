local Object = require "scripts.base.Object"

---@class Item : Object 道具
---@field id number 道具id
---@field name string 道具名称
---@field description string 道具描述
local Item = Object:extend()

---构造函数
function Item:new()
    self.id = 0
    self.name = ""
    self.description = ""
end

return Item