local Component   = require "scripts.base.Component"
local ItemManager = require "scripts.manager.ItemManager"

---@class Inventory : Component 库存
---@field cellNum number 格子数量
---@field items Item[] 道具列表
local Inventory   = Component:extend()

---构造函数
function Inventory:new()
    self.cellNum = 10
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
    local item = ItemManager.createItem(id)
    table.insert(self.items, item)
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

---使用道具
---@param id number 道具id
function Inventory:use(id)
    --库存中寻找目标道具
    for _, v in pairs(self.items) do
        if v.id == id then
            --调用目标物品的使用函数
            v:use(self.gameObject)
            self:remove(id)
            return
        end
    end
    print("未拥有物品:" .. id)
end

function Inventory:__tostring()
    return "Inventory"
end

return Inventory