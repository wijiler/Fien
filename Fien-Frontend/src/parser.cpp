#ifdef DEBUG
#include <iostream>
#endif
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
                std::string ident = std::string(tok.end - tok.start, '\0');
                ident.copy(lexer.file.data(), tok.end - tok.start, tok.start);
                Token next_tok = lexer.peek();
                switch (next_tok.type)
                {
                        // declaration, constant declaration, struct, enum, function definition
                    case TokenType::Colon:
                    {
                        AstNode *node = ast.head;
                        lexer.consume();
                        next_tok = lexer.peek();
                        // now either a constant declaration, function definition, or struct/enum definition
                        if (next_tok.type == TokenType::Colon)
                        {
                            lexer.consume();
                            next_tok = lexer.peek();
                        }
                        else
                        {
                        }
                    }
                    break;
                    case TokenType::Dot:
                    {
                        AstNode *node = ast.head;
                        node->data.uni_op_expr = {
                            {&tok.start},
                            OperationKind::MemberAccess,
                        };
                        ast.head += 1;
                    }
                    break;
                    // function call
                    case TokenType::LParen:
                    {
                        std::string ident = std::string(tok.end - tok.start, '\0');
                        ident.copy(lexer.file.data(), tok.end - tok.start, tok.start);
                        AstNode *node = ast.head;

                        node->kind = AstNode::NodeKind::Proccall;
                        AstNode *oldhead = ast.head;
                        std::string *buf = new std::string[256];
                        ast.head += 1;
                        uint8_t argInc = 0;
                        while (tok.type != TokenType::RParen)
                        {
                            if (tok.type == TokenType::Identifier)
                            {
                                buf[argInc].copy(lexer.file.data(), tok.end - tok.start, tok.start);
                                AstNode *arg = ast.head;
                                arg->kind = AstNode::NodeKind::Expression;
                                arg->data.expr.data = buf[argInc].data();
                                argInc += 1;
                                ast.head += 1;
                            }
                            tok = lexer.consume();
                        }
                        tok = lexer.consume();
                        node->data.proc_call.fun = ident.data();
                        if (argInc > 0)
                        {
                            node->data.proc_call.args = &(oldhead + 1)->data.expr;
                            node->data.proc_call.args_count = argInc;
                        }
                        else
                        {
                            node->data.proc_call.args = nullptr;
                            node->data.proc_call.args_count = 0;
                        }
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