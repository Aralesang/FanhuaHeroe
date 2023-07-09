local Game = require "scripts.game.Game"
local sti = require "scripts.utils.sti"
local Player = require "scripts.game.Player"
local bump = require "scripts.utils.bump"
local Debug = require "scripts.utils.debug"
local Slim = require "scripts.game.Slim"
local AnimManager = require "scripts.manager.AnimManager"
local ItemManager = require "scripts.manager.ItemManager"
local RoleManager = require "scripts.manager.RoleManager"
local FSM         = require "scripts.game.FSM"
local Role        = require "scripts.game.Role"
local gamera = require "scripts.utils.gamera"
local Timer = require "scripts.utils.hump.timer"
local Camera = require "scripts.utils.hump.camera"
local map
local camera
local player

function love.load()
    -- if love.system.getOS() == "Windows" then
    --     print("将终端字体设置为65001")
    --     os.execute("chcp 65001") -- 设置代码页为UTF-8
    -- end
    print("游戏初始化...")
    --加载中文字体(启动会很缓慢)
    print("加载中文字体...")
    local myFont = love.graphics.newFont("fonts/SourceHanSansCN-Bold.otf", 16)
    love.graphics.setFont(myFont)
    --更改图像过滤方式，以显示高清马赛克
    print("更改图像过滤方式...")
    love.graphics.setDefaultFilter("nearest", "nearest")

    --加载系统管理器
    AnimManager.init()
    ItemManager.init()
    RoleManager.init()
    --加载有限状态机
    FSM.init()

    --加载场景
    print("加主场景...")

    map = sti("scenes/测试地图.lua",{"bump"})

    --创建物理世界
    Game.world = bump.newWorld()
    map:bump_init(Game.world)
    --实例化角色对象
    ---@type Player
    player = Player(1280/4 - 25,720/4 + 50)
    camera = Camera(0,0,3)
    ---@type Slim
    Slim(1280/4 - 16,720/4 -32 + 20)
    
    ItemManager.createDrop(4,1280/4,720/4)
    ItemManager.createDrop(5,1280/4,720/4)
    ItemManager.createDrop(6,1280/4,720/4)
    print("游戏初始化完毕!")
end

--每帧逻辑处理
---@param dt number 距离上一帧的间隔时间
function love.update(dt)
    Timer.update(dt)
    map:update(dt)
    camera:lookAt(player.x,player.y)
    --触发对象更新
    for _, gameObject in pairs(Game.gameObjects) do
        --首先触发对象本身的更新
        if gameObject.load and gameObject.isLoad == false then
            gameObject:load()
            gameObject.isLoad = true
        end
        if gameObject.update then
            gameObject:update(dt)
            --如果是角色对象,触发有限状态机
            if gameObject:is(Role) then
                FSM.call(gameObject --[[@as Role]],dt)
            end
        end
        --然后触发对象所附加的组件更新
        if gameObject.components then
            for _, component in pairs(gameObject.components) do
                --触发组件load函数
                if component.load and component.isLoad == false then
                    component:load()
                    component.isLoad = true
                end
                --触发组件更新
                if component.update then
                    component:update(dt)
                end
            end
        end
    end
end

--每帧绘制
function love.draw()
    ---@diagnostic disable-next-line: undefined-field
    camera:attach()
    --绘制地图
    map:draw(1280 / 6  - player.x, 720/6 - player.y,3)
    --绘制对象
    for _, value in pairs(Game.gameObjects) do
        --绘制游戏对象
        value:draw()
        if value.components then
            --触发组件绘制
            for _, component in pairs(value.components) do
                if component.draw ~= nil then
                    component:draw()
                end
            end
        end
        if Config.ShowCollision then
            --绘制碰撞体积
            Debug.drawBox(value,0,1,0)
        end
    end
    --map:bump_draw()
    camera:detach()
    Debug.showFPS()
end

--按键按下
---@param key number 按下的键值
function love.keypressed(key)
    --触发对象输入事件
    for _, value in pairs(Game.gameObjects) do
        value:keypressed(key)
        if value.components then
            for _, component in pairs(value.components) do
                if component.keypressed then
                    component:keypressed(key)
                end
            end
        end
    end
end

--按键释放
---@param key number 释放的键值
function love.keyreleased(key)
    --触发对象输入事件
    for _, value in pairs(Game.gameObjects) do
        value:keyreleased(key)
        if value.components then
            for _, component in pairs(value.components) do
                if component.keyreleased then
                    component:keyreleased(key)
                end
            end
        end
    end
end