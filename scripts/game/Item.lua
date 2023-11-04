
---@class item : class 道具
---@field id number 道具id
---@field name string 道具名称
---@field description string 道具描述
---@field stats table<string,number> 影响的属性列表
---@field skills number[] 能学会的技能列表
---@field slot string 可以装备到哪个槽
---@field icon string 道具的图像路径
local Item = Class('Item')

---构造函数
function Item:new()
    self.id = 0
    self.name = ""
    self.description = ""
end

---使用该物品
---@param target Role 使用道具的对象
function Item:use(target)
    --增加记述在道具上的属性
    local stats = self.stats
    if stats then
        for key, value in pairs(stats) do
            target:changeStats(key,value)
        end
    end
    --学会记述在道具上的技能
    local skills = self.skills

    if skills and target.skills then
        for _, id in pairs(skills) do
            target.skills[id] = id
            print(target.name .. " 学会了:"..id)
        end
    end
end

---装备该物品时
---@param target Role 装备的对象
function Item:equip(target)
    --如果没有装备槽则无法装备
    if not self.slot then
        print("该道具无法装备")
        return
    end
    self:use(target)
    --如果是装备,则穿到玩家身上
    target.equips[self.slot] = self.id
    print(target.name .. " 装备:"..self.name)
end

---卸载该物品时
---@param target Role 卸载道具的对象
function Item:unequip(target)
    --如果没有装备槽则无法装备
    if not self.slot then
        print("该道具无法卸载")
        return
    end
    print(target.name .. " 卸除:"..self.name)
    --清除道具带来的属性
    local stats = self.stats
    if stats then
        for key, value in pairs(stats) do
            target:changeStats(key,-value)
        end
    end
    --遗忘记述在道具上的技能
    local skills = self.skills
    if skills then
        for _, id in pairs(skills) do
            target.skills[id] = nil
            print(target.name .. " 遗忘了:"..id)
        end
    end
    target.equips[self.slot] = 0
end

return Item
