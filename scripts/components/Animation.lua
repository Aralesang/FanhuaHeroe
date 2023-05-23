require "scripts.base.Component"
require "scripts.enums.AnimaState"
require "scripts.base.Anim"

---动画组件
---@class Animation : Component
---@field private frameInterval number 动画播放帧率间隔
---@field private frameLastCount number 距离上一帧动画已过去的帧数
---@field private frameLastTime number 距离上一帧动画已过去的时间(毫秒)
---@field private state AnimationState 动画状态
---@field private eventList function[] | nil 动画事件字典 关键帧:程序处理器
---@field private anims Anim[] | nil 动画列表
---@field useName string | nil 当前使用的动画名称
Animation = Component:extend()

--创建一个新的动画对象
---@return Animation | Component
function Animation:new ()
    self.xCount = 0
    self.yCount = 0
    self.width = 0
    self.height = 0
    self.row = 0
    self.frameInterval = 0
    self.frameLastCount = 0
    self.frameLastTime = 0
    self.frameIndex = 0
    self.frameCount = 0
    self.quad = nil
    self.eventList = nil
    self.componentName = "Animation"
    return self
end

---创建一个动画
---@param name string 动画名称
---@param imagePath string 用于创建动画的序列帧位图地址
---@param xCount number x轴帧数量
---@param yCount number y轴帧数量
function Animation:create(name,imagePath,xCount,yCount)
    local image = love.graphics.newImage(imagePath)
    if image == nil then
        error("动画图像创建错误:" .. imagePath)
        return
    end
    local animLayer = Anim:new(name,image,xCount,yCount)
    if self.anims == nil then
        self.anims = {}
    end
    self.anims[name] = animLayer
    print("创建动画:["..animLayer.name.."] 图像路径:"..imagePath)
end

---获取当前正在使用的动画
---@param name string 目标动画名称
---@return Anim anim 目标动画对象
function Animation:getAnim(name)
    local anim = self.anims[name]
    return anim
end

---动画帧刷新(按照顺序从左到右播放动画)
---@param dt number 所经过的时间间隔
function Animation:update(dt)
    if self.state ~= AnimationState.Playing then
        return
    end
    self.frameLastCount = self.frameLastCount + 1
    --已经过去的帧数如果低于间隔则不绘制新动画
    if self.frameLastCount < self.frameInterval then
        return
    end
    self.frameLastCount = 0
    --计算出帧所对应的坐标
    local index = self.frameIndex
    self:setFrameIndex(index)
    if index < self.frameCount - 1 then
        index = index + 1
    else
        index = 0
    end
    self.frameIndex = index
end

function Animation:draw()
    local gameObject = self.gameObject
    if gameObject == nil then
        return
    end
    local position = gameObject:getPosition()
    local x = position.x - self.gameObject.central.x * self.gameObject.scale.x
    local y = position.y - self.gameObject.central.y * self.gameObject.scale.y
    if self.useName == nil then
        return
    end
    --根据当前动画名称取出动画对象
    local anim = self.anims[self.useName]
    if anim == nil then
        error("目标动画不存在:"..self.useName)
        return
    end
    local image = anim.image
    local quad = anim.quad
    if image == nil or quad == nil then return end
    x = math.floor(x)
    y = math.floor(y)
    love.graphics.draw(image,quad,x,y,gameObject.rotate,gameObject.scale.x,gameObject.scale.y,0,0,0,0)
end

---设置动画行
---@overload fun(row)
---@param row number 目标动画行
---@param animIndex number 从第几帧开始播放 默认值0
function Animation:setRow(row,animIndex)
    local anim = self:getAnim(self.useName)
    if anim == nil then return end
    anim.row = row
    local quad = anim.quad
    if quad == nil then return end
    self.frameIndex = animIndex or 0
    quad:setViewport(0, anim.row * anim.height, anim.width, anim.height, anim.image:getWidth(), anim.image:getHeight())
end

---设置动画帧
function Animation:setFrameIndex(frameIndex)
    local anim = self:getAnim(self.useName)
    if anim == nil then return end
    local quad = anim.quad
    if quad == nil then return end
    anim.frameIndex = frameIndex
    quad:setViewport(anim.frameIndex * anim.width, anim.row * anim.height, anim.width, anim.height, anim.image:getWidth(), anim.image:getHeight())
    --当前的动画帧
    local key = anim.xCount * anim.row + anim.frameIndex
    --触发动画帧事件
    local event = self:getEvent(key)
    if event then
        event()
    end
end

---检查动画状态
---@param state AnimationState
function Animation:checkState(state)
    return self.state == state
end

---播放动画
---@param name string 要播放的动画名称
function Animation:play(name)
    print("play:"..name)
    self.useName = name
    self.state = AnimationState.Playing
    self:setFrameIndex(0)
end

---停止动画
---@overload fun()
---@param frameIndex number 指定停止后显示的动画帧 默认值: 当前动画帧下标
function Animation:stop(frameIndex)
    frameIndex = frameIndex or self.frameIndex
    self.state = AnimationState.Stop
    self:setFrameIndex(frameIndex)
end

---暂停动画
function Animation:pause()
    self.state = AnimationState.Pause
end

---继续上一次暂定的帧和时间继续播放
function Animation:continue()
    self.state = AnimationState.Playing
end

---向动画帧添加事件
---@param key number 动画帧
---@param event function 事件处理器
function Animation:addEvent(key,event)
    if self.eventList == nil then
        self.eventList = {}
    end
    self.eventList[key] = event
end

---获取目标帧上的事件
---@param key number 目标帧
---@return function #事件处理器
function Animation:getEvent(key)
    if self.eventList == nil then
        self.eventList = {}
    end
    return self.eventList[key]
end