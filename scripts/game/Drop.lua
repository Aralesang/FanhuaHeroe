local GameObject = require "scripts.game.game_object"

---@class Drop:game_object 掉落物
---@field itemId number 对应的物品id
---@field itemNum number 堆中的物品数量
---@field icon string 物品图标
local Drop = Class('Drop',GameObject)

function Drop:initialize(itemId,name,x,y,icon)
    GameObject.initialize(self,x,y)
    self.w = 16
    self.h = 16
    self.itemId = itemId
    self.name = name
    self.tag = "drop"
    self.icon = icon
end

function Drop:draw()
    local img = love.graphics.newImage(self.icon)
    love.graphics.draw(img,self.x,self.y)
end

return Drop