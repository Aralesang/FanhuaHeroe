require "scripts.base.GameObject"
require "scripts.components.CollisionBox"
require "scripts.components.Animation"
require "scripts.components.Role"
require "scripts.components.DebugDraw"

---角色管理器
---@class RoleManager
RoleManager = {}

---创建一个玩家
---@param imagePath string 角色图像地址
---@param roleName string 角色名称
---@param x number 角色初始位置x
---@param y number 角色初始位置y
---@return Role
function RoleManager.createRole(imagePath,roleName,x,y)
     --创建角色
     local roleObj = GameObject:new()
     roleObj.position.x = x or 0
     roleObj.position.y = y or 0
     roleObj:setCentral(32 / 2,48 / 2)
 
     --附加动画组件
     ---@type Animation
     local animation = roleObj:addComponent(Animation)
     local image = love.graphics.newImage(imagePath)
     animation:init(image,4,4,0.3)
 
     --附加碰撞器组件
     local collision = roleObj:addComponent(CollisionBox)
     collision:setScale(32,48)
 
     --附加角色组件
     local role = roleObj:addComponent(Role)
     role.name = roleName or ""

     --附加调试组件
     roleObj:addComponent(DebugDraw)

     return role
end

return RoleManager