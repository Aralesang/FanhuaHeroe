local Object = require "scripts.base.Object"

---动画
---@class Anim
---@field name string | nil 动画名称
---@field image love.Texture | nil 用于创建动画的序列帧位图
---@field xCount number x轴帧数量
---@field yCount number y轴帧数量
---@field width number 单帧动画的宽度
---@field height number 单帧动画的高度
---@field row number 当前所使用的动画行
---@field quad love.Quad | nil 视图窗口
Anim = Object:extend()

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
    --计算出单帧动画的宽高
    local sw = self.image:getWidth()
    local sh = self.image:getHeight()
    self.width = sw / xCount
    self.height = sh / yCount
    self.quad = love.graphics.newQuad(0,0,self.width, self.height, sw, sh)
    self.row = 0
    return self
end