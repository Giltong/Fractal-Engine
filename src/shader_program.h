

#ifndef SHADER_PROGRAM_H
#define SHADER_PROGRAM_H

#include "glad/glad.h"

enum shader_type{
    fragment = GL_FRAGMENT_SHADER,
    vertex = GL_VERTEX_SHADER
};

class shader_program {
public:
    shader_program();
    void add(const char* file_path, shader_type type);
    void bind();
    void use() const;
    bool linked();

    void set_float2f(const std::string& name, float val1, float val2);
    void set_float4f(const std::string& name, float val1, float val2, float val3, float val4);
    void set_float(const std::string& name, float val);
    void set_double(const std::string& name, double val);
    void set_double2d(const std::string& name, double val1, double val2);
private:
    unsigned int m_id;
    bool m_linked;
};


#endif //SHADER_PROGRAM_H
