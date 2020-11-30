open MLPyExceptions
open MLPyUtils
(* type slice = {
  start: int option;
  stop: int option;
  step: int option
} *)

let adjust_start start upper lower length step_is_negative =
  match start with
    None -> begin
      if step_is_negative then
        upper
      else
        lower
    end
    |Some(i) -> begin
      if is_negative i then (* start is negative *)
        let start = i + length in
        if start < lower then
          lower
        else
          start
      else
        if i > upper then
          upper
        else
          i
    end

let adjust_stop stop upper lower length step_is_negative =
  match stop with
    None -> begin
      if step_is_negative then
        lower
      else
        upper
    end
    |Some(i) -> begin
      if is_negative i then (* stop is negative *)
        let stop = i + length in
        if stop < lower then
          lower
        else
          stop
      else
        if i > upper then
          upper
        else
          i
    end


let adjust_loop start stop step =
  if is_negative step && stop < start then
    (start - stop - 1) / (-step) + 1
  else if start < stop then
    (stop - start - 1) / step + 1
  else
    0

let adjust_index start stop step length =
  let step = unwrap_optional step 1 in
  if step = 0 then
    raise ValueError
  else
    begin
      let step_is_negative = 0 > step in
      if step_is_negative then
        let lower = -1 in
        let upper = length + lower in
        let start = adjust_start start upper lower length step_is_negative in
        let stop = adjust_stop stop upper lower length step_is_negative in
        let loop = adjust_loop start stop step in
        (start, stop, step, loop)
      else
        let lower = 0 in
        let upper = length in
        let start = adjust_start start upper lower length step_is_negative in
        let stop = adjust_stop stop upper lower length step_is_negative in
        let loop = adjust_loop start stop step in
        (start, stop, step, loop)
    end
