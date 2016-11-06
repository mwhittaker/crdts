open Core.Std

(* A PN-Set is a set CRDT in which elements can be added and removed. It is
 * implemented as a map from elements to PN-Counters. Query returns all
 * elements with a postive count; add increments the elemement's count; remove
 * decrements the elements count; and merge performs a element-wise merge of
 * PN-Counters. *)
module StateBased : sig
  (* For simplicity, we only consider sets of integers over three nodes. *)
  type t = PnCounter.StateBased.t Int.Map.t
  type query = Int.Set.t
  type update =
    | Add of GCounter.StateBased.node * int
    | Remove of GCounter.StateBased.node * int
  [@@deriving compare]

  include Crdt.StateBased with
    type t := t and
    type query := query and
    type update := update
end
