local JSON = require "scripts.utils.JSON"

---@class SkillManager 技能管理器
---@field skills table<number,Skill>
local SkillManager = {}

function SkillManager.init()
    print("加载技能管理器...")

    --加载模板
    local skillFile = love.filesystem.read("data/skill.json")
    if skillFile == nil then
        error("道具管理器初始化失败,items.json失败")
    end
    ---@type any
    local skillJson = JSON:decode(skillFile)
    if skillJson == nil then
        error("道具管理器初始化失败,item对象创建失败")
    end

    SkillManager.skills = {}

    for _, v in pairs(skillJson) do
        SkillManager.skills[v["id"]] = v
    end

    --注册技能
    SkillManager:batchSkills()
end

---获取技能模板
---@param id number 技能id
---@return Skill
function SkillManager:getItem(id)
    if id == nil then
        error("技能模板id为nil!")
    end
    if self.skills == nil then
        error("技能模板列表为空！")
    end
    local skill = self.skills[id]
    if skill == nil then
        error(string.format("目标id的技能不存在:%d",id))
    end
    return skill
end

function SkillManager:batchSkills()
    
end

return SkillManager