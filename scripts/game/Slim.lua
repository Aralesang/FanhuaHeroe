local Enemy = require "scripts.game.Enemy"
local State = require "scripts.enums.State"
local RoleManager = require "scripts.manager.RoleManager"
local Animation = require "scripts.components.Animation"
local Game = require "scripts.game.Game"
local ItemManager = require "scripts.manager.ItemManager"

---@class Slim:Enemy 史莱姆
---@field animation Animation 动画组件
---@field sight number 视野范围
---@field state number 状态
---@field target GameObject 仇恨目标
---@field range number 射程
local Slim = Enemy:extend()

---构造函数
---@param x number
---@param y number
function Slim:new(x,y)
    self.super:new(x,y)
    self:setState(State.idle)
    local role = RoleManager.getRole(2)
    for k,v in pairs(role) do
        self[k] = v
    end
    Game:addEnemys(self)
end

function Slim:load()
    self.animation = self:addComponent(Animation)
    self.animation:play("闲置_史莱姆")

    --测试代码：直接将第一个玩家作为仇恨目标
    for _, player in pairs(Game.players) do
        --self.target = player
        break
    end
end

---如果进入闲置状态
function Slim:idleState()
    if self.animation:getAnimName() ~= "闲置_史莱姆" then
        self.animation:play("闲置_史莱姆")
    end
    if self.target == nil or self.target.isDestroy then
        self.target = nil
        return
    end
    local distance = self:getDistance(self.target)
    --print(distance)
    --目标进入视野，则向玩家移动
    if distance < self.sight then
        --print("目标进入视野！")
        self:setState(State.walking)
    end
end

--如果进入移动状态
function Slim:walkState(dt)
    local distance = self:getDistance(self.target)
    --目标已丢失
    if distance > self.sight then
        self:setState(State.idle)
        return
    end

    --目标进入射程
    if distance < self.range then
        --print("目标进入射程！")
        self:setState(State.attack)
        return
    end

    local dx = math.abs(self.x - self.target.x)
    local dy = math.abs(self.y - self.target.y)
    local angle = math.atan2(dy, dx)
    local x = self.x + math.cos(angle) * self.speed * dt
    local y = self.y + math.sin(angle) * self.speed * dt
    self:move(x, y) --移动
end

---普通攻击
function Slim:attackState()
    self.animation:play("攻击_史莱姆", function(index)
        if index == 4 then
            print("触发伤害帧!")
            --查找所有的玩家对象，并检查距离
            for _, v in pairs(Game.players) do
                local dis = self:getDistance(v)
                --在射程内找到一个玩家
                if dis <= self.range then
                    --扣除对象的生命值
                    v:damage(self, self.atk)
                end
            end
        end
    end, function()
        self:setState(State.idle)
    end)
end

---移动
---@param x number
---@param y number
function Slim:move(x, y)
    --self.x, self.y = Game.world:move(self, math.floor(x), math.floor(y))
    self.x = math.floor(x)
    self.y = math.floor(y)
    --print("x:" .. self.x .. "y:" .. self.y)
end

---受到伤害
---@param obj GameObject
---@param atk number
function Slim:onDamage(obj, atk)
    print(self.name.."受到了" .. obj.name .. "的" .. atk .. "点攻击")
    self:setState(State.damage)
end

---死亡
function Slim:deathState()
    if self.animation:getAnimName() ~= "死亡_史莱姆" then
        self.animation:play("死亡_史莱姆", nil, function()
            self:destroy()
             --在死亡位置创建一个掉落物
             math.randomseed(os.time())
             local itemId = math.random(1,6)
             local drop = ItemManager.createDrop(itemId,self.x,self.y)
             print("掉落物品:"..drop.name)
             Game.world:remove(self)
        end)
    end
end

function Slim:onDestroy()
    print(self.name.."死了")
end

---受伤状态
function Slim:damageState()
    self.animation:play("受伤_史莱姆",nil,function ()
        --print("史莱姆挨打结束")
        self:setState(State.idle)
    end)
end

return Slim