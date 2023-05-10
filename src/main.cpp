#include <iostream>
#include <chrono>
#include "glad/glad.h"
#include "GLFW/glfw3.h"
#include "shader_program.h"

static void glfwError(int id, const char* description)
{
    std::cerr << description << std::endl;
}



GLFWwindow* window;
int WINDOW_WIDTH = 800;
int WINDOW_HEIGHT = 800;

float deltatime = 0.0f;


static void framebuffer_size_callback(GLFWwindow* _window, int width, int height)
{
    WINDOW_WIDTH = width;
    WINDOW_HEIGHT = height;

    glViewport(0, 0, width, height);
}


int main() {
    std::chrono::steady_clock::time_point lastUpdate;

    glfwSetErrorCallback(glfwError);
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_SAMPLES, 4);

    window = glfwCreateWindow(WINDOW_WIDTH,WINDOW_HEIGHT,"Ray Tracer", nullptr, nullptr);

    if(window == nullptr)
    {
        std::cerr << "Failed to create GLFW window!" << std::endl;
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);

    if(!gladLoadGLLoader((GLADloadproc) glfwGetProcAddress))
    {
        std::cerr << "Failed to initialize glad" << std::endl;
        return -1;
    }

    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    glViewport(0,0,WINDOW_WIDTH,WINDOW_HEIGHT);
    //glEnable(GL_MULTISAMPLE);
    shader_program shader;
    shader.add("../shaders/vert.glsl", shader_type::vertex);
    shader.add("../shaders/frag.glsl", shader_type::fragment);
    shader.bind();

    if(!shader.linked())
    {
        return -1;
    }

    unsigned int vao;
    glGenVertexArrays(1, &vao);

    unsigned int vbo;
    glGenBuffers(1, &vbo);

    glBindVertexArray(vao);
    const static float vertices[] = {
            -1.0f,  1.0f,  1.0f,  1.0f,  1.0f, -1.0f,
            1.0f,  -1.0f, -1.0f, -1.0f, -1.0f,  1.0f
    };
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof (vertices), vertices, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof (float), (void*) nullptr);
    glEnableVertexAttribArray(0);



    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    while(!glfwWindowShouldClose(window))
    {
        auto now = std::chrono::steady_clock::now();
        deltatime = std::chrono::duration_cast<std::chrono::microseconds>(now-lastUpdate).count() / 1000000.0f;
        lastUpdate = now;
        glfwPollEvents();

        glClear(GL_COLOR_BUFFER_BIT);
        glBindVertexArray(vao);

        shader.use();

        shader.set_float2f("iResolution", WINDOW_WIDTH, WINDOW_HEIGHT);
        shader.set_float("iTime", glfwGetTime());
        shader.set_float("iDeltaTime", deltatime);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glDrawArrays(GL_TRIANGLES, 0, 6);
        glBindVertexArray(0);
        glfwSwapBuffers(window);
    }

    return 0;
}

