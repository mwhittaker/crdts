open Core.Std

module StateBased = struct
  type t = int * int * int
  type query = int
  type node = | One | Two | Three [@@deriving compare]
  type update = Increment of node * int [@@deriving compare]

  let query (x, y, z) =
    x + y + z

  let update (x, y, z) (Increment (node, k)) =
    match node with
    | One -> (x + k, y, z)
    | Two -> (x, y + k, z)
    | Three -> (x, y, z + k)

  let merge (x, y, z) (x', y', z') =
    (Int.max x x', Int.max y y', Int.max z z')

  let string_of_t (x, y, z) =
    let to_string = Int.to_string in
    Printf.sprintf "(%s, %s, %s)" (to_string x) (to_string y) (to_string z)

  let string_of_node node =
    match node with
    | One -> "one"
    | Two -> "two"
    | Three -> "three"

  let string_of_update (Increment (node, k)) =
    Printf.sprintf "(%s, %s)" (string_of_node node) (Int.to_string k)

  let string_of_query =
    Int.to_string
end
