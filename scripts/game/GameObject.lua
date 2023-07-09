local Vector2    = require "scripts.base.Vector2"
local Direction  = require "scripts.enums.Direction"
local State      = require "scripts.enums.State"
local Object     = require "scripts.base.Object"
local FSM        = require "scripts.game.FSM"
local Game       = require "scripts.game.Game"

---游戏对象基本类
---@class GameObject : Object
---@field name string 对象名称
---@field scale table 对象缩放比例因子{x,y}
---@field rotate number 对象旋转弧度
---@field components Component[] | nil 组件
---@field central Vector2 中心坐标,相对对象0,0坐标的中心坐标位置
---@field direction Direction 当前对象方向
---@field isLoad boolean 是否已经调用过load函数
---@field x number 对象空间水平坐标
---@field y number 对象空间垂直坐标
---@field w number 对象宽度
---@field h number 对象高度
local GameObject = Object:extend()

---构造函数
function GameObject:new(x,y,w,h)
    self.name = ""
    self.x = x or 0
    self.y = y or 0
    self.w = w or 0
    self.h = h or 0
    self.scale = { x = 1, y = 1 }
    self.rotate = 0
    self.components = nil
    self.central = Vector2.zero()
    self.direction = Direction.Down
    self.isLoad = false
    self.speed = 0
    self.tag = ""
end

---元方法
---@private
---@vararg function
---@return GameObject
function GameObject:__call(...)
    local obj = setmetatable({}, self)
    ---@cast obj GameObject
    ---@diagnostic disable-next-line: redundant-parameter
    obj:new(...)
    return obj
end

---对象加载
function GameObject:load()

end

---对象更新
---@param delayTime number 距离上一帧的间隔时间
function GameObject:update(delayTime)
end

---图像绘制
function GameObject:draw()
end

--销毁前一帧率调用
function GameObject:onDestroy()
end

---键盘按下
---@param key number 键盘键入值
function GameObject:keypressed(key)
end

---按键释放
---@param key number 键盘释放的键值
function GameObject:keyreleased(key)
end

---设置对象中心点
---@param x number 坐标x
---@param y number 坐标y
function GameObject:setCentral(x, y)
    self.central.x = x
    self.central.y = y
end

---设置对象比例因子
---@param x number x轴比例因子
---@param y number y轴比例因子
function GameObject:setScale(x, y)
    self.scale.x = x
    self.scale.y = y
end

---附加一个组件
---@generic T : Component
---@param componentType T 组件对象
---@return T
function GameObject:addComponent(componentType)
    if componentType == nil then
        error("附加组件失败,组件类型为空")
    end
    if self.components == nil then
        self.components = {}
    end
    ---@type Component
    local component = componentType()
    component.super:new()
    component.gameObject = self
    if component.awake then
        component:awake()
    end
    table.insert(self.components, component)
    return component
end

---获取组件对象
---@generic T : Component
---@param componentType T 组件类型
---@return T | nil
function GameObject:getComponent(componentType)
    if componentType == nil then
        error("componentType 为空")
    end
    for _, v in pairs(self.components) do
        if v:is(componentType) then
            return v
        end
    end
    return nil
end

---对象销毁
function GameObject:destroy()
    Game:removeGameObject(self)
end

---设置对象方向
---@param dir Direction | string 方向
function GameObject:setDir(dir)
    if type(dir) == "string" then
        if dir == "up" then
            self.direction = Direction.Up
        elseif dir == "down" then
            self.direction = Direction.Down
        elseif dir == "left" then
            self.direction = Direction.Left
        elseif dir == "right" then
            self.direction = Direction.Right
        end
    else
        self.direction = dir
    end
end

---移动
---@param dt number 距离上一帧的间隔时间
---@param dir Direction 移动方向
---@param filter fun(item:table,other:table):filter
---@return table cols, number cols_len
function GameObject:move(dt, dir, filter)
    local speed = self.speed
    local dx, dy = 0, 0
    --获取移动
    if dir == Direction.Left then
        dx = -speed * dt
    elseif dir == Direction.Right then
        dx = speed * dt
    elseif dir == Direction.Up then
        dy = -speed * dt
    elseif dir == Direction.Down then
        dy = speed * dt
    end

    if dx ~= 0 or dy ~= 0 then
        local cols
        local cols_len = 0
        local x = self.x + dx
        local y = self.y + dy
        self.x, self.y, cols, cols_len =  Game.world:move(self, x, y, filter)
        return cols, cols_len
    end
    return {},0
end

---获取与目标对象之间的距离
---@param target GameObject
---@return number
function GameObject:getDistance(target)
    --计算距离
    local dx = math.abs(self.x - target.x)
    local dy = math.abs(self.y - target.y)
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance
end

return GameObject
