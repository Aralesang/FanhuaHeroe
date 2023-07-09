local Component = require "scripts.base.Component"
local AnimationState = require "scripts.enums.AnimaState"
local Anim = require "scripts.base.Anim"
local Direction = require "scripts.enums.Direction"
local AnimManager = require "scripts.manager.AnimManager"

---动画组件
---@class Animation : Component
---@field private state AnimationState 动画状态
---@field private eventList function[] | nil 动画事件字典 关键帧:程序处理器
---@field private anims Anim[] | nil 动画列表
---@field private anim Anim 当前使用的动画对象
---@field private frameTime number 每帧动画间隔
---@field private currentTime number 当前已持续的时间(秒)
---@field private direction Direction 当前动画方向
---@field frameCall fun(index:number) |nil 动画帧回调,每帧开始之前调用
---@field endCall fun()|nil 动画结束回调,动画最后一帧绘制完成时调用
---@field frameIndex number 当前动画帧
local Animation = Component:extend()

--创建一个新的动画对象
---@private
function Animation:new()
    self.frameIndex = -1
    self.eventList = {}
    self.frameTime = 0.25
    self.currentTime = 0
    self.direction = Direction.Down
    self.state = AnimationState.Stop
    self.anims = {}
end

---创建一个动画
---@param name string 动画名称
---@param imagePath string 用于创建动画的序列帧位图地址
---@param frame number 帧数量
function Animation:create(name, imagePath, frame)
    local image = love.graphics.newImage(imagePath)
    if image == nil then
        error("动画图像创建错误:" .. imagePath)
        return
    end
    local animLayer = Anim(name, image, frame)
    self.anims[name] = animLayer
    print("创建动画:[" .. animLayer.name .. "] 图像路径:" .. imagePath)
end

---向动画组件添加一个动画
---@param name string
---@return Anim
function Animation:addAnim(name)
    local anim = AnimManager.careteAnim(name)
    self.anims[name] = anim
    return anim
end

---创建一组动画
---@param names string[] 动画名称列表
function Animation:addAnims(names)
    --构造动画对象
    for _, animName in pairs(names) do
        self:addAnim(animName)
    end
end

---获取一个动画对象
---@param name string 目标动画名称
---@return Anim|nil anim 目标动画对象
function Animation:getAnim(name)
    local anim = self.anims[name]
    --如果动画不存在，则尝试创建
    if anim == nil then
        anim = self:addAnim(name)
    end
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
    local anim = self.anim
    --如果是第一次播放该动画，需立即渲染第0帧
    if self.frameIndex == -1 then
        self:setFrameIndex(0)
    else
        --如果动画当前时间超过单帧持续时间，进入下一帧
        if self.currentTime >= self.frameTime then
            self.currentTime = 0
            --如果加一帧后超过了最大帧数
            if self.frameIndex + 1 >= anim.frame then
                --动画不可以循环的情况下，直接停止
                if not self.anim.loop then
                    self:stop()
                    self.state = AnimationState.Stop
                    if self.endCall then
                        self.endCall()
                    end
                else
                    self:setFrameIndex(0)
                end
            else
                self:setFrameIndex(self.frameIndex + 1)
            end
        end
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
    local x = gameObject.x - self.gameObject.central.x * self.gameObject.scale.x
    local y = gameObject.y - self.gameObject.central.y * self.gameObject.scale.y
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
    self.currentTime = 0
    quad:setViewport(0, anim.row * anim.height, anim.width, anim.height, anim.image:getWidth(), anim.image:getHeight())
end

---设置动画帧
---@private
function Animation:setFrameIndex(frameIndex)
    local anim = self.anim
    if anim == nil then return end
    local quad = anim.quad
    if quad == nil then return end
    if self.frameIndex ~= frameIndex then
        if self.frameCall then
            self.frameCall(frameIndex)
        end
    end
    self.frameIndex = frameIndex
    local row = self.gameObject.direction
    quad:setViewport(self.frameIndex * anim.width, row * anim.height, anim.width, anim.height, anim.image:getWidth(),
        anim.image:getHeight())
end

---检查动画状态
---@param state AnimationState
function Animation:checkState(state)
    return self.state == state
end

---播放动画
---@param name string 要播放的动画名称
---@param frameCall? function 动画帧回调 参数: index 当前的动画帧
---@param endCall? function 动画结束回调
function Animation:play(name, frameCall, endCall)
    local anim = self:getAnim(name)
    if anim == nil then
        error("目标动画不存在:" .. name)
    end
    --如果已经在播放目标动画，则不进行处理
    if self.anim and self.anim.name == name and
        self.state == AnimationState.Playing then
        return
    end
    --print("play:" .. name)
    self.anim = anim
    self.frameIndex = -1
    self.currentTime = 0
    self.state = AnimationState.Playing
    self.frameCall = frameCall
    self.endCall = endCall
end

---停止动画
function Animation:stop()
    self.state = AnimationState.Stop
    self.currentTime = 0
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

return Animation