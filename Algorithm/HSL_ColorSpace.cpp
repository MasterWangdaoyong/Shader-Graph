
//20200829
//HSL
float H;
float S;
float L;

float r;
float g;
float b;

float R;
float G;
float B;

R = r / 255;
G = g / 255;
B = b / 255;

vec3 Cmax = max(R,G,B);
vec3 Cmin = min(R,G,B);
float delta = Cmax - Cmin;




