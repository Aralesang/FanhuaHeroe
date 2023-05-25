---游戏对象基本类
require "scripts.base.Game"
require "scripts.base.Vector2"
---@class GameObject
---@field gameObjectName string 对象名称
---@field position Vector2 对象所在空间坐标{x,y}
---@field scale table 对象缩放比例因子{x,y}
---@field rotate number 对象旋转弧度
---@field components Component[] | nil 组件
---@field load function 对象加载
---@field update function 对象帧更新 参数: dt 与上一帧的时间间隔(毫秒)
---@field isDestroy boolean 销毁标记,持有此标记的对象，将会在本次帧事件的末尾被清除
---@field central Vector2 中心坐标,相对对象0,0坐标的中心坐标位置
GameObject = Object:extend()

---构造函数
---@return GameObject
function GameObject:new()
    self.gameObjectName = ""
    self.position = Vector2.zero()
    self.scale = {x = 1, y = 1}
    self.rotate = 0
    self.components = nil
    self.isDestroy = false
    self.central = Vector2.zero()
    Game.gameObjects[tostring(self)] = self
    return self
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
---@return T
function GameObject:addComponent(componentType)
    ---@type Component
    local component = componentType()
    local componentName = component.componentName
    if componentName == nil then
        error("附加组件失败,目标组件名称为空")
    end
    if self.components == nil then
        self.components = {}
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
---@return T | nil
function GameObject:getComponent(componentType)
    if componentType == nil then
        error("componentType 为空")
    end
    local componentName = componentType.componentName
    if componentName == nil then
        error("目标组件名称为空")
    end
    if self.components == nil then
        return nil
    end
    local component = self.components[componentName]
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