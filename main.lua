Class      = require "scripts.utils.middleclass"
Game = require "scripts.game.game"
Tool = require "scripts.utils.Tool"
local sti = require "scripts.utils.sti"
local player_class = require "scripts.game.player"
local bump = require "scripts.utils.bump"
local debug = require "scripts.utils.debug"
local slim = require "scripts.game.slim"
local anim_manager = require "scripts.manager.anim_manager"
local item_manager = require "scripts.manager.item_manager"
local role_manager = require "scripts.manager.role_manager"
local fsm         = require "scripts.game.fsm"
local timer = require "scripts.utils.hump.timer"
local camera = require "scripts.utils.hump.camera"
local skill_manager = require "scripts.manager.skill_manager"
local ui_manager    = require "scripts.manager.ui_manager"
local ruby         = require "scripts.game.npc.ruby"

---@type map
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
    anim_manager:init()
    item_manager:init()
    role_manager:init()
    skill_manager:init()
    ui_manager:init()
    
    --加载有限状态机
    fsm.init()

    --加载场景
    print("加主场景...")

    map = sti("scenes/测试地图.lua",{"bump"})

    --创建物理世界
    Game.world = bump.newWorld()
    map:bump_init(Game.world)
    --实例化角色对象
    ---@type player
    player = player_class:new(300,100)
    player.name = ""
    Game.camera = camera(0,0,3)
    ---@type slim
    slim:new(390,40)

    ruby:new(300,50)
    print("游戏初始化完毕!")
end

--每帧逻辑处理
---@param dt number 距离上一帧的间隔时间
function love.update(dt)
    timer.update(dt)
    map:update(dt)
    Game.camera:lockPosition(player.x,player.y)
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
                fsm.call(gameObject --[[@as Role]],dt)
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
    local uis = ui_manager.uis
    for _, ui in pairs(uis) do
        ui:update(dt)
    end
end

--每帧绘制
function love.draw()
    ---@diagnostic disable-next-line: undefined-field
    Game.camera:attach()
    --绘制地图
    --map:draw(Game.camera.x / 3, Game.camera.y / 3, 3)
    map:draw(1280 / 6  - player.x, 720/6 - player.y,3)
    --map:draw(0, 0,1)
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
    local uis = ui_manager.uis
    for _, ui in pairs(uis) do
        ui:drwa()
    end
    debug.showFPS()
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