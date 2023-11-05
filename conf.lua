function love.conf(t)
    t.title = "繁花镇英雄"
    t.window.width = 1280
    t.window.height = 720
    t.console = true
    t.audio.mixwithsystem = false
end

Config = {
    --是否显示fps
    show_fps = true,
    --是否显示碰撞区域
    show_collision = false,
    --是否显示中心点
    show_central = false,
    --放大倍率
    scale = 3
}