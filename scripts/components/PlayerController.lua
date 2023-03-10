require "scripts.components.Bullet"
require "scripts.components.Animation"
require "scripts.base.GameObject"
require "scripts.components.CollisionCircular"
require "scripts.utils.Debug"
require "scripts.base.Component"

--子弹图片
local bulletImage

---@class PlayerController : Component 玩家控制器
PlayerController = {
    componentName = "PlayerController",
}

---@return PlayerController
---@param player Role 要控制的目标玩家
function PlayerController:new()
    ---@type PlayerController
    local o = Component:new()
    setmetatable(o, {__index = self})

    return o
end

function PlayerController:update(dt)
    local player = self.gameObject
    local width, height = love.window.getMode()
    if player then
        Camera:setPosition(player.position.x - width / 2, player.position.y - height / 2)
    end

    local key
    if love.keyboard.isDown("left") then
        key = "left"
    elseif love.keyboard.isDown("right") then
        key = "right"
    elseif love.keyboard.isDown("up") then
        key = "up"
    elseif love.keyboard.isDown("down") then
        key = "down"
    end

    local animation = player:getComponent(Animation)
    local role = player:getComponent(Role)

    if key ~= nil then
        if player.orientation ~= key then
            role:setDir(key) --设置角色面向
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
    self.player:attack()
end

---发射子弹
function PlayerController:fire()
    if bulletImage == nil then
        bulletImage = love.graphics.newImage("image/bullet.png")
    end

    local playerPosition = self.player.gameObject:getPosition()
    
    --创建子弹对象
    local bulletObj = GameObject:new()
    bulletObj:setCentral(bulletImage:getWidth() / 2,bulletImage:getHeight() / 2)
    bulletObj:setScale(0.2, 0.2)
    bulletObj:setPosition(playerPosition.x,playerPosition.y)
    --附加动画组件
    ---@type Animation
    local animation = bulletObj:addComponent(Animation)
    animation:init(bulletImage, 1, 1, 0)

    --为子弹附加碰撞组件
    local collision = bulletObj:addComponent(CollisionCircular)
    collision:setScale(10)

    --附加子弹组件
    ---@type Bullet
    local bullet = bulletObj:addComponent(Bullet)
    bullet.master = self.player.name
    local playerDir = self.player.orientation
    local dir = Vector2.zero()
    if playerDir == "up" then
        dir = Vector2.up()
    elseif playerDir == "down" then
        dir = Vector2.down()
    elseif playerDir == "left" then
        dir = Vector2.left()
    elseif playerDir == "right" then
        dir = Vector2.right()
    end
    
    bullet.dir = dir 

    --附加动画组件
    bulletObj:addComponent(Animation):init(bulletImage, 1, 1)

    print(bulletObj.position.x .. "," .. bulletObj.position.y)
end

function PlayerController:keyreleased(key)
end

function PlayerController:move(dt, dir)
    local player = self.gameObject
    local role = player:getComponent(Role)

    local position = player:getPosition()
    local x = position.x
    local y = position.y
    local distance = math.modf(dt * role.speed)

    if dir == "left" then
        x = x - distance
    elseif dir == "right" then
        x = x + distance
    elseif dir == "up" then
        y = y - distance
    elseif dir == "down" then
        y = y + distance
    end
    player:setPosition(x, y)
end

return PlayerController