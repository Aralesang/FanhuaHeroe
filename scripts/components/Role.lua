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
---@field animation Animation | nil 动画组件
---@field equipment Equipment | nil 装备组件
Role = Component:extend()

function Role:new()
    self.name = nil
    self.speed = 100
    self.moveDir = Direction.Donw --移动方向
    self.direction = Direction.Donw
end

function Role:load()
    self.animation = self.gameObject:getComponent(Animation)
    self.equipment = self.gameObject:getComponent(Equipment)
end

function Role:update(dt)
    if self.animation == nil then
        error("角色对象未找到动画组件")
    end
    if self.equipment == nil then
        error("角色未找到装备组件")
    end
    --同步装备动画
    local frameIndex = self.animation.frameIndex
    local animName = self.animation:getAnimName()
    self.equipment:changeAnim(animName,frameIndex)
end

--获取角色方向
---@return Direction
function Role:getDir()
    return self.direction
end

function Role:onDestroy()
    --摧毁接触到的对象
    --Debug.log("对象被销毁:"..self.gameObject.gameObjectName)
end

---攻击
function Role:attack()
    print("Normal Attack ...")
    --TODO:创建攻击区域
    local attackRange = GameObject()
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