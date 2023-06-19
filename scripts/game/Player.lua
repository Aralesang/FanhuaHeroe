---@class Player:GameObject 玩家对象
---@field moveDir Direction 移动方向
---@field animation Animation | nil 动画组件
---@field name string | nil 角色名称
---@field speed number 角色速度
---@field equipment Equipment | nil 装备组件
---@field keyList string[] 按键记录
---@field state number 玩家当前状态
Player = GameObject:extend()

--- 状态
local State = {
    idle = 1,    --闲置
    walking = 2, --移动中
    attack = 3   --攻击
}

function Player:new()
    self.super:new()
    self.moveDir = Direction.Down
    self.name = "player"
    self.speed = 100
    self.animation = self:addComponent(Animation)
    self.equipment = self:addComponent(Equipment)
    self.x = 150
    self.y = 50
    self.w = 32
    self.h = 32
    self.keyList = {}
    self.state = State.idle
end

function Player:load()
    --要创建的动画列表
    local role = RoleManager.getRole(0)
    local anims = role.anims
    --构造动画对象
    self.animation:addAnims(anims)
    --播放默认动画
    self.animation:play("闲置")
    --设置头发
    self.equipment:equip("头发", 2)
    --添加装备
    self.equipment:equip("衣服", 3)
    self.equipment:equip("下装", 4)
end

function Player:update(dt)
    if self.animation == nil then
        error("角色对象未找到动画组件")
    end
    if self.equipment == nil then
        error("角色未找到装备组件")
    end
    --同步装备动画
    local frameIndex = self.animation.frameIndex
    local animName = self.animation:getAnimName()
    self.equipment:changeAnim(animName, frameIndex)
    --相机跟随
    local width, height = love.window.getMode()
    Camera:setPosition(self.x - width / 2, self.y - height / 2)
    --有限状态机
    self:stateCheck(dt)
end

---状态检测
function Player:stateCheck(dt)
    if self.state == State.idle then
        self:idleState()
    elseif self.state == State.walking then
        self:moveState(dt)
    elseif self.state == State.attack then
        self:attackState()
    end
end

---如果进入闲置状态
function Player:idleState()
    if self.animation:getAnimName() ~= "闲置" then
        self.animation:play("闲置")
    end
    --处于闲置状态下，此时如果检测到方向键被按下，则进入移动
    --寻找最后一个按住的方向键
    for i = #self.keyList, 1, -1 do
        local key = self.keyList[i]
        --如果按了任何方向键，进入移动状态
        if key == "up" or key == "down" or
            key == "left" or key == "right" then
            self.state = State.walking
            break
        end
        if key == "space" then
            self.state = State.attack
            break
        end
    end
end

--如果进入移动状态
function Player:moveState(dt)
    local isMove = false
    --寻找最后一个按住的方向键
    for i = #self.keyList, 1, -1 do
        local key = self.keyList[i]
        if key == "up" or key == "down" or
            key == "left" or key == "right" then
            --找到了一个方向键,改变玩家移动状态
            self:setDir(key)
            --如果当前动画不是行走，则改为行走
            if self.animation:getAnimName() ~= "行走" then
                self.animation:play("行走")
            end
            self:move(dt, self.direction) --移动
            isMove = true
            break
        end
        if key == "space" then
            self.state = State.attack
            break
        end
    end

    if isMove == false then
        --没有按住任何有功能的按键,回到闲置
        self.state = State.idle
    end
end

---普通攻击
function Player:attackState()
    if self.animation:getAnimName() ~= "挥击" then
        print("普通攻击!")
        ---@param anim Anim
        self.animation:play("挥击",function (anim,index)
            --print("普攻帧事件",index)
            if index == 3 then
                print("触发伤害帧!")
            end
        end,function ()
            self.state = State.idle
        end)
    end
end

---按键检测
---@param key string
function Player:keypressed(key)
    table.insert(self.keyList, key)
end

---按键释放
---@param key string
function Player:keyreleased(key)
    for k, v in pairs(self.keyList) do
        if v == key then
            table.remove(self.keyList, k)
            break
        end
    end
end