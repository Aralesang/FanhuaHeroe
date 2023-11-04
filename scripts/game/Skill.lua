
---@class Skill : class 技能基类
---@field id number 技能id
---@field name string 技能名称
---@field description string 技能描述
---@field stats table<string,number> 影响的属性列表
---@field skills number[] 能学会的技能列表
local Skill = Class('Skill')

---使用技能
---@param target role 技能的目标
function Skill:use(target)
    print("发动:"..self.name)
    if self.stats then
        for key, value in pairs(self.stats) do
            target:changeStats(key,value)
        end
    end
    --学会记述在道具上的技能
    local skills = self.skills

    if skills and target.skills then
        for _, id in pairs(skills) do
            target.skills[id] = id
            print("学会了:"..id)
        end
    end
end

return Skill