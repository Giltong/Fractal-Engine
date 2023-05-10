#version 460 core

uniform vec2 iResolution;
uniform float iTime;
uniform float iDeltaTime;
//uniform dvec2 offset;
//uniform double scale;

out vec4 out_color;

float smin(float a, float b, float k) {
    float h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
    return mix(a, b, h) - k*h*(1.0-h);
}

float sd_mandelbulb(vec3 p) {
    mat3x3 rotMatrix = mat3x3(
        vec3(cos(iTime * 0.5), -sin(iTime * 0.5), 0.0),
        vec3(sin(iTime * 0.5), cos(iTime * 0.5), 0.0),
        vec3(0.0, 0.0, 1.0)
    );

    mat3x3 rotMatrix2 = mat3x3(
        vec3(cos(iTime * 0.5), 0.0, -sin(iTime * 0.5)),
        vec3(0.0, 1.0, 0.0),
        vec3(sin(iTime * 0.5), 0.0, cos(iTime * 0.5))
    );

    vec3 v1 = rotMatrix * rotMatrix2 * vec3(1.0, 1.0, 1.0);
    vec3 v2 = rotMatrix * rotMatrix2 * vec3(-1.0, 1.0, -1.0);
    vec3 v3 = rotMatrix * rotMatrix2 * vec3(1.0, -1.0, -1.0);
    vec3 v4 = rotMatrix * rotMatrix2 * vec3(-1.0, -1.0, 1.0);

    vec3 c;
    int counter = 0;
    int MAX_ITERATIONS = 10;
    float SCALE = 2.0;
    float distToVertex, d;
    while(counter < MAX_ITERATIONS)
    {
        c = v1;
        distToVertex = length(p - v1);

        d = length(p - v2); if(d < distToVertex) {c = v2; distToVertex = d;}
        d = length(p - v3); if(d < distToVertex) {c = v3; distToVertex = d;}
        d = length(p - v4); if(d < distToVertex) {c = v4; distToVertex = d;}

        p = SCALE * p - c * (SCALE - 1.0);
        counter++;
    }

    return length(p) * pow(SCALE, float(-counter));
}

float sd_sphere(vec3 p, vec3 c, float s )
{

    return length(p-c) - s;
}

float find_closest(vec3 p)
{
    return sd_mandelbulb(p);
}

vec3 get_normal(in vec3 p)
{
    const vec3 small_step = vec3(0.001, 0.0, 0.0);

    float gradient_x = find_closest(p + small_step.xyy) - find_closest(p - small_step.xyy);
    float gradient_y = find_closest(p + small_step.yxy) - find_closest(p - small_step.yxy);
    float gradient_z = find_closest(p + small_step.yyx) - find_closest(p - small_step.yyx);

    vec3 normal = vec3(gradient_x, gradient_y, gradient_z);

    return normalize(normal);
}

vec3 ray_march(in vec3 ro, in vec3 rd, vec3 bg_color)
{
    float total_distance_traveled = 0.0;
    const int NUMBER_OF_STEPS = 255;
    const float MINIMUM_HIT_DISTANCE = 0.0001;
    const float MAXIMUM_TRACE_DISTANCE = 10000.0;

    const float global_lighting = 0.2f;

    for (int i = 0; i < NUMBER_OF_STEPS; i++) {
        vec3 current_position = ro + total_distance_traveled * rd;
        float distance_to_closest = find_closest(current_position);

        if(distance_to_closest < MINIMUM_HIT_DISTANCE)
        {
            vec3 normal = get_normal(current_position);
            vec3 light_pos = vec3 (2,-5,3);
            float diff = max(dot(normalize(current_position - light_pos),normal), global_lighting);

            return vec3(0.2, 1.0, 0.0) * diff + bg_color * global_lighting;
        }

        if(total_distance_traveled > MAXIMUM_TRACE_DISTANCE)
        {
            break;
        }
        total_distance_traveled += distance_to_closest;
    }
    return vec3(bg_color);
}



void main()
{
    vec2 uv = (gl_FragCoord.xy - .5 * iResolution) / iResolution.y;

    vec3 ro = vec3(0.0, 0.0, -5.0);
    vec3 rd = normalize(vec3(uv, 1.0));

    vec3 result = ray_march(ro, rd, vec3(0));

    out_color = vec4(result,1);
}