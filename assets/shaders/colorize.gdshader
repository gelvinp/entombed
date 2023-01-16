shader_type canvas_item;
render_mode blend_premul_alpha;

uniform vec3 colors[6] : source_color;
uniform float exponent;
uniform float radius;
uniform float bias;

float map_gray_value(float input)
{
	return clamp(pow(input, exponent), 0.0, 1.0);
}

int index_from_gray(float input)
{
	return int(floor(input * 5.999));
}

float get_pixel_factor(vec2 uv)
{
	vec2 to_center = uv - vec2(0.5);
	float dist_squared = abs(to_center.x) + to_center.y * to_center.y;
	
	if (dist_squared < radius * radius)
	{
		return 1.0;
	}
	
	return 0.0;
}


bool only_red(vec3 color)
{
	return color.r > 0.0 && (color.g + color.b) == 0.0;
}


bool only_black(vec3 color)
{
	return color.r <= 0.0 && color.g <= 0.0 && color.b <= 0.0;
}


void fragment()
{
	vec4 sample = texture(TEXTURE, UV).xyzw;
	
	if (only_black(sample.xyz) || only_red(sample.xyz))
	{
		COLOR = sample;
	}
	else
	{
		vec3 screen_color = sample.xyz;
		float gray = 0.2126 * screen_color.r + 0.7152 * screen_color.g + 0.0722 * screen_color.b;
		float mapped = map_gray_value(bias + gray);
		vec3 color = colors[index_from_gray(mapped)];
		
		float factor = get_pixel_factor(UV);
		vec3 factored = mix(screen_color, color, factor);
		
		COLOR = vec4(factored, sample.w);
	}
}
