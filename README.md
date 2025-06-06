# Fien MetaCompiler - The most powerful, and useless compiler you'll ever want to use

![fien logo](./assets/Fien%20Logo.png)

Fien is a compiler in which you can completely edit the ins and outs of while programming with  
the language. To do this Fien introduces extremely strong metaprogramming, and type system concepts.  
Default Fien is actually a very useable language, but not everyone programs in the same way  
Fien allows you to run arbitrary code at compile time (given that its compiletime evaluatable)  
and lets you edit, or replace the lexer, parser, and codegen, allowing you to easily cross-compile  
and add features to the language.

## WIJ'S NEVER ENDING COBBLED TOGETHER DESIGN DOC

### Base syntax

---
Im going to heavily base my syntax off of odin, I think the colon declaration style of programming  
provides a really nice, consistent, and readable syntax.

We're going to be a little bit lisp-pilled with it as well.

Everything is a declaration. Everything is syntactic sugar on declarations.

```rust
// function decl
main :: () /* implicitily () -> () */ {
    // variable decl
    foo: i64 = 0;
    // constant decl
    bar :: i64 -> 0; // () -> (i64) -> 0
    // "macros", functions that return codeblocks
    macroexample :: () -> {} // () -> Code
    // ^ making a macro that returns a value may change the type
    // macros are allowed to change return type on different code branches
    // if this is the case.
    // expanding macros works like a normal function // ? is this a good ideads

    // compile time code execution
    #eval {}
    // or
    #eval function(); // function HAS to be comptime evaluable
                      // I reccomend using macros here to enforce this
    // constructing structs
    thing: structtype = {
        /*
        fields in order or named
        say this had 2 fields
        size:i64
        value:i64
        you could either
        1,
        2,
        or
        value = 2,
        size = 1,
        */
    };
}

// struct definitions
/*
Structs are just sugar for a type of multiple named declarations
*/
structexample :: struct {
    thing: i64;
    otherthing:i32 = 32; // default values are allowed
} // (i64,i32) -> structexample -> ((thing) -> i64, (otherthing) -> i32)
// similar to rust, enums allow for algebraic data types
enumexample :: enum /*Types are allowed here, but get rid of the ADT function, eg. enum u8*/{
    ADTVariant(i32,i64);
    A :: 0; // assume i32 unless either specified or does not fit
    b, // () -> i32 -> 1
} // ((i32,i64) | i32)
// Row-types
/*
Row types are just combined types that can be de-structured, added, and operated on like maths
this is the intended way to return multiple types 
*/
// Regarding Memory
/*
There is no concepts of memory safety in this language
RAII, borrow-checkers, or garbage collection (or even both RAII, and RC/BC) 
get in the way and sometimes FORCE you to produce slower code. 
I find that in my experience there has never been a case 
were either of these concepts have prevented a bug. Oftentimes
they abstract away the memory management and create **MORE**
bugs. Its easier to not have a skill issue, than to have something
that tries (and fails) to prevent it. Memory issues are really easy
to not run into if you just group everything togethether. Minimizing
allocations makes everything easier, and I find is much more effective
than some overarching stupid system that forces you to do things its
way, removing the freedom of programming.
*/
// Pointer syntax
/*
    *type to create a pointer
    name* to dereference a pointer
    *name to get a pointer to a declaration
*/
// namespaces
/*
structs and enums are given their own namespaces, but if you want to
create your own custom namespace it's really easy
*/
export thisisanamespace :: {
}
// anything not in an export block is considered private
// you can also use export on individual functions / structs/ enums
// if you do not want a namespace
```

### Lexer editing

---
Lexers are defined through grammars, and to make an easy to generate,
fast, and easy to use lexer generator.

I intend for the grammar language to be much more of an actual language than EBNF
It will be rule based and the best way to show it off is just to show it through code

```md
Lexers are defined through the following
Tokens, The kinds of tokens, and a grammar

What should lexergen do?

*   Make it easy to write lexers
*   Be fast
*   Be relatively simple
*   Generate a lexer that is both time and space complex optimized


How should we define a grammar?

Well
*   Things you must do! (::)
*   Things you cant do! (!:)

ex.

* All of the rules for the Ident token
Ident -> {
    alpha cc :: true -> // the first character of the lexeme must be alphabetic
    agg whitespace(cc);
}

_ -> {
    agg is_whitespace current_char; // aggregate until the current character is whitespace 
}

from ':' -> {
    peek == ':' :: Constdecl : Decl; // if true go to the Constdecl rule, if not go to the Decl rule
}
```

I'll get around to documenting it some day

### Modifying the AST

ideally this should be the exact same structure as the  
AST structure in the actual compiler

Macros are implicitly passed an ast, and can modify the ast within their  
scope, letting you more easily generate different behaviors and branches

If you so choose, you can modify the AST by passing it to a compile time  
evaluated function

```rust
astmodifyingfunction :: (AST) {

}

#eval astmodifyingfunction();
```

AST works a bit different than other arguments, as you may have noticed  
its a bit like the implicit this in oop languages, except you have to declare
it to use it

What if you want to add onto the existing ASTNode structure?  
in Fien you can do that! And it's really easy too!

```rust
ThingNode :: struct {
    Type = NODE_TYPE_THING;
    // Now you're free to add any arbitrary data
} @node
```

But how do we even generate these custom AST nodes?

Parsing Hooks

```rust
example_node :: struct {
    Type = Example;
    test: i64;
} @node

examplehook :: (AST,tok: Token) #hook {
    if tok.type == TokenType.Example {
        node: AstNode* = AST.head;

        node.kind = AstNode.NodeKind.Example;

        node.data.example_node = .{
            3
        };

        AST.head += 1;
    }
}
```

### Codegen Functions

Exactly the same as AST modifying functions except  
they're now of the type (AST) -> str

### Proposals

---

* [ ] Context, jai/odin style
* [ ] Rename #eval to #run
* [x] Type generics (checked because they are planned)
* [ ] Polymorphic types (Could this be done in a metaprogram?)
