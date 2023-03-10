require "scripts.components.Animation"
require "scripts.base.GameObject"
require "scripts.base.Game"
require "scripts.components.CollisionBox"
require "scripts.base.Component"

---@class Role : Component
---@field name string 角色名称
---@field speed number 角色速度
---@field moveDir string 角色移动方向
---@field orientation string 角色朝向 | "left" | "right" | "up" | "down"
---@field animation Animation 动画组件
Role = {
    name = nil,
    speed = 100,
    moveDir = "down", --移动方向
    orientation = "down", --角色朝向
    componentName = "Role"
}

---@return Role
function Role:new()
    ---@type Role
    local o = Component:new()
    setmetatable(o, {__index = self})
    
    return o
end
---@alias ld fun():void
function Role:load()
end

function Role:update(dt)
    
end

---设置角色方向
function Role:setDir(dir)
    if self.animation == nil then
        self.animation = self:getComponent(Animation)
    end

    if dir == "left" then
        self.orientation = "left"
        self.animation:setRow(1, 1)
    elseif dir == "right" then
        self.orientation = "right"
        self.animation:setRow(2, 1)
    elseif dir == "up" then
        self.orientation = "up"
        self.animation:setRow(3, 1)
    elseif dir == "down" then
        self.orientation = "down"
        self.animation:setRow(0, 1)
    end
end

function Role:onDestroy()
    --摧毁接触到的对象
    --Debug.log("对象被销毁:"..self.gameObject.gameObjectName)
end

---攻击
function Role:attack()
    print("Normal Attack ...")
    --TODO:创建攻击区域
    local attackRange = GameObject:new()
    local gameObject = self.gameObject
    local x = gameObject:getPosition().x
    local y = gameObject:getPosition().y + 40
    attackRange:setPosition(x,y)

    attackRange:addComponent(DebugDraw)

    local collision = attackRange:addComponent(CollisionBox)
    collision:setScale(30,20)
    --TODO:检查攻击区域

    collision.onBeginCollision = function(collision)
        print("atk on!".. collision)
    end
    
end