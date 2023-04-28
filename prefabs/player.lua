require "scripts.game.Role"
require "scripts.manager.RoleManager"
require "scripts.game.PlayerController"
require "scripts.base.GameObject"

---@type GameObject
local roleObj = RoleManager.createRole("player");
---@type Role
local role = roleObj:getComponent(Role)
if role == nil then return nil end
--附加动画组件
---@type Animation | nil
local animation = role:addComponent(Animation)
if animation == nil then
    error("animation component add fail")
    return nil 
end
--创建行走动画
animation:create("行走","image/player.png",8,8)
--TODO:创建闲置动画
animation:create("闲置","image/player.png",8,8)

roleObj:addComponent(PlayerController)
return role

-- return{
--     components = {
--         Role = {
--             name = nil,
--             speed = 100,
--             moveDir = Direction.Donw, --移动方向
--             componentName = "player",
--             direction = Direction.Donw
--         }
--     }
-- }