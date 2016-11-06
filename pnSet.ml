open Core.Std

module StateBased = struct
  type t = PnCounter.StateBased.t Int.Map.t
  type query = Int.Set.t
  type update =
    | Add of GCounter.StateBased.node * int
    | Remove of GCounter.StateBased.node * int
  [@@deriving compare]

  module GCounter = GCounter.StateBased
  module PnCounter = PnCounter.StateBased
  module GSet = GSet.StateBased

  let query xs =
    Int.Map.filteri xs ~f:(fun ~key:_ ~data -> PnCounter.query data > 0)
    |> Int.Map.keys
    |> Int.Set.of_list

  let update xs update =
    let zero = PnCounter.{p=(0, 0, 0); n=(0, 0, 0)} in
    let (x, pn_update) =
      match update with
      | Add (node, x) -> (x, PnCounter.Increment (node, 1))
      | Remove (node, x) -> (x, PnCounter.Decrement (node, 1))
    in
    let x_count = Option.value (Int.Map.find xs x) ~default:zero in
    Int.Map.add xs ~key:x ~data:(PnCounter.update x_count pn_update)

  let merge xs ys =
    Int.Map.merge xs ys ~f:(fun ~key:_ v ->
      match v with
      | `Left x -> Some x
      | `Right y -> Some y
      | `Both (x, y) -> Some (PnCounter.merge x y)
    )

  let string_of_t xs =
    let bindings = Int.Map.to_alist xs in
    let strings = List.map bindings ~f:(fun (k, v) ->
      let v_string = (PnCounter.string_of_query (PnCounter.query v)) in
      sprintf "%s:%s" (Int.to_string k) v_string
    ) in
    sprintf "\\{%s\\}" (String.concat ~sep:", " strings)

  let string_of_update update =
    match update with
    | Add (node, x) -> sprintf "%s: +%d" (GCounter.string_of_node node) x
    | Remove (node, x) -> sprintf "%s: -%d" (GCounter.string_of_node node) x

  let string_of_query =
    GSet.string_of_t
end
