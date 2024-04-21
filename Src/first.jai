#run build();

build :: () {
        w := compiler_create_workspace("FIEN debug");
        options := get_build_options();

        imp:[..] string;
        array_add(*imp,"modules");
        array_add(*imp, ..options.import_path);

        options.import_path = imp;
        options.output_executable_name = "FIEN";
        set_optimization(*options, .DEBUG);
        set_build_options_dc(.{do_output=false});
        compiler_begin_intercept(w);
        set_build_options(*options,w);
        add_build_file("main.jai",w);
        compiler_end_intercept(w);
}

#import "Compiler";
#import "Basic";