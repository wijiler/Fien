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
            case .k_struct;
            parse_struct(tokens,it_index);
            case;;
        }
    }

    return tree;
}

add_node :: (node:Node,tree:*AST) {
        tree.RootNode = node;
}

parse_enum :: () {

}

parse_struct :: (tokens:[] TOKEN,start:int) {
    st:STRUCTTYPE = .{};
    name := tokens[start + 1].lexeme;
    enter_scope(.{.STRUCT,name});

    if nested_scope(.{.STRUCT,""}) then name = sprint("%.%",get_outer_scope_name(.{.STRUCT,""},"."),name);
    // here literally just so I dont have to change shit again
    i:int = start + 1;
    while tokens[i].tokentype != .lbrack {
        i += 1;
    }
    constructor:String_Builder;
    append(*constructor,"{");
    while tokens[i].tokentype != .rbrack {
        if tokens[i].tokentype =={
            case .m_struct;
            // TODO: error if no typeinfo, add to members if correct
            if tokens[i + 1].tokentype != .col {
                print("cannot find typeinfo for member % of struct %\n",tokens[i].lexeme,name);
                exit(1);
            }
            if tokens[i+2].tokentype == {
            case .t_int;;
            case .t_char;;            
            case .t_bool;;
            case .t_float;;
            case .t_string;;
            case .type;;
            case;
                print("cannot find typeinfo for member % of struct %\n",tokens[i].lexeme,name);
                exit(1);
            }


            case .t_int;
            append(*constructor,"int");
            
            case .t_char;
            append(*constructor,"char");
            
            case .t_bool;
            append(*constructor,"bool");
            
            case .t_float;
            append(*constructor,"float");
            
            case .t_string;
            append(*constructor,"string");
            

            case .k_struct;
            parse_struct(tokens,i);

            case .type;
            for str:structs {
                if tokens[i].lexeme == str.name {
                    append(*constructor,str.constructor);
                    break;
                }
            }
            for en:enums {
                if tokens[i].lexeme == en.name {
                    append(*constructor,"|");
                    for member:en.members {
                        append(*constructor,member);
                        append(*constructor,",");
                    }
                    break;
                }
            }
            case;;
        }
        append(*constructor,",");
        i += 1;
    }
    append(*constructor,"}");
    
    exit_scope();

    st.name = name;
    st.constructor = builder_to_string(*constructor);
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
parse_function :: (tokens:[] TOKEN,start:int) -> Node {

}

#scope_file
structs:[..] STRUCTTYPE;
enums:[..] ENUMTYPE;
STRUCTTYPE :: struct {
    name:string;
    constructor:string;
    members:[..] string;
}
ENUMTYPE :: struct {
    name:string;
    members:[..] string;
}

scope:[..] Scope;

get_outer_scope_name :: (s:Scope,separator:string) -> string {
    if scope.count == 1 then return "";
    if scope.count == 0 then return "";
    i := scope.count - 1;
    sb:String_Builder;
    while scope[i].scope == s.scope {
        append(*sb,separator);
        append(*sb,scope[i].info);
        i -= 1;
    }
    str := builder_to_string(*sb);
    str.data += 1;
    str.count -= 1;
    return str;
}

enter_scope :: (s:Scope) {
    if scope.count > 0 && scope[scope.count - 1].scope == .GLOBAL then pop(*scope);
    if s.scope == .GLOBAL then array_reset(*scope);
    array_add(*scope,s);
}

exit_scope :: () {
    if scope.count > 0 && scope[scope.count - 1].scope != .GLOBAL then pop(*scope);
    if scope.count == 0 then array_add(*scope,.{.GLOBAL,""});
}

nested_scope :: (s:Scope) -> bool {
    if scope.count > 1 && scope[scope.count - 2].scope == s.scope then return true; else return false;
}

nested_scope :: () -> bool {
    if scope.count > 1 then return true; else return false;
}

outer_scope :: () -> Scope #expand {
    if nested_scope() then return scope[scope.count - 2];

    print("trying to find non existant scope");
    return .{};
}

Scope :: struct {
    scope:enum u8 {
    STRUCT       :: 1;
    FUNCTION     :: 2;
    ENUM         :: 3;
    IF_STATEMENT :: 4;
    ELSE         :: 5;
    MATCH        :: 6;
    MATCH_CASE   :: 7;



    GLOBAL            :: 255;
    }
    info:string;
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