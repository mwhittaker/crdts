open Core.Std

module StateBased = struct
  type t = {a: GSet.StateBased.t; r: GSet.StateBased.t}
  type query = Int.Set.t
  type update =
    | Add of int
    | Remove of int
  [@@deriving compare]

  module GSet = GSet.StateBased

  let query {a; r} =
    Int.Set.diff (GSet.query a) (GSet.query r)

  let update {a; r} update =
    match update with
    | Add x -> {a=GSet.update a (GSet.Add x); r}
    | Remove x -> {a; r=GSet.update r (GSet.Add x)}

  let merge {a; r} {a=a'; r=r'} =
    {a=GSet.merge a a'; r=GSet.merge r r'}

  let string_of_t {a; r} =
    Printf.sprintf "a: %s\nr: %s" (GSet.string_of_t a) (GSet.string_of_t r)

  let string_of_update update =
    match update with
    | Add x -> Printf.sprintf "+%d" x
    | Remove x -> Printf.sprintf "-%d" x

  let string_of_query xs =
    GSet.string_of_query xs
end
