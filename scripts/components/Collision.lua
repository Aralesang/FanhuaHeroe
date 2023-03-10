require "scripts.base.Component"

---@class Collision : Component 碰撞器基类
---@field position Vector2 碰撞器位置
---@field debug boolean 是否启用debug模式，启用后将在游戏中绘制出碰撞器的轮廓
---@field collisions Collision[] 当前正在碰撞的对象列表
---@field isCollision boolean 当前碰撞器是否处于碰撞中
Collision = {
    position = nil,
    debug = false,
    collisions = nil,
    isCollision = false
}

function Collision:new()
    ---@type Collision
    local o = Component:new()
    setmetatable(o, {__index = self})
    table.insert(Game.controllers,o)
    o.position = Vector2.zero()
    o.debug = true
    o.collisions = {}
    o.setPosition = self.setPosition
    o.getPosition = self.getPosition
    o.onBeginCollision = self.onBeginCollision
    o.onEndCollision = self.onEndCollision
    o.checkCollision = self.checkCollision
    return o
end

---获取碰撞器所在位置
---@return Vector2 碰撞器所在坐标
function Collision:getPosition()
    return self.position
end

---设置碰撞器位置
function Collision:setPosition(x, y)
    self.position.x = x
    self.position.y = y
end

---碰撞开始
function Collision:onBeginCollision(otherColl)
    table.insert(self.collisions, otherColl)
    self.isCollision = true

    --对象上所有组件触发碰撞事件
    for _, v in pairs(self.gameObject.components) do
        if v.componentName ~= "CollisionBox" and v.componentName ~= "CollisionCircular" and v.onBeginCollision then
            v:onBeginCollision(otherColl)
        end
    end
end

---碰撞结束
---@param otherColl Collision
function Collision:onEndCollision(otherColl)
    local count = 0
    for k, v in pairs(self.collisions) do
        if v ~= nil then
            count = count + 1
            if v == otherColl then
                table.remove(self.collisions, k)
                count = count - 1
            end
        end
    end

    if count == 0 then
        self.isCollision = false
    end

    for _, v in pairs(self.gameObject.components) do
        if v.componentName ~= "CollisionBox" and v.componentName ~= "CollisionCircular" and v.onEndCollision then
            v:onEndCollision(otherColl)
        end
    end
end

---检查目标碰撞器是否与该碰撞器碰撞
function Collision:checkCollision(otherColl)
    for _, v in pairs(self.collisions) do
        if v == otherColl then
            return true
        end
    end
    return false
end