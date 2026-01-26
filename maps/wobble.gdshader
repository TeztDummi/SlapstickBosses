// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx, sss_mode_skin;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform float grow : hint_range(-16.0, 16.0);
uniform float growtex_scale : hint_range(-16.0, 16.0);
uniform float grow_speed : hint_range(-16.0, 16.0);
uniform float grow_size_offset : hint_range(-0.5, 0.5);
uniform vec3 grow_movement = vec3(1.0, 1.0, 1.0);

uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_grow : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);
uniform float emission : hint_range(0.0, 1.0, 0.01);

uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0);

uniform sampler2D texture_ambient_occlusion : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 ao_texture_channel;
uniform float ao_light_affect : hint_range(0.0, 1.0, 0.01);

uniform bool subsurface = true;
uniform float subsurface_scattering_strength : hint_range(0.0, 1.0, 0.01);
uniform sampler2D texture_subsurface_scattering : hint_default_white, filter_linear_mipmap, repeat_enable;

uniform vec4 transmittance_color : source_color;
uniform float transmittance_depth : hint_range(0.001, 100.0, 0.001);
uniform sampler2D texture_subsurface_transmittance : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform float transmittance_boost : hint_range(0.0, 10.0, 0.01);
varying vec3 uv1_triplanar_pos;

uniform float uv1_blend_sharpness : hint_range(0.0, 150.0, 0.001);
varying vec3 uv1_power_normal;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

global uniform vec3 player_pos;

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}

void vertex() {
	vec3 normal = NORMAL;

	TANGENT = vec3(0.0, 0.0, -1.0) * abs(normal.x);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.y);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.z);
	TANGENT = normalize(TANGENT);

	BINORMAL = vec3(0.0, 1.0, 0.0) * abs(normal.x);
	BINORMAL += vec3(0.0, 0.0, -1.0) * abs(normal.y);
	BINORMAL += vec3(0.0, 1.0, 0.0) * abs(normal.z);
	BINORMAL = normalize(BINORMAL);

	// UV1 Triplanar: Enabled
	uv1_power_normal = pow(abs(NORMAL), vec3(uv1_blend_sharpness));
	uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
	uv1_power_normal /= dot(uv1_power_normal, vec3(1.0));
	uv1_triplanar_pos *= vec3(1.0, -1.0, 1.0);
	
	float time = TIME*grow_speed;
	vec3 grow_offset = vec3(time, time, time)*grow_movement;

	vec4 grow_tex = triplanar_texture(texture_grow, uv1_power_normal, uv1_triplanar_pos*growtex_scale+grow_offset);
	// Grow: Enabled
	vec3 world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float min_dist = min(length(player_pos - world_vertex), 1);
	
	VERTEX += NORMAL * grow * (grow_tex.x-(0.5-grow_size_offset));
}

void fragment() {
	vec4 albedo_tex = triplanar_texture(texture_albedo, uv1_power_normal, uv1_triplanar_pos);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	EMISSION = albedo.rgb * emission;

	float metallic_tex = dot(triplanar_texture(texture_metallic, uv1_power_normal, uv1_triplanar_pos), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
	float roughness_tex = dot(triplanar_texture(texture_roughness, uv1_power_normal, uv1_triplanar_pos), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;

	// Normal Map: Enabled
	NORMAL_MAP = triplanar_texture(texture_normal, uv1_power_normal, uv1_triplanar_pos).rgb;
	NORMAL_MAP_DEPTH = normal_scale;

	// Ambient Occlusion: Enabled
	AO = dot(triplanar_texture(texture_ambient_occlusion, uv1_power_normal, uv1_triplanar_pos), ao_texture_channel);
	AO_LIGHT_AFFECT = ao_light_affect;

	// Subsurface Scattering: Enabled
	if (subsurface)
	{
		float sss_tex = triplanar_texture(texture_subsurface_scattering, uv1_power_normal, uv1_triplanar_pos).r;
		SSS_STRENGTH = subsurface_scattering_strength * sss_tex;

		// Subsurface Scattering Transmittance: Enabled
		vec4 trans_color_tex = triplanar_texture(texture_subsurface_transmittance, uv1_power_normal, uv1_triplanar_pos);
		SSS_TRANSMITTANCE_COLOR = transmittance_color * trans_color_tex;
		SSS_TRANSMITTANCE_DEPTH = transmittance_depth;
		SSS_TRANSMITTANCE_BOOST = transmittance_boost;
	}
}
