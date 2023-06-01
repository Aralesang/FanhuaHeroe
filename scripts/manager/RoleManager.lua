require "scripts.base.GameObject"
require "scripts.components.CollisionBox"
require "scripts.components.Animation"
require "scripts.components.Role"
require "scripts.components.DebugDraw"
local JSON = require "scripts.utils.JSON"

---@class RoleJsonData 角色模板
---@field id number 角色id
---@field name string 角色名称
---@field anims number[] 动画列表
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

---创建一个玩家
---@param roleId number 角色模板id
---@param x? number 角色初始位置x
---@param y? number 角色初始位置y
---@return GameObject | nil
function RoleManager.createRole(roleId, x, y)
     local roleTemp = RoleManager.roles[roleId]
     --创建角色
     local roleObj = GameObject:new()
     roleObj.position.x = x or 0
     roleObj.position.y = y or 0
     roleObj:setCentral(32 / 2, 32 / 2)

     --附加碰撞器组件
     ---@type CollisionBox | nil
     local collision = roleObj:addComponent(CollisionBox)
     if collision == nil then return nil end
     collision:setWH(64, 64)

     --附加角色组件
     ---@type Role | nil
     local role = roleObj:addComponent(Role)
     role.name = roleTemp.name

     ---附加动画组件
     ---@type Animation | nil
     local animation = roleObj:addComponent(Animation)
     if animation == nil then
          error("animation component add fail")
          return nil
     end
     --构造动画对象
     for _,animId in pairs(roleTemp.anims) do
          local anim = AnimManager.careteAnim(animId)
          animation:addAnim(anim)
     end

     

     --附加调试组件
     roleObj:addComponent(DebugDraw)
     return roleObj
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