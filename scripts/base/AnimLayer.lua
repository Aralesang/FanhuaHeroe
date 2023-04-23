local Object = require "scripts.base.Object"

AnimLayer = Object:extend()

---动画层
---@class AnimLayer
---@field name string | nil 动画名称
---@field image love.Texture | nil 用于创建动画的序列帧位图
---@field xCount number x轴帧数量
---@field yCount number y轴帧数量
AnimLayer={
    name = nil, --动画名称
    image = nil, --用于创建动画的序列帧位图
    xCount = 0, --x轴帧数量
    yCount = 0, --y轴帧数量
}

function AnimLayer:new(name, image, xCount, yCount)
    self.name = name
    self.image = image
    self.xCount = xCount
    self.yCount = yCount
end