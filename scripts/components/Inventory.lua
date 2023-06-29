local Component = require "scripts.base.Component"
local Item = require "scripts.game.Item"

---@class Inventory : Component 库存
---@field cellNum number 格子数量
---@field items Item[] 道具列表
local Inventory = Component:extend()

---构造函数
---@param cellNum number 格子数量
function Inventory:new(cellNum)
    self.cellNum = cellNum
    self.items = {}
end

---向库存中添加道具
---@param id number 道具id
---@return boolean result 是否添加成功
function Inventory:add(id)
    if self.items == nil then
        error("错误: 库存道具列表未初始化")
    end
    --检查当前库存中的道具数量
    local itemNum = #self.items
    if itemNum >= self.cellNum then
        return false
    end
    local item = Item(id)
    table.insert(self.items,item)
    return true
end

---从库存中删除道具
---@param id number
---@return boolean result 是否删除成功
function Inventory:remove(id)
    local items = self.items
    if items == nil then
        return false
    end
    if #items <= 0 then
        return false
    end
    for i = #items, 1, -1 do
        local item = items[i]
        if item.id == id then
            table.remove(items, i)
            return true
        end
    end
    return false
end

return Inventory