---@class Tool 工具类
local Tool = {}

---检查文件是否存在
---@param fileName string 文件名
---@return boolean
function Tool.fileExists(fileName)
    local f = io.open(fileName, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

---检查列表中是否包含指定值
---@param t table 要检查的列表
---@param target any 可能包含的值
---@return boolean
function Tool.isContains(t,target)
    for key, value in pairs(t) do
        if value == target then
            return true
        end
    end
    return false
end

return Tool