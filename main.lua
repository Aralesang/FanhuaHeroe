require "scripts.base.Camera"
require "scripts.base.GameObject"
require "scripts.base.Game"
require "scripts.components.Animation"
require "scripts.components.Role"
require "scripts.components.CollisionBox"
require "scripts.manager.RoleManager"
require "scripts.manager.SceneManager"

--启用远程调试
--Debug.debugger()
---@type Role[]
local roleArr = {}
---@type PlayerController 玩家控制器
local playerController
--背景图片
---@type love.Texture
local backgroundImage

function love.load()
    print("game starting...")
    --加载中文字体(启动会很缓慢)
    local myFont = love.graphics.newFont("fonts/SourceHanSansCN-Bold.otf", 16)

    love.graphics.setFont(myFont)
    --更改图像过滤方式，以显示高清马赛克
    love.graphics.setDefaultFilter("nearest", "nearest")
    --加载场景
    SceneManager.load("main")
    --加载背景图片
    --backgroundImage = love.graphics.newImage("image/background.jpg")
    --创建npc
    --local npc = RoleManager.createRole("image/npc.png", "npc", 0, 0)
    --roleArr["npc"] = npc
    --创建玩家
    --local player = RoleManager.createRole("image/player.png", "player", 50, 0)
    --roleArr["player"] = player

    --初始化角色控制器
    --playerController = PlayerController:new(player)
end

--绘制
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
end

function love.update(dt)
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

function love.keypressed(key)
    --触发对象输入事件
    for key, value in pairs(Game.gameObjects) do
        for _, component in pairs(value.components) do
            if component.keypressed then
                component:keypressed(key)
            end
        end
    end
end

function love.keyreleased(key)
    --触发对象输入事件
    for key, value in pairs(Game.gameObjects) do
        for _, component in pairs(value.components) do
            if component.keyreleased then
                component:keyreleased(key)
            end
        end
    end
end