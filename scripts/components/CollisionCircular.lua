require "scripts.base.Game"
require "scripts.base.Component"
require "scripts.components.Collision"

---碰撞器_圆形
---@class CollisionCircular : Collision
---@field debug boolean 绘制形状
---@field radius number 半径
CollisionCircular = {
    radius = 0,
    componentName = "CollisionCircular"
}

---创建一个新碰撞器
---@return CollisionCircular | Collision | Component
function CollisionCircular:new()
    local o = Collision:new()
    setmetatable(o, {__index = self})
    self.radius = 0
    return o
end

function CollisionCircular:load()
end

function CollisionCircular:update(dt)
    self:setPosition(self.gameObject.position.x, self.gameObject.position.y)
    ---@type CollisionCircular
    ---@param otherCollision Collision
    for _, otherCollision in pairs(Game.controllers) do
        --对圆形的碰撞
        ---@type CollisionCircular | Collision
        local otherCollisionCircular = otherCollision
        if
            otherCollision.componentName == "CollisionCircular" and
                tostring(self) ~= tostring(otherCollisionCircular)
         then
            if
                math.abs(otherCollisionCircular.position.x - self.position.x) <= otherCollisionCircular.radius + self.radius and
                    math.abs(otherCollisionCircular.position.y - self.position.y) <= otherCollisionCircular.radius + self.radius
             then
                if self:checkCollision(otherCollisionCircular) == false then
                    self:onBeginCollision(otherCollisionCircular)
                end
            else
                if self:checkCollision(otherCollisionCircular) == true then
                    self:onEndCollision(otherCollisionCircular)
                end
            end
        end

        --对四边形的碰撞
        ---@type CollisionBox | Collision
        local otherCollisionBox = otherCollision
        if otherCollision.componentName == "CollisionBox" then
            if
                math.abs(self.position.x - otherCollisionBox.position.x) <= otherCollisionBox.width / 2 + self.radius and
                    math.abs(self.position.y - otherCollisionBox.position.y) <= otherCollisionBox.height / 2 + self.radius
             then
                if self:checkCollision(otherCollisionBox) == false then
                    self:onBeginCollision(otherCollisionBox)
                    otherCollisionBox:onBeginCollision(self) --触发四边形的碰撞回调
                end
            else
                if self:checkCollision(otherCollisionBox) == true then
                    self:onEndCollision(otherCollisionBox)
                    otherCollisionBox:onEndCollision(self) --触发四边形的碰撞回调
                end
            end
        end
    end
end

function CollisionCircular:draw()
    if Config.ShowCollision then
        if self.isCollision then
            love.graphics.setColor(0.76, 0.18, 0.05)
        end
        love.graphics.ellipse("line", self.position.x, self.position.y, self.radius, self.radius)
        love.graphics.setColor(1, 1, 1)
    end
end

---设置碰撞器半径
function CollisionCircular:setRadius(radius)
    self.radius = radius
end