package main

import im_k2 "imgui_impl_karl2d"
import im "../odin-imgui"
import k2 "../karl2d"

main :: proc() {
    k2.init(1280, 720, "karl2D Imgui")

    im.CreateContext()
    defer im.DestroyContext()

    io := im.GetIO()
	io.ConfigFlags += { .NavEnableKeyboard, .DockingEnable }

    im_k2.init()
    defer im_k2.shutdown()

    for k2.update() {
        k2.clear(k2.BLACK)

        k2.draw_text("Hellope!", { 600, 100 }, 32, k2.WHITE)
        
        im_k2.process_events()
        im_k2.new_frame()
        im.NewFrame()
        
        im.ShowDemoWindow()

        im.Render()
        im_k2.render_draw_data(im.GetDrawData())

        k2.present()
    }

    k2.shutdown()
}
