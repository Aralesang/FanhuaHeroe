local ItemManager = require "scripts.manager.ItemManager"
local Ui          = require "scripts.game.Ui"

---@class Bag:Ui 背包
---@field cells table<number,number> 格子<格子id,道具id>
local Bag = Class("Bag",Ui)

local img
local quad
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
    for cellId, itemId in pairs(self.cells) do
        for itemId2, num in pairs(items) do
            if num > 0 and itemId == itemId2 then
                break
            end
        end
        --删除所有已经没有的东西
        self.cells[cellId] = 0
    end

    --将库存补充进背包
    for _, itemId in pairs(stored) do
        for i = 1, 10, 1 do
            if self.cells[i] == 0 then
                self.cells[i] = itemId
                break
            end
        end
    end

    print("=======背包======")
    for cellId, itemId in pairs(self.cells) do
        if itemId > 0 then
            local item = ItemManager:getItem(itemId)
            local name = item.name
            if player.equips[item.slot] == item.id then
                name = name .. "E"
            end
            local num = player.items[itemId]
            print(name, num)
        end
    end
    self.visible = true
end

function Bag:drwa()
    self.visible = true
    if not self.visible then
        return
    end
    if img == nil then
        img = love.graphics.newImage("image/ui/BagBg.png")
    end
    quad = love.graphics.newQuad(0,0,img:getWidth(),img:getHeight(),img:getDimensions())
    love.graphics.draw(img,quad,640,630,0,4,4,8,0)
end

return Bag
