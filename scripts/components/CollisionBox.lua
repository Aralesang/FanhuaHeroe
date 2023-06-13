require "scripts.base.Game"
require "scripts.base.Component"
require "scripts.utils.Debug"
require "scripts.components.Collision"

---碰撞器_盒状
---@class CollisionBox : Collision
---@field width number 碰撞器的宽度
---@field height number 碰撞器的高度
---@field isCollision boolean 如果当前碰撞器处于碰撞中,则为true
CollisionBox = Component:extend()

---创建一个新碰撞器
function CollisionBox:new()
    self.width = 0
    self.height = 0
    self.width = 0
    self.height = 0
    self.isCollision = false
    self.position = Vector2.zero()
end

function CollisionBox:load()
end

function CollisionBox:update(dt)
    self.position.x = self.gameObject.x
    self.position.y = self.gameObject.y
    ---@param otherCollision CollisionBox
    for _, otherCollision in pairs(Game.controllers) do
        if otherCollision:is(CollisionBox) and tostring(self) ~= tostring(otherCollision) then
            if
                self.position.x + self.width >= otherCollision.position.x and
                    self.position.x - otherCollision.position.x <= self.width and
                    self.position.y + self.height >= otherCollision.position.y and
                    self.position.y - otherCollision.position.y <= self.height
             then
                if self:checkCollision(otherCollision) == false then
                    self:onBeginCollision(otherCollision)
                end
            else
                if self:checkCollision(otherCollision) == true then
                    self:onEndCollision(otherCollision)
                end
            end
        end
    end
end

function CollisionBox:draw()
    if Config.ShowCollision then
        if self.isCollision then
            love.graphics.setColor(0.76, 0.18, 0.05)
        end
        love.graphics.rectangle("line", self.position.x - self.width / 2, self.position.y - self.height / 2, self.width, self.height)
        love.graphics.setColor(1, 1, 1)
    end
end

---设置碰撞器宽高
function CollisionBox:setWH(w, h)
    self.width = w
    self.height = h
end