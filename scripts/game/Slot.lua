---@class Slot : Object 装备槽
---@field name string 装备槽名称
---@field itemId number 所装备的物品id
---@field anims table<string,Anim> 装备动画列表
Slot = Object:extend()

function Slot:new(name)
    self.name = name
    self.itemId = 0
end