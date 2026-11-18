// Based on the raylib extras rlImGui: https://github.com/raylib-extras/rlImGui/blob/main/rlImGui.cpp
package imgui_impl_karl2d

import "core:c"
import "core:mem"
import "core:math"
import "core:slice"

// Follow build instruction for imgui bindings in: https://gitlab.com/L-4/odin-imgui
import imgui "../../odin-imgui"
import k2 "../../karl2d"

imgui_to_karl_cursor_map:  [imgui.MouseCursor]k2.Standard_Cursor = {
    .None       = .Default,
    .Arrow      = .Default,
    .TextInput  = .Text,
    .ResizeAll  = .Resize_NWSE,
    .ResizeNS   = .Resize_NS,
    .ResizeEW   = .Resize_EW,
    .ResizeNESW = .Resize_NESW,
    .ResizeNWSE = .Resize_NWSE,
    .Hand       = .Hand,
    .Wait       = .Wait,
    .Progress   = .Progress,
    .NotAllowed = .Not_Allowed,
    .COUNT = .Default,
}

karl2d_key_map: #sparse [k2.Keyboard_Key]imgui.Key = {
    .None = imgui.Key.None,
    .Backtick = imgui.Key.GraveAccent,
    .Apostrophe = imgui.Key.Apostrophe,
    .Menu = imgui.Key.Menu,
    .Comma = imgui.Key.Comma,
    .Minus = imgui.Key.Minus,
    .Period = imgui.Key.Period,
    .Slash = imgui.Key.Slash,
    .N0 = imgui.Key._0,
    .N1 = imgui.Key._1,
    .N2 = imgui.Key._2,
    .N3 = imgui.Key._3,
    .N4 = imgui.Key._4,
    .N5 = imgui.Key._5,
    .N6 = imgui.Key._6,
    .N7 = imgui.Key._7,
    .N8 = imgui.Key._8,
    .N9 = imgui.Key._9,
    .Semicolon = imgui.Key.Semicolon,
    .Equal = imgui.Key.Equal,
    .A = imgui.Key.A,
    .B = imgui.Key.B,
    .C = imgui.Key.C,
    .D = imgui.Key.D,
    .E = imgui.Key.E,
    .F = imgui.Key.F,
    .G = imgui.Key.G,
    .H = imgui.Key.H,
    .I = imgui.Key.I,
    .J = imgui.Key.J,
    .K = imgui.Key.K,
    .L = imgui.Key.L,
    .M = imgui.Key.M,
    .N = imgui.Key.N,
    .O = imgui.Key.O,
    .P = imgui.Key.P,
    .Q = imgui.Key.Q,
    .R = imgui.Key.R,
    .S = imgui.Key.S,
    .T = imgui.Key.T,
    .U = imgui.Key.U,
    .V = imgui.Key.V,
    .W = imgui.Key.W,
    .X = imgui.Key.X,
    .Y = imgui.Key.Y,
    .Z = imgui.Key.Z,
    .Space = imgui.Key.Space,
    .Escape = imgui.Key.Escape,
    .Enter = imgui.Key.Enter,
    .Tab = imgui.Key.Tab,
    .Backspace = imgui.Key.Backspace,
    .Insert = imgui.Key.Insert,
    .Delete = imgui.Key.Delete,
    .Right = imgui.Key.RightArrow,
    .Left = imgui.Key.LeftArrow,
    .Down = imgui.Key.DownArrow,
    .Up = imgui.Key.UpArrow,
    .Page_Up = imgui.Key.PageUp,
    .Page_Down = imgui.Key.PageDown,
    .Home = imgui.Key.Home,
    .End = imgui.Key.End,
    .Caps_Lock = imgui.Key.CapsLock,
    .Scroll_Lock = imgui.Key.ScrollLock,
    .Num_Lock = imgui.Key.NumLock,
    .Print_Screen = imgui.Key.PrintScreen,
    .Pause = imgui.Key.Pause,
    .F1 = imgui.Key.F1,
    .F2 = imgui.Key.F2,
    .F3 = imgui.Key.F3,
    .F4 = imgui.Key.F4,
    .F5 = imgui.Key.F5,
    .F6 = imgui.Key.F6,
    .F7 = imgui.Key.F7,
    .F8 = imgui.Key.F8,
    .F9 = imgui.Key.F9,
    .F10 = imgui.Key.F10,
    .F11 = imgui.Key.F11,
    .F12 = imgui.Key.F12,
    .Left_Shift = imgui.Key.LeftShift,
    .Left_Control = imgui.Key.LeftCtrl,
    .Left_Alt = imgui.Key.LeftAlt,
    .Left_Super = imgui.Key.LeftSuper,
    .Right_Shift = imgui.Key.RightShift,
    .Right_Control = imgui.Key.RightCtrl,
    .Right_Alt = imgui.Key.RightAlt,
    .Right_Super = imgui.Key.RightSuper,
    .Left_Bracket = imgui.Key.LeftBracket,
    .Backslash = imgui.Key.Backslash,
    .Right_Bracket = imgui.Key.RightBracket,
    .NP_0 = imgui.Key.Keypad0,
    .NP_1 = imgui.Key.Keypad1,
    .NP_2 = imgui.Key.Keypad2,
    .NP_3 = imgui.Key.Keypad3,
    .NP_4 = imgui.Key.Keypad4,
    .NP_5 = imgui.Key.Keypad5,
    .NP_6 = imgui.Key.Keypad6,
    .NP_7 = imgui.Key.Keypad7,
    .NP_8 = imgui.Key.Keypad8,
    .NP_9 = imgui.Key.Keypad9,
    .NP_Decimal = imgui.Key.KeypadDecimal,
    .NP_Divide = imgui.Key.KeypadDivide,
    .NP_Multiply = imgui.Key.KeypadMultiply,
    .NP_Subtract = imgui.Key.KeypadSubtract,
    .NP_Add = imgui.Key.KeypadAdd,
    .NP_Enter = imgui.Key.KeypadEnter,
    .NP_Equal = imgui.Key.KeypadEqual,
}

modifier_keys: #sparse [k2.Keyboard_Key]imgui.Key = #partial {
    .Left_Shift = imgui.Key.ImGuiMod_Shift,
    .Right_Shift = imgui.Key.ImGuiMod_Shift,
    
    .Left_Control = imgui.Key.ImGuiMod_Ctrl,
    .Right_Control = imgui.Key.ImGuiMod_Ctrl,
    
    .Left_Alt = imgui.Key.ImGuiMod_Alt,
    .Right_Alt = imgui.Key.ImGuiMod_Alt,

    .Left_Super = imgui.Key.ImGuiMod_Super,
    .Right_Super = imgui.Key.ImGuiMod_Super,
}

init :: proc() {
    io: ^imgui.IO = imgui.GetIO()
    io.BackendPlatformName = "imgui_impl_karl2d"
    io.BackendFlags = { .RendererHasTextures, .HasMouseCursors }
    io.MousePos = { 0, 0 }
}

shutdown :: proc() {
    io: ^imgui.PlatformIO = imgui.GetPlatformIO()
    textures: []^imgui.TextureData = mem.slice_ptr(io.Textures.Data, int(io.Textures.Size))
    for texture in textures {
        if texture.Status != .Destroyed {
            handle := transmute(k2.Texture)texture.TexID
            k2.destroy_texture(handle)
        }
    }
}

new_frame :: proc() {
    io: ^imgui.IO = imgui.GetIO()

    io.DisplaySize.x = f32(k2.get_screen_width())
    io.DisplaySize.y = f32(k2.get_screen_height())

    io.DisplayFramebufferScale = k2.get_window_scale()
    io.DeltaTime = k2.get_frame_time()

    if .NoMouseCursorChange not_in io.ConfigFlags {
        imgui_cursor := imgui.GetMouseCursor()
        if io.MouseDrawCursor || imgui_cursor == .None {
            k2.set_cursor_hidden(true)
        } else {
            k2.set_cursor_hidden(false)
            karl_cursor := imgui_to_karl_cursor_map[imgui.GetMouseCursor()]
            k2.set_cursor(karl_cursor)
        }
    }

    // if io.WantSetMousePos {
    //    k2.set_mouse_position(io.MousePos)
    // }
}

render_draw_data :: proc(draw_data: ^imgui.DrawData) {
    k2.draw_current_batch()
    k2.set_shader(nil)

    if draw_data.Textures != nil {
        textures: []^imgui.TextureData = mem.slice_ptr(draw_data.Textures.Data, int(draw_data.Textures.Size))
        for tex in textures {
            update_texture(tex)
        }
    }

    command_lists: []^imgui.DrawList = mem.slice_ptr(draw_data.CmdLists.Data, int(draw_data.CmdLists.Size))
   
    for command_list in command_lists {
        cmd_slice: []imgui.DrawCmd = mem.slice_ptr(command_list.CmdBuffer.Data, int(command_list.CmdBuffer.Size))
        for i in 0..<command_list.CmdBuffer.Size {  
            cmd := &cmd_slice[i] 
            k2.set_scissor_rect(k2.Rect {
                cmd.ClipRect.x - draw_data.DisplayPos.x,
                cmd.ClipRect.y,
                cmd.ClipRect.z - (cmd.ClipRect.x - draw_data.DisplayPos.x),
                cmd.ClipRect.w - (cmd.ClipRect.y - draw_data.DisplayPos.y)
            })
            
            if cmd.UserCallback != nil {
                cmd.UserCallback(command_list, cmd)
                continue
            }

            tex_id := imgui.DrawCmd_GetTexID(cmd)

            render_triangles(cmd.ElemCount, cmd.IdxOffset, command_list.IdxBuffer, command_list.VtxBuffer, tex_id)
            k2.draw_current_batch()
        }
    }

    k2.set_scissor_rect(nil)
}

@private
render_triangles :: proc(count: u32, index_start: u32, index_buffer: imgui.Vector_DrawIdx, vert_buffer: imgui.Vector_DrawVert, texture_ptr: imgui.TextureID) {
    if count < 3 {
        return
    }

    texture: k2.Texture = transmute(k2.Texture)texture_ptr

    tex := k2._get_texture_or_error(texture, "Trying to draw invalid texture with handle %v", texture)
    if tex == nil {
        return
    }

    if !k2._begin_textured_draw(tex, int(count))
     {
        return
    }

    shader := k2.get_default_shader()
    texture_loc := shader.default_texture_index.(int)
    k2.set_shader_texture(shader, texture_loc, texture)

    index_slice: []imgui.DrawIdx = mem.slice_ptr(index_buffer.Data, int(index_buffer.Size))
    vert_slice: []imgui.DrawVert = mem.slice_ptr(vert_buffer.Data, int(vert_buffer.Size))

    for i: u32 = 0; i <= (count - 3); i += 3 {
        index_a := index_slice[index_start + i]
        index_b := index_slice[index_start + i + 1]
        index_c := index_slice[index_start + i + 2]

        vertex_a := vert_slice[index_a]
        vertex_b := vert_slice[index_b]
        vertex_c := vert_slice[index_c]

        k2.batch_vertex(vertex_a.pos, vertex_a.uv, transmute(k2.Color)vertex_a.col)
        k2.batch_vertex(vertex_b.pos, vertex_b.uv, transmute(k2.Color)vertex_b.col)
        k2.batch_vertex(vertex_c.pos, vertex_c.uv, transmute(k2.Color)vertex_c.col)
    }
}

process_events :: proc() {
    io: ^imgui.IO = imgui.GetIO()

    for event in k2.get_events() {
        #partial switch e in event {
        case k2.Event_Key_Went_Down:
            imgui.IO_AddKeyEvent(io, karl2d_key_map[e.key], true)
            modifier := modifier_keys[e.key]
            if modifier != nil {
                imgui.IO_AddKeyEvent(io, modifier, true)
            }

            key := u32(e.key)
            if key < 255 {
                imgui.IO_AddInputCharacter(io, u32(e.key))
            }
        case k2.Event_Key_Went_Up:
            imgui.IO_AddKeyEvent(io, karl2d_key_map[e.key], false)
            modifier := modifier_keys[e.key]
            if modifier != nil {
                imgui.IO_AddKeyEvent(io, modifier, false)
            }
        case k2.Event_Mouse_Button_Went_Down:
            imgui.IO_AddMouseButtonEvent(io, i32(e.button), true)
        case k2.Event_Mouse_Button_Went_Up:
            imgui.IO_AddMouseButtonEvent(io, i32(e.button), false)
        case k2.Event_Mouse_Move:
            imgui.IO_AddMousePosEvent(io, e.position.x, e.position.y)
        case k2.Event_Mouse_Wheel:
            imgui.IO_AddMouseWheelEvent(io, 0, e.delta)
        case k2.Event_Window_Focused:
            imgui.IO_AddFocusEvent(io, true)
        case k2.Event_Window_Unfocused:
            imgui.IO_AddFocusEvent(io, false)
        }
    }
}

@private
update_texture :: proc(tex: ^imgui.TextureData) {
    switch tex.Status {
    case .OK, .Destroyed:
        return
    case .WantCreate:
        format := tex.Format == .RGBA32 ? k2.Pixel_Format.RGBA_8_Norm : k2.Pixel_Format.R_8_Norm
        format_size := k2.pixel_format_size(format)
        width := int(tex.Width)
        height := int(tex.Height)
        texture := k2.load_texture_from_bytes_raw(slice.bytes_from_ptr(tex.Pixels, width * height * format_size), width, height, format)
        tex.Status = .OK
        imgui.TextureData_SetTexID(tex, transmute(imgui.TextureID)texture)
    case .WantDestroy:
        texture := transmute(k2.Texture)tex.TexID
        k2.destroy_texture(texture)
        tex.Status = .Destroyed
        imgui.TextureData_SetTexID(tex, {})
    case .WantUpdates:
        texture := transmute(k2.Texture)tex.TexID
        size := k2.get_texture_size(texture)
        k2.update_texture(texture, slice.bytes_from_ptr(imgui.TextureData_GetPixels(tex), int(imgui.TextureData_GetSizeInBytes(tex))), { 0, 0, size.x, size.y })
        tex.Status = .OK
    }
}
