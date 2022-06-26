#version 120
// Standard Vertex Shader Transparent Boilerplate
// XDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
varying vec2 _xy;
void main(){
    _xy = gl_MultiTexCoord0.xy;
    gl_Position = ftransform();
}