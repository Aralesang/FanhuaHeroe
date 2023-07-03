local GameObject = require "scripts.game.GameObject"

---@class Drop:GameObject 掉落物
---@field itemId number 对应的物品id
local Drop = GameObject:extend()

function Drop:new(itemId,x,y)
    self.super:new()
    self.w = 32
    self.h = 32
    self.itemId = itemId
    self.x = x
    self.y = y
    self.name = "微弱的治愈药剂"
end

return Drop