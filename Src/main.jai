main :: () {
    args := get_command_line_arguments();
    if args.count < 2 {
        print("You need to provide input files\nThe format is fien [INPUT FILE] -o [OUTPUT] [-l|-p] [ARGS]");
        exit(1);
    } 
    tokens:[] TOKEN  = lex(args[1]);
    print("%\n",tokens);
}

#import "Basic";
#import "DefaultLexer";