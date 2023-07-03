local Role = require "scripts.game.Role"

---@class Enemy:Role 敌人基类
local Enemy = Role:extend()

---继承
---@return GameObject
function Enemy:extend()
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
end

function Enemy:new()
    self.super:new()
end

return Enemy