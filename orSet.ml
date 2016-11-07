open Core.Std

module StateBased = struct
  (* For the [@@deriving compare] on update. *)
  let compare_id_stream _ _ = 0

  type t = {a: GSet.StateBased.t Int.Map.t; r: GSet.StateBased.t Int.Map.t}
  type query = Int.Set.t
  type id_stream = unit -> int
  type update =
    | Add of id_stream * int
    | Remove of int
  [@@deriving compare]

  module GSet = GSet.StateBased

  let nats =
    let x = ref (-1) in
    fun () -> (incr x; !x)

  let query {a; r} =
    let diff = Int.Map.merge a r ~f:(fun ~key v ->
      match v with
      | `Left avs -> Some avs
      | `Right rvs -> Some rvs
      | `Both (avs, rvs) -> Some (Int.Set.diff avs rvs)
    ) in
    Int.Map.filteri diff ~f:(fun ~key:_ ~data -> not (Int.Set.is_empty data))
    |> Int.Map.keys
    |> Int.Set.of_list

  let update {a; r} (update: update) =
    match update with
    | Add (id_stream, x) ->
      let x_ids = Option.value (Int.Map.find a x) ~default:Int.Set.empty in
      let x_ids = GSet.update x_ids (GSet.Add (id_stream ())) in
      {a=Int.Map.add a ~key:x ~data:x_ids; r}
    | Remove x ->
      let a_x_ids = Option.value (Int.Map.find a x) ~default:Int.Set.empty in
      let r_x_ids = Option.value (Int.Map.find r x) ~default:Int.Set.empty in
      let r_x_ids = GSet.merge a_x_ids r_x_ids in
      {a; r=Int.Map.add r ~key:x ~data:r_x_ids}

  let merge {a; r} {a=a'; r=r'} =
    let merge_map (xs: GSet.t Int.Map.t) (ys: GSet.t Int.Map.t) =
      Int.Map.merge xs ys ~f:(fun ~key:_ v ->
        match v with
        | `Left x -> Some x
        | `Right y -> Some y
        | `Both (x, y) -> Some (GSet.merge x y)
      )
    in
    {a=merge_map a a'; r=merge_map r r'}

  let string_of_t {a; r} =
    let string_of_map (xs: GSet.t Int.Map.t) : string =
      let bindings = Int.Map.to_alist xs in
      let strings = List.map bindings ~f:(fun (key, data) ->
        sprintf "%d:%s" key (GSet.string_of_t data)
      ) in
      sprintf "\\{%s\\}" (String.concat ~sep:", " strings)
    in
    sprintf "a: %s\nr: %s" (string_of_map a) (string_of_map r)

  let string_of_update update =
    match update with
    | Add (_, x) -> Printf.sprintf "+%d" x
    | Remove x -> Printf.sprintf "-%d" x

  let string_of_query =
    GSet.string_of_t
end
