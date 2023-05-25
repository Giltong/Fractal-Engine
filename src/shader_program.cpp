

#include <fstream>
#include <sstream>
#include <iostream>
#include "shader_program.h"

shader_program::shader_program() {
    m_id = glCreateProgram();
}

void shader_program::add(const char *file_path, shader_type type) {
    unsigned int shader;
    std::string shader_code;
    std::ifstream file;

    file.exceptions(std::ifstream::failbit | std::ifstream::badbit);
    try
    {
        file.open(file_path);
        std::stringstream shader_stream;
        shader_stream << file.rdbuf();
        file.close();
        shader_code = shader_stream.str();
    }
    catch(std::ifstream::failure &e) {
        std::cerr << "Failed to read file at " << file_path << std::endl;
        return;
    }
    const char* shader_str = shader_code.c_str();

    shader = glCreateShader(type);
    glShaderSource(shader, 1, &shader_str, nullptr);
    glCompileShader(shader);

    int success;
    char infoLog[512];

    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if(!success) {
        glGetShaderInfoLog(shader, 512, nullptr, infoLog);
        std::cerr << "Shader failed to compile: " << infoLog << std::endl;
    }

    glAttachShader(m_id, shader);
}

void shader_program::bind() {
    glLinkProgram(m_id);

    int success;
    char infoLog[512];

    glGetProgramiv(m_id, GL_LINK_STATUS, &success);
    if(!success)
    {
        glGetProgramInfoLog(m_id, 512, nullptr, infoLog);
        std::cout << "Shader program linking failed: \n" << infoLog << std::endl;
        return;
    }
    m_linked = true;
}

void shader_program::use() const {
    if(!m_linked)
    {
        std::cerr << "Shader program not properly linked!" << std::endl;
        return;
    }
    glUseProgram(m_id);
}

bool shader_program::linked() {
    return m_linked;
}

void shader_program::set_float2f(const std::string &name, float val1, float val2) {
    glUniform2f(glGetUniformLocation(m_id, name.c_str()), val1, val2);
}

void shader_program::set_float(const std::string &name, float val) {
    glUniform1f(glGetUniformLocation(m_id, name.c_str()), val);
}

void shader_program::set_double(const std::string &name, double val) {
    glUniform1d(glGetUniformLocation(m_id, name.c_str()), val);
}

void shader_program::set_double2d(const std::string &name, double val1, double val2) {
    glUniform2d(glGetUniformLocation(m_id, name.c_str()), val1, val2);
}

void shader_program::set_float4f(const std::string &name, float val1, float val2, float val3, float val4) {
    glUniform4f(glGetUniformLocation(m_id, name.c_str()), val1, val2, val3, val4);
}

void shader_program::set_int(const std::string &name, int val) {
    glUniform1i(glGetUniformLocation(m_id, name.c_str()), val);
}

void shader_program::set_float3f(const std::string &name, float val1, float val2, float val3) {
    glUniform3f(glGetUniformLocation(m_id, name.c_str()), val1, val2, val3);
}
