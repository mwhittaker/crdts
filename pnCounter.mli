open Core.Std

(* A state-based PN-Counter, or increment-decrement counter, over n nodes
 * 1,...,n is implemented as a pair (p, n) of two G-Counters over n nodes.
 * Query returns p - n; an increment increments p; a decrement increments n;
 * and a merge performs a pairwise merge. *)
module StateBased : sig
  type t = {p: GCounter.StateBased.t; n: GCounter.StateBased.t}
  type query = int
  type update =
    | Increment of GCounter.StateBased.node * int
    | Decrement of GCounter.StateBased.node * int
  [@@deriving compare]

  include Crdt.StateBased with
    type t := t and
    type query := query and
    type update := update
end
