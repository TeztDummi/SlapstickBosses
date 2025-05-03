shader_type spatial;
render_mode blend_add, cull_back, unshaded;

uniform vec4 color : source_color = vec4(1,0,0,1);
uniform float size : hint_range(1.0, 1.5, 0.01) = 1.05;

uniform sampler2D tex;

void vertex() {
	VERTEX *= size;
}

void fragment() {
	ALBEDO.rgb = color.rgb;
	ALPHA = color.a*texture(tex, SCREEN_UV + vec2(VIEWPORT_SIZE), 0.0).r;
}
