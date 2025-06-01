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
    head = nullptr;
}
AstNode::NodeData::~NodeData()
{
    // do nothing, fuck you c++ for giving unions constructors and destructors
    // Bjarne, how high were you?
}
