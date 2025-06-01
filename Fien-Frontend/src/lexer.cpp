#include <filesystem>
#include <fstream>
#include <iostream>
#include <lexer.hpp>

using namespace Fien;

Token::Token(TokenType type, uint64_t index)
{
    this->type = type;
    start = index;
}

void Lexer::open(std::string filename)
{
    size_t size = std::filesystem::file_size(filename);
    this->file = std::string(size + 1, '\0');
    std::ifstream file(filename);
    if (!file.is_open())
    {
        std::cout << "could not open file %" << filename << "\n";
    }
    file.read(&this->file[0], size);
    file.close();
    head = this->file.data();
}

void Lexer::close()
{
    file.clear();
}

Token Lexer::consume()
{
    // skip whitespace and comments
    while (std::isspace(*head))
        AdvanceChar();
    if (*head == '/')
    {
        if (peek_char() == '/')
        {
            AdvanceChar(2);
            for (int i = index; i < file.length(); i = index)
            {
                if (*head == '\n')
                    break;
                AdvanceChar();
            }
            while (std::isspace(*head))
                AdvanceChar();
        }
    }

    Token tok(TokenType::Unknown, index);

    if (index >= file.length())
    {
        tok = Token(TokenType::EndOfFile, index);
        return tok;
    }
    // lex
    switch (*head)
    {
        case 'e':
        {
            if (peek_char() == 'n' && peek_char(2) == 'u' && peek_char(3) == 'm')
            {
                tok = Token(TokenType::Enum, index);
                AdvanceChar(3);
            }
            else if (peek_char() == 'x' && peek_char(2) == 'p' && peek_char(3) == 'o' && peek_char(4) == 'r' && peek_char(5) == 't')
            {
                tok = Token(TokenType::Export, index);
                AdvanceChar(5);
            }
            else if (peek_char() == 'l' && peek_char(2) == 's' && peek_char(3) == 'e')
            {
                tok = Token(TokenType::Else, index);
                AdvanceChar(3);
            }
            else
                default_case(&tok);
        }
        break;
        case 's':
        {
            if (peek_char() == 't' && peek_char(2) == 'r')
            {
                if (peek_char(3) == 'u')
                {
                    if (peek_char(4) == 'c' && peek_char(5) == 't')
                    {
                        tok = Token(TokenType::Struct, index);
                        AdvanceChar(5);
                    }
                    else
                        default_case(&tok);
                }
                else
                {
                    tok = Token(TokenType::String, index);
                    AdvanceChar(2);
                }
            }
            else
                default_case(&tok);
        }
        break;
        case 'm':
        {
            if (peek_char() == 'a' && peek_char(2) == 't' && peek_char(3) == 'c' && peek_char(4) == 'h')
            {
                tok = Token(TokenType::Match, index);
                AdvanceChar(4);
            }
            else
                default_case(&tok);
        }
        break;
        case 'b':
        {
            if (peek_char() == 'o' && peek_char(2) == 'o' && peek_char(3) == 'l')
            {
                tok = Token(TokenType::Bool, index);
                AdvanceChar(3);
            }
            else
                default_case(&tok);
        }
        break;
        case 'f':
        {
            switch (peek_char())
            {
                case '6':
                {
                    if (peek_char(2) == '4')
                    {
                        tok = Token(TokenType::Float64, index);
                        AdvanceChar(2);
                    }
                    else
                        default_case(&tok);
                }
                break;
                case '3':
                {
                    if (peek_char(2) == '2')
                    {
                        tok = Token(TokenType::Float32, index);
                        AdvanceChar(2);
                    }
                    else
                        default_case(&tok);
                }
                break;
                default:
                    default_case(&tok);
            }
        }
        break;
        case 'u':
        {
            switch (peek_char())
            {
                case '6':
                {
                    if (peek_char(2) == '4')
                    {
                        tok = Token(TokenType::Uint64, index);
                        AdvanceChar(2);
                    }
                    else
                        default_case(&tok);
                }
                break;
                case '3':
                {
                    if (peek_char(2) == '2')
                    {
                        tok = Token(TokenType::Uint32, index);
                        AdvanceChar(2);
                    }
                    else
                        default_case(&tok);
                }
                break;
                case '1':
                {
                    if (peek_char(2) == '6')
                    {
                        tok = Token(TokenType::Uint16, index);
                        AdvanceChar(2);
                    }
                    else
                        default_case(&tok);
                }
                break;
                case '8':
                {
                    tok = Token(TokenType::Uint8, index);
                    AdvanceChar();
                }
                break;
                default:
                    default_case(&tok);
            }
        }
        break;
        case 'i':
        {
            switch (peek_char())
            {
                case '6':
                {
                    if (peek_char(2) == '4')
                    {
                        tok = Token(TokenType::Int64, index);
                        AdvanceChar(2);
                    }
                    else
                        default_case(&tok);
                }
                break;
                case '3':
                {
                    if (peek_char(2) == '2')
                    {
                        tok = Token(TokenType::Int32, index);
                        AdvanceChar(2);
                    }
                    else
                        default_case(&tok);
                }
                break;
                case '1':
                {
                    if (peek_char(2) == '6')
                    {
                        tok = Token(TokenType::Int16, index);
                        AdvanceChar(2);
                    }
                    else
                        default_case(&tok);
                }
                break;
                case '8':
                {
                    tok = Token(TokenType::Int8, index);
                    AdvanceChar();
                }
                break;
                case 'f':
                {
                    if (!std::isalnum(peek_char(2)))
                    {
                        tok = Token(TokenType::If, index);
                        AdvanceChar();
                    }
                }
                break;
                default:
                    default_case(&tok);
            }
        }
        break;
        case ':':
        {
            tok = Token(TokenType::Colon, index);
        }
        break;
        case '=':
        {
            tok = Token(TokenType::Equ, index);
        }
        break;
        case '(':
        {
            tok = Token(TokenType::LParen, index);
        }
        break;
        case ')':
        {
            tok = Token(TokenType::RParen, index);
        }
        break;
        case '.':
        {
            tok = Token(TokenType::Dot, index);
        }
        break;
        case '|':
        {
            tok = Token(TokenType::Pipe, index);
        }
        break;
        case '!':
        {
            tok = Token(TokenType::Not, index);
        }
        break;
        case '$':
        {
            tok = Token(TokenType::Dollar, index);
        }
        break;
        case '*':
        {
            tok = Token(TokenType::Asterisk, index);
        }
        break;
        case '+':
        {
            tok = Token(TokenType::Plus, index);
        }
        break;
        case '-':
        {
            AdvanceChar();
            if (*head == '>')
            {
                AdvanceChar();
                tok = Token(TokenType::Into, index);
            }
            else
            {
                tok = Token(TokenType::Minus, index);
            }
        }
        break;
        case '{':
        {
            tok = Token(TokenType::LBrace, index);
        }
        break;
        case '}':
        {
            tok = Token(TokenType::RBrace, index);
        }
        break;
        case '[':
        {
            tok = Token(TokenType::LBrack, index);
        }
        break;
        case ']':
        {
            tok = Token(TokenType::RBrack, index);
        }
        break;
        case '\\':
        {
            tok = Token(TokenType::FSlash, index);
        }
        break;
        case '/':
        {
            tok = Token(TokenType::BSlash, index);
        }
        break;
        case ';':
        {
            tok = Token(TokenType::SemiColon, index);
        }
        break;
        case ',':
        {
            tok = Token(TokenType::Comma, index);
        }
        break;
        case '#':
        {
            tok = Token(TokenType::Hash, index);
        }
        break;
        case '&':
        {
            tok = Token(TokenType::Ampersand, index);
        }
        break;
        case '%':
        {
            tok = Token(TokenType::Modulo, index);
        }
        break;
        case '@':
        {
            tok = Token(TokenType::Note, index);
        }
        break;
        case '>':
        {
            tok = Token(TokenType::GreaterThan, index);
        }
        break;
        case '<':
        {
            tok = Token(TokenType::LessThan, index);
        }
        break;
        case '\"':
        {
            tok = Token(TokenType::DoubleQuote, index);
        }
        break;
        case '\'':
        {
            tok = Token(TokenType::SingleQuote, index);
        }
        break;
        case '\0':
        {
            tok = Token(TokenType::EndOfFile, index);
        }
        break;
        default:
        {
            default_case(&tok);
        }
    }
    AdvanceChar();
    return tok;
}

Token Lexer::peek()
{
    char *oldhead = head;
    Token tok = consume();
    head = oldhead;
    return tok;
}