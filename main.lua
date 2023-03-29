require "scripts.base.Camera"
require "scripts.base.GameObject"
require "scripts.base.Game"
require "scripts.components.Animation"
require "scripts.game.Role"
require "scripts.components.CollisionBox"
require "scripts.manager.RoleManager"
require "scripts.manager.SceneManager"

--启用远程调试
--Debug.debugger()

--甚至每帧的时间为1/60秒，即帧率为60帧每秒
local deltaTime = 1/60
---@type number
local width
---@type number
local height
---@type love.Image
local image
---@type table
local quads
---@type table
local tilemap

function love.load()
    print("game starting...")
    love.window.setVSync(0)
    --加载中文字体(启动会很缓慢)
    local myFont = love.graphics.newFont("fonts/SourceHanSansCN-Bold.otf", 16)

    love.graphics.setFont(myFont)
    --更改图像过滤方式，以显示高清马赛克
    love.graphics.setDefaultFilter("nearest", "nearest")
    --加载场景
    SceneManager.load("main")
    image = love.graphics.newImage("image/tileset.png")
    local image_width = image:getWidth()
    local image_height = image:getHeight()
    width = 32
    height = 32


    width = (image_width / 3) - 2
    height = (image_height / 2) - 2
    quads = {}

    for i = 0, 1 do
        for j = 0, 2 do
            table.insert(quads, love.graphics.newQuad(
                1 + j * (width + 2),
                1 + i * (height + 2),
                width, height,
                image_width, image_height
            ))
        end
    end

    tilemap = {
        {1,6,6,2,1,6,6,2},
        {3,0,0,4,5,0,0,3},
        {3,0,0,0,0,0,0,3},
        {4,2,0,0,0,0,1,5},
        {1,5,0,0,0,0,4,2},
        {3,0,0,0,0,0,0,3},
        {3,0,0,1,2,0,0,3},
        {4,6,6,5,4,6,6,5}
    }
end

--每帧绘制
function love.draw()
    Camera:set()
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
    for i,row in ipairs(tilemap) do
        for j,tile in ipairs(row) do
            if tile ~= 0 then
                love.graphics.draw(image, quads[tile], j * width, i * height)
            end
        end
    end
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