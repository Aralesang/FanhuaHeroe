require "scripts.components.Bullet"
require "scripts.components.Animation"
require "scripts.base.GameObject"
require "scripts.components.CollisionCircular"
require "scripts.utils.Debug"
require "scripts.base.Component"
require "scripts.enums.Direction"

--子弹图片
local bulletImage

---玩家控制器
---@class PlayerController : Component
---@field role Role | nil 玩家组件
PlayerController = {
    componentName = "PlayerController",
    role = nil
}

---@return PlayerController | Component
function PlayerController:new()
    ---@type Component
    local o = Component:new()
    setmetatable(o, {__index = self})

    return o
end

function PlayerController: load()
    self.role = self.gameObject:getComponent(Role)
end

function PlayerController:update(dt)
    local player = self.gameObject
    local width, height = love.window.getMode()
    if player == nil then return end
    Camera:setPosition(player.position.x - width / 2, player.position.y - height / 2)

    local key
    if love.keyboard.isDown("left") then
        key = Direction.LEFT
    elseif love.keyboard.isDown("right") then
        key = Direction.RIGHT
    elseif love.keyboard.isDown("up") then
        key = Direction.UP
    elseif love.keyboard.isDown("down") then
        key = Direction.DONW
    end

    ---@type Animation
    local animation = player:getComponent(Animation)

    if key ~= nil then
        if self.role.direction ~= key then
            self.role:setDir(key) --设置角色面向
        end
        if animation.status ~= "playing" then
            animation:play(1)
        end
        self:move(dt, key) --移动
        key = nil
    else
        if animation.status == "playing" then
            animation:stop(0)
        end
    end
end

---按键检测
function PlayerController:keypressed(key)
    if key == "space" then
        self:attack()
    end
end

---普通攻击
function PlayerController:attack()
    --TODO:实现普通攻击逻辑
    self.role:attack()
end

---发射子弹
function PlayerController:fire()
    if bulletImage == nil then
        bulletImage = love.graphics.newImage("image/bullet.png")
    end
    local player = self.gameObject
    if player == nil then
        return
    end
    local playerPosition = player:getPosition()

    --创建子弹对象
    local bulletObj = GameObject:new()
    bulletObj:setCentral(bulletImage:getWidth() / 2,bulletImage:getHeight() / 2)
    bulletObj:setScale(0.2, 0.2)
    bulletObj:setPosition(playerPosition.x,playerPosition.y)
    --附加动画组件
    ---@type Animation | nil
    local animation = bulletObj:addComponent(Animation)
    if animation == nil then
        return
    end
    animation:init(bulletImage, 1, 1, 0)

    --为子弹附加碰撞组件
    ---@type CollisionCircular | nil
    local collision = bulletObj:addComponent(CollisionCircular)
    if collision == nil then return end
    collision:setRadius(10)

    --附加子弹组件
    ---@type Bullet | nil
    local bullet = bulletObj:addComponent(Bullet)
    bullet.master = self.role.name
    local playerDir = self.role.direction
    local dir = Vector2.zero()
    if playerDir == Direction.UP then
        dir = Vector2.up()
    elseif playerDir == Direction.DONW then
        dir = Vector2.down()
    elseif playerDir == Direction.LEFT then
        dir = Vector2.left()
    elseif playerDir == Direction.RIGHT then
        dir = Vector2.right()
    end

    bullet.dir = dir

    --附加动画组件
    bulletObj:addComponent(Animation):init(bulletImage, 1, 1)

    print(bulletObj.position.x .. "," .. bulletObj.position.y)
end

function PlayerController:keyreleased(key)
end

---玩家移动
---@param dt number 距离上一帧的间隔时间
---@param dir Direction 移动方向
function PlayerController:move(dt, dir)
    local player = self.gameObject
    if player == nil then return end

    local position = player:getPosition()
    local x = position.x
    local y = position.y
    local distance = math.modf(dt * self.role.speed)

    if dir == Direction.LEFT then
        x = x - distance
    elseif dir == Direction.RIGHT then
        x = x + distance
    elseif dir == Direction.UP then
        y = y - distance
    elseif dir == Direction.DONW then
        y = y + distance
    end
    player:setPosition(x, y)
end

return PlayerController