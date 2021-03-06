open Core_kernel.Std

let init_table = Node.Weak_table.create ()

let create shape ~type_ ~init =
  let node =
    Ops_generated.variable ()
      ~type_
      ~shape:(List.map shape ~f:(fun size -> { Node.Dim.size; name = None }))
  in
  let assign = Node.P (Ops.assign node init) in
  Node.Weak_table.set init_table ~key:(Node.P node) ~data:assign;
  node

let load ~type_ shape ~file ~tensor_name =
  let init =
    Ops.restore ~type_ (Ops.const_string [ file ]) (Ops.const_string [ tensor_name ])
  in
  create shape ~type_ ~init
let load_f = load ~type_:Float
let load_d = load ~type_:Double

let float shape ~init = create shape ~type_:Float ~init

let f shape x = float shape ~init:(Ops.f ~shape x)

let normalf_gen node shape ~stddev =
  let init =
    node (Ops.const_int ~type_:Int32 shape) ~type_:Node.Type.Float
    |> Ops.mul (Ops.f stddev)
  in
  float shape ~init

let normalf = normalf_gen (fun shape -> Ops.randomStandardNormal shape)

let truncated_normalf = normalf_gen (fun shape -> Ops.truncatedNormal shape)

let double shape ~init = create shape ~type_:Double ~init

let d shape x = double shape ~init:(Ops.d ~shape x)

let normald_gen node shape ~stddev =
  let init =
    node (Ops.const_int ~type_:Int32 shape) ~type_:Node.Type.Double
    |> Ops.mul (Ops.d stddev)
  in
  double shape ~init

let normald = normald_gen (fun shape -> Ops.randomStandardNormal shape)

let truncated_normald = normald_gen (fun shape -> Ops.truncatedNormal shape)

let get_init p =
  Node.Weak_table.find init_table p
