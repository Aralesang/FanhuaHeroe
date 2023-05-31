local JSON = require "scripts.utils.JSON"

---@class AnimJsonData 动画json结构体
---@field id number 动画id
---@field name string 动画名称
---@field path string 动画所用的图像文件路径
---@field xCount number x轴动画数量
---@field yCount number y轴动画数量
AnimJsonData = {}

---@class AnimManager 动画管理器
---@field anims AnimJsonData[] 动画配置列表
AnimManager = {}

function AnimManager.init()
    --加载动画列表
    local file = love.filesystem.read("data/anims.json")
    if file == nil then
         error("动画管理器初始化失败,anims.json失败")
    end
    local json = JSON:decode(file)
    if json == nil then
         error("动画管理器初始化失败,json对象创建失败")
    end
    AnimManager.anims = {}
    ---@cast json AnimJsonData[]
    for _,v in pairs(json) do
        AnimManager.anims[v.id] = v
   end
end

---创建动画对象
---@param id number 要创建的动画id
---@return Anim anim 
function AnimManager.careteAnim(id)
    local temp = AnimManager.anims[id]
    if temp == nil then
        error("目标id的动画不存在:"..id)
    end
    local imagePath = temp.path
    local image = love.graphics.newImage(imagePath)
    if image == nil then
        error("动画图像创建错误:" .. imagePath)
    end
    ---@type Anim
    local anim = Anim(temp.name, image, temp.xCount, temp.yCount)
    return anim
end