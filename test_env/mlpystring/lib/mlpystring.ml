
open MLPyUtils
include Slice

let slice str start stop step =
  let start, _, step, loop = adjust_index start stop step (String.length str) in
  let rec iter buf i count =
    if is_zero count then
      Buffer.contents buf
    else
      begin
        Buffer.add_char buf (str.[i]);
        iter buf (i+step) (count-1)
      end
in iter (Buffer.create loop) start loop

let repeat str n =
  let rec iter result i =
    if i <= 0 then
      Buffer.contents result
    else
      begin
        Buffer.add_string result str;
        iter result (i-1) 
      end
    in iter (Buffer.create (String.length str * n)) n


let char_of_string c =  String.make 1 c;;

let ( *$ ) = repeat
let ($^) s c = s ^ char_of_string c;; (* append *)
let (^$) c s = char_of_string c ^ s;; (* prepend *)

let capitalize str = String.capitalize_ascii str;;

let center str ?(fillchar=' ') width =
  let slen = String.length str in
  if slen >= width then
    str
  else
    let a = width - slen in
    let b = a/2 + a mod 2 in
    (String.make b fillchar) ^ str ^ (String.make (a-b) fillchar);;
(* TODO:center Buffer を利用した最適化の余地あり*)


let back_index_ n len =
  if n < 0 then
    len + n
  else
    n;;

let get str n =
  let i = back_index_ n (String.length str) in
  String.get str i;;

let at = get

let simple_slice ?(start=0) ?(stop=max_int) str =
  let start, stop, _, _ = adjust_index (Some start) (Some stop) None (String.length str) in
  String.sub str start (stop-start)

let find_internal str sub start stop =
  let sublen = String.length sub in
  let rec iter cursor =
    if (cursor+sublen) > stop then
      -1
    else
      let it = String.sub str cursor sublen in
      if it = sub then
        cursor
      else
        iter (cursor+1)
  in iter start

let find str ?(start=None) ?(stop=None) sub =
  let len = (String.length str) in
  let start,stop,_,_ = adjust_index start stop None len in
  find_internal str sub start stop

let count str ?(start=None) ?(stop=None) sub =
  let start, stop, _,_ = adjust_index start stop None (String.length str) in
  let sublen = String.length sub in
  let rec iter cnt cursor = 
    if cursor <> -1 && (cursor+sublen) <= stop+1 then
      iter (cnt+1) (find_internal str sub (cursor+sublen) stop)
    else
      cnt
  in iter 0 (find_internal str sub start stop);;

let endswith text ?(start=None) ?(stop=None) suffix =
  let start, stop, _, _ = adjust_index start stop None (String.length text) in
  let sublen = String.length suffix in
  if (stop - start) < sublen then
    false
  else
    let sub = String.sub text (stop-sublen) sublen in
    sub = suffix;;

let split text ?(count=max_int) sep = 
  let rec iter lst txt cnt s = 
    if cnt = 0 then
      List.rev (txt::lst)
    else
      let cusor = find txt sep in
      if cusor = -1 then
        List.rev (txt::lst)
      else
        let hd = simple_slice txt ~start:0 ~stop:cusor in
        let tl = simple_slice txt ~start:(cusor+(String.length sep)) in
        iter (hd::lst) tl (cnt-1) s
  in iter [] text count sep;;

let join str lst = 
  let rec iter result lst = 
    match lst with
    | [s] -> result ^ s
    |hd::tl -> iter (result^hd^str) tl
    | [] -> result
  in iter "" lst;;

let replace text ?(count=max_int) old new_ = 
    let lst = split text old ~count:count in
    join new_ lst;;

let expandtabs ?(tabsize=8) str = 
 replace str "\t" (String.make tabsize ' ')

let index text ?(start=None) ?(stop=None) sub =
  let i = find text ~start:start ~stop:stop sub in
  if i = -1 then
    raise Not_found
  else
    i

let cisdigit c =
  '0' <= c && c <= '9';;

let cisupper c =
  'A' <= c && c <= 'Z';;

let cislower c =
  'a' <= c && c <= 'z';;

let cisalpha c =
  cislower c || cisupper c;;

let cisalnum c =
  cisalpha c || cisdigit c;;

let cisascii c =
  '\000' <= c && c <= '\127'

let cisspace c =
  ('\009' <= c && c <= '\013') || ('\028' <= c && c <= '\032');;

let cisprintable c =
  '\032' <= c && c <= '\126';;

let cisrowboundary c =
  match c with
    '\n' -> true
  | '\r' -> true
  | '\011' -> true
  | '\012' -> true
  | '\028' -> true
  | '\029' -> true
  | '\030' -> true
  | '\133' -> true
  |  _ -> false;;


let isx str ?(zero=false) f =
  let l = String.length str in
  if l = 0 then
    zero
  else
  let rec iter slen =
    if slen = 0 then
      true
    else if not (f (String.get str (slen-1)) ) then
      false
    else
      iter (slen-1)
  in iter l;;

let isalnum str = isx str cisalnum;;

let isalpha str = isx str cisalpha;;

let isascii str = isx str cisascii ~zero:true;;

let isdecimal str = isx str cisdigit;;

let isdigit str = isx str cisdigit;;

let islower str = isx str cislower;;

let isnumeric str = isdecimal str;;

let isprintable str = isx str cisprintable ~zero:true;;

let isspace str = isx str cisspace;;

let isupper str = isx str cisupper;;

let ljust str ?(fillchar=' ') width =
  let l = String.length str in
  if l >= width then
    str
  else
    str ^ String.make (width-l) fillchar;;

let rjust str ?(fillchar=' ') width =
  let r = String.length str in
  if r >= width then
    str
  else
    String.make (width-r) fillchar ^ str;;

let lower str = String.lowercase_ascii str;;

let lstrip str = 
  let rec iter cnt = 
    if cisspace (String.get str cnt) then
      iter (cnt+1)
    else
      cnt
  in 
  simple_slice str ~start:(iter 0);;

let rstrip str = 
  let rec iter cnt = 
    if cisspace (String.get str cnt) then
      iter (cnt-1)
    else
      cnt
  in
  simple_slice str ~stop:((iter ((String.length str)-1))+1);;

let strip str = lstrip (rstrip str);;

let partition str sep = 
  let i = find str sep in
    if i = (-1) then
      [str ;"";""]
    else
      [simple_slice str ~stop:i; sep; simple_slice str ~start:(i+(String.length sep))]

let splitlines ?(keepends=false) str =
  let len = String.length str in
  let rec iter i j lst =
    if i < len then
      let rec siter si =
        if si < len && not (cisrowboundary (String.get str si)) then
          siter (si+1)
        else
          si,si
        in
      let i, eol = siter i in
      let get_eol i eol = 
      if i < len then
        let get_i i = 
        if String.get str i = '\r' && (i+1) < len && String.get str (i+1) = '\n' then
           i+2
        else
           i+1
        in 
        let i = get_i i in
        if keepends then
           i,i
        else
          i,eol
      else
        i,eol
      in
      let i,eol = get_eol i eol in
      iter i i  ((String.sub str j (eol-j))::lst)
    else if j < len then
      List.rev ((String.sub str j (len-j))::lst)
    else
      List.rev lst

  in iter 0 0 [];;
