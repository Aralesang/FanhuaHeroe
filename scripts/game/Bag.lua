local ItemManager = require "scripts.manager.ItemManager"

---@class Bag 背包
---@field cells table<number,number> 格子<格子id,道具id>
local Bag = {}

function Bag:show()
    local player = Game.player
    --将玩家库存转换到背包
    local items = Game.player.items
    if self.cells == nil then
        self.cells = {}
        for i = 1, 10, 1 do
            self.cells[i] = 0
        end
    end
    --首先获取到背包中没有，但库存中有的东西
    local stored = {}
    for itemId, num in pairs(items) do
        for _, itemId2 in pairs(self.cells) do
            if num > 0 and itemId == itemId2 then
                break
            end
        end
        table.insert(stored, itemId)
    end
    --然后获取背包中有，但库存中已经没有的东西
    local removes = {}
    for cellId, itemId in pairs(self.cells) do
        for itemId2, num in pairs(items) do
            if num > 0 and itemId == itemId2 then
                break
            end
        end
        removes[cellId] = itemId
    end
    --删除所有已经没有的东西
    for cellId, ItemId in pairs(removes) do
        self.cells[cellId] = 0
    end
    --将库存补充进背包
    for _, itemId in pairs(stored) do
        for i = 1, 10, 1 do
            if self.cells[i] == 0 then
                self.cells[i] = itemId
            end
        end
    end

    print("=======背包======")
    for id, num in pairs(self.cells) do
        local item = ItemManager:getItem(id)
        local name = item.name
        if player.equips[item.slot] == item.id then
            name = name .. "E"
        end
        print(name, num)
    end
end

return Bag
