main :: () {
    args := get_command_line_arguments();
    tokens:[] TOKEN  = lex(args[1]);
    print("%\n",tokens);
}

#import "Basic";
#import "Lexer";