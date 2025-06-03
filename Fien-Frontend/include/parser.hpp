#pragma once

#include <ast.hpp>
#include <lexer.hpp>
namespace Fien
{
    struct Parser
    {
        Lexer lexer;
        Ast ast;
        AstError *errors;
        uint32_t error_count = 0;

        void open(std::string filename);
        void parse();
        void close();
    };
} // namespace Fien