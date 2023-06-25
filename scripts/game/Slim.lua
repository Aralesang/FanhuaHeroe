---@class Slim:GameObject 史莱姆
---@field animation Animation 动画组件
---@field sight number 视野范围
---@field state number 状态
---@field target GameObject 仇恨目标
---@field range number 射程
Slim = GameObject:extend()

function Slim:new()
    self.super:new()
    self.state = State.idle
    self.sight = 100
    self.speed = 100
    self.x = 50
    self.y = 50
    self.w = 16
    self.h = 16
    self.hp = 2
    self.hpMax = 2
    self.range = 16
end

function Slim:load()
    self.animation = self:addComponent(Animation)
    local role = RoleManager.getRole(1)
    self.animation:addAnims(role.anims)
    self.animation:play("闲置_史莱姆")
    --测试代码：直接将玩家作为仇恨目标
    self.target = Game.player
    Game:addEnemy(self)
end

function Slim:update(dt)
    --print("x:"..self.x.."y:"..self.y)
    self:stateCheck(dt)
end

---状态检测
function Slim:stateCheck(dt)
    if self.state == State.idle then
        self:idleState()
    elseif self.state == State.walking then
        self:moveState(dt)
    elseif self.state == State.attack then
        self:attackState()
    elseif self.state == State.death then
        self:deathState()
    end
end

---如果进入闲置状态
function Slim:idleState()
    if self.animation:getAnimName() ~= "闲置_史莱姆" then
        self.animation:play("闲置_史莱姆")
    end
    local distance = GameObject.getDistance(self,Game.player)
    --如果距离小于视野，则向玩家移动
    if distance < self.sight then
        self.state = State.walking
    end
end

--如果进入移动状态
function Slim:moveState(dt)
    local distance = GameObject.getDistance(self,Game.player)
    --目标已丢失
    if distance > self.sight then
        self.state = State.idle
        return
    end

    --目标进入射程
    -- if distance < self.range then
    --     self.state = State.attack
    --     return
    -- end

    -- local dx = self.x - self.target.x
    -- local dy = self.y - self.target.y
    -- local angle = math.atan2(dy,dx)
    -- local x = self.x + math.cos(angle) * self.speed * dt
    -- local y = self.y + math.sin(angle) * self.speed * dt
    -- self:move(x ,y) --移动
end

---普通攻击
function Slim:attackState()
    if self.animation:getAnimName() ~= "攻击_史莱姆" then
        print("普通攻击!")
        ---@param anim Anim
        self.animation:play("攻击_史莱姆",function (anim,index)
            if index == 2 then
                print("触发伤害帧!")
                --扣除对象的生命值
                Game.player.hp = Game.player.hp - self.atk
            end
        end)
    end
end

---移动
---@param x number
---@param y number
function Slim:move(x,y)
    self.x,self.y = Game.world:move(self,math.floor(x),math.floor(y))
end

---受到伤害
---@param obj GameObject
---@param atk number
function Slim:damage(obj,atk)
    print("我受到了"..obj.name.."的"..atk.."点攻击")
end

---死亡
function Slim:deathState()
    if self.animation:getAnimName() ~= "死亡_史莱姆" then
        self.animation:play("死亡_史莱姆", nil, function (_,index)
            self:destroy()
        end)
    end
end