local JSON = require "scripts.utils.JSON"
local Anim = require "scripts.base.Anim"

---@class AnimJsonData 动画json结构体
---@field name string 动画名称
---@field path string 动画所用的图像文件路径
---@field frame number 动画数量
---@field loop boolean 是否循环
local AnimJsonData = {}

---@class AnimManager 动画管理器
---@field anims AnimJsonData[] 动画配置列表
local AnimManager = {}

function AnimManager.init()
    --加载动画列表
    print("加载动画管理器...")
    local file = love.filesystem.read("data/anim.json")
    if file == nil then
        error("动画管理器初始化失败,anims.json失败")
    end
    local json = JSON:decode(file)
    if json == nil then
        error("动画管理器初始化失败,json对象创建失败")
    end
    AnimManager.anims = {}
    ---@cast json AnimJsonData[]
    for _, v in pairs(json) do
        AnimManager.anims[v.name] = v
    end
end

---创建动画对象
---@param name string 动画名称
---@return Anim anim
function AnimManager.careteAnim(name)
    local temp = AnimManager.anims[name]
    if temp == nil then
        error("目标动画不存在:" .. name)
    end
    local imagePath = temp.path
    local image = love.graphics.newImage(imagePath)
    if image == nil then
        error("动画图像创建错误:" .. imagePath)
    end
    local anim = Anim(temp.name, image, temp.frame, temp.loop)
    return anim
end

---获取动画模板
---@param name string 动画名称
---@return AnimJsonData
function AnimManager.getAnim(name)
    local anim = AnimManager.anims[name]
    if anim == nil then
        error("目标动画不存在" .. name)
    end
    return anim
end

return AnimManager
