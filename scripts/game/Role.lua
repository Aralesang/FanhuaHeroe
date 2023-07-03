local GameObject = require "scripts.game.GameObject"
local State = require "scripts.enums.State"
local FSM = require "scripts.game.FSM"

---@class Role:GameObject 角色对象
---@field speed number 移动速度
---@field hp number 生命值
---@field hpMax number 最大生命值
---@field atk number 攻击力
---@field def number 防御力
---@field state State 状态
local Role = GameObject:extend()

function Role:new()
    self.super:new()
    self.hp = 0
    self.hpMax = 0
    self.atk = 0
    self.def = 0
    self.state = State.idle
end

---继承
---@return Role
function Role:extend()
    local cls = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            cls[k] = v
        end
    end
    cls.__index = cls
    cls.super = self
    setmetatable(cls, self)
    return cls
end

---元受伤函数
---@param obj GameObject 伤害来源
---@param atk number 攻击力
function Role:damage(obj, atk)
    --如果已经处于死亡或已经在受伤状态，则不会再受伤
    if self.state == State.death or self.state == State.damage then
        return
    end
    self.hp = self.hp - atk
    if self.hp < 0 then
        self.hp = 0
    end
    if self.hp > self.hpMax then
        self.hp = self.hpMax
    end
    if self.hp == 0 then
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
    FSM.change(self,state)
end

return Role