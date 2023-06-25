---@class Attribute:Component 属性
---@field hp number 生命值
---@field hpMax number 最大生命值
---@field atk number 攻击力
---@field def number 防御力
Attribute = Attribute:extend()

function Attribute:new()
    self.super:new()
end