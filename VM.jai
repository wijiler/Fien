lirae :: struct {
    rom:string; // file
    program:[] instruction = .[];
    toks:**u8;
    tokreg:*u8;
    quit:bool = false;
    new_work:bool = false;
    pos:int;
}

instruction :: struct {
    arguments:string;
    ins :: enum u8 {
        pop  :: 1;
        
    }
    type:ins;
}

launch_lirae :: (thread:*Thread,vm:*lirae,program:string,file:string) {
    vm.rom = file;

    load_program(vm,program);
    print("Loaded program into memory\n");

    thread.data = vm;
    success := thread_init(thread,lirae_proc);
    assert(success);

    thread_start(thread);
}


destroyvm :: (vm:*Thread) {
    using data := cast(*lirae)vm.data;
    quit = true;
    while !thread_is_done(vm) {}
    thread_deinit(vm);
    print("destroyed lirae %\n",vm);
}

#scope_file


lirae_proc :: (_thread:*Thread) -> s64 {
    using vm := cast(*lirae) _thread.data;
    while !quit {
        if quit {
             break;
        }
        _thread.data=vm;
    }
    return 0;
}

load_program :: (lira:*lirae,code:string) {
    instructions: [..] instruction;
    ins:[] string = split(code,";");
    for j:0..ins.count - 1 {
        for 0..ins[j].count - 1 {
            char := ins[j][it];
            if char== {
                case #char "p";
                if peek(ins[j],it,1) =={
                    case #char "e";
                    array_add(*instructions,.{slice(ins[j],it + 5,ins[j].count - 1),.peekl});
                    it += ins[j].count - 1;
                    case #char "u";
                    array_add(*instructions,.{slice(ins[j],it + 5,ins[j].count - 1),.push});
                    it += ins[j].count - 1;
                    case #char "o";
                    array_add(*instructions,.{"",.pop});
                    it += ins[j].count - 1;
                    case;;
                }
                case #char "a";
                if peek(ins[j],it,1) =={
                    case #char "i";
                    array_add(*instructions,.{slice(ins[j],it + 7,ins[j].count - 1),.aident});
                    it += ins[j].count - 1;
                    case #char "e";
                    array_add(*instructions,.{slice(ins[j],it + 6,ins[j].count - 1),.aexpr});
                    it += ins[j].count - 1;
                    case #char "t";
                    array_add(*instructions,.{slice(ins[j],it + 5,ins[j].count - 1),.atok});
                    it += ins[j].count - 1;
                    case;;
                }
                case #char "c";
                if peek(ins[j],it,1) == {
                    case #char "e";
                    array_add(*instructions,.{slice(ins[j],it + 6,ins[j].count - 1),.aexpr});
                    it += ins[j].count - 1;
                    case #char "o";
                    array_add(*instructions,.{slice(ins[j],it + 10,ins[j].count - 1),.condition});
                    it += ins[j].count - 1;
                    case;;
                }
                case #char "r";
                array_add(*instructions,.{slice(ins[j],it + 4,ins[j].count - 1),.ret});
                it += ins[j].count - 1;
                case;;
            }
        }
    }
    print("%\n",instructions);
    lira.program = instructions;
}



peek :: (file:string,start:int,ahead:int) -> u8 {
        return file[start + ahead];
}

add_ident :: (file:string,start:int) -> string {
    i:int = start;
    builder:String_Builder;
    while i <= file.count - 1 && is_alnum(file[i]) {
        append(*builder,file[i]);
    }
    return builder_to_string(*builder);
}


#import "Thread";
#import "String";
#import "Basic";