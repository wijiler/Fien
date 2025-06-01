#pragma once
#include <cstdint>
#include <string>

namespace Fien
{
    enum class TokenType : uint8_t
    {
        // Gen
        Identifier = 0, // A-Z:a-z*[A-Z : a-z][0-9]

        // Sym
        Colon = 1,   // :
        Equ,         // =
        LParen,      // (
        RParen,      // )
        Dot,         // .
        Into,        // ->
        Pipe,        // ur mom!!!!! |
        Not,         // '!
        Dollar,      // $
        Asterisk,    // '*
        Plus,        // +
        Minus,       // -
        LBrace,      // {
        RBrace,      // }
        LBrack,      // [
        RBrack,      // ]
        FSlash,      // '\'
        BSlash,      // /
        SemiColon,   // ;
        Comma,       // ,
        Hash,        // #
        Ampersand,   // &
        Modulo,      // %
        Note,        // @
        GreaterThan, // >
        LessThan,    // <
        DoubleQuote, // "
        SingleQuote, // '

        // Literal

        NumericalLiteral,
        StringLiteral,

        // Type

        Int64,   // i64
        Float64, // f64
        Int32,   // i32
        Float32, // f32
        Int16,   // i16
        Int8,    // i8
        Uint64,  // u64
        Uint32,  // u32
        Uint16,  // u16
        Uint8,   // u8
        Bool,    // bool
        String,  // str // counted string masterrace

        // Keywords

        Struct, // struct
        Enum,   // enum
        Export, // export
        Match,  // match
        If,     // if COND {}
        Else,

        // Special

        Unknown,
        EndOfFile,
    };
    static const std::string printable_token_type[] = {
        "Identifier",
        "Colon",
        "Equ",
        "LParen",
        "RParen",
        "Dot",
        "Into",
        "Pipe",
        "Not",
        "Dollar",
        "Asterisk",
        "Plus",
        "Minus",
        "LBrace",
        "RBrace",
        "LBrack",
        "RBrack",
        "FSlash",
        "BSlash",
        "SemiColon",
        "Comma",
        "Hash",
        "Ampersand",
        "Modulo",
        "Note",
        "GreaterThan",
        "LessThan",
        "DoubleQuote",
        "SingleQuote",
        "NumericalLiteral",
        "StringLiteral",
        "Int64",
        "Float64",
        "Int32",
        "Float32",
        "Int16",
        "Int8",
        "Uint64",
        "Uint32",
        "Uint16",
        "Uint8",
        "Bool",
        "String",
        "Struct",
        "Enum",
        "Export",
        "Match",
        "If",
        "Else",
        "Unknown",
        "EndOfFile",
    };

    struct Token
    {
        uint64_t start;
        TokenType type;

        Token(TokenType type, uint64_t start);
        ~Token() = default;
    };

    struct Lexer
    {
        std::string file;
        uint64_t index = 0;
        char *head;

        Lexer() = default;
        ~Lexer() = default;

        void open(std::string filename);
        Token consume();
        Token peek();
        void close();

      private:
        constexpr inline void AdvanceChar()
        {
            if (*head == '\0' || index >= file.length())
                return;
            index += 1;
            head += 1;
        };
        constexpr inline void AdvanceChar(uint64_t amount)
        {
            if (*head == '\0' || index + amount >= file.length())
                return;
            index += amount;
            head += amount;
        };
        constexpr char peek_char()
        {
            if (index + 1 < file.length())
            {
                return *(head + 1);
            }
            return '\0';
        }
        constexpr char peek_char(uint64_t amount)
        {
            if (index + amount < file.length())
            {
                return *(head + amount);
            }
            return '\0';
        }
        inline void default_case(Token *tok)
        {
            if (std::isdigit(*head))
            {
                Token lit(TokenType::NumericalLiteral, index);
                while (std::isdigit(*head) || *head == '.')
                {
                    this->AdvanceChar();
                }
                head -= 1;
                *tok = lit;
            }
            else if (std::isalpha(*head))
            {
                Token lit(TokenType::Identifier, index);
                while (std::isalnum(*head))
                {
                    this->AdvanceChar();
                }
                head -= 1;
                *tok = lit;
            }

            else
            {
                *tok = Token(TokenType::Unknown, index);
            }
        }
    };
} // namespace Fien