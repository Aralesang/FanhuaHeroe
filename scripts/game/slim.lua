local enemy = require "scripts.game.enemy"
local state = require "scripts.enums.state"
local item_manager = require "scripts.manager.item_manager"

---@class slim:enemy 史莱姆
---@field sight number 视野范围
---@field state number 状态
---@field target game_object 仇恨目标
---@field range number 射程
local slim = Class('slim', enemy)

---构造函数
---@param x number
---@param y number
function slim:initialize(x, y)
    enemy.initialize(self, 2, x, y)
    self.tag = "slim"
    Game:addEnemys(self)
    print("史莱姆坐标:" .. x .. "," .. y)
end

function slim:load()
    self.animation:play("闲置_史莱姆")
    --测试代码：直接将玩家作为仇恨目标
end

---如果进入闲置状态
function slim:idle_state()
    if self.animation:get_anim_name() ~= "闲置_史莱姆" then
        self.animation:play("闲置_史莱姆")
    end
    if self.target == nil then
        self.target = nil
        return
    end
    local distance = self:get_distance(self.target)
    --print(distance)
    --目标进入视野，则向玩家移动
    if distance < self.sight then
        --print("目标进入视野！")
        self:set_state(state.walking)
    end
end

--如果进入移动状态
function slim:walkState(dt)
    local distance = self:get_distance(self.target)
    --目标已丢失
    if distance > self.sight then
        self:set_state(state.idle)
        return
    end

    --目标进入射程
    if distance < self.range then
        --print("目标进入射程！")
        self:set_state(state.attack)
        return
    end

    local dx = math.abs(self.x - self.target.x)
    local dy = math.abs(self.y - self.target.y)
    local angle = math.atan2(dy, dx)
    local x = self.x + math.cos(angle) * self.stats.speed * dt
    local y = self.y + math.sin(angle) * self.stats.speed * dt
    self:move(x, y) --移动
end

---普通攻击
function slim:attackState()
    self.animation:play("攻击_史莱姆", function(index)
        if index == 4 then
            --print("触发伤害帧!")
            --查找所玩家对象，并检查距离
            local player = Game.player
            local dis = self:get_distance(player)
            --在射程内找到一个玩家
            if dis <= self.range then
                --扣除对象的生命值
                player:damage(self, self.stats["atk"])
            end
        end
    end, function()
        self:set_state(state.idle)
    end)
end

---移动
---@param x number
---@param y number
function slim:move(x, y)
    --self.x, self.y = Game.world:move(self, math.floor(x), math.floor(y))
    self.x = math.floor(x)
    self.y = math.floor(y)
    --print("x:" .. self.x .. "y:" .. self.y)
end

---受到伤害
---@param obj game_object
---@param atk number
function slim:on_damage(obj, atk)
    print(self.name .. "受到了" .. obj.name .. "的" .. atk .. "点攻击")
    self:set_state(state.damage)
end

---死亡
function slim:death_state()
    print(self.name .. "死了")
    local sound = love.audio.newSource("audio/sfx/explosion.wav", "stream")
    love.audio.play(sound)
    if self.animation:get_anim_name() ~= "死亡_史莱姆" then
        self.animation:play("死亡_史莱姆", nil, function()
            --在死亡位置创建一个掉落物
            math.randomseed(os.time())
            local itemId = math.random(1, 6)
            --local itemId = 1
            local drop = item_manager:createDrop(itemId, self.x, self.y)
            print("掉落物品:" .. drop.name)
            Game:addVar(3, 1)
            self:destroy()
        end)
    end
end

---受伤状态
function slim:damage_state()
    local sound = love.audio.newSource("audio/sfx/hitHurt.wav", "stream")
    love.audio.play(sound)
    self.animation:play("受伤_史莱姆", nil, function()
        --print("史莱姆挨打结束")
        self:set_state(state.idle)
    end)
end

return slim
