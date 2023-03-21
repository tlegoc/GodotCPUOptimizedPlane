shader_type spatial;
render_mode world_vertex_coords, shadows_disabled;

uniform float wave_strength = 0.2;

void fragment() {
	
	ALBEDO = vec3(.1, .2, 1.0);
}

void light() {
	SPECULAR_LIGHT += vec3(ATTENUATION);
}

void vertex() {
	VERTEX.y += wave_strength * cos(VERTEX.x + TIME) * sin(VERTEX.z + TIME);
}
