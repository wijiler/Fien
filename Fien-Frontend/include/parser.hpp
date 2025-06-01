#pragma once

#include <ast.hpp>
#include <lexer.hpp>
namespace Fien
{
    struct Parser
    {
        Lexer lexer;
        Ast ast;

        void open(std::string filename);
        Ast parse();
    };
} // namespace Fien