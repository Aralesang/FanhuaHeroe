---@enum State 状态
local State = {
    idle = 1,    --闲置
    walking = 2, --移动中
    attack = 3,  --攻击
    damage = 4,   --受伤
    death = 5   --死亡
}

return State