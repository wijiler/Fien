# LIRA ISA

atok %STRING% - Creates a new token  

lident - Lexes the current word as an ident and pushes it into the token register  

lex %TOK% %STRING% %LEN% - Lexes the current word as a token and pushes it into the token register  

pop - pops from the token register into the token array  

GRAMMARFUNC: %BLOCK% - Define the 

ERROR: %BLOCK%  

## %BLOCK% TYPE

Can be any valid Fien, although comes with a fien lexing library (FLL)  
Functions include  

- peek %AMOUNT% - peeks a certain amount ahead  
- ident 
