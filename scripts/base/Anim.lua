
---动画
---@class Anim:Class
---@field name string 动画名称
---@field image love.Texture 用于创建动画的序列帧位图
---@field frame number 帧数量
---@field width number 单帧动画的宽度
---@field height number 单帧动画的高度
---@field row number 当前所使用的动画行
---@field quad love.Quad 视图窗口
---@field loop boolean 是否循环
local Anim = Class('Anim')

---构造函数
---@param name string 动画名称
---@param image love.Texture 用于创建动画的序列帧位图
---@param frame number 帧数量
---@param loop boolean 动画是否循环
function Anim:initialize(name, image, frame, loop)
    self.name = name
    self.image = image
    self.frame = frame
    --计算出单帧动画的宽高
    local sw = self.image:getWidth()
    local sh = self.image:getHeight()
    self.width = sw / frame
    self.height = sh / 4
    self.quad = love.graphics.newQuad(0,0,self.width, self.height, sw, sh)
    self.row = 0
    self.loop = loop
end

return Anim