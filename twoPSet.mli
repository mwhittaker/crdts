open Core.Std

(* A state-based 2P-Set, or two-phase set, is a set that can be added to or
 * removed from. If a set is concurrently added to and removed from, the remove
 * wins. Moreover, once an element is removed, it can never be re-inserted. A
 * 2P-Set is implemented as a pair (A, R) of two G-Sets. Query returns A - R;
 * add adds to A; remove adds to R; merge performs a pairwise merge. *)
module StateBased : sig
  (* For simplicity, we only consider sets of integers. *)
  type t = {a: GSet.StateBased.t; r: GSet.StateBased.t}
  type query = Int.Set.t
  type update =
    | Add of int
    | Remove of int
  [@@deriving compare]

  include Crdt.StateBased with
    type t := t and
    type query := query and
    type update := update
end
