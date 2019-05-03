val parse_int: string -> (int, [> `Msg of string]) result
(** Parse the given string as an int or return [Error (`Msg _)]. Does not raise, usually... *)
