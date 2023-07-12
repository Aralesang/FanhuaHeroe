local GameObject = require "scripts.game.GameObject"

---@class Drop:GameObject 掉落物
---@field itemId number 对应的物品id
---@field itemNum number 堆中的物品数量
local Drop = Class('Drop',GameObject)

function Drop:initialize(itemId,name,x,y)
    GameObject.initialize(self,x,y)
    self.w = 32
    self.h = 32
    self.itemId = itemId
    self.name = name
    self.tag = "drop"
end

return Drop