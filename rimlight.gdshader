shader_type spatial;
render_mode unshaded;

uniform int blur_strength: hint_range(1,8) = 3;
uniform float falloff: hint_range(1.0, 1000.0) = 20.0;
uniform float delay: hint_range(1.0, 1000.0) = 20.0;
uniform sampler2D depth_texture : source_color, hint_depth_texture, filter_linear;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

uniform sampler2D flowMap; //Displacement map
uniform float strength;    //Force of the effect
uniform float speed;       //Speed of the effect
uniform int frames : hint_range(1, 10); //Frames of the effect

//Returns a value between 0 and 1 depending of the frames -> exemple: frames = 4, frame 1 = 0.25
float clock(float time){
	float fframes = float(frames);
	return floor(mod(time * speed, fframes)) / fframes;
}

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

// Configurable Box Blur by Nighteyes -> https://godotshaders.com/shader/configurable-box-blur/
vec3 blur_size(sampler2D tex,vec2 uv, vec2 pixelSize) {
	vec2 pixel = uv / pixelSize;
	int x_min = max(int(pixel.x) - blur_strength, 0);
	int y_min = max(int(pixel.y) - blur_strength, 0);
	int x_max = min(int(pixel.x) + blur_strength, int(1.0 / pixelSize.x));
	int y_max = min(int(pixel.y) + blur_strength, int(1.0 / pixelSize.y));

	int count = 0;
	vec3 color = vec3(0.0);
	for(int x = x_min; x <= x_max; x++) {
		for(int y = y_min; y <= y_max; y++) {
			color += texture(tex, vec2(float(x), float(y)) * pixelSize).rgb;
			count++;
		}
	}
	return color / float(count);
}

void fragment() {

	float c = clock(TIME); //Get clock frame

	//ALBEDO = vec3( c, c, c);
	vec4 offset = texture(flowMap, vec2(UV.x + c, UV.y + c)) * strength; //Get offset
	//ALBEDO = texture(screen_texture, vec2(UV.x,UV.y) + depth_texture.xy); //Apply offset
	vec3 distort = texture(screen_texture, vec2(SCREEN_UV.x,SCREEN_UV.y) + offset.xy - vec2(0.5,0.5)*strength).rgb; //We need to remove the displacement

	float depth = texture(depth_texture, SCREEN_UV).x;
	vec2 screen_coords = SCREEN_UV * 2.0 - 1.0;
	vec3 ndc = vec3(screen_coords, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z/falloff;

	linear_depth = clamp(linear_depth, 0, 1);

	//vec3 blur = blur_size(screen_texture, SCREEN_UV, 1.0/VIEWPORT_SIZE);

	//distort = mix(distort, blur, 0.5);

	vec3 screen = texture(screen_texture, SCREEN_UV).rgb;
	ALBEDO = distort;
	ALPHA = linear_depth;
}