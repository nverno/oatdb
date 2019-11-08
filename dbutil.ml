open Dbll

let mapcat s f l = String.concat s @@ List.map f l
let prefix p f a = p ^ f a
let ( ^. ) s t = if s = "" || t = "" then "" else s ^ t
let pp = Printf.sprintf
           
let soni = Llutil.string_of_named_insn

let string_of_loc ((l,c), s) =
  pp "line: %d, column: %d, scope: %s" l c s

let sol = string_of_loc

let string_of_dbi d =
  match d with 
  | CU f ->
      pp ("distinct !DICompileUnit(language: DW_LANG_C99, file: %s, " ^^
          "producer: \"oat\", " ^^
          "isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug") f

  | File (f,d) ->
      pp "!DIFile(filename: \"%s\", directory: \"%s\")" f d
  | Fun (l,s,name,t) ->
      pp "distinct !DISubprogram(name: \"%s\", type: %s, scope: %s, line: %d)"
        name t s l
  | TFun id ->
      pp "!DISubroutineType(types: %s)" id
  | TSet lst ->
      pp "!{%s}" (String.concat " " lst)
  | Var (l,v,t) ->
      pp "!DILocalVariable(name: \"%s\", type: %s, %s)" v t (sol l)
  | GVar -> ""
  | Loc l -> pp "!DILocation(%s)" (sol l)
  | Blck -> "!DILexicalBlock()"
  | TBasic (n,sz,enc) ->
      pp "!DIBasicType(name: \"%s\", size: %d, encoding: %s)" n sz enc
  | TDeriv bt ->
      pp "!DIDerivedType(tag: DW_TAG_pointer_type, baseType: %s, size: 64)" bt
  | DCall (t,o,vid) ->
      pp
        ("call void @llvm.dbg.declare(metadata %s %s, metadata %s, " ^^
         "metadata !DIExpression())")
        (Llutil.string_of_ty t) (Llutil.string_of_operand o) vid

let string_of_dbg id s = pp "%s, !dbg %s" s id
let sod = string_of_dbg
  
let string_of_elt : elt -> string = function
  | I ins -> soni ins
  | T (id, (uid,term)) -> sod id (Llutil.string_of_terminator term)
  | D (id, ins) -> sod id (soni ins)
  | G (id, di) -> pp "%s = %s" id (string_of_dbi di)
  | C (id, di) -> sod id (string_of_dbi di)

let string_of_stream code =
  (mapcat "\n" (prefix "  " string_of_elt) code ^. "\n")
