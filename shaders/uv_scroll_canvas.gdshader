shader_type canvas_item;


uniform sampler2D tex : repeat_enable;
uniform vec2 uv_scroll = vec2(0.0, 0.0);

void fragment() {
    vec2 uv = UV + uv_scroll;
    COLOR = texture(TEXTURE, uv);
}
