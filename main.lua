Object = require "scripts.base.Object"
require "scripts.base.Camera"
require "scripts.base.GameObject"
require "scripts.base.Game"
require "scripts.components.Animation"
require "scripts.game.Role"
require "scripts.components.CollisionBox"
require "scripts.manager.RoleManager"
require "scripts.manager.SceneManager"
require "scripts.game.PlayerController"
require "scripts.utils.PrefabUtil"
local sti = require "scripts.utils.sti"

--启用远程调试
--Debug.debugger()

--甚至每帧的时间为1/60秒，即帧率为60帧每秒
local deltaTime = 1 / 60
--地图对象
local map

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

    --实例化角色对象
    PrefabUtil.instantiate("player")
    print("game start completed!")
end

--每帧逻辑处理
---@param dt number 距离上一帧的间隔时间
function love.update(dt)
    -- 锁定帧率
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
    local scale = 2

    -- Draw world with translation and scaling
    map:draw(0, 0, scale)
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
