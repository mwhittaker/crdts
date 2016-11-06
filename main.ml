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

let main () : unit =
  state_based_gcounter ();
  state_based_pncounter ();
  ()

let () = main ()
