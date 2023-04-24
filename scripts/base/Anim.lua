local Object = require "scripts.base.Object"

Anim = Object:extend()

---动画
---@class Anim
---@field name string | nil 动画名称
---@field image love.Texture | nil 用于创建动画的序列帧位图
---@field xCount number x轴帧数量
---@field yCount number y轴帧数量
---@field quad love.Quad | nil 视图窗口
Anim={
    name = nil, --动画名称
    image = nil, --用于创建动画的序列帧位图
    xCount = 0, --x轴帧数量
    yCount = 0, --y轴帧数量
    quad = nil
}

---构造函数
---@param name string | nil 动画名称
---@param image love.Texture | nil 用于创建动画的序列帧位图
---@param xCount number x轴帧数量
---@param yCount number y轴帧数量
---@return Anim
function Anim:new(name, image, xCount, yCount)
    self.name = name
    self.image = image
    self.xCount = xCount
    self.yCount = yCount
    self.quad = love.graphics.newQuad(0,0,self.width, self.height, self.image:getWidth(), self.image:getHeight())
    return self
end