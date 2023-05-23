require "scripts.components.Animation"
require "scripts.base.GameObject"
require "scripts.base.Game"
require "scripts.components.CollisionBox"
require "scripts.base.Component"
require "scripts.enums.Direction"

---角色组件
---@class Role : Component
---@field name string | nil 角色名称
---@field speed number 角色速度
---@field moveDir Direction 角色移动方向
---@field private direction Direction 角色朝向
Role = Component:extend()

---@return Role | Component
function Role:new()
    self.name = nil
    self.speed = 100
    self.moveDir = Direction.Donw --移动方向
    self.componentName = "Role"
    self.direction = Direction.Donw
    return self
end

function Role:load()
end

function Role:update(dt)
end

--获取角色方向
---@return Direction
function Role:getDir()
    return self.direction
end

---设置角色方向
---@param dir Direction 方向
function Role:setDir(dir)
    if self.animation == nil then
        self.animation = self.gameObject:getComponent(Animation)
    end
    self.direction = dir
    if dir == Direction.Left then
        self.animation:setRow(3)
    elseif dir == Direction.Right then
        self.animation:setRow(2)
    elseif dir == Direction.Up then
        self.animation:setRow(1)
    elseif dir == Direction.Donw then
        self.animation:setRow(0)
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
    if gameObject == nil then
        return
    end
    local x = gameObject:getPosition().x
    local y = gameObject:getPosition().y + 40
    attackRange:setPosition(x,y)

    attackRange:addComponent(DebugDraw)
    ---@type CollisionBox | nil
    local collision = attackRange:addComponent(CollisionBox)
    if collision == nil then
        return
    end
    collision:setWH(30,20)
    --TODO:检查攻击区域

    collision.onBeginCollision = function(collision)
        print("atk on!".. collision)
    end
end