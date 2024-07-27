# FIEN


## basic, simple syntax

```ocaml
fn add ( a: int b: int ) -< int -> a + b


fn main () -< int {

    let three:int = add 1 2
    let four:int  = add three 1
    ret 0
}
```

and a bit more complex, your favorite, MY favorite BEZIER CURVES :D

```ocaml
import "std/math"
import "std/graphics"

let sr = 100



bezier :: [vec2]
fn bezier ( a:vec2 b:vec2 c:vec2 d:vec2 t:float = 0 ) -< [vec2] {

    if t == 1 then ret bezier

    let d11:vec2 = lerp a b t
    let d12:vec2 = lerp b c t
    let d13:vec2 = lerp c d t

    let d21:vec2 = lerp d11 d12 t
    let d22:vec2 = lerp d12 d13 t

    let point:vec2 =  lerp d21 d22 t

    bezier^point // concatenation
    t += 1.0 / sr
    bezier a b c d t
}

fn main () -< int {
    win = open_window "win" 640 480
}

```
