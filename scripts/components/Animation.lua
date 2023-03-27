require "scripts.base.Component"
require "scripts.enums.AnimaState"

---动画组件
---@class Animation : Component
---@field image love.Texture | nil 用于创建动画的序列帧位图
---@field width number 单帧对象宽度
---@field height number 单帧对象高度
---@field quad table | nil 视图窗口
---@field frameIndex number 当前动画帧下标
---@field frameCount number 帧总数量
---@field row number 当前所使用的动画行
---@field frameInterval number 动画播放帧率间隔
---@field frameLastCount number 距离上一帧动画已过去的帧数
---@field xCount number x轴帧数量
---@field yCount number y轴帧数量
---@field private state AnimationState 动画状态
---@field eventList function[] | nil 动画事件字典 关键帧:程序处理器
Animation = {
    image = nil, --用于创建动画的序列帧位图
    width = 0, --单帧对象宽度
    height = 0, --单帧对象高度
    quad = nil, --视图窗口
    frameInterval = 0, --动画播放帧率间隔
    frameLastCount = 0, --当前动画帧所经过的帧率
    frameCount = 0, --帧数
    row = 0, --当前所使用的动画行
    xCount = 0, --x轴帧数量
    yCount = 0, --y轴帧数量
    state = AnimationState.Stop, --动画状态
    componentName = "Animation",
    eventList = nil --事件列表
}

function Animation:load()

end

function Animation:draw()
    local gameObject = self.gameObject
    if gameObject == nil then
        return
    end
    local position = gameObject:getPosition()
    local x = position.x - self.gameObject.central.x * self.gameObject.scale.x
    local y = position.y - self.gameObject.central.y * self.gameObject.scale.y
    self:drawAnimation(x, y, gameObject.rotate, gameObject.scale.x, gameObject.scale.y,0,0)
end

--创建一个新的动画对象
---@return Animation | Component
function Animation:new ()
    ---@type Animation | Component
    local o = Component:new()
    setmetatable(o,{__index=self})
    o.image = nil
    o.xCount = 0
    o.yCount = 0
    o.width = 0
    o.height = 0
    o.row = 0
    o.frameInterval = 0
    o.frameLastCount = 0
    o.frameIndex = 0
    o.frameCount = 0
    o.quad = nil
    o.eventList = nil
    return o
end

--动画组件初始化
---@overload fun (image,xCount,yCount,frameInterval)
---@param image love.Texture 用于创建动画的序列帧位图
---@param xCount number x轴帧数量
---@param yCount number y轴帧数量
---@param frameInterval number 动画播放帧率间隔
---@param row number 当前所使用的动画行
function Animation:init(image,xCount,yCount,frameInterval,row)
    self.image = image or {}
    self.xCount = xCount or 0
    self.yCount = yCount or 0
    self.width = self.image:getWidth() / self.xCount
    self.height = self.image:getHeight() / self.yCount
    self.row = row or 0
    self.frameInterval = frameInterval or 0
    self.frameCount = self.image:getWidth() / self.width
    self.quad = love.graphics.newQuad(0,self.row * self.height,self.width, self.height, self.image:getWidth(), self.image:getHeight())
end

---绘制动画图像
---@param x number 绘制对象的位置(x轴)
---@param y number 绘制对象的位置(y轴)
---@param r number 旋转弧度
---@param sx number 比例因子(x轴)
---@param sy number 比例因子(y轴)
---@param ox number 原点偏移(x轴)
---@param oy number 原点偏移(y轴)
function Animation:drawAnimation(x,y,r,sx,sy,ox,oy,kx,ky)
    local image = self.image
    local quad = self.quad
    if image == nil or quad == nil then return end
    love.graphics.draw(image,quad,x,y,r,sx,sy,ox,oy,kx,ky)
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

---设置动画行
---@overload fun(row)
---@param row number 目标动画行
---@param animIndex number 从第几帧开始播放 默认值0
function Animation:setRow(row,animIndex)
    self.row = row
    self.frameIndex = animIndex or 0
    self.quad:setViewport(0, self.row * self.height, self.width, self.height, self.image:getWidth(), self.image:getHeight())
end

---设置动画帧
function Animation:setFrameIndex(frameIndex)
    self.frameIndex = frameIndex
    self.quad:setViewport(self.frameIndex * self.width, self.row * self.height, self.width, self.height, self.image:getWidth(), self.image:getHeight())
    --当前的动画帧
    local key = self.xCount * self.row + self.frameIndex
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
---@overload fun()
---@param frameIndex number 指定开始播放的第一帧 默认值: 0
function Animation:play(frameIndex)
    frameIndex = frameIndex or 0
    self.state = AnimationState.Playing
    self:setFrameIndex(frameIndex)
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