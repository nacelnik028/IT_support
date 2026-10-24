shader_type sky;

// Static studio-like interior radiance; local geometry is reflected by SSR.
void sky() {
	vec3 direction = normalize(EYEDIR);
	vec3 ceiling = vec3(0.12,0.17,0.21);
	vec3 floor_color = vec3(0.035,0.055,0.075);
	float upper = smoothstep(-0.3,0.4,direction.y);
	COLOR = mix(floor_color,ceiling,upper);
	if (direction.y>0.025) {
		vec2 point = direction.xz/direction.y*2.2;
		vec2 cell = abs(mod(point+vec2(2.5,2.0),vec2(5.0,4.0))-vec2(2.5,2.0));
		float panel = (1.0-smoothstep(0.3,0.44,cell.x))*(1.0-smoothstep(0.8,1.0,cell.y));
		COLOR += vec3(1.6,1.85,2.0)*panel;
	}
}
