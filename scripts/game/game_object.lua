local vector2    = require "scripts.base.vector2"
local direction  = require "scripts.enums.direction"


---游戏对象基本类
---@class game_object:class
---@field name string 对象名称
---@field scale table 对象缩放比例因子{x,y}
---@field rotate number 对象旋转弧度
---@field central vector2 中心坐标,相对对象0,0坐标的中心坐标位置
---@field direction direction 当前对象方向
---@field x number 对象空间水平坐标
---@field y number 对象空间垂直坐标
---@field w number 对象宽度
---@field h number 对象高度
---@field isLoad boolean 是否加载过
local game_object = Class("game_object")
---构造函数
function game_object:initialize(x,y,w,h)
    self.name = "游戏对象"
    self.x = x or 0
    self.y = y or 0
    self.w = w or 0
    self.h = h or 0
    self.scale = { x = 1, y = 1 }
    self.rotate = 0
    self.components = {}
    self.central = vector2.zero()
    self.direction = direction.Down
    self.speed = 0
    self.tag = ""
    self.isLoad = false
end

---对象加载
function game_object:load()

end

---对象更新
---@param delay_time number 距离上一帧的间隔时间
function game_object:update(delay_time)
end

---图像绘制
function game_object:draw()
end

--销毁前一帧率调用
function game_object:on_destroy()
end

---键盘按下
---@param key number 键盘键入值
function game_object:keypressed(key)
end

---按键释放
---@param key number 键盘释放的键值
function game_object:keyreleased(key)
end

---设置对象中心点
---@param x number 坐标x
---@param y number 坐标y
function game_object:set_central(x, y)
    self.central.x = x
    self.central.y = y
end

---设置对象比例因子
---@param x number x轴比例因子
---@param y number y轴比例因子
function game_object:set_scale(x, y)
    self.scale.x = x
    self.scale.y = y
end

---对象销毁
function game_object:destroy()
    self:on_destroy()
    Game:remove_game_object(self)
end

---设置对象方向
---@param dir direction | string 方向
function game_object:set_dir(dir)
    if type(dir) == "string" then
        if dir == "up" then
            self.direction = direction.Up
        elseif dir == "down" then
            self.direction = direction.Down
        elseif dir == "left" then
            self.direction = direction.Left
        elseif dir == "right" then
            self.direction = direction.Right
        end
    else
        self.direction = dir
    end
end

---获取与目标对象之间的距离
---@param target game_object
---@return number
function game_object:get_distance(target)
    --计算距离
    local dx = math.abs(self.x - target.x)
    local dy = math.abs(self.y - target.y)
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance
end

---获取该对象目前可以操作到的对象
---@return game_object | nil
function game_object:get_operate()
    --假设对象直线前进，找出一个身位内的可碰撞对象
    local x,y
    local touch = 5
    if self.direction == direction.Up then
        x = self.x
        y = self.y - touch
    elseif self.direction == direction.Down then
        x = self.x
        y = self.y + touch
    elseif self.direction == direction.Left then
        x = self.x - touch
        y = self.y
    elseif self.direction == direction.Right then
        x = self.x + touch
        y = self.y
    end
    local goalX, goalY, cols, len = Game.world:check(self,x,y)
    local obj
    for i = 1, len do
        obj = cols[i]
        return obj.other
    end
    return nil
end

return game_object
