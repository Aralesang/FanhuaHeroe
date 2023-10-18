local Role = require "scripts.game.role"

---@class Enemy:Role 敌人基类
local Enemy = Class('Enemy',Role)

function Enemy:initialize(roleId,x,y)
    Role.initialize(self,roleId,x,y)
end

return Enemy