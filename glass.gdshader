shader_type spatial;
uniform sampler2D glass_texture;
uniform lowp float alpha : hint_range(0.0, 1.0);
uniform vec3 color : source_color;

void fragment() {
    vec4 glass_color = texture(glass_texture, SCREEN_UV);
    ALBEDO = glass_color.rgb+color.rgb;
	ALPHA = 1.0-alpha;
}