local Object = require "scripts.base.Object"

---@class Item : Object 道具
---@field id number 道具id
---@field name string 道具名称
---@field description string 道具描述
---@field attrs table<string,number> 影响的属性列表
---@field skills number[] 能学会的技能列表
local Item = Object:extend()

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
    local attrs = self.attrs
    if attrs then
        for key, attr in pairs(attrs) do
            local rk = target[key]
            if rk then
                target[key] = rk + attr
                print(key.."增加了"..attr)
            end
        end
    end
    --学会记述在道具上的技能
    local skills = self.skills
    if skills then
        for _, skill in pairs(skills) do
            target.skills[skill] = skill
            print("学会了:"..skill)
        end
    end
end

---卸载该物品时
---@param target GameObject 卸载道具的对象
function Item:unequip(target)
    --清除道具带来的属性
    local attrs = self.attrs
    if attrs then
        for key, value in pairs(attrs) do
            local curr = target[key]
            if curr then
                target[key] = curr - value
                print(key.."减少了"..value)
            end
        end
    end
    --遗忘记述在道具上的技能
    local skills = self.skills
    if skills then
        for _, skill in pairs(skills) do
            print("遗忘了:"..skill)
        end
    end
end

return Item
