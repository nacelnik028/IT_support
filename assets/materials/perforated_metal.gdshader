shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
uniform vec3 steel : source_color = vec3(0.055,0.075,0.09);
uniform vec2 holes = vec2(64.0,12.0);
void fragment() {
	vec2 cell = fract(UV*holes)-0.5;
	if (length(cell)<0.29) { discard; }
	ALBEDO = steel;
	METALLIC = 0.7;
	ROUGHNESS = 0.38;
}
