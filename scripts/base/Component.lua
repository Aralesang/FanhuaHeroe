---组件基类
---@class Component
---@field componentName string | nil 组件名称
---@field gameObject GameObject | nil 组件所附加到的游戏物体
---@field isLoad boolean 是否已经调用过初始化函数
Component = {
    componentName = nil,
    gameObject = nil,
    isLoad = false
}

function Component:new()
    ---@type Component
    local o = {}
    setmetatable(o,{__index = self})
    o.isLoad = false
    o.addComponent = self.addComponent
    o.getComponent = self.getComponent
    return o
end

---组件附加到对象后，立即调用一次
function Component:awake()
end

---组件附加到对象后，刷新帧之前调用一次
function Component:load()
end

--组件附加到对象后，每一帧调用一次
---@param delayTime number 距离上一帧的间隔时间
function Component:update(delayTime)
end

---组件附加到对象后，每一帧调用一次，并将帧改变后的图像绘制到屏幕
function Component:draw()
end

--组件销毁前一帧率调用
function Component:onDestroy()
end

---为该组件所附加的游戏对象附加一个新组件
---@generic T : Component
---@param componentType T 组件对象
---@return T
function Component:addComponent(componentType)
    local component = self.gameObject:addComponent(componentType)
    return component
end

---获取该组件所附加的游戏对象上指定的组件对象
---@generic T : Component
---@param componentType T 组件类型
---@return T
function Component:getComponent(componentType)
    local component = self.gameObject:getComponent(componentType)
    return component
end

---键盘按下
---@param key number 键盘键入值
function Component: keypressed(key) 
end

---按键释放
---@param key number 键盘释放的键值
function Component: keyreleased(key)
end