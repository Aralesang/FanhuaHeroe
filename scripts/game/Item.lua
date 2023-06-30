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

---使用该物品
---@param target GameObject 使用道具的对象
function Item:use(target)end

return Item