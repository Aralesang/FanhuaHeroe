---@class Item : Object 道具
---@field id number 道具id
---@field name string 道具名称
Item = Object:extend()

---构造函数
---@param id number 道具id
function Item:new(id)
    self.id = 0
    self.name = ""
end