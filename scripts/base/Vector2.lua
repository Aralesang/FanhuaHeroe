---向量_2D
---@class Vector2
---@field x number
---@field y number
local Vector2={
    x = 0,
    y = 0
}

function Vector2:new(x,y)
    ---@type Vector2
    local o = {}
    setmetatable(o,{__index=self})

    o.x = x or 0
    o.y = y or 0

    return o
end

---返回参照系为世界的原点位置向量 注:love2d的坐标系中原点0,0为左上角
---@return Vector2
function Vector2.zero()
    return Vector2:new(0,0)
end

---获取一个表示上方的向量 x:0 y:-1
---@return Vector2
function Vector2.up()
    return Vector2:new(0,-1)
end

---获取一个表示下方的向量 x:0 y:1
---@return Vector2
function Vector2.down()
    return Vector2:new(0,1)
end

---获取一个表示左方的向量 x:-1 y:0
---@return Vector2
function Vector2.left()
    return Vector2:new(-1,0)
end

---获取一个表示右方的向量 x:1 y:0
---@return Vector2
function Vector2.right()
    return Vector2:new(1,0)
end

return Vector2