require "scripts.base.GameObject"
require "scripts.components.Animation"
require "scripts.components.DebugDraw"
local JSON = require "scripts.utils.JSON"
require "scripts.components.Equipment"
require "scripts.components.Body"

---@class RoleJsonData 角色模板
---@field id number 角色id
---@field name string 角色名称
---@field anims string[] 动画列表
RoleJsonData = {}

---角色管理器
---@class RoleManager
---@field roles RoleJsonData[] 玩家模板列表
RoleManager = {}

---初始化角色管理器
function RoleManager.init()
     RoleManager.roles = {}
     --加载角色模板
     local file = love.filesystem.read("data/roles.json")
     if file == nil then
          error("角色管理器初始化失败,读取roles.json失败")
     end
     local json = JSON:decode(file)
     if json == nil then
          error("角色管理器初始化失败,json对象创建失败")
     end
     ---@cast json RoleJsonData[]
     for _,v in pairs(json) do
          RoleManager.roles[v.id] = v
     end
end

---获取角色模板数据
---@param id number 角色模板id
---@return RoleJsonData
function RoleManager.getRole(id)
     local role = RoleManager.roles[id]
     if role == nil then
          error("目标角色模板不存在:"..id)
     end
     return role
end