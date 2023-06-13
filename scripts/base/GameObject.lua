require "scripts.base.Game"
require "scripts.base.Vector2"
require "scripts.enums.Direction"

---游戏对象基本类
---@class GameObject : Object
---@field name string 对象名称
---@field scale table 对象缩放比例因子{x,y}
---@field rotate number 对象旋转弧度
---@field components Component[] | nil 组件
---@field load function 对象加载
---@field update function 对象帧更新 参数: dt 与上一帧的时间间隔(毫秒)
---@field isDestroy boolean 销毁标记,持有此标记的对象，将会在本次帧事件的末尾被清除
---@field central Vector2 中心坐标,相对对象0,0坐标的中心坐标位置
---@field direction Direction 当前对象方向
---@field isLoad boolean 是否已经调用过load函数
---@field x number 对象空间水平坐标
---@field y number 对象空间垂直坐标
---@field w number 对象宽度
---@field h number 对象高度
GameObject = Object:extend()

---构造函数
function GameObject:new()
    self.name = ""
    self.x = 0
    self.y = 0
    self.w = 0
    self.h = 0
    self.scale = { x = 1, y = 1 }
    self.rotate = 0
    self.components = nil
    self.isDestroy = false
    self.central = Vector2.zero()
    self.direction = Direction.Down
    self.isLoad = false
end

---继承
---@return GameObject
function GameObject:extend()
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
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
    Game:addGameObject(obj)
    return obj
end

---后一帧刷新帧之前调用一次
function GameObject:load()

end

---每一帧调用一次
---@param delayTime number 距离上一帧的间隔时间
function GameObject:update(delayTime)
end

---每一帧调用一次，并将帧改变后的图像绘制到屏幕
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
    local component = componentType()
    component.super:new()
    if self.components == nil then
        self.components = {}
    end
    table.insert(self.components, component)
    component.gameObject = self
    if component.awake then
        component:awake()
    end
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
    if self.components == nil then
        return nil
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
    self.isDestroy = true
end

---碰撞开始回调
---@param collision Collision
function GameObject:onBeginCollision(collision) end

---碰撞结束回调
---@param collision Collision
function GameObject:onEndCollision(collision) end

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
