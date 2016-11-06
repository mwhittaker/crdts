open Core.Std

(* A state-based G-Counter, or grow-only counter, over n nodes 1,...,n is
 * implemented as an n-tuple. Query returns the sum of the tuple; an increment
 * at node i increments the ith entry of the tuple, and merge computes a
 * pairwise max. *)
module StateBased : sig
  (* For simplicity, we assume three nodes. *)
  type t = int * int * int
  type query = int
  type node = | One | Two | Three [@@deriving compare]
  type update = Increment of node * int [@@deriving compare]

  val string_of_node : node -> string

  include Crdt.StateBased with
    type t := t and
    type query := query and
    type update := update
end
