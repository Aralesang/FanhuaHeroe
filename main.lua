Object = require "scripts.base.Object"
require "scripts.base.Camera"
require "scripts.base.GameObject"
require "scripts.base.Game"
require "scripts.components.Animation"
require "scripts.components.CollisionBox"
require "scripts.manager.RoleManager"
require "scripts.utils.PrefabUtil"
local sti = require "scripts.utils.sti"
require "scripts.manager.AnimManager"
require "scripts.manager.RoleManager"
require "scripts.game.Player"
local bump = require "scripts.utils.bump"
local bump_debug = require "scripts.utils.bump_debug"

--地图对象
local map

function love.load()
    print("游戏初始化...")
    --加载中文字体(启动会很缓慢)
    print("加载中文字体...")
    local myFont = love.graphics.newFont("fonts/SourceHanSansCN-Bold.otf", 16)
    love.graphics.setFont(myFont)
    -- if love.system.getOS() == "Windows" then
    --     print("将终端字体设置为65001")
    --     os.execute("chcp 65001 > nul") -- 设置代码页为UTF-8
    -- end
    --更改图像过滤方式，以显示高清马赛克
    print("更改图像过滤方式...")
    love.graphics.setDefaultFilter("nearest", "nearest")
    print("加载动画管理器...")
    AnimManager.init()
    print("加载角色管理器...")
    RoleManager.init()
    print("加载道具管理器...")
    ItemManager.init()
    --加载场景
    print("加主场景...")
    map = sti("scenes/测试地图.lua")

    --创建物理世界
    Game.world = bump.newWorld()
    --实例化角色对象
    ---@type Player
    local player = Player()
    Game.player = player
    --添加到物理世界
    Game.world:add(player, player.x, player.y, player.w, player.h)
    print("游戏初始化完毕!")
end

--每帧逻辑处理
---@param dt number 距离上一帧的间隔时间
function love.update(dt)
    ---碰撞检测
    ---@type number[]
    local destroyPool = {}
    --触发对象更新
    for key, gameObject in pairs(Game.gameObjects) do
        --首先触发对象本身的更新
        if gameObject.load and gameObject.isLoad == false then
            gameObject:load()
            gameObject.isLoad = true
        end
        if gameObject.update then
            gameObject:update(dt)
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
                --触发组件销毁
                if component.onDestroy and gameObject.isDestroy then
                    component:onDestroy()
                end
            end
        end
        if gameObject.isDestroy then
            table.insert(destroyPool, key)
            gameObject:onDestroy()
        end
    end

    for i = #destroyPool, 1, -1 do
        local index = destroyPool[i]
        table.remove(Game.gameObjects, index)
    end
    map:update(dt)
end

-- local function drawDebug()
--     bump_debug.draw(Game.world)

--     local statistics = ("fps: %d, mem: %dKB, collisions: %d, items: %d"):format(love.timer.getFPS(),
--         collectgarbage("count"), cols_len, Game.world:countItems())
--     love.graphics.setColor(1, 1, 1)
--     love.graphics.printf(statistics, 0, 580, 790, 'right')
-- end

local function drawBox(box, r, g, b)
    love.graphics.setColor(r, g, b, 0.25)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
end

local function drawPlayer()
    drawBox(Game.player, 0, 1, 0)
  end

--每帧绘制
function love.draw()
    Camera:set()
    -- Scale world
    drawPlayer()
    local scale = 2

    -- Draw world with translation and scaling
    --绘制地图
    map:draw(0, 0, scale)
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
    end

    Camera:unset()
    Debug.draw()
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
