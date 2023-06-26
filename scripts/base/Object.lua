--
-- classic
--
-- Copyright (c) 2014, rxi
--
-- This module is free software; you can redistribute it and/or modify it under
-- the terms of the MIT license. See LICENSE for details.
--

---对象基类
---@class Object
---@field private __index Object
---@field super Object 父对象
Object = {}
Object.__index = Object

---构造函数
function Object:new()
  local obj = setmetatable({}, self)
  return obj
end

---继承
---@return Object
function Object:extend()
  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.super = self
  setmetatable(cls, self)
  return cls
end

---实现接口
---@vararg table
function Object:implement(...)
  for _, cls in pairs({ ... }) do
    for k, v in pairs(cls) do
      if self[k] == nil and type(v) == "function" then
        self[k] = v
      end
    end
  end
end

---判断是否是目标类型
---@generic T
---@param t T
---@return boolean
function Object:is(t)
  local mt = getmetatable(self)
  while mt do
    if mt == t then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end

-- ---返回对象名称
-- ---@private
-- ---@return string
-- function Object:__tostring()
--   return "Object"
-- end

---元方法
---@private
---@vararg function
---@return Object
function Object:__call(...)
  local obj = setmetatable({}, self)
  ---@diagnostic disable-next-line: redundant-parameter
  obj:new(...)
  return obj
end

return Object
