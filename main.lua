Class               = require "scripts.utils.middleclass"
Game                = require "scripts.game.game"
Tool                = require "scripts.utils.tool"
local sti           = require "scripts.utils.sti"
local player_class  = require "scripts.game.player"
local bump          = require "scripts.utils.bump"
local debug         = require "scripts.utils.debug"
local slim          = require "scripts.game.slim"
local anim_manager  = require "scripts.manager.anim_manager"
ItemManager         = require "scripts.manager.item_manager"
local role_manager  = require "scripts.manager.role_manager"
local fsm           = require "scripts.game.fsm"
local timer         = require "scripts.utils.hump.timer"
local camera        = require "scripts.utils.hump.camera"
local skill_manager = require "scripts.manager.skill_manager"
local ui_manager    = require "scripts.manager.ui_manager"
local ruby          = require "scripts.game.npc.ruby"
local test_map      = require "scenes.test_map"

---@type map
local map
local player

function love.load()
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
    ItemManager:init()
    role_manager:init()
    skill_manager:init()
    ui_manager:init()

    --加载有限状态机
    fsm.init()

    --加载场景
    print("加主场景...")

    map = sti("scenes/test_map.lua", { "bump" })

    --创建物理世界
    Game.world = bump.newWorld()
    map:bump_init(Game.world)

    --构造地图对象
    for _, value in pairs(test_map.layers) do
        local objects = value.objects
        if objects then
            for _, object in pairs(objects) do
                if object.type == "player" then
                    --实例化角色对象
                    ---@type player
                    player = player_class:new(object.x, object.y)
                elseif object.type == "ruby" then
                    ruby:new(object.x, object.y)
                elseif object.type == "slim" then
                    slim:new(object.x, object.y)
                end
            end
        end
    end
    --构造主摄像机
    Game.camera = camera(0, 0, Config.scale)
    --道具快捷栏
    ui_manager:show("bag")
    print("游戏初始化完毕!")
end

--每帧逻辑处理
---@param dt number 距离上一帧的间隔时间
function love.update(dt)
    timer.update(dt)
    map:update(dt)
    Game.camera:lockPosition(player.x, player.y)
    --触发对象更新
    for _, gameObject in pairs(Game.gameObjects) do
        --首先触发对象本身的更新
        if gameObject.load and gameObject.isLoad == false then
            gameObject:load()
            gameObject.isLoad = true
        end
        if gameObject.update then
            gameObject:update(dt)
        end
        ---@cast gameObject role
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
    map:draw(1280 / 6 - player.x, 720 / 6 - player.y, 3)
    --map:draw(0, 0,1)
    --绘制对象
    for _, gameObject in pairs(Game.gameObjects) do
        --绘制游戏对象
        gameObject:draw()
        ---@cast gameObject role
        if gameObject.animation then
            gameObject.animation:draw()
        end
        if gameObject.equipment then
            gameObject.equipment:draw()
        end
    end
    if Config.show_collision then
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
    --触发ui按键事件
    local uis = ui_manager.uis
    for _, ui in pairs(uis) do
        ui:keypressed(key)
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

function love.run()
    ---@diagnostic disable-next-line: undefined-field, redundant-parameter
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    -- 初始化 FPS 控制
    local desiredFPS = 60
    local frameTime = 1 / desiredFPS
    local lastTime = love.timer.getTime()

    -- 主循环
    return function()
        -- 计算当前帧的时间差
        local currentTime = love.timer.getTime()
        local deltaTime = currentTime - lastTime

        -- 如果还没到下一帧的时间，就 sleep 剩余时间
        if deltaTime < frameTime then
            love.timer.sleep(frameTime - deltaTime)
            return -- 跳过这帧，等待下一帧
        end

        -- 更新 lastTime（固定步长，避免累积误差）
        lastTime = lastTime + frameTime

        -- 处理事件
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == "quit" then
                    ---@diagnostic disable-next-line: undefined-field
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                ---@diagnostic disable-next-line: undefined-field
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        -- 更新游戏逻辑（传入固定 dt）
        if love.update then love.update(frameTime) end

        -- 绘制
        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        -- 控制帧率（防止超快循环）
        love.timer.step()
    end
end
