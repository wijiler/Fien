error :: (r:int,c:int,file:string,format:string,args:.. Any) {
    message := sprint(format,..args);
    fmat := split(file,"\n");
    line := fmat[r - 1];
    
    tokapp:String_Builder;
    tokCounter := c - 1;
    while tokCounter <= line.count - 1 && is_alnum(line[tokCounter]) && !is_whitespace(line[tokCounter]) {
        append(*tokapp,line[tokCounter]);
        tokCounter += 1;
    }
    tok := builder_to_string(*tokapp);

    print("\x1B[1m\x1B[31mError:\x1B[0m %\n",message);
    print("┃\n┃\n└▶ %\n",line);

    len := line.count;
    pointerBuilder:String_Builder;
    for 0..len + 1 {
        append(*pointerBuilder," ");
    }
    pointer:string = builder_to_string(*pointerBuilder);
    caratCounter:int = tok.count;
    while caratCounter > 0 {
        pointer[caratCounter] = #char "^";
        caratCounter -= 1;
    }
    print("%\n",string_reverse(pointer));
}
string_reverse :: (str:string) -> string {
    rev:string = str;
    i:int = 0;
    j:int = str.count-1;
    while i <= j {
        c:u8 = rev[i];
        rev[i] = rev[j];
        rev[j] = c;
        i += 1;
        j -= 1;
    }
    return rev;
}
is_nl :: (char:u8) -> bool {
    if char == #char "\r" || char == #char "\n" {
        return true;
    }
    return false;
}
is_whitespace :: (char:u8) -> bool {
    if char == #char " " || char == #char "\t" {
        return true;
    }
    return false;
}
#import "Basic";
#import "String";