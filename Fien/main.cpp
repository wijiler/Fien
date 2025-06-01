#include <iostream>
#include <lexer.hpp>

int main(int argc, char *argv[])
{
    Fien::Lexer lexer;
    std::string root_compilation_unit;
    for (int i = 0; i < argc; i++)
    {
        std::string arg = argv[i];
        if (arg[0] == '-')
        {
        }
        else
        {
            root_compilation_unit = std::move(arg);
        }
    }
    lexer.open(root_compilation_unit);
    Fien::Token tok = lexer.consume();
    while (tok.type != Fien::TokenType::EndOfFile)
    {
        std::cout << "Token: " << Fien::printable_token_type[static_cast<uint8_t>(tok.type)].c_str() << " " << tok.start << "\n";
        tok = lexer.consume();
    }
    std::cout << "Token: " << Fien::printable_token_type[static_cast<uint8_t>(tok.type)].c_str() << " " << tok.start << "\n";
    lexer.close();
    return 0;
}