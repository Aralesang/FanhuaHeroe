require "scripts.components.Role"
require "scripts.manager.RoleManager"
require "scripts.components.PlayerController"
require "scripts.base.GameObject"

---@type GameObject | nil
local roleObj = RoleManager.createRole("player",200,200);
if roleObj == nil then return end
---@type Role | nil
local role = roleObj:getComponent(Role)
if role == nil then return nil end
--附加动画组件
---@type Animation | nil
local animation = roleObj:addComponent(Animation)
if animation == nil then
    error("animation component add fail")
    return nil
end
--创建行走动画
animation:create("行走","image/character/角色_行走.png",6,4)
--TODO:创建闲置动画
animation:create("闲置","image/character/角色_待机.png",1,4)
animation:play("闲置")

roleObj:addComponent(PlayerController)
return role