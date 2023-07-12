local JSON = require "scripts.utils.JSON"
local Skill = require "scripts.game.Skill"

---@class SkillManager 技能管理器
---@field skills table<number,Skill>
local SkillManager = {}

function SkillManager:init()
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

    self.skills = {}

    for _, v in pairs(skillJson) do
        ---@type Skill
        local skill = Skill()
        for k, v2 in pairs(v) do
            skill[k] = v2
        end
        self.skills[skill.id] = skill
    end

    --注册技能
    self:batchSkills()
end

---根据id获取技能
---@param id number 技能id
---@param filter? number[] 过滤器,如果填写此参数,则仅从此参数范围内选择
---@return Skill|nil
function SkillManager:getSkill(id, filter)
    if id == nil then
        return nil
    end
    if self.skills == nil then
        error("技能模板列表为空！")
    end
    if filter then
        local isOk = false
        for _, value in pairs(filter) do
            if value == id then
                isOk = true
                break
            end
        end
        if not isOk then
            return nil
        end
    end
    local skill = self.skills[id]
    if skill == nil then
        error(string.format("目标id的技能不存在:%d", id))
    end
    return skill
end

function SkillManager:batchSkills()

end

return SkillManager
