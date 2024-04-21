lex :: (filename:string) -> [] TOKEN {

    tokens: [..] TOKEN;

    file,success := read_entire_file(filename);
    if !success {
        print("Could not find file %  E001 \n",filename);
        exit(1);
    }
    file = to_lower_copy_new(file);
    r:int = 1;
    c:int = 1;
    for 0..file.count - 1 {
        c += 1;
            if file[it]== {
            case #char "f";
            if lexer_peek(1) == #char "n" {
                if is_alnum(lexer_peek(2)) then unknown_token_error(r,c,it,file);
                array_add(*tokens, .{"",.fn});
                array_add(*tokens,.{add_identifier(it+3,true),.identifier});
            }
            else if lexer_peek(1) == #char "l" && lexer_peek(2) == #char "o" && lexer_peek(3) == #char "a" && lexer_peek(4) == #char "t" { 
                if is_alnum(lexer_peek(5)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.type_float}); 
                it +=4; 
            }
            else {
                ident,skip := check_identifier(it);
                print("%\n",ident);
                if array_find(identifiers,ident) {
                    array_add(*tokens,.{ident,.identifier});
                    it = skip;
                }
                else if array_find(ltypes,ident) {
                    array_add(*tokens,.{ident,.type});
                    it = skip;
                }
                else {
                unknown_token_error(r,c,it,file);
                }
            }

            case #char "(";
            array_add(*tokens,.{"",.lparen});
            array_add(*tokens,..lex_arguments());

            case #char "i";
            if lexer_peek(1) == #char "n" && lexer_peek(2) == #char "t" { 
                if is_alnum(lexer_peek(3)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.type_int}); 
                it += 2;
            }
            else {
                ident,skip := check_identifier(it);
                print("%\n",ident);
                if array_find(identifiers,ident) {
                    array_add(*tokens,.{ident,.identifier});
                    it = skip;
                }
                else if array_find(ltypes,ident) {
                    array_add(*tokens,.{ident,.type});
                    it = skip;
                }
                else {
                unknown_token_error(r,c,it,file);
                }
            }

            case #char "c";
            if lexer_peek(1) == #char "h" && lexer_peek(2) == #char "a" && lexer_peek(3) == #char "r" {
                if is_alnum(lexer_peek(4)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.type_char}); 
                it += 3;
            }
            else {
                ident,skip := check_identifier(it);
                print("%\n",ident);
                if array_find(identifiers,ident) {
                    array_add(*tokens,.{ident,.identifier});
                    it = skip;
                }
                else if array_find(ltypes,ident) {
                    array_add(*tokens,.{ident,.type});
                    it = skip;
                }
                else {
                unknown_token_error(r,c,it,file);
                }
            }

            case #char ":"; 
            array_add(*tokens,.{"",.col});

            case #char "b";
            if lexer_peek(1) == #char "o" && lexer_peek(2) == #char "o" && lexer_peek(3) == #char "l" { 
                if is_alnum(lexer_peek(4)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.type_bool}); 
                it +=3; 
            }
            else {
                ident,skip := check_identifier(it);
                print("%\n",ident);
                if array_find(identifiers,ident) {
                    array_add(*tokens,.{ident,.identifier});
                    it = skip;
                }
                else if array_find(ltypes,ident) {
                    array_add(*tokens,.{ident,.type});
                    it = skip;
                }
                else {
                unknown_token_error(r,c,it,file);
                }
            }

            case #char "s";
            if lexer_peek(1) == #char "t" && lexer_peek(2) == #char "r" {
                if lexer_peek(3) != #char "u" then {
                    if is_alnum(lexer_peek(3)) then unknown_token_error(r,c,it,file);
                    array_add(*tokens,.{"",.type_string}); 
                    it += 2;
                }
                else if lexer_peek(4) == #char "c" && lexer_peek(5) == #char "t" {
                    if is_alnum(lexer_peek(6)) then unknown_token_error(r,c,it,file);
                    array_add(*tokens, .{"",.k_struct});
                    array_add(*tokens,.{add_type(it+7,true),.type});
                }
            }
            else {
                ident,skip := check_identifier(it);
                print("%\n",ident);
                if array_find(identifiers,ident) {
                    array_add(*tokens,.{ident,.identifier});
                    it = skip;
                }
                else if array_find(ltypes,ident) {
                    array_add(*tokens,.{ident,.type});
                    it = skip;
                }
                else {
                unknown_token_error(r,c,it,file);
                }
            }

            case #char "e";
            if lexer_peek(1) == #char "n" && lexer_peek(2) == #char "u" && lexer_peek(3) == #char "m" {
                    if is_alnum(lexer_peek(4)) then unknown_token_error(r,c,it,file);
                    array_add(*tokens, .{"",.k_enum});
                    array_add(*tokens,.{add_type(it+5,true),.type});
            }
            else {
                ident,skip := check_identifier(it);
                print("%\n",ident);
                if array_find(identifiers,ident) {
                    array_add(*tokens,.{ident,.identifier});
                    it = skip;
                }
                else if array_find(ltypes,ident) {
                    array_add(*tokens,.{ident,.type});
                    it = skip;
                }
                else {
                unknown_token_error(r,c,it,file);
                }
            }

            case #char "l";
            if lexer_peek(1) == #char "e" && lexer_peek(2) == #char "t" {
                if is_alnum(lexer_peek(3)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.let});
                array_add(*tokens,.{add_identifier(it+4,true),.identifier});
            }
            else {
                ident,skip := check_identifier(it);
                print("%\n",ident);
                if array_find(identifiers,ident) {
                    array_add(*tokens,.{ident,.identifier});
                    it = skip;
                }
                else if array_find(ltypes,ident) {
                    array_add(*tokens,.{ident,.type});
                    it = skip;
                }
                else {
                unknown_token_error(r,c,it,file);
                }
            }

            
            case #char "r";
            if lexer_peek(1) == #char "e" && lexer_peek(2) == #char "t" {
                if is_alnum(lexer_peek(3)) then unknown_token_error(r,c,it,file);
                array_add(*tokens,.{"",.ret});
                array_add(*tokens,.{add_expression(it+4),.expression});
            }
            else {
                ident,skip := check_identifier(it);
                print("%\n",ident);
                if array_find(identifiers,ident) {
                    array_add(*tokens,.{ident,.identifier});
                    it = skip;
                }
                else if array_find(ltypes,ident) {
                    array_add(*tokens,.{ident,.type});
                    it = skip;
                }
                else {
                unknown_token_error(r,c,it,file);
                }
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

            }
            case #char ")";
            array_add(*tokens,.{"",.rparen});
            case #char "{";
            array_add(*tokens,.{"",.lbrack});
            case #char "}";
            array_add(*tokens,.{"",.rbrack});
            case #char "\r";
            r += 1;
            c = 0;
            it += 1;
            case #char "\n";
            r += 1;
            c = 0;
            case #char " ";;
            case #char "\t";;

            case;
            ident,skip := check_identifier(it);
            print("%\n",ident);
            if array_find(identifiers,ident) {
                array_add(*tokens,.{ident,.identifier});
                it = skip;
            }
            else if array_find(ltypes,ident) {
                array_add(*tokens,.{ident,.type});
                it = skip;
            }
            else {
            unknown_token_error(r,c,it,file);
            }
        }
    }
    return tokens;
}

TOKEN :: struct {
    lexeme:string;
    type :: enum u8 {
        identifier :: 255;
        ret        :: 254;
        let        :: 253;
        sh_ret     :: 240;
        //! literal    :: 252; replaced by broader expression token
        fn         :: 249;
        type       :: 232;
        expression :: 242;
        k_struct   :: 235;
        k_enum     :: 231;


        eq         :: 251;
        col        :: 250;
        lparen     :: 247;
        rparen     :: 246;
        lbrack     :: 245;
        rbrack     :: 244;
        carat      :: 243;
        //asterix  :: 239;

        r_type     :: 234;

        type_int   :: 239;
        type_char  :: 238;
        type_bool  :: 237;
        type_float :: 236;
        type_string :: 233;
    }
    tokentype:type;
}

#scope_file


// ! Lexing library
identifiers: [..] string;
ltypes: [..] string;

unknown_token_error :: (r:int,c:int,i:int,file:string) {
    print("%\n%\n",ltypes,identifiers);
    builder:String_Builder;
    tokapp:String_Builder;
    i2 := i;
    i3 := i;
    while i2 <= file.count - 1 && !is_nl(file[i2]) {
        append(*builder,file[i2]);
        i2 += 1;
    }
    while i3 <= file.count - 1 && !is_whitespace(file[i3]) {
        append(*tokapp,file[i3]);
        i3 += 1;
    }
    line := builder_to_string(*builder);
    tok := builder_to_string(*tokapp);
    print("Unknown token \"%\" at row:% column:% \n",tok,r,c);
    print("┃\n┃\n└▶ %\n",line);
    spaces:String_Builder;
    carats:String_Builder;
    for 0..tok.count -1  {
        append(*carats,"^");
    }
    carats_s := builder_to_string(*carats);
    for c..c + tok.count - carats_s.count  {
        append(*spaces," ");
    }

    print("  %1%",builder_to_string(*spaces),carats_s);
    exit(0);
}

// skip_whitespace :: () #expand {
//     if is_whitespace(`file[`it]) {
//         `it += 1;
//     }
// }

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
            if `file[i+1] == #char "n" && `file[i+2] == #char "t" { array_add(*argument_tokens,.{"",.type_int}); i += 2;}
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
            if `file[i+1] == #char "h" && `file[i+2] == #char "a" && `file[i+3] == #char "r" { array_add(*argument_tokens,.{"",.type_char}); i += 3;}
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
            if `file[i+1] == #char "l" && `file[i+2] == #char "o" && `file[i+3] == #char "a" && `file[i+4] == #char "t" { array_add(*argument_tokens,.{"",.type_float}); i +=4; }
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
            if `file[i+1] == #char "o" && `file[i+2] == #char "o" && `file[i+3] == #char "l" { array_add(*argument_tokens,.{"",.type_bool}); i+=3; }
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