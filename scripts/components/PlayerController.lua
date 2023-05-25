require "scripts.components.Bullet"
require "scripts.components.Animation"
require "scripts.base.GameObject"
require "scripts.components.CollisionCircular"
require "scripts.utils.Debug"
require "scripts.base.Component"
require "scripts.enums.Direction"

---玩家控制器
---@class PlayerController : Component
---@field role Role | nil 角色组件
---@field bulletImage love.Image 子弹图片
---@field isMove boolean 是否正在移动
---@field moveDir Direction 移动方向
---@field animation Animation | nil 动画组件
---@field player GameObject 玩家对象
PlayerController = Component:extend()
PlayerController.componentName = "PlayerController"

function PlayerController:new()
    self.player = self.gameObject
    self.moveDir = Direction.Donw
    self.isMove = false
end

function PlayerController:load()
    self.role = self.gameObject:getComponent(Role)
    self.animation = self.gameObject:getComponent(Animation)
end

function PlayerController:update(dt)
    local player = self.gameObject
    local width, height = love.window.getMode()
    if player == nil then 
        error("player is nil")
    end
    local animation = self.animation
    if animation == nil then 
        error("animation is nil")
    end
    local role = self.role
    if role == nil then return end
    local isMove = self.isMove
    Camera:setPosition(player.position.x - width / 2, player.position.y - height / 2)
    if love.keyboard.isDown("up") then
        self.gameObject:setDir(Direction.Up)
        --animation:updateDir()
        isMove = true
    end
    if love.keyboard.isDown("down") then
        self.gameObject:setDir(Direction.Donw)
        --animation:updateDir()
        isMove = true
    end
    if love.keyboard.isDown("left") then
        self.gameObject:setDir(Direction.Left)
        --animation:updateDir()
        isMove = true
    end
    if love.keyboard.isDown("right") then
        self.gameObject:setDir(Direction.Right)
        --animation:updateDir()
        isMove = true
    end
    if isMove then                                               --如果移动被激活
        if animation.anim.name ~= "行走" then --如果当前动画不是行走，则改为行走
            animation:play("行走")
        end
        self:move(dt, self.gameObject.direction)                               --移动
    else                                                     --如果没在移动了
        if animation.anim.name == "行走" then --当前如果正在播放动画，则停止播放并定格到第0帧
            animation:play("闲置")
        end
    end
    isMove = false
end

---按键检测
---@param key string
function PlayerController:keypressed(key)
    if key == "space" then
        self:attack()
    end
end

---按键释放
---@param key string
function PlayerController:keyreleased(key)

end

---普通攻击
function PlayerController:attack()
    --TODO:实现普通攻击逻辑
    self.role:attack()
end

---发射子弹
function PlayerController:fire()
    local bulletImage = self.bulletImage
    if bulletImage == nil then
        bulletImage = love.graphics.newImage("image/bullet.png")
    end
    local player = self.gameObject
    if player == nil then
        return
    end
    local playerPosition = player:getPosition()
    local role = self.role
    if role == nil then return end
    --创建子弹对象
    local bulletObj = GameObject:new()
    bulletObj:setCentral(bulletImage:getWidth() / 2, bulletImage:getHeight() / 2)
    bulletObj:setScale(0.2, 0.2)
    bulletObj:setPosition(playerPosition.x, playerPosition.y)
    --附加动画组件
    ---@type Animation | nil
    local animation = bulletObj:addComponent(Animation)
    if animation == nil then return end
    --为子弹附加碰撞组件
    ---@type CollisionCircular | nil
    local collision = bulletObj:addComponent(CollisionCircular)
    if collision == nil then return end
    collision:setRadius(10)

    --附加子弹组件
    ---@type Bullet | nil
    local bullet = bulletObj:addComponent(Bullet)
    bullet.master = role.name
    local playerDir = role:getDir()
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

---玩家移动
---@param dt number 距离上一帧的间隔时间
---@param dir Direction 移动方向
function PlayerController:move(dt, dir)
    local player = self.gameObject
    if player == nil then return end

    local role = self.role
    if role == nil then return end
    local position = player:getPosition()
    local x = position.x
    local y = position.y
    --获取移动
    local distance = dt * role.speed
    if dir == Direction.Left then
        x = x - distance
    elseif dir == Direction.Right then
        x = x + distance
    elseif dir == Direction.Up then
        y = y - distance
    elseif dir == Direction.Donw then
        y = y + distance
    end
    --if Tile:isEmpty(x, y) then
    player:setPosition(x, y)
    --end
end

return PlayerController
