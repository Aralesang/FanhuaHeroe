local Object = require "scripts.base.Object"

---动画
---@class Anim : Object
---@field name string 动画名称
---@field image love.Texture 用于创建动画的序列帧位图
---@field xCount number x轴帧数量
---@field yCount number y轴帧数量
---@field width number 单帧动画的宽度
---@field height number 单帧动画的高度
---@field row number 当前所使用的动画行
---@field quad love.Quad 视图窗口
---@field loop boolean 是否循环
Anim = Object:extend()

---构造函数
---@param name string 动画名称
---@param image love.Texture 用于创建动画的序列帧位图
---@param xCount number x轴帧数量
---@param yCount number y轴帧数量
---@param loop boolean 动画是否循环
function Anim:new(name, image, xCount, yCount,loop)
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
    self.loop = loop
end