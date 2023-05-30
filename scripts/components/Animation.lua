require "scripts.base.Component"
require "scripts.enums.AnimaState"
require "scripts.base.Anim"

---动画组件
---@class Animation : Component
---@field private state AnimationState 动画状态
---@field private eventList function[] | nil 动画事件字典 关键帧:程序处理器
---@field private anims Anim[] | nil 动画列表
---@field private anim Anim 当前使用的动画对象
---@field private duration number 动画持续时间(秒)
---@field private currentTime number 当前已持续的时间(秒)
---@field private direction Direction 当前动画方向
Animation = Component:extend()
Animation.componentName = "Animation"

--创建一个新的动画对象
---@private
function Animation:new()
    self.frameIndex = 0
    self.eventList = nil
    self.duration = 1
    self.currentTime = 0
    self.direction = Direction.Donw
    self.state = AnimationState.Stop
end

---创建一个动画
---@param name string 动画名称
---@param imagePath string 用于创建动画的序列帧位图地址
---@param xCount number x轴帧数量
---@param yCount number y轴帧数量
function Animation:create(name, imagePath, xCount, yCount)
    local image = love.graphics.newImage(imagePath)
    if image == nil then
        error("动画图像创建错误:" .. imagePath)
        return
    end
    ---@type Anim
    local animLayer = Anim(name, image, xCount, yCount)
    if self.anims == nil then
        self.anims = {}
    end
    self.anims[name] = animLayer
    print("创建动画:[" .. animLayer.name .. "] 图像路径:" .. imagePath)
end

---向动画组件添加一个动画
---@param anim Anim
function Animation:addAnim(anim)
    if self.anims == nil then
        self.anims = {}
    end
    self.anims[anim.name] = anim
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
    --更新动画当前时间
    self.currentTime = self.currentTime + dt
    --如果动画当前时间超过动画持续时间，重置动画当前时间
    if self.currentTime >= self.duration then
        self.currentTime = self.currentTime - self.duration
    end
end

function Animation:draw()
    local gameObject = self.gameObject
    if gameObject == nil then
        return
    end
    if self.state ~= AnimationState.Playing then
        return
    end
    --计算当前帧
    local currentFrame = math.floor(self.currentTime / self.duration * self.anim.xCount)
    self:setFrameIndex(currentFrame)
    local position = gameObject:getPosition()
    local x = position.x - self.gameObject.central.x * self.gameObject.scale.x
    local y = position.y - self.gameObject.central.y * self.gameObject.scale.y
    local anim = self.anim
    if anim == nil then
        error("目标动画不存在")
    end
    local image = anim.image
    local quad = anim.quad
    if image == nil or quad == nil then return end
    x = math.floor(x)
    y = math.floor(y)
    love.graphics.draw(image, quad, x, y, gameObject.rotate, gameObject.scale.x, gameObject.scale.y, 0, 0, 0, 0)
end

---设置动画行
---@overload fun(row)
---@param row number 目标动画行
---@param animIndex number 从第几帧开始播放 默认值0
function Animation:setRow(row, animIndex)
    local anim = self.anim
    anim.row = row
    local quad = anim.quad
    if quad == nil then return end
    self.frameIndex = animIndex or 0
    quad:setViewport(0, anim.row * anim.height, anim.width, anim.height, anim.image:getWidth(), anim.image:getHeight())
end

---设置动画帧
---@private
function Animation:setFrameIndex(frameIndex)
    local anim = self.anim
    if anim == nil then return end
    local quad = anim.quad
    if quad == nil then return end
    self.frameIndex = frameIndex
    local row = self.gameObject.direction
    quad:setViewport(self.frameIndex * anim.width, row * anim.height, anim.width, anim.height, anim.image:getWidth(),
        anim.image:getHeight())
    --当前的动画帧
    local key = anim.xCount * row + self.frameIndex
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
---@alias side
---| '"闲置"'
---| '"行走"'
---@param name side 要播放的动画名称
function Animation:play(name)
    self.anim = self:getAnim(name)
    if self.anim == nil then
        error("目标动画不存在")
    end
    self.state = AnimationState.Playing
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
function Animation:addEvent(key, event)
    if self.eventList == nil then
        self.eventList = {}
    end
    self.eventList[key] = event
end

---获取目标帧上的事件
---@private
---@param key number 目标帧
---@return function #事件处理器
function Animation:getEvent(key)
    if self.eventList == nil then
        self.eventList = {}
    end
    return self.eventList[key]
end

---获取当前正在播放的动画名称
---@return string
function Animation:getAnimName()
    if self.anim == nil then
        return ""
    end
    return self.anim.name
end