local Vector2    = require "scripts.base.Vector2"
local Direction  = require "scripts.enums.Direction"
local Game       = require "scripts.game.Game"

---游戏对象基本类
---@class GameObject:Class
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
local GameObject = Class("GameObject")
---构造函数
function GameObject:initialize(x,y,w,h)
    self.name = ""
    self.x = x or 0
    self.y = y or 0
    self.w = w or 0
    self.h = h or 0
    self.scale = { x = 1, y = 1 }
    self.rotate = 0
    self.components = {}
    self.central = Vector2.zero()
    self.direction = Direction.Down
    self.isLoad = false
    self.speed = 0
    self.tag = ""
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
    ---@type Component
    local component = componentType(self)
    if component.awake then
        component:awake()
    end
    self.components[component.class.name] = component
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
    return self.components[componentType.name]
end

---对象销毁
function GameObject:destroy()
    self:onDestroy()
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
