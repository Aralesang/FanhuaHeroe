local Role = require "scripts.game.Role"

---@class Enemy:Role 敌人基类
local Enemy = Class('Enemy',Role)

function Enemy:initialize(roleId,x,y)
    Role.initialize(self,roleId,x,y)
end

return Enemy