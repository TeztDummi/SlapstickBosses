shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float level : hint_range(0, 1) = 0;
uniform vec3 maincolor: source_color;
uniform vec3 bgcolor: source_color;

void fragment() {
	if (texture(SCREEN_TEXTURE, SCREEN_UV).s >= level)
	{
    	COLOR.rgb = maincolor;
	}
	if (texture(SCREEN_TEXTURE, SCREEN_UV).s < level)
	{
		COLOR.rgb = bgcolor;
	}
}