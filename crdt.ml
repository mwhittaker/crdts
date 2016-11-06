open Core.Std

module type StateBased = sig
  type t
  type query
  type update [@@deriving compare]

  val query  : t -> query
  val update : t -> update -> t
  val merge  : t -> t -> t

  val string_of_t      : t      -> string
  val string_of_query  : query  -> string
  val string_of_update : update -> string
end

module type OpBased = sig end

(* Lineage graphs are represented using the OCamlgraph library which also has
 * built in support for converting a graph into a DOT file! *)
module StateBasedGraphed(C: StateBased) = struct
  (* The vertexes of our lineage graph are labelled with CRDT instances. *)
  module Vertex = struct
    type t = C.t
  end

  (* The edges of our lineage graph are labelled with either (a) updates or (b)
   * nothing (for merges). *)
  module Edge = struct
    type t =
      | Nothing
      | Update of C.update
    [@@deriving compare]

    let default = Nothing
  end

  (* The lineage graph. *)
  module G = Graph.Persistent.Digraph.AbstractLabeled(Vertex)(Edge)

  (* Graph operations *)
  module Oper = Graph.Oper.P(G)

  (* Graph Graphviz options. *)
  module GDot = struct
    include G

    let graph_attributes _ =
      [`Rankdir `LeftToRight]

    let default_vertex_attributes _ =
      [`Shape `Record; `Fontname "Courier"]

    let vertex_name v =
      Int.to_string (V.hash v)

    let get_subgraph _ =
      None

    let default_edge_attributes _ =
      [`Fontname "Courier"]

    let vertex_attributes v =
      let x = V.label v in
      let x_string = C.string_of_t x in
      let q_string = C.string_of_query (C.query x) in
      let s = Printf.sprintf "%s|%s" x_string q_string in
      [`Label s ]

    let edge_attributes e =
      match E.label e with
      | Edge.Nothing -> []
      | Edge.Update u -> [`Label (C.string_of_update u)]
  end

  (* Module to output DOT files. *)
  module Dot = Graph.Graphviz.Dot(GDot)

  (* Each element in our lineage tracked CRDT is annotated with its lineage
   * graph and the vertex to which it corresponds. *)
  type t = G.t * G.V.t * C.t

  type query = C.query

  type update = C.update [@@deriving compare]

  let query (_, _, x) = C.query x

  let update (g, vx, x) update =
    let y = C.update x update in
    let vy = G.V.create y in
    let e = G.E.create vx (Edge.Update update) vy in
    let g = G.add_edge_e g e in
    (g, vy, y)

  let merge (gx, vx, x) (gy, vy, y) =
    let z = C.merge x y in
    let vz = G.V.create z in
    let g = Oper.union gx gy in
    let g = G.add_edge g vx vz in
    let g = G.add_edge g vy vz in
    (g, vz, z)

  let string_of_t (_, _, x) =
    C.string_of_t x

  let string_of_query =
    C.string_of_query

  let string_of_update =
    C.string_of_update

  let wrap x =
    let vx = G.V.create x in
    (G.add_vertex G.empty vx, vx, x)

  let unwrap (_, _, x) =
    x

  let to_dot (g, _, _) =
    let arbitarary_size = 4096 in
    let b = Buffer.create arbitarary_size in
    let formatter = Format.formatter_of_buffer b in
    Dot.fprint_graph formatter g;
    Format.pp_print_flush formatter ();
    Buffer.contents b
end
