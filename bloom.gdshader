shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D noise_texture;
uniform lowp float alpha : hint_range(0.0, 1.0);
uniform lowp float curve : hint_range(1, 8);

vec3 rgb_to_hsv(vec3 color) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(color.bg, K.wz), vec4(color.gb, K.xy), step(color.b, color.g));
	vec4 q = mix(vec4(p.xyw, color.r), vec4(color.r, p.yzx), step(p.x, color.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void fragment() {
	float r = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE), 0.0).r;
	float g = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE), 0.0).g;
	float b = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE), 0.0).b;
	
	vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	vec3 hsvcol = rgb_to_hsv(vec3(col.r, col.g, col.b));
	
	float y = texture(noise_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE), 0.0).s;
	
	float a = hsvcol.y*hsvcol.z;
	float reala = pow(a,2);
	
	
	col.rgb = mix(col.rgb, vec3(1.0), alpha);
	
	COLOR = vec4(col.rgb, reala-y);
	//COLOR = vec4(a, a, a, 1.0);
}