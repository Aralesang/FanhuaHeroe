---@class Slim:GameObject 史莱姆
---@field animtion Animation 动画组件
---@field sight number 视野范围
---@field speed number 移动速度
Slim = GameObject:extend()

function Slim:new()
    self.super:new()
    self.sight = 100
    self.speed = 100
    self.x = 0
    self.y = 50
    self.w = 16
    self.h = 16
end

function Slim:load()
    self.animtion = self:addComponent(Animation)
    local role = RoleManager.getRole(1)
    self.animtion:addAnims(role.anims)
    self.animtion:play("闲置_史莱姆")
end

function Slim:update(dt)
    --检查玩家是否进入了自己的攻击范围
    local player = Game.player
    --计算距离
    local dx = player.x - self.x
    local dy = player.y - self.y
    local distance = math.sqrt(dx * dx + dy * dy)
    
    --如果距离小于视野，则向玩家移动
    if distance < self.sight then
        -- local angle = math.atan2(dy,dx)
        -- self.x = self.x + math.cos(angle) * self.speed * dt
        -- self.y = self.y + math.sin(angle) * self.speed * dt
    end
end