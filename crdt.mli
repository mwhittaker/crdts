open Core.Std

(* The Crdt module defines interfaces for state based and operation based
 * CRDTs. It also provides functors to transform a CRDT module into a new
 * module which can generate visualiziations of the CRDT. *)

(* A state-based CRDTs, or CvRDTs [1, 2], is a tuple (S, s^0, q, u, m) where
 *
 *   - S is a join semillatice,
 *   - s^0 in S is the initial state,
 *   - q: S -> query is a query method,
 *   - u: S -> update -> S is a monotonic* update method, and
 *   - m: S -> S -> S is the join operator defined for S.
 *
 * * Here, monotonic means that for all states `x` and all updates `u`, `x <=
 * update x u`.
 *
 * [1]: https://scholar.google.com/scholar?cluster=4496511741683930603
 * [2]: https://scholar.google.com/scholar?cluster=13367952773539942258 *)
module type StateBased = sig
  (* The type of join semillatice implementing the CRDT. This is denoted S
   * above. *)
  type t

  (* The type returned by querying the CRDT. *)
  type query

  (* The type of arguments used to update the CRDT. Note that there is a single
   * update type. If you'd like have a CRDT have multiple update functions, use
   * a algebraic datatype. For example, if we wanted to support a CRDT which
   * can be incremented and decremented:
   *
   *   type update =
   *     | Increment of int
   *     | Decrement of int
   *   [@@deriving compare] *)
  type update [@@deriving compare]

  (* Query, update, and merge the CRDT. These are denoted q, u, and m above. *)
  val query  : t -> query
  val update : t -> update -> t
  val merge  : t -> t -> t

  (* CRDT pretty printers. *)
  val string_of_t      : t      -> string
  val string_of_query  : query  -> string
  val string_of_update : update -> string
end

(* TODO(mwhittaker): Implement *)
module type OpBased = sig end

(* Say we've implemented a state based CRDT---take G-Counters as an
 * example---and we've written some code using it:
 *
 *   module GCounter = struct ... end
 *   let open GCounter in
 *   let a = (0, 0, 0) in
 *   let b = increment a One 1 in
 *   let c = increment a Two 3 in
 *   let d = merge b c in
 *
 * The StateBasedGraphed functor allows us to transform GCounter into a new
 * module which mimics the GCounter module, except that each GCounter object is
 * now tagged internally with a lineage graph showing how the value was
 * derived. Moreover, it provides a function `to_dot` to convert a
 * lineage-tracked GCounter into a DOT file. For example, this code:
 *
 *   module GCounter = struct ... end
 *   module GCounterGraphed = StateBasedGraphed(GCounter)
 *   let open GCounterGraphed in
 *   let a = wrap (0, 0, 0) in
 *   let b = increment a GCounter.One 1 in
 *   let c = increment a GCounter.Two 3 in
 *   let d = merge b c in
 *   print_endline (to_dot d)
 *
 * will print out a DOT file which corresponds to the following graph:
 *
 *                      +---------+
 *             one: 1   |(1, 0, 0)|
 *                 +--->|---------|----+
 *                 |    |    1    |    |
 *                 |    +---------+    |
 *   +---------+   |                   |   +---------+
 *   |(0, 0, 0)|---+                   |   |(1, 3, 0)|
 *   +---------+                       +-->|---------+
 *   |    0    |---+                   |   |    4    |
 *   +---------+   |                   |   +---------+
 *                 |    +---------+    |
 *                 |    |(0, 3, 0)|    |
 *                 +--->|---------|----+
 *             two: 3   |    3    |
 *                      +---------+
 *
 * For each GCounter, the graph shows its internal representation (i.e. a
 * 3-tuple of integers) as well as the result of querying it (i.e. an int).
 * Moreover, labeled edges show how one GCounter is derived from another via
 * an update. Unlabaled edges show how GCounters are merged. *)
module StateBasedGraphed(C: StateBased) : sig
  type t

  include StateBased with
    type t := t and
    type query = C.query and
    type update = C.update

  val wrap : C.t -> t
  val unwrap : t -> C.t
  val to_dot : t -> string
end
