open Core.Std

module StateBased = struct
  type t = PnSet.StateBased.t
  type query = PnSet.StateBased.query
  type update = PnSet.StateBased.update [@@deriving compare]

  module PnCounter = PnCounter.StateBased
  module PnSet = PnSet.StateBased

  let query = PnSet.query
  let merge = PnSet.merge
  let string_of_t = PnSet.string_of_t
  let string_of_update = PnSet.string_of_update
  let string_of_query = PnSet.string_of_query

  let update xs update =
    let x =
      match update with
      | PnSet.Add (_, x)
      | PnSet.Remove (_, x) -> x
    in
    let zero = PnCounter.{p=(0, 0, 0); n=(0, 0, 0)} in
    let x_count = Option.value (Int.Map.find xs x) ~default:zero in
    let pn_update =
      match update with
      | PnSet.Add (node, _) ->
          let x_count = PnCounter.query x_count in
          if x_count < 0
            then PnCounter.Increment (node, Int.abs x_count + 1)
            else PnCounter.Increment (node, 1)
      | PnSet.Remove (node, _) -> PnCounter.Decrement (node, 1)
    in
    Int.Map.add xs ~key:x ~data:(PnCounter.update x_count pn_update)
end
