val adjust_index :
  int option -> int option -> int option -> int -> int * int * int * int
val slice : string -> int option -> int option -> int option -> string
val ( *$ ) : string -> int -> string
val ( ^$ ) : char -> string -> string
val ( $^ ) : string -> char -> string

val repeat : string -> int -> string
val char_of_string : char -> string 
val at : string -> int -> char
val center : string -> ?fillchar:char -> int -> string
val capitalize : string -> string
val count : string -> ?start:int option -> ?stop:int option -> string -> int
val endswith : string -> ?start:int option -> ?stop:int option -> string -> bool

val expandtabs : ?tabsize:int -> string -> string

val find : string -> ?start:int option -> ?stop:int option -> string -> int
val index : string -> ?start:int option -> ?stop:int option -> string -> int

val get : string -> int -> char
val isalnum : string -> bool
val isalpha : string -> bool
val isascii : string -> bool
val isdecimal : string -> bool
val isdigit : string -> bool
val islower : string -> bool
val isnumeric : string -> bool
val isprintable : string -> bool
val isspace : string -> bool
val isupper : string -> bool


val ljust : string -> ?fillchar:char -> int -> string
val lower : string -> string
val lstrip : string -> string
val join : string -> string list -> string
val rjust : string -> ?fillchar:char -> int -> string
val rstrip : string -> string
val replace : string -> ?count:int -> string -> string -> string
val split : string -> ?count:int -> string -> string list
val strip : string -> string
val partition : string -> string -> string list
val splitlines : ?keepends:bool -> string -> string list
