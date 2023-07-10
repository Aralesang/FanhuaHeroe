local Object = require "scripts.base.Object"
---@class Skill : Object 技能基类
---@field id number 技能id
---@field name string 技能名称
---@field description string 技能描述
---@field attrs table<string,number> 影响的属性列表
---@field skills number[] 能学会的技能列表
local Skill = Object:extend()

---使用技能
---@param target GameObject 技能的目标
function Skill:use(target)
    if self.attrs then
        for key, attr in pairs(self.attrs) do
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
            print("学会了:"..skill)
        end
    end
end

return Skill