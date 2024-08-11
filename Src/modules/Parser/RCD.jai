exprNode :: struct {
    identifier:string;
    type:TYPE;
    value:string;
}


functionNode :: struct {
    args:[..] exprNode;
    rettype:TYPE;
    ret:exprNode;
}


Node :: struct {
    type:enum u8 {
        function   :: 0;
        expression :: 1;
    }
    value:union {
        expr:exprNode;
        fnNode:functionNode;
    }
    children:*Node;
}

AST :: struct {
    RootNode:Node;
}


parse :: (tokens:[] TOKEN) -> AST {
    tree:AST;
    for token:tokens {
        if token.tokentype =={
            case .k_let;
            node := parse_variable(tokens,it_index,*tree);
            add_node(node,*tree);
            case;;
        }
    }

    return tree;
}

add_node :: (node:Node,tree:*AST) {
        tree.RootNode = node;
}

parse_variable :: (tokens:[] TOKEN,start:int,ast:*AST) -> Node {
        node:exprNode;
        ident := tokens[start + 1];
        node.identifier = ident.lexeme;
        if tokens[start + 2].tokentype != .col {
            print("variable % missing typeinfo\n",node.identifier);
        }
        typeinfo := tokens[start + 3];
        if typeinfo.tokentype =={
            case .t_int;
            node.type = .{.Int,""};
            
            case .t_bool;
            node.type = .{.Bool,""};

            case .t_float;
            node.type = .{.Float,""};

            case .t_char;
            node.type = .{.Char,""};

            case .t_string;
            node.type = .{.String,""};
            
            case .type;
            for str:structs {
                if typeinfo.lexeme == str.name {
                    node.type = .{.Struct,str.name};
                    break;
                }
            }
            for en:enums {
                if typeinfo.lexeme == en.name {
                    node.type = .{.Enum,en.name};
                    break;
                }
            }
            #through;
            case;
            print("unknown type for variable %\n",node.identifier);
        }
    nnode:Node = .{type = .expression,value.expr = node};
    return nnode;
}
parse_function :: (tokens:[] TOKEN,start:int) -> Node,int {

}

#scope_file
structs:[..] STRUCTTYPE;
enums:[..] ENUMTYPE;
STRUCTTYPE :: struct {
    name:string;
    constructor:string;
}
ENUMTYPE :: struct {
    name:string;
    members:[] string;
}

TYPE :: struct {
    type:enum u8 {
        Int    :: 0;
        Bool   :: 1;
        Float  :: 2;
        Char   :: 3;
        String :: 4;
        Struct :: 5;
        Enum   :: 6;
    }
    info:string;
}

#import "Lexer";
#import "Basic";