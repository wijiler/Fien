main :: () {
    args := get_command_line_arguments();
    if args.count < 2 {
        print("You need to provide input files\nThe format is fien [INPUT FILE] -o [OUTPUT]");
        exit(1);
    }
    
    input := args[1];
    output:string;
    for 2..args.count - 1 {
        if args[it]== {
            case "-o";
            output = args[it + 1];
            it += 1;
            
            case;;
        }
    }
    
    print("%",lex(input));

}

#import "Basic";
#import "Lexer";
