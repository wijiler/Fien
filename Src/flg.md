# Fien Lexer Grammar

Fien being a language with an extensible syntax needs a way to extend the lexer

## How do we do that

Easy, we write a lexer generator

## FLG syntax

heres an example of the entire default lexer

```nothing
tok ____ <- define a new token

args -> ..code.. <- handles how you parse arguments

char "f" -> ..code.. <- handles characters


..code..
   |
if,else statements + lexing library

```

> [!IMPORTANT]
> [in defaultlexer.jai](modules/DefaultLexer.jai) there is a section marked  lexing library, every function there excluding lex arguments is valid in FLG
