#version 460 core

uniform vec2 iResolution;
uniform float iTime;
uniform float iDeltaTime;
//uniform dvec2 offset;
//uniform double scale;

//USER SETTINGS
uniform float camDist;

out vec4 out_color;
const float epsilon = 0.002f;
const float contrast_offset = 0.3;
const float contrast_mid_level = 0.5;
float mandelbulb_power = 8.;
const int mandelbulb_iter_num = 10;
const float view_radius = 10.0f;
const int maxSteps = 512;

vec3 sq3 (vec3 v) {
    return vec3(
    v.x*v.x-v.y*v.y-v.z*v.z,
    2.*v.x*v.y,
    2.*v.x*v.z
    );
}

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
    return mix(a, b, h) - k*h*(1.0-h);
}

float julia_sdf(vec3 p, vec3 c)
{
    vec3 k = p;
    for(int i = 0; i < mandelbulb_iter_num; i++)
    {
        k = sq3(k) + c;
        if(length(k) > 10.) return 1.-pow((float(i)/float(mandelbulb_iter_num)),3);
    }
    return -.01;
}
float mandelbulb_sdf(vec3 pos) {
    vec3 z = pos;
    float dr = 1.0;
    float r = 0.0;
    for (int i = 0; i < mandelbulb_iter_num ; i++)
    {
        r = length(z);
        if (r>3.) break;

        // convert to polar coordinates
        float theta = acos(z.z / r);
        float phi = atan(z.y, z.x);

        dr =  pow( r, mandelbulb_power-1.0)*mandelbulb_power*dr + 1.0;

        // scale and rotate the point
        float zr = pow( r,mandelbulb_power);
        theta = theta*mandelbulb_power;
        phi = phi*mandelbulb_power;

        // convert back to cartesian coordinates
        z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
        z+=pos;
    }
    return 0.5*log(r)*r/dr;
}

float sphere_sdf(vec3 p, vec3 c, float s )
{

    return length(p-c) - s;
}

float scene_sdf(vec3 p)
{
    return mandelbulb_sdf(p);
    //return julia_sdf(p, vec3(sin(iTime*0.3)*0.7, cos(iTime*0.4)*0.7, 0.1));
}

vec3 estimate_normal(const vec3 p, const float delta)
{
    return normalize(vec3(
    scene_sdf(vec3(p.x + delta, p.y, p.z)) - scene_sdf(vec3(p.x - delta, p.y, p.z)),
    scene_sdf(vec3(p.x, p.y + delta, p.z)) - scene_sdf(vec3(p.x, p.y - delta, p.z)),
    scene_sdf(vec3(p.x, p.y, p.z  + delta)) - scene_sdf(vec3(p.x, p.y, p.z - delta))
    ));
}

float contrast(float val, float contrast_offset, float contrast_mid_level)
{
    return clamp((val - contrast_mid_level) * (1. + contrast_offset) + contrast_mid_level, 0., 1.);
}

vec3 ray_march(in vec3 ro, in vec3 rd, out int steps, out float depth)
{

    depth = 0.;
    steps = 0;
    float dist;
    float t;
    vec3 intersection_point;

    do{
        intersection_point = ro + depth * rd;
        dist = scene_sdf(intersection_point);
        depth += dist * 0.5;
        steps++;
    }while(depth < view_radius && dist > epsilon && steps < maxSteps);

    if(depth > view_radius)
    {
        return vec3(0.0);
    }

    return intersection_point;
}



void main()
{
    vec2 uv = (gl_FragCoord.xy - vec2(iResolution.x-iResolution.y, 0) - .5 * iResolution.yy) / iResolution.y;
    vec3 rd = normalize(vec3(uv, 1));
    float angle = radians(iTime);
    rd.xz *= mat2(cos(angle), -sin(angle), sin(angle), cos(angle));

    vec3 ro = vec3 (camDist * sin(angle),0.0,-camDist *cos(angle));
    int steps = 0;
    float depth = 0.;
    vec3 current_position = ray_march(ro + epsilon * rd, rd, steps, depth);
    if(current_position == vec3(0,0,0))
    {
        out_color = vec4(0,0,0,1);
        return;
    }
    float frac = depth/view_radius;
    vec3 normal = estimate_normal(current_position, epsilon);
    float ao = steps * 0.01;
    ao = 1. - ao / (ao + 0.5);
    vec3 base_color = vec3(1.0,1.0,1.0);
    ao = contrast(ao, contrast_offset, contrast_mid_level);
    out_color = vec4(ao * (normal * 0.5 +0.5),1.0);
}