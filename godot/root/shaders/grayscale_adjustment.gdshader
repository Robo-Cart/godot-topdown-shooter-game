shader_type canvas_item;

uniform float brightness : hint_range(-1.0, 1.0) = 0.0;
uniform float contrast : hint_range(0.0, 2.0) = 1.0;
uniform float saturation : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);


void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	// Saturation
	float grey = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 color = mix(vec3(grey), tex_color.rgb, saturation);

	// Contrast
	color = (color - 0.5) * contrast + 0.5;

	// Brightness
	color = color + brightness;

	// Tint
	color = color * tint.rgb;

	COLOR = vec4(color, tex_color.a);
}
