local GameObject = require "scripts.game.GameObject"
local State      = require "scripts.enums.State"
local FSM        = require "scripts.game.FSM"
local Direction  = require "scripts.enums.Direction"
local Game       = require "scripts.game.Game"

---@class Role:GameObject 角色对象
---@field stats table 玩家属性
---@field state State 状态
---@field skills number[] 技能列表
local Role = GameObject:extend()

---构造函数
---@param x number
---@param y number
function Role:new(x, y)
    self.super:new(x, y)
    self.state = State.idle
    self.skills = {}
end

---元受伤函数
---@param obj GameObject 伤害来源
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
        stats["hp"] = hpMax
    end
    if hp == 0 then
        self:setState(State.death)
    end
    self:onDamage(obj, atk)
end

---抽象受伤函数
---@param obj GameObject 伤害来源
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
    local curr = self.stats[key]
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
---@param dir Direction 移动方向
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
        self.x, self.y, cols, cols_len =  Game.world:move(self, x, y, filter)
        return cols, cols_len
    end
    return {},0
end

return Role
