---向量_2D
---@class vector2
---@field x number
---@field y number
local vector2={
    x = 0,
    y = 0
}

function vector2:new(x,y)
    ---@type vector2
    local o = {x=0,y=0}
    setmetatable(o,{
        __index=self;
        --重载操作符
        __add = function (t1, t2)
            local v = vector2:new(t1.x + t2.x,t2.y + t2.y)
            return v
        end;
        __sub = function (t1, t2)
            local v = vector2:new(t1.x - t2.x,t2.y - t2.y)
            return v
        end;
        __mul = function (t1, t2)
            local v = vector2:new(t1.x * t2.x,t2.y * t2.y)
            return v
        end;
        __div = function (t1, t2)
            local v = vector2:new(t1.x / t2.x,t2.y / t2.y)
            return v
        end;
        __tostring = function (t)
            return t.x..","..t.y
        end
    })

    o.x = x or 0
    o.y = y or 0

    return o
end

---返回参照系为世界的原点位置向量 注:love2d的坐标系中原点0,0为左上角
---@return vector2
function vector2.zero()
    return vector2:new(0,0)
end

---获取一个表示上方的向量 x:0 y:-1
---@return vector2
function vector2.up()
    return vector2:new(0,-1)
end

---获取一个表示下方的向量 x:0 y:1
---@return vector2
function vector2.down()
    return vector2:new(0,1)
end

---获取一个表示左方的向量 x:-1 y:0
---@return vector2
function vector2.left()
    return vector2:new(-1,0)
end

---获取一个表示右方的向量 x:1 y:0
---@return vector2
function vector2.right()
    return vector2:new(1,0)
end

return vector2