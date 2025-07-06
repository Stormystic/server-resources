#version 150

#moj_import <minecraft:dynamictransforms.glsl>

out vec4 fragColor;

void main() {
	float alpha = ColorModulator.a * 5.0;
	if (alpha > 1.0) { alpha = 1.0; }
    fragColor = vec4(2.0,2.0,2.0,alpha);
}
