open Core.Std

(* A state-based OR-Set, or observed-remove set, is a set CRDT in which
 * elements can be added and removed. Like an LWW-Set, elements can be added
 * again after they've been removed. A state-based OR-Set is implemented as a
 * pair of maps A and R from elements to G-Sets of uniquely generated
 * identifiers.
 *
 * When an element x is added, a globally unique identifier is generated for
 * it. This identifier is then added to A(x). When an element x is removed,
 * A(x) is unioned into R(x).  Query returns every element x such that A(x) -
 * R(x) is non-empty. Thus, sequentially adding an element after a remove will
 * add it, and removing an element after it is added will remove it.
 *
 * Merge simply computes a pairwise merge of A and R. Note that when an element
 * is concurrently added and removed, the add will win because the remove will
 * not have access to the unique identifier generated by the add. *)
module StateBased : sig
  (* For simplicity, we only consider sets of integers. *)
  type t = {a: GSet.StateBased.t Int.Map.t; r: GSet.StateBased.t Int.Map.t}

  type query = Int.Set.t

  (* An id_stream must be a stateful function that returns unique integer every
   * invocation. *)
  type id_stream = unit -> int

  type update =
    | Add of id_stream * int
    | Remove of int
  [@@deriving compare]

  val nats : id_stream

  include Crdt.StateBased with
    type t := t and
    type query := query and
    type update := update
end
