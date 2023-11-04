local JSON = require "scripts.utils.JSON"

---@class RoleJsonData 角色模板
local RoleJsonData = {}

---角色管理器
---@class RoleManager
---@field roles RoleJsonData[] 玩家模板列表
local RoleManager = {}

function RoleManager:init()
     print("加载角色管理器...")
     self.roles = {}
     --加载角色模板
     local file = love.filesystem.read("data/role.json")
     if file == nil then
          error("角色管理器初始化失败,读取roles.json失败")
     end
     local json = JSON:decode(file)
     if json == nil then
          error("角色管理器初始化失败,json对象创建失败")
     end
     ---@cast json RoleJsonData[]
     for _, v in pairs(json) do
          self.roles[v["id"]] = v
     end
end

---获取角色模板数据
---@param id number 角色模板id
---@return RoleJsonData
function RoleManager:getRole(id)
     local role = self.roles[id]
     if role == nil then
          error("目标角色模板不存在:" .. id)
     end
     return role
end

return RoleManager
