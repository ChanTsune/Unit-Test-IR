let unwrap_optional option_value default =
  match option_value with
     Some(i) -> i
    |None -> default

let is_positive i = i > 0
let is_zero i = i = 0
let is_negative i = i < 0
