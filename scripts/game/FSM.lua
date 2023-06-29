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
---@param obj GameObject
function FSM.call(obj,dt)
    local state = obj.state
    local func = FSM.funcs[state]
    if obj[func] == nil then
        return
    end
    obj[func](obj,dt)
end

---改变目标状态
---@param obj GameObject 目标对象
---@param state State 目标状态
---@return boolean result 是否成功
function FSM.change(obj,state)
    --获取目标当前状态
    local curState = obj.state
    if curState == nil then
        error("目标对象状态未初始化")
    end
    --判断是否可以进入目标分支
    local branch = FSM.branchs[curState]
    if branch[state] == nil then
        return false
    end
    obj.state = state
    return true
end

return FSM