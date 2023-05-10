#version 460 core

uniform vec2 iResolution;
uniform float iTime;
uniform float iDeltaTime;
//uniform dvec2 offset;
//uniform double scale;

out vec4 out_color;

const float epsilon = 0.002f;

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
    return mix(a, b, h) - k*h*(1.0-h);
}

float mandelbulb_power = 8.;
const int mandelbulb_iter_num = 20;
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

float sd_sphere(vec3 p, vec3 c, float s )
{

    return length(p-c) - s;
}

float scene_sdf(vec3 p)
{
    return mandelbulb_sdf(p);
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
    const float view_radius = 10.0f;
    const int maxSteps = 64;
    depth = 0.;
    steps = 0;
    float dist;
    vec3 intersection_point;

    do{
        intersection_point = ro + depth * rd;
        dist = scene_sdf(intersection_point);
        depth += dist;
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
    vec2 uv = (gl_FragCoord.xy - .5 * iResolution) / iResolution.y;



    vec3 rd = normalize(vec3(uv * tan(radians(35)), 1.0));

    float angle = radians(360) * iTime * 1.0/36.0;

    mat3 cam_basis = mat3(0, cos(angle), sin(angle),
    -1, 0, 0,
    0, -sin(angle), cos(angle));

    rd = cam_basis * rd;

    vec3 ro = -cam_basis[2]*4;
    int steps = 0;
    float depth = 0.;
    vec3 current_position = ray_march(ro + epsilon * rd, rd, steps, depth);

    vec3 normal = estimate_normal(current_position, epsilon);

    float ao = steps * 0.01;
    ao = 1. - ao / (ao + 0.5);

    const float contrast_offset = 0.3;
    const float contrast_mid_level = 0.5;
    ao = contrast(ao, contrast_offset, contrast_mid_level);

    out_color = vec4(ao * vec3(normal * 0.5 + 0.5),1.0);
}