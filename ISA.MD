# LIRA

`atok %name%` -> creates a new tokentype  
`attok %name%` -> creates a new tokentype specified as a type  
`expr %format%,` -> sets expression format  
`lex %amount%` -> lexes based on previously set rules amount is optional, it will only lex that amount of tokens if set, if not set will use stopping rule  
`tok %lexeme% %tokentype`  -> returns a token into the token array  
`peek %ahead% %char%` -> peeks ahead x amount and checks for char  
`grammarFunc: %function%` -> allows you to define the grammar of a token  
`ascope %scope%` -> add scope  
`scope %scoperule%` -> set scope  
`gscope %scope%` -> sets the default global scope  
`pscope` -> pops the scope array  
`isident` -> checks if current token is an identifier  
`istype`  -> checks if current token is a valid type  
`error` -> I mean it unknown token errors what would you expect, uses the default fien error function

## Symbols

```nothing
> - after this do
:: - rule for this token
!! - stop the rule when hitting this character
%condition% ? %truecase% ! %falsecase% - conditional

```

## Formats

```nothing
%Ident% - add this as a valid global Identifier
%ident% - add this as a valid Identifier in this scope
%Type%  - add this a valid global type
%type%  - add this a valid type in this scope
%t%     - just lex a type
```

## Example of use in fien

```fien
#lexer,add {
    atok foo

    atok lparen
    atok rparen
    atok lbrack
    atok rbrack

    atok struct
    atok m_struct

    ascope GLOBAL
    gscope GLOBAL
    ascope STRUCT

    grammarFunc:
     "foo" :: tok "" foo
     "(" :: tok "" lparen > expr "%ident%:%t%" > lex !! ")"
     "struct" :: tok "" struct > scope == global ? expr "%Type%" ! expr "%type%" > lex !! "{" > scope STRUCT > tok "" lbrack

     default :: scope == STRUCT ? fitexpr "%ident%:%t%",m_struct ? lex !! "\n" ! ! 
     isident ? expr "%ident%" > lex 1 ! istype ? expr "%t%" > lex 1  ! error

}

```
