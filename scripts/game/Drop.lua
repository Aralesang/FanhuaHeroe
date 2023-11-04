local GameObject = require "scripts.game.GameObject"

---@class Drop:GameObject 掉落物
---@field itemId number 对应的物品id
---@field itemNum number 堆中的物品数量
---@field icon string 图标
---@field private img love.Image 图标对象
local Drop = Class('Drop',GameObject)

function Drop:initialize(itemId,name,x,y)
    GameObject.initialize(self,x,y)
    self.w = 16
    self.h = 16
    self.itemId = itemId
    self.name = name
    self.tag = "drop"
end

function Drop:update()
   
end

function Drop:draw()
    if self.img == nil then
        self.img = love.graphics.newImage(self.icon)
    end
    love.graphics.draw(self.img, self.x, self.y)
end

return Drop