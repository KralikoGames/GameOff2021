shader_type canvas_item;

uniform float perc_dist : hint_range(0, 1) = 0.0;
//uniform vec2 source_offset = vec2(0.0, 0.0);
//uniform vec2 text_size = vec2(0.0, 0.0);
uniform bool solid = false;
uniform bool circle = false;
uniform bool cone = false;
uniform bool rect = false;
uniform bool arc = false;

const float high = 0.8;
const float med = 0.5;
const float low = 0.3;
const float line_thickness = 0.1;



float translate(float value, float leftMin, float leftMax, float rightMin, float rightMax) {
	// Figure out how 'wide' each range is
	float leftSpan = leftMax - leftMin;
	float rightSpan = rightMax - rightMin;

	// Convert the left range into a 0-1 range (float)
	float valueScaled = float(value - leftMin) / float(leftSpan);

	// Convert the 0-1 range into a value in the right range.
	return rightMin + (valueScaled * rightSpan);
}


void fragment() {
	vec2 source;
	if (circle) {
		if(distance(UV, vec2(0.5,0.5)) > 0.5) {
			COLOR.a = 0.0;
		}
		source = vec2(0.5,0.5);
	} else if (cone) {
		if(
			distance(UV, vec2(0.0,0.5)) > 1.0 ||
			(UV.y > 0.5*UV.x + 0.5) ||
			UV.y < -0.5*UV.x+0.5
		) {
			COLOR.a = 0.0;
		}
		source = vec2(0.0,0.5);
	} else if (rect) {
		source = vec2(0.0,0.5);
	}
	
	if (COLOR.a > 0.0) {
		if(solid) {
			COLOR.a = 1.0;
		} else if (rect) {
			float dist = translate(perc_dist, 0.0, 1.0, -line_thickness, 1.0);
			if (UV.x > dist && UV.x < dist+line_thickness) {
				COLOR.a = high;
			} else if (UV.x < dist) {
				COLOR.a = med;
			} else {
				COLOR.a = low;
			}
		}
		else {
			//vec2 source = (source_offset + text_size / 2.0) / text_size;// - (text_size / 2.0);
			float dist_from_source = distance(UV, source);
			float source_to_center = distance(vec2(0.5,0.5), source);
			
			float max_dist = 0.5 + 1.0 * source_to_center;
			float min_dist = -0.1 - 0.2 * source_to_center; // -0.1 at dist 0, 0.1 at dist 0.5
			float dist = translate(perc_dist, 0.0, 1.0, min_dist, max_dist);
			
			if(dist_from_source > dist && dist_from_source < dist+line_thickness) {
				COLOR.a = high;
			}
			else if(dist_from_source < dist) {
				COLOR.a = med;
			}
			else {
				COLOR.a = low;
			}
		}
	}
}