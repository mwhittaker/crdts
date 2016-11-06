open Core.Std

module StateBased = struct
  type t = {p: GCounter.StateBased.t; n: GCounter.StateBased.t}
  type query = int
  type update =
    | Increment of GCounter.StateBased.node * int
    | Decrement of GCounter.StateBased.node * int
  [@@deriving compare]

  module GCounter = GCounter.StateBased

  let query {p; n} =
    GCounter.(query p - query n)

  let to_gcounter_update (update: update) : GCounter.update =
    match update with
    | Increment (node, k)
    | Decrement (node, k) -> GCounter.Increment (node, k)

  let update {p; n} update =
    let g_update = to_gcounter_update update in
    match update with
    | Increment _ -> {p=GCounter.update p g_update; n}
    | Decrement _ -> {p; n=GCounter.update n g_update}

  let merge {p; n} {p=p'; n=n'} =
    GCounter.({p=merge p p'; n=merge n n'})

  let string_of_t {p; n} =
    let to_string = GCounter.string_of_t in
    Printf.sprintf "p: %s\nn: %s" (to_string p) (to_string n)

  let string_of_update (update: update) =
    let plus_or_minus =
      match update with
      | Increment _ -> "+"
      | Decrement _ -> "-"
    in
    let update_string = GCounter.string_of_update (to_gcounter_update update) in
    Printf.sprintf "%s%s" plus_or_minus update_string

  let string_of_query =
    Int.to_string
end
