r:int = 1;
c:int = 1;

message:[..] MESSAGE;
#run array_add(*message,.GLOBAL);
potential_scope: MESSAGE;

MESSAGE :: enum u8 {
    DEFAULT           :: 0;
    SCOPED_STRUCT     :: 1;
    SCOPED_FN         :: 2;
    SCOPED_ENUM       :: 3;
    SCOPED_IF         :: 4;
    SCOPED_ELSE       :: 5;
    SCOPED_MATCH      :: 6;
    SCOPED_MATCH_CASE :: 7;



    GLOBAL            :: 255;
}

change_scope :: (scope:MESSAGE) {
    potential_scope = scope;
    if message.count != 0 && message[message.count - 1] == .GLOBAL then pop(*message);
}

lex :: (filename:string) -> [] TOKEN {

    tokens: [..] TOKEN;

    file,success := read_entire_file(filename);
    if !success {
        print("Could not find file % E001 \n",filename);
        exit(1);
    }
    file = to_lower_copy_new(file);

    for 0..file.count - 1 {
        c += 1;
            if file[it]== {
            case #char "f";
            if lexer_peek(1) == #char "n" {
                if is_alnum(lexer_peek(2)) then unknown_token_error(r,c,it,file);
                array_add(*tokens, .{"",.k_fn});
                array_add(*tokens,.{add_function(it+3,true),.identifier});

                change_scope(.SCOPED_FN);
            }
            else if lexer_peek(1) == #char "l" && lexer_peek(2) == #char "o" && lexer_peek(3) == #char "a" && lexer_peek(4) == #char "t" { 
                if is_alnum(lexer_peek(5)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.t_float}); 
                it +=4; 
            }
            else if lexer_peek(1) == #char "a" && lexer_peek(2) == #char "l" && lexer_peek(3) == #char "s" && lexer_peek(4) == #char "e" { 
                if is_alnum(lexer_peek(5)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.k_false}); 
                it += 4; 
            }
            else {
                check();
            }

            case #char "(";
            array_add(*tokens,.{"",.lparen});
            array_add(*tokens,..lex_arguments());

            case #char "i";
            if lexer_peek(1) == #char "n" && lexer_peek(2) == #char "t" { 
                if is_alnum(lexer_peek(3)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.t_int}); 
                it += 2;
            }
            else if lexer_peek(1) == #char "f" {
                if is_alnum(lexer_peek(2)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.k_if}); 
                i:int = it + 2;
                builder:String_Builder;
                while i <= file.count - 1 && file[i] != #char "{" {
                    append(*builder,file[i]);
                    i += 1;
                }
                array_add(*tokens,.{builder_to_string(*builder),.expression});
                it = i - 1;
                change_scope(.SCOPED_IF);
            }
            else {
                check();
            }

            case #char "c";
            if lexer_peek(1) == #char "h" && lexer_peek(2) == #char "a" && lexer_peek(3) == #char "r" {
                if is_alnum(lexer_peek(4)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.t_char}); 
                it += 3;
            }
            else {
                check();
            }

            case #char ":"; 
            array_add(*tokens,.{"",.col});

            case #char "b";
            if lexer_peek(1) == #char "o" && lexer_peek(2) == #char "o" && lexer_peek(3) == #char "l" { 
                if is_alnum(lexer_peek(4)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.t_bool}); 
                it +=3; 
            }
            else {
                check();
            }

            case #char "s";
            if lexer_peek(1) == #char "t" && lexer_peek(2) == #char "r" {
                if lexer_peek(3) != #char "u" then {
                    if is_alnum(lexer_peek(3)) then unknown_token_error(r,c,it,file);
                    array_add(*tokens,.{"",.t_string}); 
                    it += 2;
                }
                else if lexer_peek(4) == #char "c" && lexer_peek(5) == #char "t" {
                    if is_alnum(lexer_peek(6)) then unknown_token_error(r,c,it,file);
                    array_add(*tokens, .{"",.k_struct});
                    // ident
                    i:int = 6;
                    while !is_alnum(file[it+i]) {
                        i += 1;
                    }
                    ident := add_type(it+i,true);
                    array_add(*tokens,.{ident,.type});
                    change_scope(.SCOPED_STRUCT);
                }
            }
            else {
                check();
            }

            case #char "e";
            if lexer_peek(1) == #char "n" && lexer_peek(2) == #char "u" && lexer_peek(3) == #char "m" {
                    if is_alnum(lexer_peek(4)) then unknown_token_error(r,c,it,file);
                    array_add(*tokens, .{"",.k_enum});
                    // ident
                    identcounter:int = 4;

                    while !is_alnum(file[it+identcounter]) {
                        identcounter += 1;
                    }

                    ident := add_type(it+identcounter,true);
                    array_add(*tokens,.{ident,.type});

                    // find the enum's members and add them as valid types and identifiers
                    // TODO: make $IDENT$. a type and the types valid identifiers? Might be easier for the parser
                    i:int = it;
                    while file[i] != #char "{" {
                        i += 1;
                    }
                    if file[i] == #char "{" {
                        array_add(*tokens,.{"",.lbrack});
                        find_enum();
                    }
                    change_scope(.SCOPED_ENUM);
            }
            else if lexer_peek(1) == #char "l" && lexer_peek(2) == #char "s" && lexer_peek(3) == #char "e" {
                    if is_alnum(lexer_peek(4)) then unknown_token_error(r,c,it,file);
                    array_add(*tokens, .{"",.k_else});
                    it += 4;
                    change_scope(.SCOPED_STRUCT);
            }
            else {
                check();
            }

            case #char "l";
            if lexer_peek(1) == #char "e" && lexer_peek(2) == #char "t" {
                if is_alnum(lexer_peek(3)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.k_let});
                array_add(*tokens,.{add_identifier(it+4,true),.identifier});
            }
            else {
                check();
            }

            
            case #char "r";
            if lexer_peek(1) == #char "e" && lexer_peek(2) == #char "t" {
                if is_alnum(lexer_peek(3)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.k_ret});
                array_add(*tokens,.{add_expression(it+4),.expression});
            }
            else {
                check();
            }

            case #char "m";
            if lexer_peek(1) == #char "a" && lexer_peek(2) == #char "t" && lexer_peek(3) == #char "c" && lexer_peek(4) == #char "h" {
                array_add(*tokens,.{"",.k_match});
                it += 4;
                change_scope(.SCOPED_MATCH);
            }
            else {
                check();
            }


            case #char "=";
            array_add(*tokens,.{"",.eq});
            array_add(*tokens,.{add_expression(it+2),.expression});

            case #char "-";
            if lexer_peek(1) == #char "<" {
                array_add(*tokens,.{add_identifier(it+3,false),.r_type});
            } 
            else if lexer_peek(1) == #char ">" { 

                array_add(*tokens,.{"",.sh_ret});
                array_add(*tokens,.{add_expression(it+2),.expression});
                if message.count != 0 && message[message.count - 1] == .SCOPED_FN {
                    pop(*message);
                }
            }


            case #char "0";
            i := it;
            builder:String_Builder;
            fl:bool = false;
            while i <= file.count && (is_digit(file[i]) || file[i] == #char ".") {
                if file[i] == #char "." then fl = true;
                append(*builder,file[i]);
                i += 1;
            }
            if fl then array_add(*tokens,.{builder_to_string(*builder),.float_literal});
            else array_add(*tokens,.{builder_to_string(*builder),.int_literal});
            it = i + 1;

            case #char "1";
            i := it;
            builder:String_Builder;
            fl:bool = false;
            while i <= file.count && (is_digit(file[i]) || file[i] == #char ".") {
                if file[i] == #char "." then fl = true;
                append(*builder,file[i]);
                i += 1;
            }
            if fl then array_add(*tokens,.{builder_to_string(*builder),.float_literal});
            else array_add(*tokens,.{builder_to_string(*builder),.int_literal});
            it = i + 1;
            
            case #char "2";
            i := it;
            builder:String_Builder;
            fl:bool = false;
            while i <= file.count && (is_digit(file[i]) || file[i] == #char ".") {
                if file[i] == #char "." then fl = true;
                append(*builder,file[i]);
                i += 1;
            }
            if fl then array_add(*tokens,.{builder_to_string(*builder),.float_literal});
            else array_add(*tokens,.{builder_to_string(*builder),.int_literal});
            it = i + 1;
            
            case #char "3";
            i := it;
            builder:String_Builder;
            fl:bool = false;
            while i <= file.count && (is_digit(file[i]) || file[i] == #char ".") {
                if file[i] == #char "." then fl = true;
                append(*builder,file[i]);
                i += 1;
            }
            if fl then array_add(*tokens,.{builder_to_string(*builder),.float_literal});
            else array_add(*tokens,.{builder_to_string(*builder),.int_literal});
            it = i + 1;
            
            case #char "4";
            i := it;
            builder:String_Builder;
            fl:bool = false;
            while i <= file.count && (is_digit(file[i]) || file[i] == #char ".") {
                if file[i] == #char "." then fl = true;
                append(*builder,file[i]);
                i += 1;
            }
            if fl then array_add(*tokens,.{builder_to_string(*builder),.float_literal});
            else array_add(*tokens,.{builder_to_string(*builder),.int_literal});
            it = i + 1;
            
            case #char "5";
            i := it;
            builder:String_Builder;
            fl:bool = false;
            while i <= file.count && (is_digit(file[i]) || file[i] == #char ".") {
                if file[i] == #char "." then fl = true;
                append(*builder,file[i]);
                i += 1;
            }
            if fl then array_add(*tokens,.{builder_to_string(*builder),.float_literal});
            else array_add(*tokens,.{builder_to_string(*builder),.int_literal});
            it = i + 1;
            
            case #char "6";
            i := it;
            builder:String_Builder;
            fl:bool = false;
            while i <= file.count && (is_digit(file[i]) || file[i] == #char ".") {
                if file[i] == #char "." then fl = true;
                append(*builder,file[i]);
                i += 1;
            }
            if fl then array_add(*tokens,.{builder_to_string(*builder),.float_literal});
            else array_add(*tokens,.{builder_to_string(*builder),.int_literal});
            it = i + 1;
            
            case #char "7";
            i := it;
            builder:String_Builder;
            fl:bool = false;
            while i <= file.count && (is_digit(file[i]) || file[i] == #char ".") {
                if file[i] == #char "." then fl = true;
                append(*builder,file[i]);
                i += 1;
            }
            if fl then array_add(*tokens,.{builder_to_string(*builder),.float_literal});
            else array_add(*tokens,.{builder_to_string(*builder),.int_literal});
            it = i + 1;
            
            case #char "8";
            i := it;
            builder:String_Builder;
            fl:bool = false;
            while i <= file.count && (is_digit(file[i]) || file[i] == #char ".") {
                if file[i] == #char "." then fl = true;
                append(*builder,file[i]);
                i += 1;
            }
            if fl then array_add(*tokens,.{builder_to_string(*builder),.float_literal});
            else array_add(*tokens,.{builder_to_string(*builder),.int_literal});
            it = i + 1;
            
            case #char "9";
            i := it;
            builder:String_Builder;
            fl:bool = false;
            while i <= file.count && (is_digit(file[i]) || file[i] == #char ".") {
                if file[i] == #char "." then fl = true;
                append(*builder,file[i]);
                i += 1;
            }
            if fl then array_add(*tokens,.{builder_to_string(*builder),.float_literal});
            else array_add(*tokens,.{builder_to_string(*builder),.int_literal});
            it = i + 1;


            case #char "t";
            if lexer_peek(1) == #char "r" && lexer_peek(2) == #char "u" && lexer_peek(3) == #char "e" {
                if is_alnum(lexer_peek(4)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.k_true});
                it += 4;
            }
            else {
                check();
            }

            case #char "\"";
            i := it + 1;
            builder:String_Builder;
            while i <= file.count && file[i] != #char "\"" {
                append(*builder,file[i]);
                i += 1;
            }
            array_add(*tokens,.{builder_to_string(*builder),.string_literal});
            it = i + 1;

            case #char ")";
            array_add(*tokens,.{"",.rparen});
            case #char "{";
            array_add(*tokens,.{"",.lbrack});
            array_add(*message,potential_scope);
            case #char "}";
            array_add(*tokens,.{"",.rbrack});
            if message.count == 0 {
                change_scope(.GLOBAL);
            }
            if message.count != 0 then pop(*message);
            array_reset(*identifiers);

            case #char "\r";
            r += 1;
            c = 0;
            it += 1;
            case #char "\n";
            r += 1;
            c = 0;
            case #char " ";;
            case #char "\t";
            c+= 4;
            case #char "^";
            array_add(*tokens,.{"",.carat});

            case;
            check();
        }
    }
    print("%\n",message);
    return tokens;
}


check :: () #expand {
    ident,skip := check_identifier(`it,`file);
    
    if array_find(identifiers,ident) {
        array_add(*`tokens,.{ident,.identifier});
        `it = skip;
    }
    else if array_find(global_idents,ident) {
        array_add(*`tokens,.{ident,.identifier});
        `it = skip;
    }
    else if array_find(global_functions,ident) {
        array_add(*`tokens,.{ident,.identifier});
        `it = skip;
    }
        else if array_find(functions,ident) {
        array_add(*`tokens,.{ident,.identifier});
        `it = skip;
    }
    else if array_find(ltypes,ident) {
        array_add(*`tokens,.{ident,.type});
        `it = skip;
    }
    else {
    it := `it;
    tokens := `tokens;
    unknown_token_error(r,c,it,`file);
    `it = it;
    `tokens = tokens;
    }
}

TOKEN :: struct {
    lexeme:string;
    tokentype: enum u8 {
        identifier    :: 255;
        k_ret         :: 254;
        k_let         :: 253;
        sh_ret        :: 252; // ->
        int_literal   :: 251;
        k_fn          :: 250;
        c_fn          :: 249;
        type          :: 247;
        expression    :: 246;
        k_struct      :: 245;
        m_struct      :: 244;
        k_enum        :: 243;
        k_match       :: 242;
        c_match       :: 240;
        k_default     :: 239;
    
       string_literal :: 238;
       float_literal  :: 237;
        
        k_true        :: 236;
        k_false       :: 235;


        eq            :: 234;
        col           :: 233;
        lparen        :: 232;
        rparen        :: 231;
        lbrack        :: 230;
        rbrack        :: 229;
        lbrace        :: 228;
        rbrace        :: 227;
        carat         :: 226;

        r_type        :: 225; // -<

        k_if          :: 224;
        k_else        :: 223;

        t_int         :: 222;
        t_char        :: 221;
        t_bool        :: 220;
        t_float       :: 219;
        t_string      :: 218;
        // other custom tokens work, as this is a u8 IF_NEEDED: increase to a u16
    }
}

#scope_file

// ! Lexing library
identifiers: [..] string;
global_idents: [..] string;
global_functions: [..] string;
functions: [..] string;
ltypes: [..] string;


add_function :: (start:int,new:bool) -> string #expand {
    builder:String_Builder;
    i:int = start;
    while  i <= `file.count - 1 && is_alnum(`file[i])  {
        append(*builder,`file[i]);
        i += 1;
    }
    ident:string = builder_to_string(*builder);
    if message.count > 0 && new && message[message.count - 1] == .GLOBAL then array_add(*global_functions,ident);
    if new then array_add(*functions,ident);
    `it = i;
    return ident;
}



find_enum :: () #expand {
    skip:int = 1;
    e:int = `i;
    while `file[e] != #char "}" {
        e += 1;
    }
    //filter out characters we dont want
    // TODO: make this more efficient
    members := string_slice(`file,`i + 1,e - 1);
    members = replace(members,"\t","");
    members,skip = replace(members,"\n","");
    members = replace(members,"\r","");
    members = replace(members," ","");
    // Split into individual members
    a_members := split(members,",");
    for member: a_members {
        if member != "" {
        array_add(*`identifiers,sprint("%.%",`ident,member));
        array_add(*`tokens,.{member,.identifier});
        }
    }
    `r += skip;
    `it = e - 1;
}




string_slice :: (T:string,from:int,to:int) -> string {
    builder:String_Builder;
    assert(from < T.count);
    assert(from < to);

    for from..to {
        append(*builder,T[it]);
    }
    return builder_to_string(*builder);
}

string_reverse :: (str:string) -> string {
    rev:string = str;
    i:int = 0;
    j:int = str.count-1;
    while i <= j {
        c:u8 = rev[i];
        rev[i] = rev[j];
        rev[j] = c;
        i += 1;
        j -= 1;
    }
    return rev;
}

scope_is_nested :: () -> bool {
    if message.count >= 2 then return true; else return false;
}

operator== :: (a:TOKEN,b:TOKEN) -> bool {
    if a.lexeme == b.lexeme && a.tokentype == b.tokentype then return true; else return false;
}

unknown_token_error :: (r:int,c:int,i:int,file:string) #expand {
        // In parser during error checking make sure m_struct never comes before "{" in a nested struct
        if message.count > 0 && message[message.count-1] == .SCOPED_STRUCT {
            i2:int = i;
            while file[i2] != #char ":" && i2 <= file.count-1 {
                if file[i2] == #char "}" then break;
                i2 += 1;
            }
            
            if file[i2] == #char ":" {
                    it := i;
                    ident := add_identifier(i,false);
                    array_add(*`tokens,.{ident,.m_struct});
                    `it += ident.count - 1;
                    return;
            }
        }
        if message.count > 0 && message[message.count-1] == .SCOPED_MATCH {
            it := `it;
            ident := add_identifier(it,false);
            if ident == "default" then array_add(*`tokens,.{"",.k_default}); else array_add(*`tokens,.{ident,.c_match});
            change_scope(.SCOPED_MATCH_CASE);
            `it = it;
            return;
        }
    // Backtrack
    counterLine:int = i;
    lineB:String_Builder;
    test:String_Builder;
    while counterLine <= file.count - 1 && !is_nl(file[counterLine]) {
        counterLine += 1;
    }
    counterLine -= 1;
    while counterLine >= 0 {
        if file[counterLine] == #char "\n" {
            break;
        }
        if file[counterLine] == #char "\r" {
            break;
        }
        append(*lineB,file[counterLine]);
        counterLine -= 1;
    }
    
    line := builder_to_string(*lineB);
    line = string_reverse(line);

    tokapp:String_Builder;
    tokCounter := i;
    while tokCounter <= file.count - 1 && is_alnum(file[tokCounter]) && !is_whitespace(file[tokCounter]) {
        append(*tokapp,file[tokCounter]);
        tokCounter += 1;
    }
    tok := builder_to_string(*tokapp);

    print("\x1B[1m\x1B[31mError\x1B[0m: Unknown token \"%\" found at line:% column:%\n",tok,r,c);
    print("┃\n┃\n└▶ %\n",line);

    len := line.count;
    pointerBuilder:String_Builder;
    for 0..len {
        append(*pointerBuilder," ");
    }
    pointer:string = builder_to_string(*pointerBuilder);
    caratCounter:int = tok.count;
    while caratCounter > 0 {
        pointer[caratCounter] = #char "^";
        caratCounter -= 1;
    }
    print("%\n",string_reverse(pointer));

    exit(0);
}

remove_whitespace :: (str:string) -> string {
    builder:String_Builder;
    for 0..str.count - 1 {
        if is_whitespace(str[it]) then it += 1; else append(*builder,str[it]);
    }
    return builder_to_string(*builder);
}

is_whitespace :: (char:u8) -> bool {
    if char == #char " " || char == #char "\t" {
        return true;
    }
    return false;
}

is_nl :: (char:u8) -> bool {
    if char == #char "\r" || char == #char "\n" {
        return true;
    }
    return false;
}

add_expression :: (start:int) -> string #expand {
    builder:String_Builder;
    i:int = 0;
    while  i <= `file.count - 1 && !is_nl(`file[start + i]) {
        append(*builder,`file[start + i]);
        i += 1;
    }
    `it = start + i;
    return sprint("%",builder_to_string(*builder));
}
add_identifier :: (start:int,new:bool) -> string #expand {
    builder:String_Builder;
    i:int = start;
    while  i <= `file.count - 1 && is_alnum(`file[i])  {
        append(*builder,`file[i]);
        i += 1;
    }
    ident:string = builder_to_string(*builder);
    if message.count > 0 && new && message[message.count - 1] == .GLOBAL then array_add(*global_idents,ident);
    if new then array_add(*identifiers,ident);
    `it = i;
    return ident;
}

check_identifier :: (start:int) -> string,int #expand {
    builder:String_Builder;
    i:int = start;
    while  i <= `file.count - 1 && is_alnum(`file[i])  {
        append(*builder,`file[i]);
        i += 1;
    }

    ident:string = builder_to_string(*builder);
    return ident,i;
}

check_identifier :: (start:int,file:string) -> string,int {
    builder:String_Builder;
    i:int = start;
    while  i <= file.count - 1 && is_alnum(file[i])  {
        append(*builder,file[i]);
        i += 1;
    }

    ident:string = builder_to_string(*builder);
    //`it = i + 1;
    return ident,i;
}

add_type :: (start:int,new:bool) -> string #expand {
    builder:String_Builder;
    i:int = start;
    while is_alnum(`file[i]) {
        append(*builder,`file[i]);
        i += 1;
    }
    type:string = builder_to_string(*builder);
    `it = i;
    if new then array_add(*ltypes,type);
    return type;
}

lex_arguments :: () -> [] TOKEN #expand {
    i:int = `it + 1;
    argument_tokens:[..] TOKEN;
    while `file[i] != #char ")" {
        if `file[i] =={
            case #char ":";
            array_add(*argument_tokens,.{"",.col});

            case #char "i";
            if `file[i+1] == #char "n" && `file[i+2] == #char "t" { array_add(*argument_tokens,.{"",.t_int}); i += 2;}
            else {
                builder:String_Builder;

                i2:int = i;
                while is_alpha(`file[i2]) {
                    append(*builder,`file[i2]);
                    i2 += 1;
                }
                array_add(*argument_tokens,.{sprint("%",builder_to_string(*builder)),.identifier});
                i = i2 - 1;
            }

            case #char "c";
            if `file[i+1] == #char "h" && `file[i+2] == #char "a" && `file[i+3] == #char "r" { array_add(*argument_tokens,.{"",.t_char}); i += 3;}
            else {
            builder:String_Builder;

                i2:int = i;
                while is_alpha(`file[i2]) {
                    append(*builder,`file[i2]);
                    i2 += 1;
                }
                array_add(*argument_tokens,.{sprint("%",builder_to_string(*builder)),.identifier});
                i = i2 - 1;
            }
            case #char "f";
            if `file[i+1] == #char "l" && `file[i+2] == #char "o" && `file[i+3] == #char "a" && `file[i+4] == #char "t" { array_add(*argument_tokens,.{"",.t_float}); i +=4; }
            else {
            builder:String_Builder;

                i2:int = i;
                while is_alpha(`file[i2]) {
                    append(*builder,`file[i2]);
                    i2 += 1;
                }
                array_add(*argument_tokens,.{sprint("%",builder_to_string(*builder)),.identifier});
                i = i2 - 1;
            }
            case #char "b";
            if `file[i+1] == #char "o" && `file[i+2] == #char "o" && `file[i+3] == #char "l" { array_add(*argument_tokens,.{"",.t_bool}); i+=3; }
            else {
            builder:String_Builder;

                i2:int = i;
                while is_alpha(`file[i2]) {
                    append(*builder,`file[i2]);
                    i2 += 1;
                }
                array_add(*argument_tokens,.{sprint("%",builder_to_string(*builder)),.identifier});
                i = i2 - 1;
            }
            case #char " ";;
            case #char "\n";;
            case #char "\t";;
            case #char "\r";;
            case;
            builder:String_Builder;
            i2:int = i;
            while is_alpha(`file[i2]) {
                append(*builder,`file[i2]);
                i2 += 1;
            }
            array_add(*argument_tokens,.{sprint("%",builder_to_string(*builder)),.identifier});
            i = i2 - 1;
        }
        i+=1;
    }
    `it = i - 1;
    return argument_tokens;
}

lexer_peek :: (x:int) -> u8 #expand {
    return `file[`it + x];
}
// grammar :: #run read_entire_file("./modules/lexer.flg");
// sp :: #run split(grammar,"---");
// tt :: sp[0];
// core :: sp[1];
// args :: sp[2];
#import "Basic";
#import "File";
#import "String";
