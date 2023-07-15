Class      = require "scripts.utils.middleclass"
Game = require "scripts.game.Game"
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
local Timer = require "scripts.utils.hump.timer"
local Camera = require "scripts.utils.hump.camera"
local SkillManager = require "scripts.manager.SkillManager"
local UiManager    = require "scripts.manager.UiManager"
local Lubi         = require "scripts.game.npc.Lubi"

local map
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
    AnimManager:init()
    ItemManager:init()
    RoleManager:init()
    SkillManager:init()
    
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
    player = Player:new(1280/4 - 16,720/4 + 50)
    player.name = ""
    Game.camera = Camera(0,0,3)
    ---@type Slim
    Slim:new(1280/4 - 16,720/4 -12)

    Lubi:new(1280/4 - 16,720/4 + 100)
    print("游戏初始化完毕!")
end

--每帧逻辑处理
---@param dt number 距离上一帧的间隔时间
function love.update(dt)
    Timer.update(dt)
    map:update(dt)
    Game.camera:lookAt(player.x,player.y)
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
            if gameObject["state"] then
                FSM.call(gameObject --[[@as Role]],dt)
            end
        end
        ---@cast gameObject Role
        if gameObject.animation then
            gameObject.animation:update(dt)
        end
        if gameObject.equipment then
            gameObject.equipment:update(dt)
        end
    end

    --触发ui更新
    local uis = UiManager.uis
    for _, ui in pairs(uis) do
        ui:update(dt)
    end
end

--每帧绘制
function love.draw()
    ---@diagnostic disable-next-line: undefined-field
    Game.camera:attach()
    --绘制地图
    map:draw(1280 / 6  - player.x, 720/6 - player.y,3)
    --绘制对象
    for _, gameObject in pairs(Game.gameObjects) do
        --绘制游戏对象
        gameObject:draw()
        ---@cast gameObject Role
        if gameObject.animation then
            gameObject.animation:draw()
        end
        if gameObject.equipment then
            gameObject.equipment:draw()
        end
    end
    if Config.ShowCollision then
        --绘制碰撞体积
        map:bump_draw()
    end
    Game.camera:detach()
    --触发ui绘制
    local uis = UiManager.uis
    for _, ui in pairs(uis) do
        ui:drwa()
    end
    Debug.showFPS()
end

--按键按下
---@param key number 按下的键值
function love.keypressed(key)
    --触发对象输入事件
    for _, value in pairs(Game.gameObjects) do
        value:keypressed(key)
    end
end

--按键释放
---@param key number 释放的键值
function love.keyreleased(key)
    --触发对象输入事件
    for _, value in pairs(Game.gameObjects) do
        value:keyreleased(key)
    end
end