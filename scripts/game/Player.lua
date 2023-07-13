local Role         = require "scripts.game.Role"
local Direction    = require "scripts.enums.Direction"
local State        = require "scripts.enums.State"
local Game         = require "scripts.game.Game"
local Animation    = require "scripts.components.Animation"
local SkillManager = require "scripts.manager.SkillManager"
local ItemManager  = require "scripts.manager.ItemManager"

---@class Player : Role 玩家对象
---@field moveDir Direction 移动方向
---@field name string 角色名称
---@field speed number 角色速度
---@field keyList string[] 按键记录
---@field state number 状态
---@field range number 射程
local Player       = Class('Player', Role)

function Player:initialize(x, y)
    Role.initialize(self, 1, x, y)
    self.moveDir = Direction.Down
    self.keyList = {}
    self.x = x
    self.y = y
    self.central = { x = 8, y = 16 }
    Game:addPlayer(self)
end

function Player:load()
    --播放默认动画
    self.animation:play("闲置")
    --设置头发
    self.equipment:setHair(4)
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
end

---如果进入闲置状态
function Player:idleState()
    self.animation:play("闲置")
    --处于闲置状态下，此时如果检测到方向键被按下，则进入移动
    --寻找最后一个按住的方向键
    for i = #self.keyList, 1, -1 do
        local key = self.keyList[i]
        --如果按了任何方向键，进入移动状态
        if key == "up" or key == "down" or
            key == "left" or key == "right" then
            self:setState(State.walking)
            break
        end
        if key == "x" then
            self:setState(State.attack)
            break
        end
    end
end

--如果进入移动状态
function Player:walkState(dt)
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
            local cols
            local cols_len
            cols, cols_len = self:move(dt, self.direction, function(item, other)
                if not other.tag then
                    return "slide"
                end
                --如果是掉落物
                if other.tag == "drop" then
                    return "cross"
                end
                return "slide"
            end) --移动
            for i = 1, cols_len do
                --将接触到的所有掉落物收入库存
                ---@type Drop
                local drop = cols[i].other
                --不是掉落物的跳过
                if drop.tag == "drop" then
                    self:addItem(drop.itemId, drop.itemNum)
                    Game:removeGameObject(drop)
                    print("获得:" .. drop.name)
                end
            end
            isMove = true
            break
        end
        if key == "x" then
            self:setState(State.attack)
            break
        end
    end
    --没有按住任何有功能的按键,回到闲置
    if isMove == false then
        self:setState(State.idle)
    end
end

---普通攻击
function Player:attackState()
    self.animation:play("挥击", function(index)
        if index == 3 then
            print("触发伤害帧!")
            --检查所有的敌对对象
            for _, enemy in pairs(Game.enemys) do
                --敌人与玩家的距离
                local dis = self:getDistance(enemy)
                if dis <= self.stats["range"] then
                    --处于射程中的敌人,调用受伤函数
                    enemy:damage(self, self.stats["atk"])
                end
            end
        end
    end, function()
        self:setState(State.idle)
    end)
end

---受伤状态
function Player:damageState()
    self.animation:play("受伤", nil, function()
        --print("受伤硬直结束")
        self:setState(State.idle)
    end)
end

---死亡
function Player:deathState()
    self.animation:play("死亡", nil, function()
        self:destroy()
        print(self.name .. "已死")
    end)
end

---按键检测
---@param key string
function Player:keypressed(key)
    table.insert(self.keyList, key)
    if key == "q" then
        ItemManager:use(1, self)
    end
    if key == "e" then
        --从库存中寻找装备
        local items = self.items
        for id, num in pairs(items) do
            local item = ItemManager:getItem(id)
            if item.slot then
                self.equipment:equip(id)
            end
        end
    end
    if key == "c" then
        print("=======玩家状态======")
        for key, value in pairs(self.stats) do
            print(key..":"..value)
        end
    end

    if key == "b" then
        print("=======背包======")
        local items = self.items
        for id, num in pairs(items) do
            local item = ItemManager:getItem(id)
            local name = item.name
            if self.equipment:isEquip(id) then
                name = name .. "E"
            end
            print(name,num)
        end
    end
    if key == "k" then
        local skill = SkillManager:getSkill(1, self.skills)
        if not skill then
            print("未掌握技能")
        else
            skill:use(self)
        end
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

---受伤
---@param obj GameObject
---@param atk number
function Player:onDamage(obj, atk)
    print(string.format("hp:%d/%d", self.stats["hp"], self.stats["hpMax"]))
    self:setState(State.damage)
end

return Player
