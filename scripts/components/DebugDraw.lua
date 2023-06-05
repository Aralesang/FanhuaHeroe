require "scripts.base.Component"

---绘制调试组件，用于可视化游戏内的各种坐标和检测范围，方便调试
---@class DebugDraw : Component
---@field drawCentral boolean 是否显示中心点
DebugDraw = Component:extend()

function DebugDraw:new()
end

function DebugDraw:awake()
end

function DebugDraw:load()
end

function DebugDraw:update()
end

function DebugDraw:draw()
    if not Config.ShowCentral then
        return
    end
    local x = self.gameObject:getPosition().x
    local y = self.gameObject:getPosition().y
    --绘制对象中心点
    love.graphics.setColor(0.76, 0.18, 0.05)
    love.graphics.ellipse("fill", x, y, 2, 2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.ellipse("line", x, y, 3, 3)
end
