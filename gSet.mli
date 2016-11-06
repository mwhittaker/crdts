open Core.Std

(* A state-based G-Set, or grow-only set, is implemented as a plain old set;
 * sets ordered by subset already form a join semilattice! Query is the
 * identity function; add adds; and merge is set union. *)
module StateBased : sig
  (* For simplicity, we only consider sets of integers. *)
  type t = Int.Set.t
  type query = Int.Set.t
  type update = Add of int [@@deriving compare]

  include Crdt.StateBased with
    type t := t and
    type query := query and
    type update := update
end
