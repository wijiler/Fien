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
        MemberAccess,
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
        union NodeData
        {
            struct ExprNode
            {
                void *data;
            };
            ExprNode expr;
            struct ScopeEntryNode
            {
                char *name;
                ScopeEntryNode *parent; // nullptr if global scope
            };
            ScopeEntryNode scope_entry;
            struct ScopeExitNode
            {
            } scope_exit;
            struct BinOpExprNode
            {
                ExprNode rhs, lhs;
                uint8_t kind;
            };
            BinOpExprNode bin_op_expr;
            struct UniOpExprNode
            {
                ExprNode expression;
                OperationKind kind;
            };
            UniOpExprNode uni_op_expr;
            struct DeclarationNote
            {
                char *data;
            };
            struct DeclarationNode
            {
                char *ident;
                DeclarationNote *note; // nullptr if no note
                ExprNode value;        // nullptr if uninitialized
                ValidTypes type;
                uint8_t is_const;
            };
            DeclarationNode declaration;
            struct CodeBlockNode
            {
                AstNode *children;
                ScopeEntryNode scope; // scope created by this codeblock
                uint64_t child_count;
            };
            CodeBlockNode code_block;
            struct IfNode
            {
                CodeBlockNode code;
                CodeBlockNode *else_statement; // nullptr if no else
                ExprNode conditional;
            };
            IfNode if_statement;
            struct StructNode
            {
                CodeBlockNode block;
                DeclarationNote *note; // nullptr if no note
            };
            StructNode struct_node;
            struct EnumNode
            {
                DeclarationNode *members; // empty enum is error, always full, always constant
                DeclarationNote *note;    // nullptr if no note
                uint64_t member_count;
            };
            struct ProcNode
            {
                CodeBlockNode block;
                DeclarationNode *args; // nullptr if no args
                DeclarationNote *note; // nullptr if no note
                uint8_t arg_count;     // you're genuinely sick if you have more than 256 args and dont combine it into a struct type
            };
            ProcNode procedure;
            struct MatchCaseNode
            {
                CodeBlockNode code;
                ExprNode condition;
            };
            struct MatchNode
            {
                MatchCaseNode *cases;
                ExprNode condition;
                uint64_t case_count;
            };
            MatchNode match;
            struct ProcCallNode
            {
                char *fun;
                ExprNode *args;
                uint8_t args_count;
            };
            ProcCallNode proc_call;
            ~NodeData();
        } data;

        enum class NodeKind : uint8_t
        {
            Expression = 0,
            Scope_Entry,
            BinaryOp,
            UnaryOp,
            Declaration,
            CodeBlock,
            If,
            Else,
            Struct,
            Enum,
            Match,
            Procdef,
            Proccall,
        } kind;
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

        static inline constexpr uint32_t AstNodeCount = 40000;

        Ast();
        ~Ast();
    };
} // namespace Fien