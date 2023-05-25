require "scripts.base.GameObject"
require "scripts.components.Animation"
require "scripts.components.CollisionCircular"
require "scripts.base.Component"
require "scripts.components.Role"
require "scripts.base.Vector2"
require "scripts.components.DebugDraw"

---子弹组件
---@class Bullet : Component
---@field animation Animation | nil
---@field speed number 子弹飞行速度
---@field master string 子弹的发射者
---@field dir Vector2 子弹飞行方向
Bullet = Component:extend()

function Bullet:new()
    self.animation = nil
    self.speed = 5
    self.componentName = "Bullet"
    self.master = ""
    self.dir = Vector2.zero()
end

function Bullet:load()
    self.gameObject:addComponent(DebugDraw)
end

function Bullet:update(dt)
    --子弹将会自动前进
    self.gameObject.position.x = self.gameObject.position.x + self.speed * self.dir.x;
    self.gameObject.position.y = self.gameObject.position.y + self.speed * self.dir.y;
end

---碰撞回调
---@param collision Collision
function Bullet:onBeginCollision(collision)
    ---@type Role | nil
    local role = collision.gameObject:getComponent(Role)
    if role == nil then
        return
    end
    if role.name ~= self.master then
        collision.gameObject:destroy()
    end
end