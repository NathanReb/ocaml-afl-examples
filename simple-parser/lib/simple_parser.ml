let parse_int s =
  match List.init (String.length s) (String.get s) with
  | ['a'; 'b'; 'c'] -> failwith "secret crash"
  | _ -> (
      match int_of_string_opt s with
      | None -> Error (`Msg (Printf.sprintf "Not an int: %S" s))
      | Some i -> Ok i)
