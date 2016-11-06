open Core.Std

module StateBased = struct
  type t = Int.Set.t
  type query = Int.Set.t
  type update = Add of int [@@deriving compare]

  let query xs =
    xs

  let update xs (Add x) =
    Int.Set.add xs x

  let merge xs ys =
    Int.Set.union xs ys

  let string_of_t xs =
    let ints = Int.Set.elements xs in
    let strings = List.map ~f:Int.to_string ints in
    Printf.sprintf "{%s}" (String.concat ~sep:", " strings)

  let string_of_update (Add x) =
    Printf.sprintf "+%d" x

  let string_of_query =
    string_of_t
end
