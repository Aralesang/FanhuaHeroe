local item_manager = require "scripts.manager.item_manager"
local ui           = require "scripts.game.ui"

---@class bag:ui 背包
---@field cells table<number,number> 格子<格子id,道具id>
local bag          = Class("Bag", ui)
---背景图片
---@type love.Image
local bg_img
---格子图片
---@type love.Image
local cell_img

function bag:show()
    self.visible = true
end

function bag:update(dt)
    if not self.visible then
        return
    end
    if bg_img == nil then
        bg_img = love.graphics.newImage("image/ui/BagBg.png")
    end
    if cell_img == nil then
        cell_img = love.graphics.newImage("image/ui/grid.png")
    end

    local player = Game.player
    --将玩家库存转换到背包
    local items = player.items
    if self.cells == nil then
        self.cells = {}
        for i = 1, 9, 1 do
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
end

function bag:drwa()
    if not self.visible then
        return
    end

    --图像宽度
    local width = bg_img:getWidth()
    local high = bg_img:getHeight()
    local screen_width = love.graphics.getWidth()
    local screen_high = love.graphics.getHeight()
    --将背包栏置于屏幕的中心
    local x = screen_width / 2 - width * Config.scale / 2
    local y = 640
    love.graphics.draw(bg_img, x, y, 0, Config.scale)

    for cell_id, item_id in ipairs(self.cells) do
        local cell_width = cell_img:getWidth() * Config.scale
        local cell_high = cell_img:getHeight() * Config.scale
        local cell_x = x + 6 + (cell_id - 1) * cell_width
        --构建道具格子
        love.graphics.draw(cell_img, cell_x, y + 6, 0, Config.scale)
        --构建格子内的道具
        if item_id > 0 then
            local item = ItemManager:getItem(item_id)
            local icon = item.icon
            local item_img = love.graphics.newImage(icon)
            love.graphics.draw(item_img, cell_x + 6, y + 12, 0, Config.scale)
            local player = Game.player
            local item_num = player.items[item_id]
            love.graphics.print(tostring(item_num), cell_x + cell_width - 15, y + cell_high - 15)
        end
    end
end

return bag
