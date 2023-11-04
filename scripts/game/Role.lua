local GameObject  = require "scripts.game.game_object"
local State       = require "scripts.enums.state"
local FSM         = require "scripts.game.fsm"
local Direction   = require "scripts.enums.direction"
local RoleManager = require "scripts.manager.role_manager"
local ItemManager = require "scripts.manager.item_manager"
local Equipment   = require "scripts.components.equipment"
local Animation   = require "scripts.components.animation"

---@class Role : game_object 角色对象
---@field stats table<string,number> 玩家属性列表
---@field state State 状态
---@field skills number[] 技能列表
---@field items table<number,number> 道具列表
---@field equips table<string,number> 装备列表
---@field bodys table<string,number> 身体组件列表
---@field equipment Equipment 装备组件
---@field animation Animation 动画组件
local Role        = Class('Role', GameObject)

---构造函数
---@param roleId number
---@param x number
---@param y number
function Role:initialize(roleId, x, y)
    GameObject.initialize(self, x, y)
    self:setState(State.idle)
    self.animation = Animation:new(self)
    self.equipment = Equipment:new(self)
    self.skills = {}
    self.items = {}
    self.stats = {}
    self.equips = {}
    local role = RoleManager:getRole(roleId or 1)
    for k, v in pairs(role) do
        if type(v) ~= "table" and k ~= "hair" then
            self[k] = v
        end
    end
    local stats = role["stats"]
    if stats then
        self.stats = stats
    end
    local skills = role["skills"]
    if skills then
        for _, skill in pairs(skills) do
            self.skills[skill] = skill
        end
    end
    local items = role["items"]
    if items then
        for _, item in pairs(items) do
            local id = tonumber(item.id)
            if not id then
                error("道具配置错误:" .. item.id)
            end
            local num = item.num or 1         --不填num的情况下默认1个
            self.items[id] = num
            local equip = item.equip or false --该道具是否装备到了对象身上
            if equip then
                self.equipment:equip(item.id)
            end
        end
    end
    local hair = role["hair"]
    if hair then
        self.equipment:setHair(hair)
    end
end

---元受伤函数
---@param obj game_object 伤害来源
---@param atk number 攻击力
function Role:damage(obj, atk)
    --如果已经处于死亡或已经在受伤状态，则不会再受伤
    if self.state == State.death or self.state == State.damage then
        return
    end
    local stats = self.stats
    local hp = stats["hp"]
    local hpMax = stats["hpMax"]
    hp = hp - atk
    if hp < 0 then
        hp = 0
    end
    if hp > hpMax then
        hp = hpMax
    end
    stats["hp"] = hp
    if hp == 0 then
        self:setState(State.death)
    end
    self:onDamage(obj, atk)
end

---抽象受伤函数
---@param obj game_object 伤害来源
---@param atk number 攻击力
function Role:onDamage(obj, atk) end

---设置状态
---@param state State
function Role:setState(state)
    FSM.change(self, state)
end

---改变属性值
---@param key string 属性名
---@param value number 属性值
function Role:changeStats(key, value)
    --如果是hp则不能超过hpMax,也不能低于0
    local curr = self.stats[key] or 0
    local newValue = curr + value
    if key == "hp" then
        newValue = math.min(newValue, self.stats["hpMax"])
        if newValue < 0 then
            newValue = 0
        end
    end
    self.stats[key] = newValue
    print(key .. "增加了" .. value)
end

---移动
---@param dt number 距离上一帧的间隔时间
---@param dir direction 移动方向
---@param filter fun(item:table,other:table):filter
---@return table cols, number cols_len
function Role:move(dt, dir, filter)
    local speed = self.stats.speed
    local dx, dy = 0, 0
    --获取移动
    if dir == Direction.Left then
        dx = -speed * dt
    elseif dir == Direction.Right then
        dx = speed * dt
    elseif dir == Direction.Up then
        dy = -speed * dt
    elseif dir == Direction.Down then
        dy = speed * dt
    end

    if dx ~= 0 or dy ~= 0 then
        local cols
        local cols_len = 0
        local x = self.x + dx
        local y = self.y + dy
        self.x, self.y, cols, cols_len = Game.world:move(self, x, y, filter)
        return cols, cols_len
    end
    return {}, 0
end

---添加道具
---@param id number 道具id
---@param num? number 道具数量
function Role:addItem(id, num)
    num = num or 1
    local curNum = self.items[id]
    curNum = curNum or 0
    self.items[id] = curNum + num
    local item = ItemManager:getItem(id)
    print("获得:" .. item.name .. "*" .. num)
end

---去除道具
---@param id number 道具id
---@param num number 道具数量
function Role:removeItem(id, num)
    local curNum = self.items[id]
    curNum = curNum == nil and 0 or curNum
    local newNum = curNum - num
    if newNum <= 0 then
        self.items[id] = nil
    else
        self.items[id] = newNum
    end
end

return Role
