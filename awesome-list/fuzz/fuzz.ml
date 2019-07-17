let is_sorted l =
  let rec is_sorted = function
    | [] | [ _ ] -> true
    | hd :: (hd' :: _ as tl) -> hd <= hd' && is_sorted tl
  in
  Crowbar.check (is_sorted l)

let int_list = Crowbar.(list (range 10))

let () =
  Crowbar.add_test ~name:"Awesome_list.sort" [ int_list ] (fun l -> is_sorted (Awesome_list.sort l))
