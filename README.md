# [Dear Imgui](https://github.com/ocornut/imgui) backend for [Karl 2D](https://github.com/karl-zylinski/karl2d) 

<img width="1282" height="752" alt="image" src="https://github.com/user-attachments/assets/8d68522c-d55b-4897-a4a1-612c5ad9be37" />

### How to use

- Configure [odin-imgui](https://gitlab.com/L-4/odin-imgui)
- Copy `imgui_impl_kar2d` folder or file to your project and fix any path issue for karl2d or odin-imgui

Run the example with `odin run .`

Example
```odin
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
```
