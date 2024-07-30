# LIRA

`atok %name%` -> creates a new tokentype  
`attok %name%` -> creates a new tokentype specified as a type  
`expr %format%` -> sets expression format  
`lex` -> lexes based on previously set rules
`tok %lexeme% %tokentype`  -> returns a token into the token array  
`peek %ahead% %char%` -> peeks ahead x amount and checks for char  
`grammarFunc: %function%` -> allows you to define the grammar of a token

## Symbols

```nothing
> - after this do
:: - rule for this token
!! - stop the rule when hitting this character
?> - if not true do this
```

## Formats

```nothing
%Ident% - add this as a valid Identifier
%ident% - add this as a valid Identifier in this scope
%Type%  - add this a valid type
%type%  - add this a valid type in this scope
```

## Example of use in fien

```fien
#lexer,add {
    atok foo
    atok lparen
    grammarFunc:
     "foo" :: tok "" foo
     "(" :: tok "" lparen > expr "%Ident%:%Type%" > lex !! ")"
}

```
