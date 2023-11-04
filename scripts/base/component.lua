
---组件基类
---@class component:class
---@field game_object game_object 组件所附加到的游戏物体
---@field isLoad boolean 是否已经调用过初始化函数
local component = Class('Component')

function component:initialize(target)
  self.game_object = target
  self.isLoad = false
end

---组件附加到对象后，立即调用一次
function component:awake()
end

---组件附加到对象后，后一帧刷新帧之前调用一次
function component:load()
end

--组件附加到对象后，每一帧调用一次
---@param delayTime number 距离上一帧的间隔时间
function component:update(delayTime)
end

---组件附加到对象后，每一帧调用一次，并将帧改变后的图像绘制到屏幕
function component:draw()
end

---键盘按下
---@param key number 键盘键入值
function component:keypressed(key)
end

---按键释放
---@param key number 键盘释放的键值
function component:keyreleased(key)
end

return component