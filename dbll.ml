(* 
 * Add debugging info to step through LLVM IR 
 * 
 * Plugs into pipeline:
 * Lexer -> Parser -> Typechecker -> Frontend -> IRdb 
 * 
 * Driver.parse_oat_file "tests/basic.oat" |> Frontend.cmp_prog |> Dbll.db_prog
 *   |> Dbutil.string_of_stream |> print_endling
*)

(* TODO:
 * - preamble
 * 
 * Scope:
 * - DICompileUnit: compilation unit scope
 * - DIFile: file scope
 * - DISubprogram: functions
 * - DILexicalScope: block scoping
 * 
 * Types:
 * - DISubroutineType: function type
 * - DIBasicType
 * - DIDerivedType
 * 
 * Variables:
 * - DILocalVariable
 * - DIGlobalVariable
 * 
 * Location:
 * - DILocation
 * 
 * Calls:
 * - llvm.dbg.addr
 * - llvm.dbg.value
 * - llvm.dbg.declare
 *  *)

type id = string
type scope = id
type loc = (int * int) * scope

(* Debug info statments *)
type dbi =
  | CU of id                                      (* DICompileUnit *)
  | File of string * string                       (* DIFile *)
  | Fun of int * scope * string * id              (* DISubprogram *)
  | TFun of id                                    (* DISubroutineType *)
  | TSet of id list                               (* !{!1, !2, !3} *)
  | Var of loc * string * id                      (* DILocalVariable *)
  | GVar                                          (* DIGlobalVariable *)
  | Loc of loc                                    (* DILocation *)
  | Blck                                          (* DILexicalScope *)
  | DCall of Ll.ty * Ll.operand * id              (* @llvm.dbg.* *)
  | TBasic of string * int * string               (* DIBasicType *)
  | TDeriv of id                                  (* DIDerivedType *)


type elt =
  | I of (Ll.uid * Ll.insn)                      (* untouched *)
  | T of id * (Ll.uid * Ll.terminator)           (* !dbg appended *)
  | D of id * (Ll.uid * Ll.insn)                 (* !dbg appended *)
  | G of id * dbi                                (* hoisted global debug stmt *)
  | C of id * dbi                                (* llvm.dbg call *)

type stream = elt list
let ( >@ ) x y = y @ x
let ( >:: ) x y = y :: x

let rec elevate (code:stream) : stream =
  let gs, rest = List.fold_left
    (fun (gs, rest) e ->
      match e with
      | G _ as x -> x :: gs, rest
      | _ as x -> gs, x :: rest
    ) ([], []) code
  in rest @ gs


module DTypeCtxt = struct
  type t = (Ll.ty * id) list
  let empty = []

  let add (c:t) (ty:Ll.ty) id : t = (ty, id) :: c
  let lookup (ty:Ll.ty) (c:t) : string = List.assoc ty c
  let defined (ty:Ll.ty) (c:t) : bool = List.mem_assoc ty c
end

(* Identifiers for debug variables start with '!' *)
let dbsym : unit -> id =
  let c = ref 0 in
  fun () -> incr c; Printf.sprintf "!%d" (!c)

module L = struct
  let lnum = ref 0
  let loc = !lnum, 1
  let line = !lnum
  let step = fun () -> incr lnum; !lnum, 1
  let gen s = let uid = dbsym() in uid, G (uid, Loc (step(), s))
end

(* generate type definitions *)
let rec db_ty (tc:DTypeCtxt.t) (t:Ll.ty): id * DTypeCtxt.t * stream =
  if DTypeCtxt.defined t tc then DTypeCtxt.lookup t tc, tc, []
  else
    let open Ll in
    let uid = dbsym() in
    let tc = DTypeCtxt.add tc t uid in
    match t with
    | I1 -> uid, tc, [ G (uid, TBasic ("bool", 1, "DW_ATE_boolean")) ]
    | I8 -> uid, tc, [ G (uid, TBasic ("char", 8, "DW_ATE_signed_char")) ]
    | I64 -> uid, tc, [ G (uid, TBasic ("int", 64, "DW_ATE_signed")) ]
    | Ptr t' ->
        let next_id, tc, s = db_ty tc t' in
        uid, tc, G (uid, TDeriv next_id) :: s
    | _ ->
        let next_id, tc, s = db_ty tc Ll.I64 in   (* FIXME: complicated types *)
        uid, tc, G (uid, TDeriv next_id) :: s


let db_block tc s (blk:Ll.block) : DTypeCtxt.t * stream =

  let db_insn tc s ((uid,ins):Ll.uid*Ll.insn) : DTypeCtxt.t * stream =
    match ins with
    | Ll.Alloca _ | Ll.Store _ -> tc, []        (* TODO: call llvm.addr here? *)
    | _ ->
        let l_id, l_code = L.gen s in
        tc, [D (l_id, (uid,ins)); l_code] in

  let db_term tc s (uid,term) =
    let l_id, l_code = L.gen s in
    tc, [T (l_id, (uid,term)); l_code] in

  let tc, insn_code = List.fold_left (fun (tc,code) ins ->
      let tc, code' = db_insn tc s ins in
      tc, code >@ code'
    ) (tc,[]) blk.insns in
  let tc, term_code = db_term tc s blk.term in
  tc, insn_code >@ term_code


let db_fdecl (tc:DTypeCtxt.t) (s:scope) (nm:string) ({f_ty;f_param;f_cfg}:Ll.fdecl) =
  let floc = L.step() in                          (* update line/scope *)
  let f_scope = dbsym() in                        (* fid is also new scope *)
  let ts, t = f_ty in

  (* Generates DILocalVariables for params 
   * FIXME: just do this when see alloca's? *)
  let tc, tids, arg_code = List.fold_left2 (fun (tc,tids,st) arg aty ->
      let tid, tc, st' = db_ty tc aty in
      let vid, (l_id, l_code) = dbsym(), L.gen f_scope in
      (* param same loc as function *)
      tc, tid :: tids,
      st >@ st' >@
      [ l_code ;
        G (vid, Var ((floc,f_scope), arg, tid));
        C (l_id, (DCall (aty, Ll.Id arg, vid))) ]
    ) (tc,[],[]) f_param ts in

  (* DISubprogram *)
  let tid, tc, rst = db_ty tc t in
  let f_tys, f_tys_id, set_id = tid :: List.rev tids, dbsym(), dbsym() in
  let f_code = rst
               >@ [ G (f_scope, Fun (L.line, s, nm, f_tys_id));
                    G (f_tys_id, TFun set_id);
                    G (set_id, TSet f_tys) ]
               >@ arg_code in

  (* Blocks *)
  let blk, named_blks = f_cfg in
  let tc, body_code = List.fold_left (fun (tc,code) blk ->
      let tc, code' = db_block tc f_scope blk in
      tc, code >@ code'
    ) (tc,[]) (blk :: (List.map snd named_blks)) in

  tc, f_code >@ body_code


let db_prog ({tdecls;gdecls;fdecls}:Ll.prog) : stream =
  let cu, file = dbsym(), dbsym() in
  let tc = DTypeCtxt.empty in
  let tc', s = List.fold_left (fun (tc,s) (n,f) ->
      let tc, s' = db_fdecl tc cu n f in
      tc, s >@ s'
    ) (tc,[]) fdecls in
  elevate s
