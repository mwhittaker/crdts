open Core.Std

(* First, a few preliminaries.
 * - Integers ordered by the usual less than or equals relation form a join
 *   semilattice where join is max (i.e. x join y = max(x, y)).
 * - A map from a set A to a join semilattice B is itself a join semilattice
 *   where f join g is defined as follows:
 *
 *                     { f(x),           x in domain(f), x not in domain(g)
 *     (f join g)(x) = { g(x),           x not in domain(f), x in domain(g)
 *                     { f(x) join g(x), x in domain(f), x in domain (g)
 *
 *   for all x that is the domain of f or g. If x is not in the domain of
 *   either f or g, then it is not in the domain of f join g. Thus, f <= g if
 *   the domain of f is a subset of the domain of g, and for all x in the
 *   domain of f, f(x) <= g(x).
 * - Given two join semilattices A and B, the cross product A x B is a join
 *   semilattice where (x, y) <= (x', y') if and only if x <= x' and y <= y'.
 *   Moreover, (x, y) join (x', y') = (x join x', y join y').
 *
 * A state-based LWW-Set, or last-writer wins set, is a set CRDT composed of
 * a pair of timestamped sets A and R. Each timestamped set is a map from some
 * element to an integer timestamp. Using the preliminaries above, it's
 * immediate that a pair of maps from an arbitrary type to integers is a join
 * semilattice.
 *
 * Query returns every element x in A where either (a) x is not in the domain
 * of R, or (b) A(x) > B(x). Note that if there is some element x where A(x) =
 * R(x), we consider the element removed. We could have easily favored
 * additions as well. Alternatively, we can ensure that each node uses a
 * disjoint subset of timestamps ensuring that there will never be ties.
 *
 * When we add an element x to an LWW-Set, we bind the value in A with a
 * timestamp greater than its timestamp in either A or R.
 *
 * Merge performs the join described in the preliminaries. *)
module StateBased : sig
  (* For simplicity, we only consider sets of integers. *)
  type t = {a: int Int.Map.t; r: int Int.Map.t}
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
