open Core.Std

module StateBased = struct
  (* For simplicity, we only consider sets of integers. *)
  type t = {a: int Int.Map.t; r: int Int.Map.t}
  type query = Int.Set.t
  type update =
    | Add of int
    | Remove of int
  [@@deriving compare]

  let query {a; r} =
    Int.Map.filteri a ~f:(fun ~key ~data ->
      match Int.Map.find r key with
      | None -> true
      | Some data' -> data > data'
    )
    |> Int.Map.keys
    |> Int.Set.of_list

  let update {a; r} update =
    let x =
      match update with
      | Add x
      | Remove x -> x
    in
    let a_timestamp = Option.value (Int.Map.find a x) ~default:0 in
    let r_timestamp = Option.value (Int.Map.find r x) ~default:0 in
    let x_timestamp = (Int.max a_timestamp r_timestamp) + 1 in
    match update with
    | Add _ -> {a=Int.Map.add a ~key:x ~data:x_timestamp; r}
    | Remove _ ->  {a; r=Int.Map.add r ~key:x ~data:x_timestamp}

  let merge {a; r} {a=a'; r=r'} =
    let merge_int_map (xs: int Int.Map.t) (ys: int Int.Map.t) : int Int.Map.t =
      Int.Map.merge xs ys ~f:(fun ~key:_ v ->
        match v with
        | `Left x -> Some x
        | `Right y -> Some y
        | `Both (x, y) -> Some (Int.max x y)
      )
    in
    {a=merge_int_map a a'; r=merge_int_map r r'}

  let string_of_t {a; r} =
    let string_of_int_map (xs: int Int.Map.t) : string =
      let bindings = Int.Map.to_alist xs in
      let strings = List.map bindings ~f:(fun (k, v) ->
        Printf.sprintf "%s:%s" (Int.to_string k) (Int.to_string v)
      ) in
      Printf.sprintf "\\{%s\\}" (String.concat ~sep:", " strings)
    in
    Printf.sprintf "a: %s\nr: %s" (string_of_int_map a) (string_of_int_map r)

  let string_of_update update =
    match update with
    | Add x -> Printf.sprintf "+%d" x
    | Remove x -> Printf.sprintf "-%d" x

  let string_of_query =
    GSet.StateBased.string_of_query
end
