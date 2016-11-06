open Core.Std

let write_to_file ~(filename: string) ~(data:string) : unit =
  Out_channel.write_all ("graphs/" ^ filename) ~data

let state_based_gcounter () : unit =
  let module GCounter = GCounter.StateBased in
  let module GCounterGraphed = struct
    include Crdt.StateBasedGraphed(GCounter)

    let increment (x: t) (node: GCounter.node) (k: int) : t =
      update x (GCounter.Increment (node, k))
  end in
  let open GCounterGraphed in

  let a = wrap (0, 0, 0) in
  let b = increment a GCounter.One 1 in
  let c = increment a GCounter.Two 3 in
  let d = merge b c in
  write_to_file ~filename:"GCounter1.dot" ~data:(to_dot d);

  let b = increment a GCounter.One 1 in
  let c = increment a GCounter.Two 2 in
  let d = increment a GCounter.Three 3 in
  let e = merge b c in
  let f = increment d GCounter.Three 3 in
  let g = merge e f in
  write_to_file ~filename:"GCounter2.dot" ~data:(to_dot g);
  ()

let state_based_pncounter () : unit =
  let module GCounter = GCounter.StateBased in
  let module PnCounter = PnCounter.StateBased in
  let module PnCounterGraphed = struct
    include Crdt.StateBasedGraphed(PnCounter)

    let increment (x: t) (node: GCounter.node) (k: int) : t =
      update x (PnCounter.Increment (node, k))

    let decrement (x: t) (node: GCounter.node) (k: int) : t =
      update x (PnCounter.Decrement (node, k))
  end in
  let open PnCounterGraphed in

  let a = wrap PnCounter.{p=(0, 0, 0); n=(0, 0, 0)} in
  let b = increment a GCounter.One 1 in
  let c = decrement a GCounter.Two 3 in
  let d = merge b c in
  write_to_file ~filename:"PnCounter1.dot" ~data:(to_dot d);

  let b = increment a GCounter.One 1 in
  let c = decrement a GCounter.Two 2 in
  let d = decrement a GCounter.Three 3 in
  let e = merge b c in
  let f = increment d GCounter.Three 3 in
  let g = merge e f in
  write_to_file ~filename:"PnCounter2.dot" ~data:(to_dot g);
  ()

let state_based_gset () : unit =
  let module GSet = GSet.StateBased in
  let module GSetGraphed = struct
    include Crdt.StateBasedGraphed(GSet)

    let add (xs: t) (x: int) : t =
      update xs (GSet.Add x)
  end in
  let open GSetGraphed in

  let a = wrap Int.Set.empty in
  let b = add a 1 in
  let c = add a 2 in
  let d = merge b c in
  write_to_file ~filename:"GSet1.dot" ~data:(to_dot d);

  let a = wrap Int.Set.empty in
  let b = add a 4 in
  let c = add a 1 in
  let d = add c 2 in
  let e = add d 3 in
  let f = add c 2 in
  let g = merge e f in
  let h = merge b g in
  write_to_file ~filename:"GSet2.dot" ~data:(to_dot h);
  ()

let state_based_twopset () : unit =
  let module TwoPSet = TwoPSet.StateBased in
  let module TwoPGraphed = struct
    include Crdt.StateBasedGraphed(TwoPSet)

    let add (xs: t) (x: int) : t =
      update xs (TwoPSet.Add x)

    let remove (xs: t) (x: int) : t =
      update xs (TwoPSet.Remove x)
  end in
  let open TwoPGraphed in

  let a = wrap TwoPSet.{a=Int.Set.empty; r=Int.Set.empty} in
  let b = add a 1 in
  let c = remove a 2 in
  let d = merge b c in
  write_to_file ~filename:"TwoPSet1.dot" ~data:(to_dot d);

  let a = wrap TwoPSet.{a=Int.Set.empty; r=Int.Set.empty} in
  let b = add a 1 in
  let b' = remove b 2 in
  let c = add a 2 in
  let c' = remove c 1 in
  write_to_file ~filename:"TwoPSet2.dot" ~data:(to_dot (merge b' c'));

  let a = wrap TwoPSet.{a=Int.Set.empty; r=Int.Set.empty} in
  let b = remove a 4 in
  let c = add a 1 in
  let d = add c 2 in
  let e = add d 4 in
  let f = remove c 2 in
  let g = merge e f in
  let h = merge b g in
  write_to_file ~filename:"TwoPSet3.dot" ~data:(to_dot h);

  ()

let state_based_lwwset () : unit =
  let module LwwSet = LwwSet.StateBased in
  let module LwwSetGraphed = struct
    include Crdt.StateBasedGraphed(LwwSet)

    let add (xs: t) (x: int) : t =
      update xs (LwwSet.Add x)

    let remove (xs: t) (x: int) : t =
      update xs (LwwSet.Remove x)
  end in
  let open LwwSetGraphed in

  let a = wrap LwwSet.{a=Int.Map.empty; r=Int.Map.empty} in
  let b = add a 1 in
  let c = remove a 2 in
  let d = merge b c in
  write_to_file ~filename:"LwwSet1.dot" ~data:(to_dot d);

  let a = wrap LwwSet.{a=Int.Map.empty; r=Int.Map.empty} in
  let b = add a 1 in
  let b' = remove b 2 in
  let c = add a 2 in
  let c' = remove c 1 in
  write_to_file ~filename:"LwwSet2.dot" ~data:(to_dot (merge b' c'));

  let a = wrap LwwSet.{a=Int.Map.empty; r=Int.Map.empty} in
  let b = remove a 4 in
  let c = add a 1 in
  let d = add c 2 in
  let e = add d 4 in
  let f = remove c 2 in
  let g = merge e f in
  let h = merge b g in
  write_to_file ~filename:"LwwSet3.dot" ~data:(to_dot h);

  let a = wrap LwwSet.{a=Int.Map.empty; r=Int.Map.empty} in
  let b1 = add a 1 in
  let b2 = remove b1 1 in
  let b3 = add b2 1 in
  write_to_file ~filename:"LwwSet4.dot" ~data:(to_dot b3);

  let a = wrap LwwSet.{a=Int.Map.empty; r=Int.Map.empty} in
  let b = add a 1 in
  let c = remove a 1 in
  let d = merge b c in
  let e1 = add d 1 in
  let e2 = add e1 1 in
  let f = remove d 1 in
  write_to_file ~filename:"LwwSet5.dot" ~data:(to_dot (merge e2 f));

  ()

let state_based_pnset () : unit =
  let module GCounter = GCounter.StateBased in
  let module PnSet = PnSet.StateBased in
  let module PnSetGraphed = struct
    include Crdt.StateBasedGraphed(PnSet)

    let add (xs: t) (node: GCounter.node) (x: int) : t =
      update xs (PnSet.Add (node, x))

    let remove (xs: t) (node: GCounter.node) (x: int) : t =
      update xs (PnSet.Remove (node, x))
  end in
  let open PnSetGraphed in

  let a = wrap Int.Map.empty in
  let b = add a GCounter.One 1 in
  let c = remove a GCounter.Two 1 in
  let d = add a GCounter.Three 1 in
  write_to_file ~filename:"PnSet1.dot" ~data:(to_dot (merge d (merge b c)));

  let a = wrap Int.Map.empty in
  let b1 = add a GCounter.One 1 in
  let b2 = add b1 GCounter.One 2 in
  let c1 = remove a GCounter.Two 1 in
  let c2 = remove c1 GCounter.Two 3 in
  let d1 = add a GCounter.Three 1 in
  let d2 = add d1 GCounter.Three 1 in
  write_to_file ~filename:"PnSet2.dot" ~data:(to_dot (merge d2 (merge b2 c2)));

  ()

let state_based_mwsset () : unit =
  let module GCounter = GCounter.StateBased in
  let module PnSet = PnSet.StateBased in
  let module MwsSet = MwsSet.StateBased in
  let module MwsSetGraphed = struct
    include Crdt.StateBasedGraphed(MwsSet)

    let add (xs: t) (node: GCounter.node) (x: int) : t =
      update xs (PnSet.Add (node, x))

    let remove (xs: t) (node: GCounter.node) (x: int) : t =
      update xs (PnSet.Remove (node, x))
  end in
  let open MwsSetGraphed in

  let a = wrap Int.Map.empty in
  let b = add a GCounter.One 1 in
  let c = remove a GCounter.Two 1 in
  let d = add a GCounter.Three 1 in
  write_to_file ~filename:"MwsSet1.dot" ~data:(to_dot (merge d (merge b c)));

  let a = wrap Int.Map.empty in
  let b1 = add a GCounter.One 1 in
  let b2 = add b1 GCounter.One 2 in
  let c1 = remove a GCounter.Two 1 in
  let c2 = remove c1 GCounter.Two 3 in
  let d1 = add a GCounter.Three 1 in
  let d2 = add d1 GCounter.Three 1 in
  write_to_file ~filename:"MwsSet2.dot" ~data:(to_dot (merge d2 (merge b2 c2)));

  let a = wrap Int.Map.empty in
  let a = remove a GCounter.One 1 in
  let a = remove a GCounter.One 1 in
  let a = remove a GCounter.One 1 in
  let a = add a GCounter.One 1 in
  let a = remove a GCounter.One 1 in
  let a = add a GCounter.One 1 in
  write_to_file ~filename:"MwsSet3.dot" ~data:(to_dot a);

  ()

let main () : unit =
  state_based_gcounter ();
  state_based_pncounter ();
  state_based_gset ();
  state_based_twopset ();
  state_based_lwwset ();
  state_based_pnset ();
  state_based_mwsset ();
  ()

let () = main ()
