cmake_minimum_required(VERSION 3.23)
project(raytracer)

set(CMAKE_CXX_STANDARD 20)

set(GLFW_INCLUDE_PATH "${CMAKE_SOURCE_DIR}/libs/glfw/include")

set(GLAD_INCLUDE_PATH "${CMAKE_SOURCE_DIR}/libs/glad/include")

set(GLM_INCLUDE_PATH "${CMAKE_SOURCE_DIR}/libs/glm")

set(IMGUI_INCLUDE_PATH "${CMAKE_SOURCE_DIR}/libs/imgui")

set(IMPLOT_INCLUDE_PATH "${CMAKE_SOURCE_DIR}/libs/implot")

add_library(IMGUI STATIC)

target_sources(IMGUI
        PRIVATE
        ${IMGUI_INCLUDE_PATH}/imgui_demo.cpp
        ${IMGUI_INCLUDE_PATH}/imgui_draw.cpp
        ${IMGUI_INCLUDE_PATH}/imgui_tables.cpp
        ${IMGUI_INCLUDE_PATH}/imgui_widgets.cpp
        ${IMGUI_INCLUDE_PATH}/imgui.cpp
        ${IMGUI_INCLUDE_PATH}/misc/cpp/imgui_stdlib.cpp
        PRIVATE
        ${IMGUI_INCLUDE_PATH}/backends/imgui_impl_opengl3.cpp
        ${IMGUI_INCLUDE_PATH}/backends/imgui_impl_glfw.cpp
        )
add_library(IMPLOT STATIC)

target_sources(IMPLOT PRIVATE
        ${IMPLOT_INCLUDE_PATH}/implot.cpp
        ${IMPLOT_INCLUDE_PATH}/implot_items.cpp
        ${IMPLOT_INCLUDE_PATH}/implot_demo.cpp
        )




include_directories(
        ${GLFW_INCLUDE_PATH}
        ${GLAD_INCLUDE_PATH}
        ${GLM_INCLUDE_PATH}
        ${IMPLOT_INCLUDE_PATH}
        ${IMGUI_INCLUDE_PATH}
        ${IMGUI_INCLUDE_PATH}/backends
        ${IMGUI_INCLUDE_PATH}/misc/cpp
)

link_directories(${PROJECT_SOURCE_DIR}/glfw/lib-mingw-w64)

add_executable(raytracer src/main.cpp glad.c src/shader_program.cpp src/shader_program.h)

target_link_libraries(raytracer mingw32 ${PROJECT_SOURCE_DIR}/libs/glfw/lib-mingw-w64/libglfw3.a opengl32 IMGUI IMPLOT)
