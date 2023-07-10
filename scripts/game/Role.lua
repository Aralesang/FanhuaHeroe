local GameObject = require "scripts.game.GameObject"
local State = require "scripts.enums.State"
local FSM = require "scripts.game.FSM"
local Animation   = require "scripts.components.Animation"
local Inventory   = require "scripts.components.Inventory"


---@class Role:GameObject 角色对象
---@field speed number 移动速度
---@field hp number 生命值
---@field hpMax number 最大生命值
---@field atk number 攻击力
---@field def number 防御力
---@field state State 状态
---@field skills number[] 技能列表
local Role = GameObject:extend()

---构造函数
---@param x number
---@param y number
function Role:new(x,y)
    self.super:new(x,y)
    self.hp = 0
    self.hpMax = 0
    self.atk = 0
    self.def = 0
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