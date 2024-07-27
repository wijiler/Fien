program := "ret 123; pop skibi; push 123; condition char == 2; aexpr hiiiii; aident foo; atok foo;";

main :: () {
    vm:lirae;
    thread:Thread;
    launch_lirae(*thread,*vm,program,"");
    while seconds_since_init() < 1 {}
    print("%\n",(cast(*lirae)thread.data).*);
    destroyvm(*thread);
}

#import "Thread";
#import "Basic";
#load "VM.jai";