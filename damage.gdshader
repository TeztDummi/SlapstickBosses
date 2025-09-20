shader_type canvas_item;

uniform sampler2D t0 : hint_screen_texture;
uniform float amount : hint_range(0, 1) = 1;
uniform sampler2D noise_texture;

void fragment() {
	vec2 blur_size = vec2(10.0, 2.0);
	
	float extra = 0.0;
	
	float bluramount = clamp((amount), 0, 1);
	
	
	//bluramount = pow(bluramount, 3);
	
	blur_size *= bluramount;
	
    vec2 size = vec2(textureSize(t0, 0));

    float uv_x = float(SCREEN_UV.x) * size.x;
    float uv_y = float(SCREEN_UV.y) * size.y;
	
	float y = texture(noise_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE), 0.0).s;

	uv_x += (0.5-y)*200.0*bluramount;

    vec4 sum = vec4(0.0);
    for (int n = 0; n < 9; ++n) {
        uv_y = float(SCREEN_UV.y) * size.y + (blur_size.y * (float(n) - 4.5));
        vec4 h_sum = vec4(0.0);
        h_sum += texelFetch(t0, ivec2(int(uv_x) - int(4.0 * blur_size.x), int(uv_y)), 0);
        h_sum += texelFetch(t0, ivec2(int(uv_x) - int(3.0 * blur_size.x), int(uv_y)), 0);
        h_sum += texelFetch(t0, ivec2(int(uv_x) - int(2.0 * blur_size.x), int(uv_y)), 0);
        h_sum += texelFetch(t0, ivec2(int(uv_x) - int(blur_size.x), int(uv_y)), 0);
        h_sum += texelFetch(t0, ivec2(int(uv_x), int(uv_y)), 0);
        h_sum += texelFetch(t0, ivec2(int(uv_x) + int(blur_size.x), int(uv_y)), 0);
        h_sum += texelFetch(t0, ivec2(int(uv_x) + int(2.0 * blur_size.x), int(uv_y)), 0);
        h_sum += texelFetch(t0, ivec2(int(uv_x) + int(3.0 * blur_size.x), int(uv_y)), 0);
        h_sum += texelFetch(t0, ivec2(int(uv_x) + int(4.0 * blur_size.x), int(uv_y)), 0);
        sum += h_sum / 9.0;
    }
	
	vec4 color = sum / 9.0;
	
	float brightness_add = 0.0+(amount*2.0);
	float contrast_mult = 1.0+(amount*7.0);
	color = (color - 0.5) * contrast_mult + 0.5 + brightness_add;
	
	float saturation = 1.0-(amount*0.99);
	color.rgb = mix(vec3(dot(color.rgb, vec3(0.299, 0.587, 0.114))), color.rgb, saturation);
	
	
	//color.s *= 2.0;

    COLOR = vec4(color.rgb, sqrt(amount));
}