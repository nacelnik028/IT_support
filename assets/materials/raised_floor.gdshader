shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 base_color : source_color = vec3(0.28,0.33,0.36);
uniform float tile_size = 0.6;
uniform float metal = 0.25;
varying vec3 world_position;

float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }

void vertex() { world_position = (MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }

void fragment() {
	vec2 p = world_position.xz/tile_size;
	vec2 edge = min(fract(p),1.0-fract(p));
	float distance_to_edge = min(edge.x,edge.y);
	float aa = max(fwidth(p.x),fwidth(p.y));
	float joint = smoothstep(0.004,0.004+aa,distance_to_edge);
	float bevel = smoothstep(0.008,0.025,distance_to_edge);
	float variation = hash(floor(p))*0.06;
	float grain = hash(floor(world_position.xz*350.0))*0.018;
	ALBEDO = mix(vec3(0.035,0.045,0.055),base_color*(0.94+variation+grain),joint);
	METALLIC = metal*joint;
	ROUGHNESS = mix(0.75,0.34+variation,bevel);
	SPECULAR = 0.5;
	AO = mix(0.6,1.0,bevel);
}
