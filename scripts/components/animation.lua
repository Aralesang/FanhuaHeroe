local animation_state = require "scripts.enums.anima_state"
local anim = require "scripts.base.anim"
local direction = require "scripts.enums.direction"
local AnimManager = require "scripts.manager.anim_manager"
local component   = require "scripts.base.component"

---动画组件
---@class animation : component
---@field private state animation_state 动画状态
---@field private event_list function[] | nil 动画事件字典 关键帧:程序处理器
---@field private anims anim[] | nil 动画列表
---@field private anim anim 当前使用的动画对象
---@field private frame_time number 每帧动画间隔
---@field private current_time number 当前已持续的时间(秒)
---@field private direction direction 当前动画方向
---@field frame_call fun(index:number) |nil 动画帧回调,每帧开始之前调用
---@field end_call fun()|nil 动画结束回调,动画最后一帧绘制完成时调用
---@field private frame_index number 当前动画帧
local animation = Class('Animation')

--创建一个新的动画对象
---@private
function animation:initialize(target)
    component.initialize(self,target)
    self.frame_index = -1
    self.event_list = {}
    self.frame_time = 0.1
    self.current_time = 0
    self.direction = direction.Down
    self.state = animation_state.stop
    self.anims = {}
end

---创建一个动画
---@param name string 动画名称
---@param imagePath string 用于创建动画的序列帧位图地址
---@param frame number 帧数量
function animation:create(name, imagePath, frame)
    local image = love.graphics.newImage(imagePath)
    if image == nil then
        error("动画图像创建错误:" .. imagePath)
        return
    end
    local animLayer = anim(name, image, frame)
    self.anims[name] = animLayer
    print("创建动画:[" .. animLayer.name .. "] 图像路径:" .. imagePath)
end

---向动画组件添加一个动画
---@param name string
---@return anim
function animation:add_anim(name)
    local anim = AnimManager.careteAnim(name)
    self.anims[name] = anim
    return anim
end

---创建一组动画
---@param names string[] 动画名称列表
function animation:add_anims(names)
    --构造动画对象
    for _, animName in pairs(names) do
        self:add_anim(animName)
    end
end

---获取一个动画对象
---@param name string 目标动画名称
---@return anim|nil anim 目标动画对象
function animation:get_anim(name)
    local anim = self.anims[name]
    --如果动画不存在，则尝试创建
    if anim == nil then
        anim = self:add_anim(name)
    end
    return anim
end

---动画帧刷新(按照顺序从左到右播放动画)
---@param dt number 所经过的时间间隔
function animation:update(dt)
    if self.state ~= animation_state.playing then
        return
    end
    --更新动画当前时间
    self.current_time = self.current_time + dt
    local anim = self.anim
    --如果是第一次播放该动画，需立即渲染第0帧
    if self.frame_index == -1 then
        self:set_frame_index(0)
    else
        --如果动画当前时间超过单帧持续时间，进入下一帧
        if self.current_time >= self.frame_time then
            self.current_time = 0
            --如果加一帧后超过了最大帧数
            if self.frame_index + 1 >= anim.frame then
                --动画不可以循环的情况下，直接停止
                if not self.anim.loop then
                    self:stop()
                    self.state = animation_state.stop
                    if self.end_call then
                        self.end_call()
                    end
                else
                    self:set_frame_index(0)
                end
            else
                self:set_frame_index(self.frame_index + 1)
            end
        end
    end
end

function animation:draw()
    local game_object = self.game_object
    if game_object == nil then
        return
    end
    if self.state ~= animation_state.playing then
        return
    end
    local x = game_object.x - self.game_object.central.x * self.game_object.scale.x
    local y = game_object.y - self.game_object.central.y * self.game_object.scale.y
    local anim = self.anim
    if anim == nil then
        error("目标动画不存在")
    end
    local image = anim.image
    local quad = anim.quad
    if image == nil or quad == nil then return end
    x = math.floor(x)
    y = math.floor(y)
    love.graphics.draw(image, quad, x, y, game_object.rotate, game_object.scale.x, game_object.scale.y, 0, 0, 0, 0)
end

---设置动画行
---@overload fun(row)
---@param row number 目标动画行
---@param animIndex number 从第几帧开始播放 默认值0
function animation:set_row(row, animIndex)
    local anim = self.anim
    anim.row = row
    local quad = anim.quad
    if quad == nil then return end
    self.frame_index = animIndex or 0
    self.current_time = 0
    quad:setViewport(0, anim.row * anim.height, anim.width, anim.height, anim.image:getWidth(), anim.image:getHeight())
end

---设置动画帧
---@private
function animation:set_frame_index(frame_index)
    local anim = self.anim
    if anim == nil then return end
    local quad = anim.quad
    if quad == nil then return end
    if self.frame_index ~= frame_index then
        if self.frame_call then
            self.frame_call(frame_index)
        end
    end
    self.frame_index = frame_index
    local row = self.game_object.direction
    quad:setViewport(self.frame_index * anim.width, row * anim.height, anim.width, anim.height, anim.image:getWidth(),
        anim.image:getHeight())
end

---检查动画状态
---@param state animation_state
function animation:check_state(state)
    return self.state == state
end

---播放动画
---@param name string 要播放的动画名称
---@param frameCall? function 动画帧回调 参数: index 当前的动画帧
---@param endCall? function 动画结束回调
function animation:play(name, frameCall, endCall)
    local anim = self:get_anim(name)
    if anim == nil then
        error("目标动画不存在:" .. name)
    end
    --如果已经在播放目标动画，则不进行处理
    if self.anim and self.anim.name == name and
        self.state == animation_state.playing then
        return
    end
    --print("play:" .. name)
    self.anim = anim
    self.frame_index = -1
    self.current_time = 0
    self.state = animation_state.playing
    self.frame_call = frameCall
    self.end_call = endCall
end

---停止动画
function animation:stop()
    self.state = animation_state.stop
    self.current_time = 0
end

---暂停动画
function animation:pause()
    self.state = animation_state.Pause
end

---继续上一次暂定的帧和时间继续播放
function animation:continue()
    self.state = animation_state.playing
end

---向动画帧添加事件
---@param key number 动画帧
---@param event function 事件处理器
function animation:add_event(key, event)
    if self.event_list == nil then
        self.event_list = {}
    end
    self.event_list[key] = event
end

---获取目标帧上的事件
---@private
---@param key number 目标帧
---@return function 事件处理器
function animation:get_event(key)
    if self.event_list == nil then
        self.event_list = {}
    end
    return self.event_list[key]
end

---获取当前正在播放的动画名称
---@return string | nil
function animation:get_anim_name()
    if self.anim == nil then
        return nil
    end
    return self.anim.name
end

---获取当前动画帧
function animation:get_frame()
    return self.frame_index
end

return animation