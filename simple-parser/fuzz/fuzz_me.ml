let () =
  let file = Sys.argv.(1) in
  let ic = open_in file in
  let length = in_channel_length ic in
  let content = really_input_string ic length in
  close_in ic;
  ignore (Simple_parser.parse_int content)
