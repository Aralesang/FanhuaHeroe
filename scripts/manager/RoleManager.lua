require "scripts.base.GameObject"
require "scripts.components.CollisionBox"
require "scripts.components.Animation"
require "scripts.components.Role"
require "scripts.components.DebugDraw"

---角色管理器
---@class RoleManager
RoleManager = {}

---创建一个玩家
---@param roleName string 角色名称
---@param x number 角色初始位置x
---@param y number 角色初始位置y
---@overload fun(roleName)
---@return GameObject | nil
function RoleManager.createRole(roleName,x,y)
     --创建角色
     local roleObj = GameObject:new()
     roleObj.position.x = x or 0
     roleObj.position.y = y or 0
     roleObj:setCentral(32 / 2,32 / 2)

     --附加碰撞器组件
     ---@type CollisionBox | nil
     local collision = roleObj:addComponent(CollisionBox)
     if collision == nil then return nil end
     collision:setWH(64,64)

     --附加角色组件
     ---@type Role | nil
     local role = roleObj:addComponent(Role)
     role.name = roleName

     --附加调试组件
     roleObj:addComponent(DebugDraw)
     --print("create role"..roleName)
     return roleObj
end

return RoleManager