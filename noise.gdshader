shader_type canvas_item;

uniform float grain_amount : hint_range(0.0, 1.0) = 0.05;
uniform float grain_size : hint_range(0.1, 10.0) = 1.0;
uniform bool animate = false;

void fragment() {

    vec4 original_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    float noise = 0.0;
    
    if (animate) {
        noise = (fract(sin(dot(UV * TIME, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 2.0;
    } else {
        noise = (fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 2.0;
    }
    
    original_color.rgb += noise * grain_amount * grain_size;
    COLOR = clamp(original_color, 0.0, 1.0);
}