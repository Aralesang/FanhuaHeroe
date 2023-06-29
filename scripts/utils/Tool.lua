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

return Tool