#include <iostream>
#include <chrono>
#include "glad/glad.h"
#include "GLFW/glfw3.h"
#include "shader_program.h"

#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"
#include "imgui_stdlib.h"

static void glfwError(int id, const char* description)
{
    std::cerr << description << std::endl;
}



GLFWwindow* window;
int WINDOW_WIDTH = 800;
int WINDOW_HEIGHT = 800;

float deltatime = 0.0f;


void draw_gui();

static void framebuffer_size_callback(GLFWwindow* _window, int width, int height)
{
    WINDOW_WIDTH = width;
    WINDOW_HEIGHT = height;

    glViewport(width-height, 0, height, height);
}


int main() {
    std::chrono::steady_clock::time_point lastUpdate;

    glfwSetErrorCallback(glfwError);
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_SAMPLES, 4);

    window = glfwCreateWindow(WINDOW_WIDTH,WINDOW_HEIGHT,"Ray Marcher", nullptr, nullptr);

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

    ImGui::CreateContext();
    if(!ImGui_ImplGlfw_InitForOpenGL(window, true)) return -1;
    if(!ImGui_ImplOpenGL3_Init()) return -1;

    ImGuiIO& io = ImGui::GetIO(); (void) io;

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

        draw_gui();

        glfwSwapBuffers(window);
    }

    return 0;
}

void draw_gui() {
    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplGlfw_NewFrame();
    ImGui::NewFrame();

    ImGui::SetNextWindowSize(ImVec2(WINDOW_WIDTH-WINDOW_HEIGHT, WINDOW_HEIGHT));
    ImGui::SetNextWindowPos(ImVec2(0,0));
    int flags = ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoTitleBar;
    ImGui::Begin("AAHHHH", nullptr, flags);



    ImGui::End();
    ImGui::Render();
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}

