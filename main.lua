require "scripts.base.Camera"
require "scripts.base.GameObject"
require "scripts.base.Game"
require "scripts.components.Animation"
require "scripts.game.Role"
require "scripts.components.CollisionBox"
require "scripts.manager.RoleManager"
require "scripts.manager.SceneManager"
local sti = require "scripts.utils.sti"

--启用远程调试
--Debug.debugger()

--甚至每帧的时间为1/60秒，即帧率为60帧每秒
local deltaTime = 1 / 60

function love.load()
    print("game starting...")
    love.window.setVSync(0)
    --加载中文字体(启动会很缓慢)
    local myFont = love.graphics.newFont("fonts/SourceHanSansCN-Bold.otf", 16)
    love.graphics.setFont(myFont)
    --更改图像过滤方式，以显示高清马赛克
    love.graphics.setDefaultFilter("nearest", "nearest")
    --加载场景
    map = sti("scenes/start.lua")

    -- Create new dynamic data layer called "Sprites" as the 8th layer
    local layer = map:addCustomLayer("Sprites", 3)

    -- Get player spawn object
    local player
    for k, object in pairs(map.objects) do
        if object.name == "player" then
            player = object
            break
        end
    end

    -- Create player object
    local sprite = love.graphics.newImage("image/character/魔力种子角色.png")
    layer.player = {
        sprite      = sprite,
        x           = player.x,
        y           = player.y,
        ox          = 64 / 2,
        oy          = 64 / 1.35,
        dir         = Direction.Donw,
        fx          = 0,
        fy          = 0,
        lastAnimTIm = 0
    }

    -- Add controls to player
    layer.update = function(self, dt)
        -- 96 pixels per second
        local speed = 96 * dt
        local isMove = false
        -- Move player up
        if love.keyboard.isDown("w", "up") then
            self.player.y = self.player.y - speed
            self.player.dir = Direction.Up
            self.player.fy = 5
            isMove = true
        end

        -- Move player down
        if love.keyboard.isDown("s", "down") then
            self.player.y = self.player.y + speed
            self.player.dir = Direction.Donw
            self.player.fy = 4
            isMove = true
        end

        -- Move player left
        if love.keyboard.isDown("a", "left") then
            self.player.x = self.player.x - speed
            self.player.dir = Direction.Left
            self.player.fy = 7
            isMove = true
        end

        -- Move player right
        if love.keyboard.isDown("d", "right") then
            self.player.x = self.player.x + speed
            self.player.dir = Direction.Right
            self.player.fy = 6
            isMove = true
        end
        if isMove then
            self.player.lastAnimTIm = self.player.lastAnimTIm + dt
            if self.player.lastAnimTIm > 0.1 then
                self.player.fx = self.player.fx > 4 and 0 or self.player.fx + 1;
                self.player.lastAnimTIm = 0
            end
        else
            self.player.fx = 0
        end
    end

    -- Draw player
    layer.draw = function(self)
        local quad = love.graphics.newQuad(self.player.fx * 64, self.player.fy * 64, 64, 64, sprite:getWidth(),
        sprite:getHeight())
        love.graphics.draw(
            self.player.sprite,
            quad,
            math.floor(self.player.x),
            math.floor(self.player.y),
            0,
            1,
            1,
            self.player.ox,
            self.player.oy
        )


        -- Temporarily draw a point at our location so we know
        -- that our sprite is offset properly
        --love.graphics.setPointSize(5)
        --love.graphics.points(math.floor(self.player.x), math.floor(self.player.y))
    end

    -- Remove unneeded object layer
    map:removeLayer("SpawnPoint")
end

--每帧逻辑处理
---@param dt number 距离上一帧的间隔时间
function love.update(dt)
    if dt < deltaTime then
        love.timer.sleep(deltaTime - dt)
    end
    ---@type number[]
    local destroyPool = {}
    --触发对象更新
    for key, value in pairs(Game.gameObjects) do
        for _, component in pairs(value.components) do
            --触发组件load函数
            if component.load and component.isLoad == false then
                component:load()
                component.isLoad = true
            end
            --触发组件更新
            if component.update then
                component:update(dt)
            end
            --触发组件销毁
            if component.onDestroy and value.isDestroy then
                component:onDestroy()
            end
        end
        if value.isDestroy then
            table.insert(destroyPool, key)
        end
    end

    for i = #destroyPool, 1, -1 do
        local index = destroyPool[i]
        table.remove(Game.gameObjects, index)
    end
    map:update(dt)
end

--每帧绘制
function love.draw()
    Camera:set()
    -- Scale world
    local scale         = 2
    local screen_width  = love.graphics.getWidth() / scale
    local screen_height = love.graphics.getHeight() / scale

    -- Translate world so that player is always centred
    local player        = map.layers["Sprites"].player
    local tx            = math.floor(player.x - screen_width / 2)
    local ty            = math.floor(player.y - screen_height / 2)

    -- Draw world with translation and scaling
    map:draw(-tx, -ty, scale)
    --绘制对象
    for _, value in pairs(Game.gameObjects) do
        --触发组件绘制
        for _, component in pairs(value.components) do
            if component.draw ~= nil then
                component:draw()
            end
        end
    end

    Camera:unset()
    Debug.draw()
end

--按键按下
---@param key number 按下的键值
function love.keypressed(key)
    --触发对象输入事件
    for _, value in pairs(Game.gameObjects) do
        for _, component in pairs(value.components) do
            if component.keypressed then
                component:keypressed(key)
            end
        end
    end
end

--按键释放
---@param key number 释放的键值
function love.keyreleased(key)
    --触发对象输入事件
    for _, value in pairs(Game.gameObjects) do
        for _, component in pairs(value.components) do
            if component.keyreleased then
                component:keyreleased(key)
            end
        end
    end
end
