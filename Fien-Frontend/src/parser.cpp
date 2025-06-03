#include <iostream>
#include <parser.hpp>
using namespace Fien;

void Parser::open(std::string filename)
{
    lexer.open(filename);
}
void Parser::parse()
{
    Token tok = lexer.consume();
    while (tok.type != TokenType::EndOfFile)
    {
#ifdef DEBUG
        std::cout << "Token: " << Fien::printable_token_type[static_cast<uint8_t>(tok.type)].c_str() << " " << tok.start << "\n";
#endif
        switch (tok.type)
        {
            case TokenType::Identifier:
            {
                Token next_tok = lexer.peek();
                switch (next_tok.type)
                {
                        // declaration, function call, constant declaration, struct, enum, function definition
                    case TokenType::Colon:
                    {
                        AstNode node;
                        lexer.consume();
                        next_tok = lexer.peek();
                        // now either a constant declaration, function definition, or struct/enum definition
                        if (next_tok.type == TokenType::Colon)
                        {
                            lexer.consume();
                            next_tok = lexer.peek();
                        }
                        else if (next_tok.type == TokenType::LParen)
                        {
                            // TODO: Multifile
                        }
                    }
                    break;
                    case TokenType::Dot:
                    {
                        AstNode node;
                        node.data.uni_op_expr = {
                            {&tok.start},
                            OperationKind::MemberAccess,
                        };
                        *ast.head = node;
                        ast.head += 1;
                    }
                    break;

                    default:
                    {
                    }
                }
            }
            break;
            default:
            {
            }
        }
    }
    tok = lexer.consume();
}