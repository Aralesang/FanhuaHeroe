function love.conf(t)
    t.title = "繁花镇英雄"
    t.window.width = 1280
    t.window.height = 720
    t.console = true
    t.audio.mixwithsystem = false
end

Config = {
    --是否显示fps
    ShowFps = true,
    --是否显示碰撞区域
    ShowCollision = true,
    --是否显示中心点
    ShowCentral = false
}