local Role = require "scripts.game.Role"

---@class Enemy:Role 敌人基类
local Enemy = Role:extend()

function Enemy:new(x,y)
    self.super:new(x,y)
end

return Enemy