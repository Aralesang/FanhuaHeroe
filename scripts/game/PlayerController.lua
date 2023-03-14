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
    role = nil,
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

    ---@type Animation
    local animation = player:getComponent(Animation)

    local key
    if love.keyboard.isDown("space") then
        self:attack()
    end
    if love.keyboard.isDown("left") then
        key = Direction.Left
    elseif love.keyboard.isDown("right") then
        key = Direction.Right
    elseif love.keyboard.isDown("up") then
        key = Direction.Up
    elseif love.keyboard.isDown("down") then
        key = Direction.Donw
    end
    if key ~= nil then --如果有方向键被按下
        if self.role:getDir() ~= key then
            self.role:setDir(key) --设置角色面向
        end
        if not animation:checkState(AnimationState.Playing)  then --如果当前动画不处于播放中,则从第一帧(初始帧为第0帧)开始播放
            animation:play(1)
        end
        self:move(dt, key) --移动
    else --如果没有按方向键
        if animation:checkState(AnimationState.Playing) then --当前如果正在播放动画，则停止播放并定格到第0帧
            animation:stop(0)
        end
    end
end

---按键检测
function PlayerController:keypressed(key)
    
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
    if animation == nil then return end
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
    local playerDir = self.role:getDir()
    local dir = Vector2.zero()
    if playerDir == Direction.Up then
        dir = Vector2.up()
    elseif playerDir == Direction.Donw then
        dir = Vector2.down()
    elseif playerDir == Direction.Left then
        dir = Vector2.left()
    elseif playerDir == Direction.Right then
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
    --获取移动
    local distance = dt * self.role.speed
    if dir == Direction.Left then
        x = x - distance
    elseif dir == Direction.Right then
        x = x + distance
    elseif dir == Direction.Up then
        y = y - distance
    elseif dir == Direction.Donw then
        y = y + distance
    end
    player:setPosition(x, y)
end

return PlayerController