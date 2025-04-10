local role         = require "scripts.game.role"
local state        = require "scripts.enums.state"
local skill_manager = require "scripts.manager.skill_manager"
local item_manager  = require "scripts.manager.item_manager"
---@type bag
local bag          = require "scripts.game.bag"

---@class player : role 玩家对象
---@field nickname string 角色名称
---@field key_list string[] 按键记录
---@field range number 射程
local player       = Class('Player', role)

function player:initialize(x, y)
    role.initialize(self, 1, x, y)
    self.tag = "Player"
    self.key_list = {}
    self.central = { x = 8, y = 16 }
    Game:addPlayer(self)
end

function player:load()
    --播放默认动画
    self.animation:play("闲置")
end

function player:update(dt)
    if self.animation == nil then
        error("角色对象未找到动画组件")
    end
    if self.equipment == nil then
        error("角色未找到装备组件")
    end
    
end

---如果进入闲置状态
function player:idle_state()
    self.animation:play("闲置")
    --处于闲置状态下，此时如果检测到方向键被按下，则进入移动
    --寻找最后一个按住的方向键
    for i = #self.key_list, 1, -1 do
        local key = self.key_list[i]
        --如果按了任何方向键，进入移动状态
        if key == "up" or key == "down" or
            key == "left" or key == "right" then
            self:set_state(state.walking)
            break
        end
        if key == "x" then
            self:set_state(state.attack)
            self:attack_state()
            break
        end
    end
end

--如果进入移动状态
function player:walk_state(dt)
    local isMove = false
    --寻找最后一个按住的方向键
    for i = #self.key_list, 1, -1 do
        local key = self.key_list[i]
        if key == "up" or key == "down" or
            key == "left" or key == "right" then
            --找到了一个方向键,改变玩家移动状态
            self:set_dir(key)
            --如果当前动画不是行走，则改为行走
            if self.animation:get_anim_name() ~= "行走" then
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
            --print(self.x,self.y)
            for i = 1, cols_len do
                --将接触到的所有掉落物收入库存
                ---@type Drop
                local drop = cols[i].other
                --不是掉落物的跳过
                if drop.tag == "drop" then
                    self:add_item(drop.itemId, drop.itemNum)
                    Game:remove_game_object(drop)
                end
            end
            isMove = true
            break
        end
        if key == "x" then
            if self:set_state(state.attack) then
                self:attack_state()
            end
            break
        end
    end
    --没有按住任何有功能的按键,回到闲置
    if isMove == false then
        self:set_state(state.idle)
    end
end

---普通攻击
function player:attack_state()
    print("普通攻击")
    self.animation:play("挥击", function(index)
        if index == 3 then
            print("触发伤害帧!")
            --检查所有的敌对对象
            for _, enemy in pairs(Game.enemys) do
                --敌人与玩家的距离
                local dis = self:get_distance(enemy)
                if dis <= self.stats["range"] then
                    --处于射程中的敌人,调用受伤函数
                    enemy:damage(self, self.stats["atk"])
                end
            end
        end
    end, function()
        self:set_state(state.idle)
    end)
end

---受伤状态
function player:damage_state()
    self.animation:play("受伤", nil, function()
        --print("受伤硬直结束")
        self:set_state(state.idle)
    end)
end

---死亡
function player:death_state()
    self.animation:play("死亡", nil, function()
        self:destroy()
        print(self.nickname .. "已死")
    end)
end

---按键检测
---@param key string
function player:keypressed(key)
    table.insert(self.key_list, key)
    if key == "q" then
        item_manager:use(1, self)
    end
    if key == "e" then
        --从库存中寻找装备
        local items = self.items
        for id, num in pairs(items) do
            local item = item_manager:getItem(id)
            if item.slot then
                self.equipment:equip(id)
            end
        end
    end
    if key == "c" then
        print("=======玩家状态======")
        for key, value in pairs(self.stats) do
            print(key .. ":" .. value)
        end
    end

    if key == "b" then
        bag:show()
    end
    if key == "k" then
        local skill = skill_manager:getSkill(2, self.skills)
        if not skill then
            print("未掌握技能")
        else
            skill:use(self)
        end
    end
    if key == "f" then
        local touch = self:get_operate()
        if touch ~= nil and touch.tag == "Npc" then
            ---@cast touch npc
            touch:talk(self)
        end
    end
end

---按键释放
---@param key string
function player:keyreleased(key)
    for k, v in pairs(self.key_list) do
        if v == key then
            table.remove(self.key_list, k)
            break
        end
    end
end

---受伤
---@param obj game_object
---@param atk number
function player:on_damage(obj, atk)
    print(string.format("hp:%d/%d", self.stats["hp"], self.stats["hpMax"]))
    self:set_state(state.damage)
end

return player
