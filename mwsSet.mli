open Core.Std

(* A MWS-Set---or Molli, Weiss, and Skaf Set---is identical to a PN-Set except
 * that when an element with a negative count is added to the set, its count is
 * set to 1. *)
module StateBased : sig
  (* For simplicity, we only consider sets of integers over three nodes. *)
  type t = PnSet.StateBased.t
  type query = PnSet.StateBased.query
  type update = PnSet.StateBased.update [@@deriving compare]

  include Crdt.StateBased with
    type t := t and
    type query := query and
    type update := update
end
