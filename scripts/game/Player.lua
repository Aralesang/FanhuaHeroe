---@class Player:GameObject 玩家对象
---@field moveDir Direction 移动方向
---@field animation Animation | nil 动画组件
---@field name string | nil 角色名称
---@field speed number 角色速度
---@field equipment Equipment | nil 装备组件
---@field keyList string[] 按键记录
Player = GameObject:extend()

function Player:new()
    self.super:new()
    self.moveDir = Direction.Down
    self.name = "player"
    self.speed = 100
    self.animation = self:addComponent(Animation)
    self.equipment = self:addComponent(Equipment)
    self.x = 50
    self.y = 50
    self.w = 32
    self.h = 32
    self.keyList = {}
end

function Player:load()
    --要创建的动画列表
    local role = RoleManager.getRole(0)
    local anims = role.anims
    --构造动画对象
    for _, animName in pairs(anims) do
        local anim = AnimManager.careteAnim(animName)
        self.animation:addAnim(anim)
    end
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

    local width, height = love.window.getMode()
    local isMove = false
    --寻找最后一个按住的方向键
    for i = #self.keyList, 1, -1 do
        local key = self.keyList[i]
        if key == "up" or key == "down" or
            key == "left" or key == "right" then
            --找到了一个方向键,改变玩家移动状态
            isMove = true
            self:setDir(key)
            break
        end
    end
    Camera:setPosition(self.x - width / 2, self.y - height / 2)

    if isMove then                                   --如果移动被激活
        if self.animation:getAnimName() ~= "行走" then --如果当前动画不是行走，则改为行走
            self.animation:play("行走")
        end
        self:move(dt, self.direction)                --移动
    else                                             --如果没在移动了
        if self.animation:getAnimName() == "行走" then --当前如果正在播放动画，则停止播放并定格到第0帧
            self.animation:play("闲置")
        end
    end
end

---按键检测
---@param key string
function Player:keypressed(key)
    table.insert(self.keyList, key)
    if key == "space" then
        self:attack()
    end
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

---普通攻击
function Player:attack()
    print("普通攻击!")
end

---玩家移动
---@param dt number 距离上一帧的间隔时间
---@param dir Direction 移动方向
function Player:move(dt, dir)
    local x = self.x
    local y = self.y
    --获取移动
    local distance = dt * self.speed
    if dir == Direction.Left then
        x = x - distance
    elseif dir == Direction.Right then
        x = x + distance
    elseif dir == Direction.Up then
        y = y - distance
    elseif dir == Direction.Down then
        y = y + distance
    end
    self.x, self.y = Game.world:move(self,math.floor(x),math.floor(y))
    --print(string.format("%d,%d",self.x,self.y))
end
