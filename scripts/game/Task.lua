---@class Task : Class 任务对象
---@field id number 任务id
---@field name string 任务名称
---@field description string 任务描述
---@field conditions table<string,number> 条件列表
local Task = Class('Task')

return Task