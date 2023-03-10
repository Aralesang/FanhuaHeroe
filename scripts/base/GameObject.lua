---@type Game
require "scripts.base.Game"
---@class GameObject 游戏对象基本类
---@field gameObjectName string | nil 对象名称
---@field animation Animation | nil 对象动画组件
---@field position Vector2 | nil 对象所在空间坐标{x,y}
---@field scale table | nil 对象缩放比例因子{x,y}
---@field rotate number 对象旋转弧度
---@field components Component[] | nil 组件
---@field load function 对象加载
---@field update function 对象帧更新 参数: dt 与上一帧的时间间隔(毫秒)
---@field isDestroy boolean 销毁标记,持有此标记的对象，将会在本次帧事件的末尾被清除
---@field central Vector2 | nil 中心坐标,相对对象0,0坐标的中心坐标位置
GameObject = {
    gameObjectName = nil,
    animation = nil,
    position = nil,
    scale = {x = 1, y = 1},
    rotate = 0,
    components = nil,
    isDestroy = false,
    central = nil
}

function GameObject:new()
    ---@type GameObject
    local o = {}
    setmetatable(o, {__index = self})
    o.setScale = GameObject.setScale
    o.setPosition = GameObject.setPosition
    o.getPosition = GameObject.getPosition
    o.position = Vector2.zero()
    o.scale = {x = 1, y = 1}
    o.rotate = 0
    o.gameObjectName = tostring(o)
    o.getPosition = GameObject.getPosition
    o.addComponent = GameObject.addComponent
    o.components = {}
    o.getComponent = self.getComponent
    o.destroy = self.destroy
    o.central = Vector2.zero()

    table.insert(Game.gameObjects, o)

    return o
end

---设置对象坐标
---@param x number 世界坐标x
---@param y number 世界坐标y
function GameObject:setPosition(x, y)
    self.position.x = x
    self.position.y = y
end

---设置对象中心点
---@param x number 坐标x
---@param y number 坐标y
function GameObject:setCentral(x, y)
    self.central.x = x
    self.central.y = y
end

---获取对象坐标
---@return Vector2
function GameObject:getPosition()
    return Vector2:new(self.position.x, self.position.y)
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
---@param componentType Component 组件对象
---@return T | nil
function GameObject:addComponent(componentType)
    local component = componentType:new()
    local componentName = component.componentName
    if componentName == nil then
        return nil
    end
    self.components[componentName] = component
    component.gameObject = self
    if component.awake then
        component:awake()
    end
    return component
end

---获取组件对象
---@generic T : Component
---@param componentType Component 组件类型
---@return T
function GameObject:getComponent(componentType)
    local component = self.components[componentType.componentName]
    return component
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