local Vector2 = require "scripts.base.Vector2"
local Direction = require "scripts.enums.Direction"
local State = require "scripts.enums.State"
local Object = require "scripts.base.Object"
local FSM    = require "scripts.game.FSM"

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
---@field speed number 移动速度
---@field hp number 生命值
---@field hpMax number 最大生命值
---@field atk number 攻击力
---@field def number 防御力
---@field state State 状态
local GameObject = Object:extend()

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
    self.speed = 0
    self.hp = 0
    self.hpMax = 0
    self.atk = 0
    self.def = 0
    self.state = State.idle
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
---@return number x, number y
function GameObject:move(dt, dir)
    local x = self.x
    local y = self.y
    --获取移动
    local distance = dt * self.speed
    if dir == Direction.Left then
        x = x - distance
    elseif dir == Direction.Right then
        x = x + distance
    elseif dir == Direction.Up then
        y = y - distance
    elseif dir == Direction.Down then
        y = y + distance
    end

    --self.x,self.y = Game.world:move(self,math.floor(x),math.floor(y))
    self.x = x;
    self.y = y;
    --print("x:"..self.x.."y:"..self.y)
    return self.x, self.y
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

---元受伤函数
---@param obj GameObject 伤害来源
---@param atk number 攻击力
function GameObject:damage(obj, atk)
    --如果已经处于死亡或已经在受伤状态，则不会再受伤
    if self.state == State.death or self.state == State.damage then
        return
    end
    self.hp = self.hp - atk
    if self.hp < 0 then
        self.hp = 0
    end
    if self.hp > self.hpMax then
        self.hp = self.hpMax
    end
    if self.hp == 0 then
        self:setState(State.death)
    end
    self:onDamage(obj, atk)
end

---抽象受伤函数
---@param obj GameObject 伤害来源
---@param atk number 攻击力
function GameObject:onDamage(obj, atk) end

---设置状态
---@param state State
function GameObject:setState(state)
    FSM.change(self,state)
end

return GameObject