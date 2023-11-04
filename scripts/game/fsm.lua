local JSON = require "scripts.utils.JSON"

---@class FSM 有限状态机
---@field states State[] 状态列表
---@field branchs table<number,number[]> 状态可进入的分支
---@field funcs string[] 状态机触发的函数名
local FSM = {}

function FSM.init()
    print("加载有限状态机...")
    local file = love.filesystem.read("data/state.json")
    if file == nil then
        error("有限状态机初始化失败,anims.json失败")
    end
    ---@type any
    local json = JSON:decode(file)
    if json == nil then
        error("有限状态机初始化失败,json对象创建失败")
    end
    FSM.states = {}
    FSM.branchs = {}
    FSM.funcs = {}
    for _, v in pairs(json) do
        local id = v["id"]
        local branch = v["branch"]
        local func = v["func"]
        FSM.states[id] = v
        FSM.branchs[id] = {}
        for _,v in pairs(branch) do
            FSM.branchs[id][v] = 1
        end
        FSM.funcs[id] = func
   end
end

---触发状态函数
---@param role Role 目标对象
---@param dt number 距离上一帧的间隔时间
function FSM.call(role,dt)
    local state = role.state
    local func = FSM.funcs[state]
    if role[func] == nil then
        return
    end
    role[func](role,dt)
end

---改变目标状态
---@param role Role 目标对象
---@param state State 目标状态
---@return boolean result 是否成功
function FSM.change(role,state)
    --获取目标当前状态
    local curState = role.state
    --如果目前没有任何状态,则无视条件成功
    if curState == nil then
        role.state = state
        return true
    end
    --判断是否可以进入目标分支
    local branch = FSM.branchs[curState]
    if branch[state] == nil then
        return false
    end
    role.state = state
    return true
end

return FSM