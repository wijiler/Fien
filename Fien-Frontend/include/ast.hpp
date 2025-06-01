#pragma once

#include <cstdint>
#include <lexer.hpp>
namespace Fien
{
    enum class AstErrorType : uint8_t
    {
    };

    enum class OperationKind : uint8_t
    {
        Addition,
        Subtraction,
        Multiplication,
        Division,
        Modulus,
        PartialEq,
        Equality,
        BitwiseNot,
        BitwiseOr,
        BitwiseAnd,
        BitwiseXor,
        LogicalNot,
        ArrayIndex,
    };
    enum class ValidTypes : uint8_t
    {
        Struct,
        String,
        Int64,
        Float64,
        Uint64,
        Int32,
        Enum,
        Float32,
        Uint32,
        Int16,
        Uint16,
        Int8,
        Uint8,
        Bool,
        Unit,
    };
    typedef struct Ast Ast;
    struct AstNode
    {
        enum class NodeKind : uint8_t
        {
            Expression = 0,
            Scope_Entry,
            BinaryOp,
            UnaryOp,
            Declaration,
            CodeBlock,
            If,
        };
        union NodeData
        {
            struct ExprNode
            {
                void *data;
            };
            ExprNode expr;
            struct ScopeEntryNode
            {
                std::string name;
            };
            ScopeEntryNode scope_entry;
            struct BinOpExprNode
            {
                uint8_t kind;
                ExprNode rhs, lhs;
            };
            BinOpExprNode bin_op_expr;
            struct UniOpExprNode
            {
                OperationKind kind;
                ExprNode expression;
            };
            UniOpExprNode uni_op_expr;
            struct DeclarationNote
            {
                std::string data;
            };
            struct DeclarationNode
            {
                std::string ident;
                ExprNode initial_value;
                DeclarationNote *note;
                ValidTypes type;
            };
            DeclarationNode declaration;
            struct CodeBlockNode
            {
                CodeBlockNode *parent_block; // nullptr if global scope
            };
            struct IfNode
            {
                ExprNode conditional;
                CodeBlockNode block;
            };
            ~NodeData();
        };
        AstNode(Ast *ast, NodeKind kind, NodeData data);
        ~AstNode();
    };

    struct AstError
    {
        Token tok;
        AstErrorType type;
    };
    struct Ast
    {
        AstNode *root;
        AstNode *head;
        AstError *errors;
        uint32_t error_count = 0;
        static inline constexpr uint32_t AstNodeCount = 40000;

        Ast();
        ~Ast();
    };
} // namespace Fien