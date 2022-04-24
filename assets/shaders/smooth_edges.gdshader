shader_type canvas_item;

void fragment() {
	vec4 top = texture(TEXTURE, UV + vec2(0, -TEXTURE_PIXEL_SIZE.y));
	vec4 bottom = texture(TEXTURE, UV + vec2(0, TEXTURE_PIXEL_SIZE.y));
	vec4 left = texture(TEXTURE, UV + vec2(-TEXTURE_PIXEL_SIZE.x, 0));
	vec4 right = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0));
	
	vec4 color = texture(TEXTURE, UV);
	if (color.a != 0.0 && (round(top.a) + round(bottom.a) + round(right.a) + round(left.a)) <= 1.0) {
		color.a = 0.0;
	}
	COLOR = color;
}