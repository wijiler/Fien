#include <ast.hpp>
using namespace Fien;

Ast::Ast()
{
    root = reinterpret_cast<AstNode *>(malloc(sizeof(AstNode) * AstNodeCount));
    head = root;
}

Ast::~Ast()
{
    free(root);
    free(errors);
    head = nullptr;
    error_count = 0;
}
AstNode::NodeData::~NodeData()
{
    // do nothing, fuck you c++ for giving unions constructors and destructors
    // Bjarne, how high were you?
}
AstNode::AstNode(Ast *ast, AstNode::NodeKind kind, AstNode::NodeData data)
{
}